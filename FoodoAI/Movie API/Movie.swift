//
//  Movie.swift
//  FoodoAI
//
//  Created by Gowtham Namuru on 30/01/26.
//

import Foundation

struct Movie: Equatable, Identifiable {
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
}
