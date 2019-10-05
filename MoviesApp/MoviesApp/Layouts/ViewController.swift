//
//  ViewController.swift
//  MoviesApp
//
//  Created by Miller on 04/10/19.
//  Copyright © 2019 Miller. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var imageLogo: UIImageView!
    @IBOutlet weak var textLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startAnimations()
        preparePopularMovies()
    }

    func startAnimations() {
        textLabel.alpha = 0.0
        imageLogo.alpha = 0.2
        imageLogo.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        
        UIView.animate(withDuration: 2.0, animations: {
            self.imageLogo.alpha = 1.0
            self.imageLogo.transform = .identity
        }, completion: {_ in
            UIView.animate(withDuration: 1.0, animations: {
                self.textLabel.alpha = 1.0
            })
        })
    }
    
    func preparePopularMovies() {
        Api.shared.fetchUpcomingMovies(completion: { isSuccessful, popularMovies, totalPages in
            if isSuccessful {
                print("Filmes populares retornados pela Api com sucesso.")
                self.prepareMainAplication(with: popularMovies, totalResponsePages: totalPages)
            } else {
                print("Erro ao acessar api e retornar filmes populares!")
            }
        })
    }
    
    func prepareMainAplication(with popularMovies: [MovieModel], totalResponsePages pages: Int) {
        Api.shared.fetchGenresList(completion: { isSuccessful, genresList in
            if isSuccessful {
                print("Generos retornados pela Api com sucesso.")
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 6.0, execute: {
                    self.startMainAplication(popularMovies: popularMovies, totalPages: pages, genresList: genresList)
                })
            } else {
                print("Erro ao requisitar generos da Api.")
            }
        })
    }
    
    func startMainAplication(popularMovies movies: [MovieModel], totalPages pages: Int, genresList genres: [Int: String]) {
        let data = InitialData(
            popularMovies: movies,
            totalPages: pages,
            genresMap: genres)
        
        performSegue(withIdentifier: "TabsViewController", sender: data)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is TabsViewController {
            let vc = segue.destination as? TabsViewController
            let information = sender as? InitialData
            vc?.initialData = information
        }
    }
}
