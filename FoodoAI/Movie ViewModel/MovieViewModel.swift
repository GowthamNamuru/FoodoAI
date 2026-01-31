//
//  MovieViewModel.swift
//  FoodoAI
//
//  Created by Gowtham Namuru on 31/01/26.
//

import Foundation

enum ViewState {
    case loading
    case success
    case failed
}

final class MovieViewModel {
    private(set) var movieAPILoader: MovieLoader
    private(set) var viewState: ViewState = .loading

    init(movieAPILoader: MovieLoader) {
        self.movieAPILoader = movieAPILoader
    }

    func load() {
        self.viewState = .loading
        movieAPILoader.load { result in
            switch result {
            case .success:
                self.viewState = .success
            case .failure:
                self.viewState = .failed
            }
        }
    }
}
