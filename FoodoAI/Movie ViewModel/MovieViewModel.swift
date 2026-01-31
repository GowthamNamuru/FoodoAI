//
//  MovieViewModel.swift
//  FoodoAI
//
//  Created by Gowtham Namuru on 31/01/26.
//

import Foundation

final class MovieViewModel {
    private(set) var movieAPILoader: MovieStore

    init(movieAPILoader: MovieStore) {
        self.movieAPILoader = movieAPILoader
    }
}
