//
//  MovieItemMapper.swift
//  FoodoAI
//
//  Created by Gowtham Namuru on 30/01/26.
//

import Foundation

final class MovieItemsMapper {

    private struct Root: Decodable {
        let results: [RemoteMovieItem]
    }

    private static var OK_200: Int { 200 }

    internal static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteMovieItem] {
        guard response.statusCode == OK_200, let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteMovieLoader.Error.invalidData
        }
        return root.results
    }
}
