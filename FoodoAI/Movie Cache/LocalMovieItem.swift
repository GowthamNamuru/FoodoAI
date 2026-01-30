//
//  LocalMovieItem.swift
//  FoodoAI
//
//  Created by Gowtham Namuru on 30/01/26.
//

import Foundation

struct LocalMovieItem: Decodable {
    let id: Int
    let description: String
    let name: String
    let poster_path: String
}
