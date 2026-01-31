//
//  MovieViewModel.swift
//  FoodoAI
//
//  Created by Gowtham Namuru on 31/01/26.
//

import SwiftUI

enum ViewState: Equatable {
    case loading
    case success(isEmpty: Bool)
    case failed
}

final class MovieViewModel: ObservableObject {
    private(set) var movieAPILoader: MoviesLoading
    @Published private(set) var viewState: ViewState = .loading
    @Published private(set) var movies: [Movie] = []
    @Published private(set) var isOfflineData: Bool = false
    @Published private(set) var failedToStore: Bool = false
    private var localMovieStore: MovieStore

    init(movieAPILoader: MoviesLoading, movieStore: MovieStore) {
        self.movieAPILoader = movieAPILoader
        self.localMovieStore = movieStore
    }

    func load() {
        self.viewState = .loading
        movieAPILoader.load { [weak self] result in
            guard let self else { return }
            DispatchQueue.main.async {
                switch result {
                case let .success(moviesPayload):
                    self.viewState = .success(isEmpty: moviesPayload.movies.isEmpty)
                    self.movies = moviesPayload.movies
                    self.isOfflineData = moviesPayload.source == .local
                    if !self.isOfflineData {
                        self.storeMovies()
                    }
                case .failure:
                    self.viewState = .failed
                }
            }
        }
    }

    private func storeMovies() {
        self.localMovieStore.insert(movies.toLocal(), timestamp: Date()) { [weak self] result in
            guard let self else { return }
            DispatchQueue.main.async {
                switch result {
                case .failure:
                    self.failedToStore = true
                case .success():
                    // TODO: We need to figure out to show to user that data has been stored successfully
                    break
                }
            }
        }
    }
}
