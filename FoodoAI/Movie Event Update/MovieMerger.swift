//
//  MovieMerger.swift
//  FoodoAI
//
//  Created by Gowtham Namuru on 31/01/26.
//

import Foundation

struct MovieMerger {
    static func apply(_ event: MovieEvent, to current: [Movie]) -> [Movie] {
        var movies = current
        switch event.type {
        case .updated:
            if let index = movies.firstIndex(where: { $0.id == event.item.id }) {
                movies[index] = event.item
            } else {
                // If updated item doesn't exist, you may choose to insert it
                movies.append(event.item)
            }
        case .created:
            if !movies.contains(where: { $0.id == event.item.id }) {
                movies.append(event.item)
            }
        case .removed:
            movies.removeAll { $0.id == event.item.id }
        }
        return movies
    }
}
