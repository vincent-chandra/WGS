//
//  MovieDetailModel.swift
//  TechnicalTestWGS
//
//  Created by Vincent on 20/06/25.
//

import Foundation

// MOVIE DETAILS
struct MovieDetails: Codable{
    var id: Int?
    var original_title: String?
    var title: String?
    var overview: String?
    var popularity: Double?
    var poster_path: String?
    var backdrop_path: String?
    var vote_average: Double?
}

// USER REVIEW
struct Reviews: Codable{
    var id: Int?
    var page: Int?
    var results: [ReviewResults]?
}

struct ReviewResults: Codable{
    var author: String?
    var author_details: AuthorDetails
    var content: String?
}

struct AuthorDetails: Codable{
    var name: String?
    var username: String?
    var avatar_path: String?
    var rating: Int?
}

// MOVIE VIDEO
struct MovieVideos: Codable{
    var id: Int?
    var results: [MovieVideoKey]?
}

struct MovieVideoKey: Codable{
    var key: String?
}

