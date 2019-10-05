//
//  Database.swift
//  MoviesApp
//
//  Created by Miller on 04/10/19.
//  Copyright © 2019 Miller. All rights reserved.
//

import UIKit
import SQLite

class Database {
    static let shared = Database()
    private var favoritesIds: Set<Int>?
    private var favoritesMovies: Array<MovieModel>?
    
    let path = {
        NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
            ).first!
    }()
    
    class func prepare() {
        shared.favoritesMovies = Array<MovieModel>()
        let isFavoritesTableCreated = shared.tableExists(tableName: "favorites")
        
        if !isFavoritesTableCreated {
            shared.createFavoritesTable()
        } else {
            shared.loadDatabaseFavorites()
        }
    }
    
    func tableExists(tableName: String) -> Bool {
        var exists: Bool = false
        
        do {
            let db = try Connection("\(path)/db.sqlite3")
            exists = try db.scalar(
                "SELECT EXISTS(SELECT name FROM sqlite_master WHERE name = ?)", tableName
                ) as! Int64 > 0
        } catch {
            print(error)
        }
        return exists
    }
    
    func loadDatabaseFavorites() {
        self.favoritesIds = Set<Int>()
        self.favoritesMovies = Array<MovieModel>()        
        
        do {
            let db = try Connection("\(path)/db.sqlite3")
            
            let favorites = Table("favorites")
            let id = Expression<Int>("id")
            let title = Expression<String>("title")
            let description = Expression<String>("description")
            let year = Expression<String>("year")
            let imagePath = Expression<String>("imagePath")
            let genresId = Expression<String>("genresId")
            
            for favorite in try db.prepare(favorites) {
                var movie = MovieModel()
                movie.id = favorite[id]
                movie.title = favorite[title]
                movie.overview = favorite[description]
                movie.release_date = favorite[year]
                movie.poster_path = favorite[imagePath]
                
                var genres = Array<Int>()
                let idsInString = favorite[genresId].components(separatedBy: ",")
                
                for genreId in idsInString {
                    genres.append(Int(genreId) ?? 0)
                }
                movie.genre_ids = genres
                self.favoritesIds?.insert(favorite[id])
                self.favoritesMovies?.append(movie)
            }
        } catch {
            print(error)
        }
    }
    
    func getDatabaseFavorites() -> [MovieModel] {
        return favoritesMovies!
    }
    
    func createFavoritesTable() {
        do {
            let db = try Connection("\(path)/db.sqlite3")
            
            let favorites = Table("favorites")
            let id = Expression<Int>("id")
            let title = Expression<String>("title")
            let description = Expression<String>("description")
            let year = Expression<String>("year")
            let imagePath = Expression<String>("imagePath")
            let genresId = Expression<String>("genresId")
            
            try db.run(favorites.create { t in
                t.column(id)
                t.column(title)
                t.column(description)
                t.column(year)
                t.column(imagePath)
                t.column(genresId)
            })
        } catch {
            print(error)
        }
        print("Tabela favoritos criada com sucesso!")
    }
    
    func saveMovies(moviesList movies: Array<MovieModel>) {
        do {
            let db = try Connection("\(path)/db.sqlite3")
            
            let favorites = Table("favorites")
            let id = Expression<Int>("id")
            let title = Expression<String>("title")
            let description = Expression<String>("description")
            let year = Expression<String>("year")
            let imagePath = Expression<String>("imagePath")
            let genresIdList = Expression<String>("genresId")
            
            for movie in movies {
                guard let movieId = movie.id,
                    let movieTitle = movie.title,
                    let movieDescription = movie.overview,
                    let movieYear = movie.release_date,
                    let genresId = movie.genre_ids,
                    let movieImagePath = movie.poster_path else {
                        print("Erro em atributos do filme: \(movie.id ?? -1)")
                        continue
                }
                var genresIdString = String()
                
                for id in genresId {
                    genresIdString += String(id)
                    
                    if id != genresId.last {
                        genresIdString += ","
                    }
                }
                
                try db.run(favorites.insert(id <- Int(movieId),
                                            title <- movieTitle,
                                            description <- movieDescription,
                                            year <- movieYear,
                                            genresIdList <- genresIdString,
                                            imagePath <- movieImagePath))
                
                self.favoritesIds?.insert(movieId)
            }
        } catch {
            print(error)
        }
        print("Salvei filmes no banco!")
        
    }
    
    func removeFavoriteMovie(movieId id: Int) {
        do {
            let db = try Connection("\(path)/db.sqlite3")
            let favorites = Table("favorites")
            let movieId = Expression<Int>("id")
            let movieRow = favorites.filter(movieId == id)
            
            if try db.run(movieRow.delete()) > 0 {
                print("Filme removido dos favoritos.")
                self.favoritesIds?.remove(id)
            } else {
                print("Movie id nao encontrado!")
            }
        } catch {
            print(error)
        }
    }
    
    func removeAllFavoritesMovies() {
        do {
            let db = try Connection("\(path)/db.sqlite3")
            let favorites = Table("favorites")
            
            if try db.run(favorites.delete()) > 0 {
                print("Todos favoritos foram removidos.")
                self.favoritesIds?.removeAll()
            } else {
                print("Nao foram encontrados favoritos!")
            }
        } catch {
            print(error)
        }
    }
    
    func hasFavoriteMovie(movieId id: Int) -> Bool {
        if favoritesIds == nil {
            return false
        }
        return favoritesIds!.contains(id)
    }
}
