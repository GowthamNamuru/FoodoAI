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
        session.dataTask(with: ConstructMovieURLRequest.makeURLRequest(for: url)) { data, response, error in
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
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.allHTTPHeaderFields = [
          "accept": "application/json",
          "Authorization": "Bearer \(Self.apiKey)"
        ]
        return urlRequest
    }

    private static let apiKey = ""
}
