//
//  Structs.swift
//  MoviesApp
//
//  Created by Miller on 04/10/19.
//  Copyright © 2019 Miller. All rights reserved.
//

import Foundation

struct PopularMoviesModel: Codable {
    var page: Int?
    var total_pages: Int?
    var total_results: Int?
    var results: Array<MovieModel>?
}

struct UpcomingMoviesModel: Codable {
    var page: Int?
    var total_pages: Int?
    var total_results: Int?
    var results: Array<MovieModel>?
    var dates: DatesModel?
}

struct MovieModel: Codable {
    var id: Int?
    var title: String?
    var original_title: String?
    var original_language: String?
    var poster_path: String?
    var adult: Bool?
    var overview: String?
    var release_date: String?
    var genre_ids: Array<Int>?
    var backdrop_path: String?
    var popularity: Float?
    var vote_count: Int?
    var video: Bool?
    var vote_average: Float?
}

struct GenresModel: Codable {
    var genres: Array<GenreModel>?
}

struct GenreModel: Codable {
    var id: Int?
    var name: String?
}

struct InitialData {
    var popularMovies: Array<MovieModel>
    var totalPages: Int
    var genresMap: [Int: String]
}

struct MovieData {
    var movie: MovieModel
    var genresNames: String
    var indexPath: IndexPath
}

struct DatesModel: Codable {
    var maximum: String?
    var minimum: String?
}
