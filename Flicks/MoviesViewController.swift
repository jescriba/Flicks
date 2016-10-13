//
//  MoviesViewController.swift
//  Flicks
//
//  Created by Joshua Escribano on 10/10/16.
//  Copyright © 2016 Joshua Escribano. All rights reserved.
//

import UIKit
import AFNetworking
import ALLoadingView

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var networkErrorView: UIView!
    @IBOutlet weak var tableView: UITableView!
    let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
    var endPoint: String!
    var movies: [NSDictionary]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        
        ALLoadingView.manager.blurredBackground = true
        ALLoadingView.manager.messageText = "Fetching movies..."
        ALLoadingView.manager.showLoadingView(ofType: .messageWithIndicator, windowMode: .fullscreen)
        
        let nowPlayingUrl = URL(string: "https://api.themoviedb.org/3/movie/\(endPoint!)?api_key=\(apiKey)")
        let request = URLRequest(url: nowPlayingUrl!)
        let session = URLSession.shared
        let task = session.dataTask(with: request) {
            (dataOrNil, response, errorOrNil) -> Void in
            if let error = errorOrNil {
                self.networkErrorView.isHidden = false
                ALLoadingView.manager.hideLoadingView(withDelay: 1.5)
            }
            if let data = dataOrNil {
                if let response = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                    self.movies = response["results"] as? [NSDictionary]
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        ALLoadingView.manager.hideLoadingView(withDelay: 1.5)

                    }
                }
            }
        }
        task.resume()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl)

        // Do any additional setup after loading the view.
    }
    
    func refreshControlAction(_ refreshControl: UIRefreshControl) {
        let nowPlayingUrl = URL(string: "https://api.themoviedb.org/3/movie/\(endPoint!)?api_key=\(apiKey)")
        let request = URLRequest(url: nowPlayingUrl!)
        let session = URLSession.shared
        let task = session.dataTask(with: request) {
            (dataOrNil, response, errorOrNil) -> Void in
            // In the event a refresh is fixing a network error
            if let error = errorOrNil {
                self.networkErrorView.isHidden = false
            } else {
                self.networkErrorView.isHidden = true
            }
            if let data = dataOrNil {
                if let response = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                    self.movies = response["results"] as? [NSDictionary]
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        refreshControl.endRefreshing()
                    }
                }
            }
        }
        task.resume()
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
        if let posterPath = movie["poster_path"] as? String {
            let baseURL = "https://image.tmdb.org/t/p/w500"
            let imageURL = URL(string: baseURL + posterPath)
            cell.posterView.setImageWith(imageURL!)
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

}
