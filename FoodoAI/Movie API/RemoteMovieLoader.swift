//
//  RemoteMovieLoader.swift
//  FoodoAI
//
//  Created by Gowtham Namuru on 30/01/26.
//

import Foundation

final class RemoteMovieLoader: MovieLoader {
    let url: URL
    let client: HTTPClient

    enum Error: Swift.Error {
        case connectivity
        case invalidData
    }

    public typealias Result = MovieLoader.Result

    public init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }

    public func load(_ completion: @escaping (Result) -> Void) {
        client.get(from: url, completion: { [weak self]  result in
            guard self != nil else { return }
            switch result {
            case let .success((data, response)):
                completion(RemoteMovieLoader.map(data, from: response))
            case .failure:
                completion(.failure(Error.connectivity))
            }
        })
    }

    private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        do {
            let items = try MovieItemsMapper.map(data, from: response)
            return .success(items.toModels())
        } catch {
            return .failure(error)
        }
    }
}

private extension Array where Element == RemoteMovieItem {
    func toModels() -> [Movie] {
        return map { Movie(id: $0.id, description: $0.overview, name: $0.title, url: $0.poster_path) }
    }
}

internal struct RemoteMovieItem: Decodable {
    let id: Int
    let overview: String
    let title: String
    let poster_path: String
}
