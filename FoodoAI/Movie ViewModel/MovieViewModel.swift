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

    init(movieAPILoader: MoviesLoading) {
        self.movieAPILoader = movieAPILoader
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
                case .failure:
                    self.viewState = .failed
                }
            }
        }
    }
}
