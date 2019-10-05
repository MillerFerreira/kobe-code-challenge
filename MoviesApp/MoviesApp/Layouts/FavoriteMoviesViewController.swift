//
//  FavoriteMoviesViewController.swift
//  MoviesApp
//
//  Created by Miller on 04/10/19.
//  Copyright © 2019 Miller. All rights reserved.
//

import UIKit

class FavoriteMoviesViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    var movies: Array<MovieModel>?
    var genresMap: [Int: String]?
    var lastAnimatedItem: Int?
    
    @IBOutlet var rootUIView: UIView!
    @IBOutlet weak var contentContainerView: UIView!
    @IBOutlet weak var favoriteMoviesCollectionView: UICollectionView!
    @IBOutlet weak var textContainerView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupGradient()
        getMoviesFromDb()
        lastAnimatedItem = -1
        textContainerView.layer.cornerRadius = CGFloat(12)
        setupNotifications()
        setupCollectionView()
    }
    
    func setupGradient() {
        let layer = CAGradientLayer()
        layer.frame = CGRect(x: .zero, y: .zero, width: rootUIView.frame.width, height: rootUIView.frame.height)
        
        let color3 = UIColor(red:100.0/255, green:100.0/255, blue: 100.0/255, alpha:0.1).cgColor
        let color4 = UIColor(red:50.0/255, green:50.0/255, blue:50.0/255, alpha:0.1).cgColor
        let color5 = UIColor(red:0.0/255, green:0.0/255, blue:0.0/255, alpha:0.1).cgColor
        
        layer.colors = [color3, color4, color5, UIColor.white.cgColor]
        rootUIView.layer.insertSublayer(layer, at: 0)
    }
    
    func setupCollectionView() {
        favoriteMoviesCollectionView.delegate = self
        favoriteMoviesCollectionView.dataSource = self
        let nibCell = UINib(nibName: "FavoriteMovieCell", bundle: nil)
        favoriteMoviesCollectionView.register(nibCell, forCellWithReuseIdentifier: "FavoriteMovieCell")
        contentContainerView.layer.cornerRadius = CGFloat(5)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movies?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 180.0, height: 320.0)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = favoriteMoviesCollectionView.dequeueReusableCell(withReuseIdentifier: "FavoriteMovieCell", for: indexPath) as! FavoriteMovieCell
        let movie = self.movies![indexPath.item]        
        cell.titleLabelView.text = movie.title
        
        let baseUrl = "https://image.tmdb.org/t/p/"
        let posterSize = "w185"
        
        if let posterPath = movie.poster_path {
            let url = baseUrl + posterSize + posterPath
            cell.posterImageView.af_setImage(withURL: URL(string: url)!)
        }        
        cell.layer.cornerRadius = CGFloat(5)
        
        if indexPath.item > self.lastAnimatedItem! {
            cell.transform = CGAffineTransform(
                translationX: 0,
                y: 50.0
            )
            cell.alpha = 0.0
            
            UIView.animate(withDuration: 1.0, animations: {
                cell.transform = .identity
                cell.alpha = 1
            })
            self.lastAnimatedItem = indexPath.item
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let movie = movies?[indexPath.item] {
            var genres = String()
            
            for genreId in movie.genre_ids! {
                let genreName = genresMap![genreId]
                genres += genreName!
                
                if genreId != movie.genre_ids?.last {
                    genres += ", "
                }
            }
            let data = MovieData(movie: movie, genresNames: genres, indexPath: indexPath)
            performSegue(withIdentifier: "FavoriteMovie", sender: data)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is MovieViewController {
            let vc = segue.destination as? MovieViewController
            vc?.fromLayout = .Favorite
            vc?.movieData = sender as? MovieData
            vc?.isMovieFavorite = true
        }
    }
    
    func setupNotifications() {
        let notificationName = Notification.Name("didReceiveData")
        NotificationCenter.default.addObserver(self, selector: #selector(onNotificationReceived(_:)), name: notificationName, object: nil)
    }
    
    private func getMoviesFromDb() {
        Database.shared.loadDatabaseFavorites()
        
        if movies != nil {
            self.movies?.removeAll()
        }
        self.movies = Database.shared.getDatabaseFavorites()
    }
    
    @objc func onNotificationReceived(_ notification: Notification) {
        if let data = notification.object as? NotificationData {
            if data.fromLayout == .Favorite {
                self.movies?.remove(at: data.indexPath.item)
                self.favoriteMoviesCollectionView.reloadData()
            } else {
                getMoviesFromDb()
                self.favoriteMoviesCollectionView.reloadData()
            }
        }
    }
}
