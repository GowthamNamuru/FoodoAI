//
//  MovieViewModel.swift
//  FoodoAI
//
//  Created by Gowtham Namuru on 31/01/26.
//

import SwiftUI

enum ViewState {
    case loading
    case success
    case failed
}

final class MovieViewModel: ObservableObject {
    private(set) var movieAPILoader: MovieLoader
    @Published private(set) var viewState: ViewState = .loading
    @Published private(set) var movies: [Movie] = []

    init(movieAPILoader: MovieLoader) {
        self.movieAPILoader = movieAPILoader
    }

    func load() {
        self.viewState = .loading
        movieAPILoader.load { [weak self] result in
            guard let self else { return }
            switch result {
            case let .success(movies):
                self.viewState = .success
                self.movies = movies
            case .failure:
                self.viewState = .failed
            }
        }
    }
}
