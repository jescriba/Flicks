//
//  DetailViewController.swift
//  Flicks
//
//  Created by Joshua Escribano on 10/12/16.
//  Copyright © 2016 Joshua Escribano. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var posterView: UIImageView!
    var movie: NSDictionary!

    override func viewDidLoad() {
        super.viewDidLoad()

        let title = movie["title"]
        let overview = movie["overview"]
        titleLabel.text = title as? String
        overviewLabel.text = overview as? String
        overviewLabel.sizeToFit()
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: infoView.frame.maxY)
        
        if let posterPath = movie["poster_path"] as? String {
            let baseURL = "https://image.tmdb.org/t/p/w500"
            let imageURL = URL(string: baseURL + posterPath)
            posterView.alpha = 0.2
            posterView.setImageWith(imageURL!)
            UIView.animate(withDuration: 1, animations: {
                self.posterView.alpha = 1
            })
        }
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
