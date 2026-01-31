//
//  MovieEventStreaming.swift
//  FoodoAI
//
//  Created by Gowtham Namuru on 31/01/26.
//

import Foundation

protocol MovieEventStreaming {
    func start(onEvent: @escaping (MovieEvent) -> Void)
    func stop()
}


enum MovieEventsLoader {
    static func loadBundledEvents() -> [MovieEvent] {
        guard let url = Bundle.main.url(forResource: "movie_events", withExtension: "json"),
              let data = try? Data(contentsOf: url) else { return [] }

        let decoder = JSONDecoder()
        guard let dtos = try? decoder.decode([MovieEventDTO].self, from: data) else { return [] }
        return dtos.map { $0.toDomain() }
    }
}

final class BundledMovieEventStream: MovieEventStreaming {
    private let events: [MovieEvent]
    private let interval: TimeInterval
    private var timer: Timer?

    init(events: [MovieEvent], interval: TimeInterval = 3.0) {
        self.events = events
        self.interval = interval
    }

    func start(onEvent: @escaping (MovieEvent) -> Void) {
        stop()
        guard !events.isEmpty else { return }

        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            // emit a random event each time
            if let e = self.events.randomElement() {
                onEvent(e)
            }
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    deinit { stop() }
}
