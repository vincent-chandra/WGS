//
//  ContentView.swift
//  TechnicalTestWGS
//
//  Created by Vincent on 19/06/25.
//

import SwiftUI

struct ContentView: View {
    @State private var searchText = ""
    @State var isSearching = false
    @State var isFinishedFetching = true
    @State private var isShowingMovieDetail = false
    
    @State private var movieData = Movies()
    @State private var pageCount = 1
    
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
                                            self.searchMovie(isTrending: true)
                                        } else {
                                            self.searchMovie(isTrending: false)
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
            searchMovie(isTrending: true)
        })
        .onChange(of: searchText) {
            self.pageCount = 1
            self.movieData.results = []
            isSearching = false
            if searchText.isEmpty && !isSearching {
                self.searchMovie(isTrending: true)
            } else {
                self.searchMovie(isTrending: false)
            }
        }
    }
    
    var filteredMovies: [MovieListDetail] {
        if searchText.isEmpty {
            return movieData.results ?? []
        } else {
            return movieData.results?.filter { $0.title?.localizedCaseInsensitiveContains(searchText) ?? false } ?? []
        }
    }
    
    func searchMovie(isTrending: Bool) {
        isSearching = true
        Task {
            guard let url = isTrending ? URL(string: "https://api.themoviedb.org/3/trending/movie/day?api_key=d7ff494718186ed94ee75cf73c1a3214&page=\(pageCount)")
            : URL(string: "https://api.themoviedb.org/3/search/movie?api_key=d7ff494718186ed94ee75cf73c1a3214&language=en-US&query=\(searchText)&page=\(pageCount)") else { return }
            let (data, _) = try await URLSession.shared.data(from: url)
            let movieDataResult = try JSONDecoder().decode(Movies.self, from: data)
            var movieDataTemp = movieData.results ?? []
            movieDataTemp.append(contentsOf: movieDataResult.results ?? [])
            movieData.results = movieDataTemp
            isSearching = false
            isFinishedFetching = true
        }
        return
    }
}

#Preview {
    ContentView()
}
