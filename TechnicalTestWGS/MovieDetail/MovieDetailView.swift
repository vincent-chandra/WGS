//
//  MovieDetailView.swift
//  TechnicalTestWGS
//
//  Created by Vincent on 20/06/25.
//

import SwiftUI
import Network

struct MovieDetailView: View {
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @State private var showNetworkAlert = false
    
    let movie: MovieListDetail
    
    @State private var movieDetailData = MovieDetails()
    @State private var arrReview = Reviews()
    @State private var currentPageReview = 1
    @State private var videoID = ""
    @State private var shouldRefreshWebView = false
    
    @State private var showPopUpError = false
    
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
            fetchMovieDetail(id: movie.id ?? 0) { result in
                switch result {
                case .success(let data):
                    movieDetailData = data
                case .failure(let failure):
                    print("Error:", failure)
                    showPopUpError = true
                }
            }
            fetchMovieTrailer(id: movie.id ?? 0) { result in
                switch result {
                case .success(let movieTrailerData):
                    if let key = movieTrailerData.results?[0].key {
                        videoID = key
                        shouldRefreshWebView = true
                    }
                case .failure(let failure):
                    print("Error:", failure)
                    showPopUpError = true
                }
            }
            fetchMovieReview(page: currentPageReview, id: movie.id ?? 0) { result in
                switch result {
                case .success(let reviewData):
                    arrReview = reviewData
                case .failure(let failure):
                    print("Error:", failure)
                    showPopUpError = true
                }
            }
            
            showNetworkAlert = networkMonitor.isConnected == false
        }
        .onChange(of: networkMonitor.isConnected) { connection, _ in
            showNetworkAlert = connection == false
        }
        .alert(
            "Network connection seems to be offline.",
            isPresented: $showNetworkAlert
        ) {}
    }
    
    func fetchMovieDetail(id: Int, completion: @escaping (Result<MovieDetails, Error>) -> Void) {
        guard let url = URL(string: "https://api.themoviedb.org/3/movie/\(id)?api_key=d7ff494718186ed94ee75cf73c1a3214&language=en-US") else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        let requestTask = URLSession.shared.dataTask(with: url) {
            (data: Data?, response: URLResponse?, error: Error?) in
            
            guard let data = data else {
                print("URLSession dataTask error:", error ?? "")
                completion(.failure(error ?? URLError(.badServerResponse)))
                return
            }
            do {
                let movieDataResult = try JSONDecoder().decode(MovieDetails.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(movieDataResult))
                }
            } catch {
                print("JSONSerialization error:", error)
                completion(.failure(URLError(.cannotDecodeContentData)))
            }
        }
        requestTask.resume()
    }
    
    func fetchMovieTrailer(id: Int, completion: @escaping (Result<MovieVideos, Error>) -> Void) {
        guard let url = URL(string: "https://api.themoviedb.org/3/movie/\(id)/videos?api_key=d7ff494718186ed94ee75cf73c1a3214&language=en-US") else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        let requestTask = URLSession.shared.dataTask(with: url) {
            (data: Data?, response: URLResponse?, error: Error?) in
            
            guard let data = data else {
                print("URLSession dataTask error:", error ?? "")
                completion(.failure(error ?? URLError(.badServerResponse)))
                return
            }
            do {
                let movieTrailer = try JSONDecoder().decode(MovieVideos.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(movieTrailer))
                }
            } catch {
                print("JSONSerialization error:", error)
                completion(.failure(URLError(.cannotDecodeContentData)))
            }
        }
        requestTask.resume()
    }
    
    func fetchMovieReview(page: Int, id: Int, completion: @escaping (Result<Reviews, Error>) -> Void) {
        guard let url = URL(string: "https://api.themoviedb.org/3/movie/\(id)/reviews?api_key=d7ff494718186ed94ee75cf73c1a3214&language=en-US&page=\(page)") else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        let requestTask = URLSession.shared.dataTask(with: url) {
            (data: Data?, response: URLResponse?, error: Error?) in
            
            guard let data = data else {
                print("URLSession dataTask error:", error ?? "")
                completion(.failure(error ?? URLError(.badServerResponse)))
                return
            }
            do {
                let reviewData = try JSONDecoder().decode(Reviews.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(reviewData))
                }
            } catch {
                print("JSONSerialization error:", error)
                completion(.failure(URLError(.cannotDecodeContentData)))
            }
        }
        requestTask.resume()
    }
}
