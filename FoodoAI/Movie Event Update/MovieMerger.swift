//
//  MovieMerger.swift
//  FoodoAI
//
//  Created by Gowtham Namuru on 31/01/26.
//

import Foundation

struct MovieMerger {
    static func apply(_ event: MovieEvent, to current: [Movie]) -> [Movie] {
        var dict = Dictionary(uniqueKeysWithValues: current.map { ($0.id, $0) })

        switch event.type {
        case .created, .updated:
            dict[event.item.id] = event.item

        case .removed:
            dict.removeValue(forKey: event.item.id)
        }

        return dict.values.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }
}
