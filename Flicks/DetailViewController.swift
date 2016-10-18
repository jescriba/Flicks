//
//  DetailViewController.swift
//  Flicks
//
//  Created by Joshua Escribano on 10/12/16.
//  Copyright © 2016 Joshua Escribano. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var posterView: UIImageView!
    internal var movie: NSDictionary!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black
        
        let overview = movie["overview"]
        let rating = movie["vote_average"] as? Double
        let releaseDate = movie["release_date"] as? String
        overviewLabel.text = overview as? String
        overviewLabel.sizeToFit()
        // In events of overflowing text still
        overviewLabel.adjustsFontSizeToFitWidth = true
        if let rating = rating {
            ratingLabel.text = NSString(format: "❤︎ %.1f%%", rating / 10.0 * 100) as String
            ratingLabel.sizeToFit()
        } else {
            ratingLabel.text = ""
        }
        if let releaseDate = releaseDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let date = dateFormatter.date(from: releaseDate)
            dateFormatter.dateStyle = .medium
            let formattedDate = dateFormatter.string(from: date!)
            releaseDateLabel.text = formattedDate
        } else {
            releaseDateLabel.text = ""
        }
        
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: infoView.frame.maxY)
        if let posterPath = movie["poster_path"] as? String {
            let baseURL = "https://image.tmdb.org/t/p/w500"
            let imageURL = URL(string: baseURL + posterPath)
            posterView.alpha = 0.2
            posterView.setImageWith(imageURL!)
            UIView.animate(withDuration: 1, animations: {
                self.posterView.alpha = 1
            })
        } else {
            // Ideally a stock photo replacement
            posterView.alpha = 0
        }
        
        // Do any additional setup after loading the view.
    }
}
