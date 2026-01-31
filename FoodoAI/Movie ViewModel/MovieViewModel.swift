//
//  MovieViewModel.swift
//  FoodoAI
//
//  Created by Gowtham Namuru on 31/01/26.
//

import Foundation

final class MovieViewModel {
    private(set) var movieAPILoader: MovieLoader

    init(movieAPILoader: MovieLoader) {
        self.movieAPILoader = movieAPILoader
    }

    func load() {
        movieAPILoader.load { _ in }
    }
}
