//
//  MovieCell.swift
//  Flicks
//
//  Created by Joshua Escribano on 10/10/16.
//  Copyright © 2016 Joshua Escribano. All rights reserved.
//

import UIKit

class MovieCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var posterView: UIImageView!
    
    var movie: NSDictionary? {
        willSet(newMovie) {
            titleLabel.text = newMovie?["title"] as? String
            overviewLabel.text = newMovie?["overview"] as? String
            titleLabel.adjustsFontSizeToFitWidth = true
            overviewLabel.adjustsFontSizeToFitWidth = true
            if let posterPath = newMovie?["poster_path"] as? String {
                let baseURL = "https://image.tmdb.org/t/p/w500"
                let imageURL = URL(string: baseURL + posterPath)
                posterView.alpha = 0
                posterView.setImageWith(imageURL!)
                UIView.animate(withDuration: 1, animations: {
                    self.posterView.alpha = 1
                })
            } else {
                // Ideally you'd have a stock photo
                posterView.alpha = 0
            }
            titleLabel.adjustsFontSizeToFitWidth = true
            overviewLabel.adjustsFontSizeToFitWidth = true
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        titleLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
        overviewLabel.font = UIFont(name: "HelveticaNeue", size: 15)
        titleLabel.textColor = UIColor(red:0.31, green:0.00, blue:0.32, alpha:1.0)
        overviewLabel.textColor = UIColor(red:0.31, green:0.00, blue:0.25, alpha:1.0)
    }

}
