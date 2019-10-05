//
//  FavoriteMovieCell.swift
//  MoviesApp
//
//  Created by Miller on 04/10/19.
//  Copyright © 2019 Miller. All rights reserved.
//

import UIKit

class FavoriteMovieCell: UICollectionViewCell {
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabelView: UILabel!
    @IBOutlet weak var favoriteIcon: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
