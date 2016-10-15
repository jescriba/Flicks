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

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CircularSpinnerDelegate {
    
    @IBOutlet weak var networkErrorView: UIView!
    @IBOutlet weak var tableView: UITableView!
    let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
    var endPoint: String!
    var movies: [NSDictionary]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        
        CircularSpinner.setAnimationDelegate(self)
        CircularSpinner.show("Fetching movies...", animated: true, type: .indeterminate)
        loadMovies()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl)

        // Do any additional setup after loading the view.
    }
    
    func refreshControlAction(_ refreshControl: UIRefreshControl) {
        loadMovies(refreshControl)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies?.count ?? 0
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        cell.accessoryType = .none
        
        let movie = movies![indexPath.row]
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        
        cell.titleLabel.text = title
        cell.overviewLabel.text = overview
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
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPath(for: cell)
        let detailVC = segue.destination as! DetailViewController
        detailVC.movie = movies?[(indexPath?.row)!]
    }
    
    func loadMovies(_ refreshControl: UIRefreshControl? = nil) {
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
            // Arbitrary sleep here to see animation
            sleep(2)
            CircularSpinner.hide()
        }
        task.resume()
    }

}
