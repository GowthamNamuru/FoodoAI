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
    private var networkMonitor: NetworkMonitoring

    init(remoteLoader: MovieLoader, localLoader: MovieLoader, network: NetworkMonitoring) {
        self.remoteLoader = remoteLoader
        self.localLoader = localLoader
        self.networkMonitor = network
    }

    func load(_ completion: @escaping (MoviesLoading.Result) -> Void) {
        if networkMonitor.isReachable {
            loadRemote(completion)
        } else {
            loadLocal(completion)
        }
    }

    private func loadRemote(_ completion: @escaping (MoviesLoading.Result) -> Void) {
        remoteLoader.load { result in
            switch result {
            case let .success(movies):
                completion(.success(MoviesPayload(movies: movies, source: .remote)))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    private func loadLocal(_ completion: @escaping (MoviesLoading.Result) -> Void) {
        localLoader.load { result in
            switch result {
            case let .success(movies):
                completion(.success(MoviesPayload(movies: movies, source: .local)))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}
