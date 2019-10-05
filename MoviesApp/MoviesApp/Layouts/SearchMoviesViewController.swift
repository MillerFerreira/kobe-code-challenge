//
//  SearchMoviesViewController.swift
//  MoviesApp
//
//  Created by Miller on 04/10/19.
//  Copyright © 2019 Miller. All rights reserved.
//

import UIKit
import AlamofireImage

class SearchMoviesViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    var movies: Array<MovieModel>?
    var genresMap: [Int: String]?
    var lastAnimatedItem: Int?
    var loadedPage: Int?
    var totalPages: Int?
    
    @IBOutlet var rootUIView: UIView!
    @IBOutlet weak var contentContainerView: UIView!
    @IBOutlet weak var searchMoviesCollectionView: UICollectionView!
    @IBOutlet weak var searchContainerView: UIView!
    @IBOutlet weak var searchView: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupGradient()
        setupCollectionView()
        lastAnimatedItem = 0
        searchContainerView.layer.cornerRadius = CGFloat(4)
        setupNotifications()
    }
    
    func setupGradient() {
        let layer = CAGradientLayer()
        layer.frame = CGRect(x: .zero, y: .zero, width: rootUIView.frame.width, height: rootUIView.frame.height)
        let color0 = UIColor(red:255.0/255, green:99.0/255, blue: 0.0, alpha:1.0).cgColor
        let color1 = UIColor(red:234.0/255, green:51.0/255, blue:121.0/255, alpha:1.0).cgColor        
        layer.colors = [color0, color1, UIColor.black.cgColor]
        rootUIView.layer.insertSublayer(layer, at: 0)
    }
    
    func setupCollectionView() {
        searchMoviesCollectionView.delegate = self
        searchMoviesCollectionView.dataSource = self
        let nibCell = UINib(nibName: "PopularMovieCell", bundle: nil)
        searchMoviesCollectionView.register(nibCell, forCellWithReuseIdentifier: "PopularMovieCell")
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
        let cell = searchMoviesCollectionView.dequeueReusableCell(withReuseIdentifier: "PopularMovieCell", for: indexPath) as! PopularMovieCell
        cell.favoriteIcon.image = nil
        let movie = self.movies![indexPath.item]
        
        cell.titleLabelView.text = movie.original_title
        
        let baseUrl = "https://image.tmdb.org/t/p/"
        let posterSize = "w185"
        
        if let posterPath = movie.poster_path {
            let url = baseUrl + posterSize + posterPath
            cell.posterImageView.af_setImage(withURL: URL(string: url)!)
        }
        let isFavorite = Database.shared.hasFavoriteMovie(movieId: movie.id!)
        
        if isFavorite {
            cell.favoriteIcon.image = UIImage(named: "favorite_full_icon")
        } else {
            cell.favoriteIcon.image = UIImage(named: "favorite_gray_icon")
        }
        cell.layer.cornerRadius = CGFloat(5)
        
        if indexPath.item == (self.movies!.count - 5) && self.loadedPage! < self.totalPages! {
            DispatchQueue.global(qos: .background).async {
                Api.shared.fetchUpcomingMovies(startingFrom: self.loadedPage! + 1, completion: { isSuccessful, movieList in
                    if isSuccessful {
                        self.loadedPage = self.loadedPage! + 1
                        var newMoviesIndexPath = [IndexPath]()
                        
                        for movie in movieList {
                            let position = self.movies!.count
                            let newIndexPath = IndexPath(item: position, section: 0)
                            newMoviesIndexPath.append(newIndexPath)
                            self.movies?.append(movie)
                        }
                        self.searchMoviesCollectionView.insertItems(at: newMoviesIndexPath)
                    }
                })
            }
        }
        
        if indexPath.item > self.lastAnimatedItem! {
            cell.transform = CGAffineTransform(
                translationX: 0,
                y: 50.0
            )
            cell.alpha = 0.1
            
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
            performSegue(withIdentifier: "SearchMovie", sender: data)
        }
    }
    private func searchMovie(movieName movie: String) {
        Api.shared.searchMovie(movie, completion: { isSuccessful, searchMovies, totalPages in
            if isSuccessful {
                print("Busca retornado pela Api com sucesso.")
                self.movies?.removeAll()
                self.totalPages = totalPages
                self.loadedPage = 1
                self.movies = searchMovies
                self.lastAnimatedItem = -1
                self.searchMoviesCollectionView.reloadData()
                self.searchView.endEditing(true)
            } else {
                print("Erro ao buscar filme!")
            }
        })
    }
    @IBAction func onClickSearchButton(_ sender: UIButton) {
        if let inputText = searchView.text {
            if !inputText.isEmpty {
                searchMovie(movieName: inputText)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is MovieViewController {
            if let data = sender as? MovieData {
                let isFavoriteMovie = Database.shared.hasFavoriteMovie(movieId: data.movie.id!)
                let vc = segue.destination as? MovieViewController
                vc?.fromLayout = .Search
                vc?.movieData = data
                vc?.isMovieFavorite = isFavoriteMovie
            }
        }
    }
    
    func setupNotifications() {
        let notificationName = Notification.Name("didReceiveData")
        NotificationCenter.default.addObserver(self, selector: #selector(onNotificationReceived(_:)), name: notificationName, object: nil)
    }
    
    @objc func onNotificationReceived(_ notification: Notification) {
        if let data = notification.object as? NotificationData {
            if data.fromLayout == .Search {
                self.searchMoviesCollectionView.reloadItems(at: [data.indexPath])
            } else {
                self.searchMoviesCollectionView.reloadData()
            }
        }
    }
    
    @IBAction func onUserSearch(_ sender: UITextField) {
        if let inputText = sender.text {
            if !inputText.isEmpty {
                searchMovie(movieName: inputText)
            }
        }
    }
}
