//
//  MovieStore.swift
//  FoodoAI
//
//  Created by Gowtham Namuru on 30/01/26.
//

import Foundation

typealias CachedMovies = (movies: [LocalMovieItem], timestamp: Date)

protocol MovieStore {
    typealias InsertionCompletion = (Result<Void, Error>) -> Void
    typealias RetrievalCompletion = (Swift.Result<CachedMovies?, Error>) -> Void

    func insert(_ feed: [LocalMovieItem], timestamp: Date, completion: @escaping InsertionCompletion)

    func retrieve(completion: @escaping RetrievalCompletion)
}
