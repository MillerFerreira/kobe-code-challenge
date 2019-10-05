//
//  MovieViewController.swift
//  MoviesApp
//
//  Created by Miller on 04/10/19.
//  Copyright © 2019 Miller. All rights reserved.
//

import UIKit
import AlamofireImage

class MovieViewController: UIViewController {
    var fromLayout: LayoutMode = .Popular
    var isMovieFavorite: Bool = false
    var movieData: MovieData?
    var genres: String?
    
    @IBOutlet var rootView: UIView!
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabelView: UILabel!
    @IBOutlet weak var yearLabelView: UILabel!
    @IBOutlet weak var genresLabelView: UILabel!
    @IBOutlet weak var favoritesButton: UIButton!
    @IBOutlet weak var descriptionLabelView: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setGradientBackground()
        fillData()
    }
    
    @IBAction func favoriteButtonDidClick(_ sender: UIButton) {
        let movie = movieData!.movie
        
        if !isMovieFavorite {
            favoritesButton.isEnabled = false
            Database.shared.saveMovies(moviesList: [movie])
            self.isMovieFavorite = true
            
            UIView.animate(withDuration: 0.8, animations: {
                self.favoritesButton.alpha = 0.4
                }, completion: { _ in
                    self.favoritesButton.isEnabled = true
                    self.favoritesButton.alpha = 1.0
                    self.favoritesButton.setTitle("Remove from Favorites", for: .normal)
                })
        } else {
            favoritesButton.isEnabled = false
            Database.shared.removeFavoriteMovie(movieId: movie.id!)
            self.isMovieFavorite = false
            
            UIView.animate(withDuration: 0.8, animations: {
                self.favoritesButton.alpha = 0.4
            }, completion: { _ in
                self.favoritesButton.isEnabled = true
                self.favoritesButton.alpha = 1.0
                self.favoritesButton.setTitle("Add to Favorites", for: .normal)
            })
        }
        sendNotification()
    }
    
    func setGradientBackground() {
        let layer = CAGradientLayer()
        layer.frame = CGRect(x: .zero, y: .zero, width: rootView.frame.width, height: rootView.frame.height)
        
        if fromLayout == .Favorite {
            let favoriteColor1 = UIColor(red:109.0/255, green:0.0, blue:178.0/255, alpha:1.0).cgColor
            let favoriteColor2 = UIColor(red:63.0/255, green:0.0, blue:224.0/255, alpha:1.0).cgColor
            let favoriteColor3 = UIColor(red:91.0/255, green:32.0/255, blue: 125.0/255, alpha:1.0).cgColor
            layer.colors = [favoriteColor1, favoriteColor2, favoriteColor3]
        } else {
            let popularColor1 = UIColor(red:177.0/255, green:243.0/255, blue: 154.0/255, alpha:1.0).cgColor
            let popularColor2 = UIColor(red:78.0/255, green:164.0/255, blue:246.0/255, alpha:1.0).cgColor
            layer.colors = [popularColor1, popularColor2]
        }        
        rootView.layer.insertSublayer(layer, at: 0)
    }
    
    func fillData() {
        closeButton.layer.cornerRadius = closeButton.frame.width / 2

        guard let movie = movieData?.movie, let genresNames = movieData?.genresNames else {
            return
        }
        titleLabelView.text = movie.title
        yearLabelView.text = "Release date: " + movie.release_date!
        genresLabelView.text = "Genres: " + genresNames
        descriptionLabelView.text = movie.overview
        
        if isMovieFavorite {
            self.favoritesButton.setTitle("Remove from Favorites", for: .normal)
        }        
        let baseUrl = "https://image.tmdb.org/t/p/"
        let posterSize = "w500"
        let posterPath = movie.poster_path
        let url = baseUrl + posterSize + posterPath!
        posterImageView.af_setImage(withURL: URL(string: url)!, imageTransition: .crossDissolve(1.1))
    }
    
    @IBAction func closeButtonDidClick(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    func sendNotification() {
        let notificationName = Notification.Name("didReceiveData")
        let notificationData = NotificationData(from: fromLayout, indexPath: movieData!.indexPath)
        NotificationCenter.default.post(name: notificationName, object: notificationData)
    }
}
