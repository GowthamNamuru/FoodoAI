//
//  OfflineFallbackMovieLoader.swift
//  FoodoAI
//
//  Created by Gowtham Namuru on 31/01/26.
//

import Foundation

enum MoviesSource {
    case remote
    case local
}

struct MoviesPayload {
    let movies: [Movie]
    let source: MoviesSource
}

protocol MoviesLoading {
    typealias Result = Swift.Result<MoviesPayload, Error>
    func load(_ completion: @escaping (Result) -> Void)
}

final class OfflineFallbackMovieLoader: MoviesLoading {
    private var remoteLoader: MovieLoader
    private var localLoader: MovieLoader

    init(remoteLoader: MovieLoader, localLoader: MovieLoader) {
        self.remoteLoader = remoteLoader
        self.localLoader = localLoader
    }

    func load(_ completion: @escaping (MoviesLoading.Result) -> Void) {

    }
}
