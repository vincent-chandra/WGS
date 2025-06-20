//
//  MovieDetailView.swift
//  TechnicalTestWGS
//
//  Created by Vincent on 20/06/25.
//

import SwiftUI

struct MovieDetailView: View {
    
    let movie: MovieListDetail
    
    @State private var movieDetailData = MovieDetails()
    @State private var arrReview = Reviews()
    @State private var currentPageReview = 1
    @State private var videoID = ""
    @State private var shouldRefreshWebView = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/w185\(movieDetailData.backdrop_path ?? "")")) { result in
                    result.image?.resizable()
                        .scaledToFit()
                }
                .frame(maxHeight: 300)
                
                HStack(alignment: .center) {
                    AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/original\(movieDetailData.poster_path ?? "")")) { result in
                        result.image?.resizable()
                            .scaledToFit()
                    }
                    .frame(height: 120)
                    .aspectRatio(6/7, contentMode: .fit)
                    .padding(.leading, 20)
                    
                    VStack(alignment: .leading) {
                        Text(movieDetailData.title ?? "")
                            .font(Font.title)
                            .fontWeight(.bold)
                        Text("\(movieDetailData.vote_average ?? 0.0)/10")
                        Text("Popularity: \(Int(movieDetailData.popularity ?? 0)) Upvote(s)")
                    }
                }
                
                Text(movieDetailData.overview ?? "")
                    .multilineTextAlignment(.leading)
                    .padding(.leading, 20)
                
                WebView(url: URL(string: "https://www.youtube.com/embed/\(videoID)")!, reload: $shouldRefreshWebView)
                    .frame(height: 200)
                    .cornerRadius(10)
                    .padding(20)
                Spacer()
                
                Text("USER'S REVIEW")
                    .font(Font.title)
                    .fontWeight(.bold)
                    .padding(.leading, 20)
                LazyVGrid(columns: [GridItem(.flexible())]) {
                    if arrReview.results?.isEmpty ?? false {
                        Text("REVIEW NOT FOUND")
                            .font(Font.title)
                            .fontWeight(.bold)
                            .padding(.leading, 20)
                    } else {
                        ForEach(Array((arrReview.results ?? []).enumerated()), id: \.0) {
                            index,
                            review in
                            ReviewCell(
                                imageProfile: "http://image.tmdb.org/t/p/original\(review.author_details.avatar_path ?? "")",
                                name: review.author ?? "",
                                review: review.content ?? "",
                                rate: review.author_details.rating ?? 0
                            )
                        }
                    }
                }
            }
        }
        .background(.gray.opacity(0.3))
        .toolbarBackground(.gray.opacity(0.3), for: .navigationBar)
        .onAppear {
            fetchMovieDetail(id: movie.id ?? 0)
            fetchMovieTrailer(id: movie.id ?? 0)
            fetchMovieReview(page: currentPageReview, id: movie.id ?? 0)
        }
    }
    
    func fetchMovieDetail(id: Int) {
        Task {
            guard let url = URL(string: "https://api.themoviedb.org/3/movie/\(id)?api_key=d7ff494718186ed94ee75cf73c1a3214&language=en-US") else { return }
            let (data, _) = try await URLSession.shared.data(from: url)
            movieDetailData = try JSONDecoder().decode(MovieDetails.self, from: data)
        }
        return
    }
    
    func fetchMovieTrailer(id: Int) {
        Task {
            guard let url = URL(string: "https://api.themoviedb.org/3/movie/\(id)/videos?api_key=d7ff494718186ed94ee75cf73c1a3214&language=en-US") else { return }
            let (data, _) = try await URLSession.shared.data(from: url)
            let movieVideoData = try JSONDecoder().decode(MovieVideos.self, from: data)
            if let key = movieVideoData.results?[0].key {
                videoID = key
                shouldRefreshWebView = true
            }
        }
        return
    }
    
    func fetchMovieReview(page: Int, id: Int) {
        Task {
            guard let url = URL(string: "https://api.themoviedb.org/3/movie/\(id)/reviews?api_key=d7ff494718186ed94ee75cf73c1a3214&language=en-US&page=\(page)") else { return }
            let (data, _) = try await URLSession.shared.data(from: url)
            arrReview = try JSONDecoder().decode(Reviews.self, from: data)
        }
        return
    }
}
