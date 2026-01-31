//
//  URLSessionHTTPClient.swift
//  FoodoAI
//
//  Created by Gowtham Namuru on 30/01/26.
//

import Foundation

class URLSessionHTTPClient: HTTPClient {
    private let session: URLSession
    public init(session: URLSession = .shared) {
        self.session = session
    }

    private struct UnexpectedValuesRepresentation: Error {}

    public func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
        let updatedRequest = ConstructMovieURLRequest.makeURLRequest(for: url)
        session.dataTask(with: updatedRequest) { data, response, error in
            completion(Result{
                if let error = error {
                    throw error
                } else if let data = data, let response = response as? HTTPURLResponse {
                    return (data, response)
                } else {
                    throw UnexpectedValuesRepresentation()
                }
            })
        }.resume()
    }
}

// TODO: - This can be refactored further
private enum ConstructMovieURLRequest {
    static func makeURLRequest(for url: URL) -> URLRequest {
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        let queryItems: [URLQueryItem] = [
            URLQueryItem(name: "language", value: "en-US"),
            URLQueryItem(name: "page", value: "1")
        ]
        components.queryItems = components.queryItems.map { $0 + queryItems } ?? queryItems

        var urlRequest = URLRequest(url: components.url!)
        urlRequest.httpMethod = "GET"
        urlRequest.allHTTPHeaderFields = [
          "accept": "application/json",
          "Authorization": "Bearer \(Self.apiKey)"
        ]
        return urlRequest
    }

    private static let apiKey = "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI3ZjY2YTRmOWFjZWNhOTNmYjA4YWU4ZWI0MWNiMDVjMiIsIm5iZiI6MTUxMTg5MjEyNi42MjUsInN1YiI6IjVhMWRhNDllOTI1MTQxMDMyYzA2YjY3NiIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.t1hTpIi0HDDhgTxuio72n-F9m_xW5f5zVFSiXRJu_us"
}

extension URL {
    static let moviesURL = URL(string: "https://api.themoviedb.org/3/movie/top_rated")!
}
