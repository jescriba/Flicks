//
//  MoviesViewController.swift
//  Flicks
//
//  Created by Joshua Escribano on 10/10/16.
//  Copyright © 2016 Joshua Escribano. All rights reserved.
//

import UIKit
import AFNetworking
import CircularSpinner

class MoviesViewController: UIViewController {

    @IBOutlet weak var listGridSegmentControl: UISegmentedControl!
    @IBOutlet weak var moviesNavigationItem: UINavigationItem!
    @IBOutlet weak var networkErrorView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var collectionView: UICollectionView!

    private let screenWidth: CGFloat = UIScreen.main.bounds.width
    private let screenHeight: CGFloat = UIScreen.main.bounds.height
    private let apiKey: String = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
    private var searchBar: UISearchBar!
    private var navMaxY: CGFloat = 0
    internal var isSearch: Bool = false
    internal var movies: [NSDictionary]?
    internal var filteredMovies: [NSDictionary]?
    internal var endPoint: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navMaxY = navigationController!.navigationBar.frame.maxY
        tableView.dataSource = self
        tableView.delegate = self
        let searchBarButton = UIBarButtonItem(image: UIImage(named: "search"), style: .plain, target: self, action: #selector(setUpSearch))
        moviesNavigationItem.rightBarButtonItem = searchBarButton
        listGridSegmentControl.addTarget(self, action: #selector(changeViewMode), for: .valueChanged)
        
        CircularSpinner.setAnimationDelegate(self)
        CircularSpinner.show("Fetching movies...", animated: true, type: .indeterminate)
        loadMovies()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: .valueChanged)
        tableView.backgroundColor = UIColor(red:1.00, green:0.98, blue:1.00, alpha:1.0)
        tableView.addSubview(refreshControl)
        
        setUpCollectionView()
        // Do any additional setup after loading the view.
    }
    
    private func setUpCollectionView() {
        // Initial sizing of collection view
        collectionView.frame = CGRect(origin: CGPoint(x: 0, y: navMaxY), size: tableView.frame.size)
        collectionView.frame.size.height = collectionView.frame.size.height - navMaxY
        (collectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize = CGSize(width: screenWidth / 3.5, height: screenHeight / 3.5)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    @objc private func setUpSearch() {
        if !isSearch {
            let searchBarRect = CGRect(x: 0, y: navMaxY, width: UIScreen.main.bounds.width, height: 50)
            searchBar = UISearchBar(frame: searchBarRect)
            searchBar.layer.opacity = 0.92
            searchBar.backgroundColor = UIColor(red:1.00, green:0.93, blue:1.00, alpha:1.0)
            let searchTextField = searchBar.value(forKey: "searchField") as? UITextField
            searchTextField?.textColor = UIColor(red:0.17, green:0.06, blue:0.68, alpha:1.0)
            searchBar.searchBarStyle = .minimal
            searchBar.delegate = self
            isSearch = true
            view.addSubview(searchBar)
            tableView.frame.origin = CGPoint(x: 0, y: searchBar.frame.height)
        } else {
            isSearch = false
            searchBar.removeFromSuperview()
            tableView.frame.origin = CGPoint(x: 0, y: 0)
        }
    }
    
    @objc private func refreshControlAction(_ refreshControl: UIRefreshControl) {
        loadMovies(refreshControl: refreshControl)
    }
    
    @objc private func changeViewMode() {
        if listGridSegmentControl.selectedSegmentIndex == 0 {
            // List Mode
            collectionView.isHidden = true
            tableView.reloadData()
            tableView.isHidden = false
        } else {
            // Grid Mode
            tableView.isHidden = true
            collectionView.reloadData()
            collectionView.isHidden = false
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let tableCell = sender as? UITableViewCell
        let collectionCell = sender as? UICollectionViewCell
        let index: Int!
        if let cc = collectionCell {
            index = collectionView.indexPath(for: cc)?.item
        } else {
            index = tableView.indexPath(for: tableCell!)?.row
        }
        let detailVC = segue.destination as! DetailViewController
        var moviesToUse = movies
        if isSearch {
            moviesToUse = filteredMovies ?? movies
        }
        detailVC.movie = moviesToUse?[index]
    }
    
    func loadMovies(refreshControl: UIRefreshControl? = nil) {
        let endPointUrl = URL(string: "https://api.themoviedb.org/3/movie/\(endPoint!)?api_key=\(apiKey)")
        let request = URLRequest(url: endPointUrl!)
        let session = URLSession.shared
        let task = session.dataTask(with: request) {
            (dataOrNil, response, errorOrNil) -> Void in
            if errorOrNil != nil {
                DispatchQueue.main.async {
                    self.networkErrorView.isHidden = false
                }
            }
            if let data = dataOrNil {
                if let response = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                    self.movies = response["results"] as? [NSDictionary]
                    DispatchQueue.main.async {
                        // If there was previously a network error and refresh worked
                        self.networkErrorView.isHidden = true
                        self.tableView.reloadData()
                    }
                }
            }
            if let refresh = refreshControl {
                refresh.endRefreshing()
            }
            // Arbitrary sleep here for demonstrative purposes
            sleep(UInt32(1.5))
            CircularSpinner.hide()
        }
        task.resume()
    }
}

// MARK: - UITableViewDataSource
extension MoviesViewController: UITableViewDataSource {
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearch {
            return filteredMovies?.count ?? 0
        }
        return movies?.count ?? 0
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        cell.accessoryType = .none
        cell.contentView.backgroundColor = UIColor(red:1.00, green:0.98, blue:1.00, alpha:1.0)
        let bgView = UIView()
        bgView.backgroundColor = UIColor(red:1.00, green:0.93, blue:1.00, alpha:1.0)
        cell.selectedBackgroundView = bgView
        var moviesToUse = movies
        if isSearch {
            moviesToUse = filteredMovies ?? movies
        }
        let movie = moviesToUse![indexPath.row]
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        
        cell.titleLabel.text = title
        cell.overviewLabel.text = overview
        cell.titleLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
        cell.overviewLabel.font = UIFont(name: "HelveticaNeue", size: 15)
        cell.titleLabel.textColor = UIColor(red:0.31, green:0.00, blue:0.32, alpha:1.0)
        cell.overviewLabel.textColor = UIColor(red:0.31, green:0.00, blue:0.25, alpha:1.0)
        cell.titleLabel.adjustsFontSizeToFitWidth = true
        cell.overviewLabel.adjustsFontSizeToFitWidth = true
        if let posterPath = movie["poster_path"] as? String {
            let baseURL = "https://image.tmdb.org/t/p/w500"
            let imageURL = URL(string: baseURL + posterPath)
            cell.posterView.alpha = 0
            cell.posterView.setImageWith(imageURL!)
            UIView.animate(withDuration: 1, animations: {
                cell.posterView.alpha = 1
            })
        } else {
            // Ideally you'd have a stock photo
            cell.posterView.alpha = 0
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension MoviesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - UICollectionViewDataSource
extension MoviesViewController: UICollectionViewDataSource {
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var moviesToUse = movies
        if isSearch {
            moviesToUse = filteredMovies ?? movies
        }
        return moviesToUse?.count ?? 0
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "movieCollectionCell", for: indexPath) as! MovieCollectionCell
        var moviesToUse = movies
        if isSearch {
            moviesToUse = filteredMovies ?? movies
        }
        let movie = moviesToUse![indexPath.item]
        if let posterPath = movie["poster_path"] as? String {
            let baseURL = "https://image.tmdb.org/t/p/w500"
            let imageURL = URL(string: baseURL + posterPath)
            let cellHeight = cell.frame.size.height
            let cellWidth = cell.frame.size.width
            cell.movieImageView.frame = CGRect.zero
            cell.movieImageView.frame.size = CGSize(width: cellWidth - 8, height: cellHeight - 6)
            cell.movieImageView.alpha = 0
            cell.movieImageView.setImageWith(imageURL!)
            UIView.animate(withDuration: 1, animations: {
                cell.movieImageView.alpha = 1
            })
        }
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension MoviesViewController: UICollectionViewDelegate {
    
}

// MARK: - UISearchBarDelegate
extension MoviesViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredMovies = movies?.filter { movie in
            let searchTerm = searchBar.text
            if searchTerm != nil && !searchTerm!.isEmpty {
                return (movie["title"] as! String).contains(searchTerm!)
            } else {
                return true
            }
        }
        tableView.reloadData()
        collectionView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        return true
    }
}

// MARK: - CircularSpinnerDelegate
extension MoviesViewController: CircularSpinnerDelegate {
    
}
