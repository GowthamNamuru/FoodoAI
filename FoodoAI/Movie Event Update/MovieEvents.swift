//
//  MovieEvents.swift
//  FoodoAI
//
//  Created by Gowtham Namuru on 31/01/26.
//

import Foundation

struct TMDBMoviesResponseDTO: Decodable {
    let results: [TMDBMovieDTO]
}

struct TMDBMovieDTO: Decodable {
    let id: Int
    let overview: String
    let title: String
    let poster_path: String
}

extension TMDBMovieDTO {
    func toDomain() -> Movie {
        Movie(
            id: id,
            description: overview,
            name: title,
            url: poster_path
        )
    }
}

enum MovieEventType {
    case created
    case updated
    case removed
}
struct MovieEvent {
    let type: MovieEventType
    let item: Movie
}

enum MovieEventTypeDTO: String, Decodable {
    case created
    case updated
    case removed
}

struct MovieEventDTO: Decodable {
    let type: MovieEventTypeDTO
    let item: MovieEventItemDTO
}

struct MovieEventItemDTO: Decodable {
    let id: Int
    let title: String
    let overview: String
    let poster_path: String
}

extension MovieEventDTO {
    func toDomain() -> MovieEvent {
        MovieEvent(
            type: type.toDomain(),
            item: item.toDomain()
        )
    }
}

extension MovieEventTypeDTO {
    func toDomain() -> MovieEventType {
        switch self {
        case .created: return .created
        case .updated: return .updated
        case .removed: return .removed
        }
    }
}

extension MovieEventItemDTO {
    func toDomain() -> Movie {
        Movie(
            id: id,
            description: overview,
            name: title,
            url: poster_path
        )
    }
}
