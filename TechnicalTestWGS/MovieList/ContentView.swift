//
//  ContentView.swift
//  TechnicalTestWGS
//
//  Created by Vincent on 19/06/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @State private var showNetworkAlert = false
    
    @State private var searchText = ""
    @State var isSearching = false
    @State var isFinishedFetching = true
    @State private var isShowingMovieDetail = false
    
    @State private var movieData = Movies()
    @State private var pageCount = 1
    @State private var showPopUpError = false
    
    private let totalColumn = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: totalColumn) {
                    ForEach(Array(filteredMovies.enumerated()), id: \.element.id) { index, movie in
                        NavigationLink(destination: MovieDetailView(movie: movie)) {
                            MovieListCell(title: movie.title ?? "", urlString: "https://image.tmdb.org/t/p/w185\(self.movieData.results?[index].poster_path ?? "")")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .foregroundStyle(.black)
                                .onAppear {
                                    if filteredMovies.count-1 == index && isFinishedFetching {
                                        isFinishedFetching = false
                                        self.pageCount += 1
                                        if searchText.isEmpty && !isSearching {
                                            searchMovie(isTrending: true) { result in
                                                switch result {
                                                case .success(let movieData):
                                                    self.movieData.results = movieData
                                                    self.isSearching = false
                                                    self.isFinishedFetching = true
                                                    self.showPopUpError = false
                                                case .failure(let failure):
                                                    print("Error:", failure)
                                                    showPopUpError = true
                                                }
                                            }
                                        } else {
                                            searchMovie(isTrending: false) { result in
                                                switch result {
                                                case .success(let movieData):
                                                    self.movieData.results = movieData
                                                    self.isSearching = false
                                                    self.isFinishedFetching = true
                                                    self.showPopUpError = false
                                                case .failure(let failure):
                                                    print("Error:", failure)
                                                    showPopUpError = true
                                                }
                                            }

                                        }
                                    }
                                }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Movie Search")
            .navigationBarTitleDisplayMode(.inline)
            .background(.gray.opacity(0.3))
            .toolbarBackground(.gray.opacity(0.3), for: .navigationBar)
        }
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
        .onAppear(perform: {
            searchMovie(isTrending: true) { result in
                switch result {
                case .success(let movieData):
                    self.movieData.results = movieData
                    self.isSearching = false
                    self.isFinishedFetching = true
                    self.showPopUpError = false
                case .failure(let failure):
                    print("Error:", failure)
                    showPopUpError = true
                }
            }
            showNetworkAlert = networkMonitor.isConnected == false
        })
        .onChange(of: searchText) {
            self.pageCount = 1
            self.movieData.results = []
            isSearching = false
            if searchText.isEmpty && !isSearching {
                searchMovie(isTrending: true) { result in
                    switch result {
                    case .success(let movieData):
                        self.movieData.results = movieData
                        self.isSearching = false
                        self.isFinishedFetching = true
                        self.showPopUpError = false
                    case .failure(let failure):
                        print("Error:", failure)
                        showPopUpError = true
                    }
                }
            } else {
                searchMovie(isTrending: false) { result in
                    switch result {
                    case .success(let movieData):
                        self.movieData.results = movieData
                        self.isSearching = false
                        self.isFinishedFetching = true
                        self.showPopUpError = false
                    case .failure(let failure):
                        print("Error:", failure)
                        showPopUpError = true
                    }
                }

            }
        }
        .onChange(of: networkMonitor.isConnected) { connection, _ in
            showNetworkAlert = connection == false
        }
        .alert(
            "Network connection seems to be offline.",
            isPresented: $showNetworkAlert
        ) {}
        .alert("There is an error when fetching API", isPresented: $showPopUpError) {}
    }
    
    var filteredMovies: [MovieListDetail] {
        if searchText.isEmpty {
            return movieData.results ?? []
        } else {
            return movieData.results?.filter { $0.title?.localizedCaseInsensitiveContains(searchText) ?? false } ?? []
        }
    }
    
    func searchMovie(isTrending: Bool, completion: @escaping (Result<[MovieListDetail], Error>) -> Void) {
        isSearching = true
        guard let url = isTrending ? URL(string: "https://api.themoviedb.org/3/trending/movie/day?api_key=d7ff494718186ed94ee75cf73c1a3214&page=\(pageCount)")
                : URL(string: "https://api.themoviedb.org/3/search/movie?api_key=d7ff494718186ed94ee75cf73c1a3214&language=en-US&query=\(searchText)&page=\(pageCount)") else {
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
                let movieDataResult = try JSONDecoder().decode(Movies.self, from: data)
                var movieDataTemp = movieData.results ?? []
                movieDataTemp.append(contentsOf: movieDataResult.results ?? [])
                DispatchQueue.main.async {
                    completion(.success(movieDataTemp))
                }
            } catch {
                print("JSONSerialization error:", error)
                completion(.failure(URLError(.cannotDecodeContentData)))
            }
        }
        requestTask.resume()
    }
}

#Preview {
    ContentView()
}
