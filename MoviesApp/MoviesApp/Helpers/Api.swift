//
//  Api.swift
//  MoviesApp
//
//  Created by Miller on 04/10/19.
//  Copyright © 2019 Miller. All rights reserved.
//

import UIKit
import Alamofire

class Api {
    static let shared = Api()
    let apiKey = "6560454ef745148fa3f20cae11134a7c"
    
    func fetchPopularMovies(completion: @escaping (_ isSuccessful: Bool, _ popularMovies: [MovieModel], _ totalPages: Int) -> Void) {
        let host = URL(string: "https://api.themoviedb.org/3/movie/popular")!
        let urlRequest = URLRequest(url: host)
        let params: Parameters = ["api_key": apiKey]
        let encodedUrlRequest = try! URLEncoding.queryString.encode(urlRequest, with: params)
        
        Alamofire.request(encodedUrlRequest).responseJSON { response in
            switch response.result {
             case .success:
                guard let data = response.data else {
                    return
                }
                let movieList = try! JSONDecoder().decode(PopularMoviesModel.self, from: data)
                
                guard let movies = movieList.results, !movies.isEmpty else {
                    print("Filmes populares nao encontrados!")
                    completion(false, [], -1)
                    return
                }
                completion(true, movies, movieList.total_pages!)
             
             case .failure(let error):
                print("Erro ao conectar a Api e Buscar filmes populares!")
                print(error)
                completion(false, [], -1)
             }
        }
    }
    
    func fetchGenresList(completion: @escaping (_ isSuccessful: Bool, _ genresMap: [Int: String]) -> Void) {
        let host = URL(string: "https://api.themoviedb.org/3/genre/movie/list")!
        let urlRequest = URLRequest(url: host)
        let params: Parameters = ["api_key": apiKey]
        let encodedUrlRequest = try! URLEncoding.queryString.encode(urlRequest, with: params)
        
        Alamofire.request(encodedUrlRequest).responseJSON { response in
            switch response.result {
            case .success:
                guard let data = response.data else {
                    return
                }
                let genresList = try! JSONDecoder().decode(GenresModel.self, from: data)
                
                guard let genres = genresList.genres, !genres.isEmpty else {
                    print("Nao foram retornados generos no JSON...")
                    completion(false, [:])
                    return
                }
                var genresMap = [Int: String]()
                
                for genre in genres {
                    if let genreName = genre.name, let genreId = genre.id {
                        genresMap[genreId] = genreName
                    }
                }
                completion(true, genresMap)
                
            case .failure(let error):
                print(error)
                completion(false, [:])
                return
            }
        }
    }
    
    func fetchPopularMovies(startingFrom page: Int, completion: @escaping (_ isSuccessful: Bool, _ movies: [MovieModel]) -> Void) {
        let host = URL(string: "https://api.themoviedb.org/3/movie/popular")!
        let urlRequest = URLRequest(url: host)
        let params: Parameters = [
            "api_key": apiKey,
            "page": page
        ]
        let encodedUrlRequest = try! URLEncoding.queryString.encode(urlRequest, with: params)
        
        Alamofire.request(encodedUrlRequest).responseJSON { response in
            switch response.result {
            case .success:
                guard let data = response.data else {
                    return
                }
                let movieList = try! JSONDecoder().decode(PopularMoviesModel.self, from: data)
                
                guard let movies = movieList.results else {
                    print("Nao foram retornados movies no JSON...")
                    return
                }
                completion(true, movies)
                
            case .failure(let error):
                print(error)
                completion(false, [])
            }
        }
    }
    
    func fetchUpcomingMovies(completion: @escaping (_ isSuccessful: Bool, _ popularMovies: [MovieModel], _ totalPages: Int) -> Void) {
        let host = URL(string: "https://api.themoviedb.org/3/movie/upcoming")!
        let urlRequest = URLRequest(url: host)
        let params: Parameters = ["api_key": apiKey]
        let encodedUrlRequest = try! URLEncoding.queryString.encode(urlRequest, with: params)
        
        Alamofire.request(encodedUrlRequest).responseJSON { response in
            switch response.result {
            case .success:
                guard let data = response.data else {
                    return
                }
                let movieList = try! JSONDecoder().decode(UpcomingMoviesModel.self, from: data)
                
                guard let movies = movieList.results, !movies.isEmpty else {
                    print("Filmes populares nao encontrados!")
                    completion(false, [], -1)
                    return
                }
                completion(true, movies, movieList.total_pages!)
                
            case .failure(let error):
                print("Erro ao conectar a Api e Buscar filmes populares!")
                print(error)
                completion(false, [], -1)
            }
        }
    }
    
    func fetchUpcomingMovies(startingFrom page: Int, completion: @escaping (_ isSuccessful: Bool, _ movies: [MovieModel]) -> Void) {
        let host = URL(string: "https://api.themoviedb.org/3/movie/upcoming")!
        let urlRequest = URLRequest(url: host)
        let params: Parameters = [
            "api_key": apiKey,
            "page": page
        ]
        let encodedUrlRequest = try! URLEncoding.queryString.encode(urlRequest, with: params)
        
        Alamofire.request(encodedUrlRequest).responseJSON { response in
            switch response.result {
            case .success:
                guard let data = response.data else {
                    return
                }
                let movieList = try! JSONDecoder().decode(UpcomingMoviesModel.self, from: data)
                
                guard let movies = movieList.results else {
                    print("Nao foram retornados movies no JSON...")
                    return
                }
                completion(true, movies)
                
            case .failure(let error):
                print(error)
                completion(false, [])
            }
        }
    }
    
    func searchMovie(_ movieName: String, completion: @escaping (_ isSuccessful: Bool, _ movies: [MovieModel], _ totalPages: Int) -> Void) {
        let host = URL(string: "https://api.themoviedb.org/3/search/movie")!
        let urlRequest = URLRequest(url: host)
        let params: Parameters = ["api_key": apiKey, "query": movieName]
        let encodedUrlRequest = try! URLEncoding.queryString.encode(urlRequest, with: params)
        
        Alamofire.request(encodedUrlRequest).responseJSON { response in
            switch response.result {
            case .success:
                guard let data = response.data else {
                    return
                }
                let movieList = try! JSONDecoder().decode(PopularMoviesModel.self, from: data)
                
                guard let movies = movieList.results, !movies.isEmpty else {
                    print("Filmes populares nao encontrados!")
                    completion(false, [], -1)
                    return
                }
                completion(true, movies, movieList.total_pages!)
                
            case .failure(let error):
                print("Erro ao conectar a Api e Buscar filmes populares!")
                print(error)
                completion(false, [], -1)
            }
        }
    }
}
