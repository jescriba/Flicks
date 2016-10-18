//
//  MovieCollectionCell.swift
//  Flicks
//
//  Created by Joshua Escribano on 10/15/16.
//  Copyright © 2016 Joshua Escribano. All rights reserved.
//

import UIKit

class MovieCollectionCell: UICollectionViewCell {
    @IBOutlet weak var movieImageView: UIImageView!
    
    var movie: NSDictionary? {
        willSet(newMovie) {
            if let posterPath = newMovie?["poster_path"] as? String {
                let baseURL = "https://image.tmdb.org/t/p/w500"
                let imageURL = URL(string: baseURL + posterPath)
                let cellHeight = frame.size.height
                let cellWidth = frame.size.width
                movieImageView.frame = CGRect.zero
                movieImageView.frame.size = CGSize(width: cellWidth - 8, height: cellHeight - 6)
                movieImageView.alpha = 0
                movieImageView.setImageWith(imageURL!)
                UIView.animate(withDuration: 1, animations: {
                    self.movieImageView.alpha = 1
                })
            }
        }
    }

}
