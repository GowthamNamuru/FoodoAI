//
//  LocalMovieLoader.swift
//  FoodoAI
//
//  Created by Gowtham Namuru on 30/01/26.
//

import Foundation

final class LocalMovieLoader {
    private let store: MovieStore
    private let currentDate: () -> Date

    public init(store: MovieStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
}

extension LocalMovieLoader {
    public typealias SaveResult = Result<Void, Error>
    public func save(_ movie: [Movie], completion: @escaping (SaveResult) -> Void) {
        store.insert(movie.toLocal(), timestamp: self.currentDate()) { [weak self] error in
            guard self != nil else { return }
            completion(error)
        }
    }
}

extension LocalMovieLoader: MovieLoader {
    public typealias LoadResult = MovieLoader.Result
    public func load(_ completion: @escaping (LoadResult) -> Void) {
        store.retrieve { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .failure(error):
                completion(.failure(error))

            case let .success(.some(movies)):
                completion(.success(movies.movies.toModels()))

            case .success(.none):
                completion(.success([]))
            }
        }
    }
}

extension Array where Element == Movie {
    func toLocal() -> [LocalMovieItem] {
        return map { LocalMovieItem(id: $0.id, description: $0.description, name: $0.name, image: $0.url) }
    }
}

private extension Array where Element == LocalMovieItem {
    func toModels() -> [Movie] {
        return map { Movie(id: $0.id, description: $0.description, name: $0.name, url: $0.image) }
    }
}
