//
//  TabsViewController.swift
//  MoviesApp
//
//  Created by Miller on 04/10/19.
//  Copyright © 2019 Miller. All rights reserved.
//

import UIKit

class TabsViewController: UITabBarController {

    var initialData: InitialData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let popularTab = self.viewControllers?[0] as? PopularMoviesViewController {
            popularTab.movies = Array<MovieModel>()
            popularTab.movies = initialData?.popularMovies
            popularTab.loadedPage = 1
            popularTab.totalPages = initialData?.totalPages
            popularTab.genresMap = initialData?.genresMap
        }
        
        if let favoritesTab = self.viewControllers?[1] as? FavoriteMoviesViewController {
            favoritesTab.genresMap = initialData?.genresMap
        }
        
        if let searchTab = self.viewControllers?[2] as? SearchMoviesViewController {
            searchTab.genresMap = initialData?.genresMap
        }
    }
}
