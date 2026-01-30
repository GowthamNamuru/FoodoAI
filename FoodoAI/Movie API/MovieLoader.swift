//
//  MovieLoader.swift
//  FoodoAI
//
//  Created by Gowtham Namuru on 30/01/26.
//

import Foundation

protocol MovieLoader {
    typealias Result = Swift.Result<[Movie], Error>

    func load(_ completion: @escaping (Result) -> Void)
}

