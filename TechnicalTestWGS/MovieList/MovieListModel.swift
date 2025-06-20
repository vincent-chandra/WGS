//
//  MovieListModel.swift
//  TechnicalTestWGS
//
//  Created by Vincent on 20/06/25.
//

import Foundation

// MOVIE FETCH
struct Movies: Codable{
    var page: Int?
    var results: [MovieListDetail]?
}

struct MovieListDetail: Identifiable, Codable{
    var original_title: String?
    var poster_path: String?
    var overview: String?
    var title: String?
    var id: Int?
}
