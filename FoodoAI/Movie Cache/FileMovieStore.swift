//
//  FileMovieStore.swift
//  FoodoAI
//
//  Created by Gowtham Namuru on 30/01/26.
//

import Foundation

class FileMovieStore: MovieStore {
   private struct Cache: Codable {
       let movies: [FileMovieItem]
       let timestamp: Date

       var localMovies: [LocalMovieItem] {
           movies.map({ $0.local })
       }
   }

   private struct FileMovieItem: Codable {
       public let id: Int
       public let description: String
       public let name: String
       public let url: String

       public init(id: Int, description: String, name: String, url: String) {
           self.id = id
           self.description = description
           self.name = name
           self.url = url
       }

       init(_ movie: LocalMovieItem) {
           id = movie.id
           description = movie.description
           name = movie.name
           url = movie.image
       }

       var local: LocalMovieItem {
           LocalMovieItem(id: id, description: description, name: name, image: url)
       }
   }

   private let queue = DispatchQueue(label: "\(FileMovieStore.self)Queue", qos: .userInitiated, attributes: .concurrent)
   private let storeURL: URL

   public init(storeURL: URL) {
       self.storeURL = storeURL
   }

   public func retrieve(completion: @escaping RetrievalCompletion) {
       let storeURL = self.storeURL
       queue.async {
           guard let data = try? Data(contentsOf: storeURL) else {
               completion(.success(.none))
               return
           }

           do {
               let decoder = JSONDecoder()
               let cache = try decoder.decode(Cache.self, from: data)
               completion(.success(CachedMovies(movies: cache.localMovies, timestamp: cache.timestamp)))
           } catch {
               completion(.failure(error))
           }
       }
   }

   public func insert(_ movies: [LocalMovieItem], timestamp: Date, completion: @escaping InsertionCompletion) {
       let storeURL = self.storeURL
       queue.async(flags: .barrier) {
           do {
               let encoder = JSONEncoder()
               let cache = Cache(movies: movies.map(FileMovieItem.init), timestamp: timestamp)
               let encoded = try encoder.encode(cache)
               try encoded.write(to: storeURL)
               completion(.success(()))
           } catch {
               completion(.failure(error))
           }
       }
   }
}
