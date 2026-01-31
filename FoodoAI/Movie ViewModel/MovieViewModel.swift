//
//  MovieViewModel.swift
//  FoodoAI
//
//  Created by Gowtham Namuru on 31/01/26.
//

import SwiftUI

enum ViewState: Equatable {
    case loading
    case success(isEmpty: Bool)
    case failed
}

final class MovieViewModel: ObservableObject {
    private(set) var movieAPILoader: MoviesLoading
    @Published private(set) var viewState: ViewState = .loading
    @Published private(set) var movies: [Movie] = []
    @Published private(set) var isOfflineData: Bool = false
    @Published private(set) var failedToStore: Bool = false
    private var localMovieStore: MovieStore

    private let eventStream: MovieEventStreaming

    @Published private(set) var showLiveUpdateHint: Bool = false
    @Published private(set) var lastLiveUpdateText: String = ""
    private var liveHintWorkItem: DispatchWorkItem?

    init(movieAPILoader: MoviesLoading, movieStore: MovieStore, eventStream: MovieEventStreaming) {
        self.movieAPILoader = movieAPILoader
        self.localMovieStore = movieStore
        self.eventStream = eventStream
    }

    func load() {
        self.viewState = .loading
        movieAPILoader.load { [weak self] result in
            guard let self else { return }
            DispatchQueue.main.async {
                switch result {
                case let .success(moviesPayload):
                    self.viewState = .success(isEmpty: moviesPayload.movies.isEmpty)
                    self.movies = moviesPayload.movies
                    self.isOfflineData = moviesPayload.source == .local
                    if !self.isOfflineData {
                        self.storeMovies()
                    }

                    self.startLiveUpdates()
                case .failure:
                    self.viewState = .failed
                }
            }
        }
    }

    func startLiveUpdates() {
        eventStream.start { [weak self] event in
            guard let self else { return }
            DispatchQueue.main.async {
                self.movies = MovieMerger.apply(event, to: self.movies)
                self.viewState = .success(isEmpty: self.movies.isEmpty)
                self.notifyLiveUpdate(event)
            }
        }
    }

    func stopLiveUpdates() {
        eventStream.stop()
    }

    private func storeMovies() {
        self.localMovieStore.insert(movies.toLocal(), timestamp: Date()) { [weak self] result in
            guard let self else { return }
            DispatchQueue.main.async {
                switch result {
                case .failure:
                    self.failedToStore = true
                case .success():
                    // TODO: We need to figure out to show to user that data has been stored successfully
                    break
                }
            }
        }
    }


    private func notifyLiveUpdate(_ event: MovieEvent) {
        let text: String
        switch event.type {
        case .created: text = "New movie added"
        case .updated: text = "Movie updated"
        case .removed: text = "Movie removed"
        }

        lastLiveUpdateText = text
        showLiveUpdateHint = true

        liveHintWorkItem?.cancel()
        let work = DispatchWorkItem { [weak self] in
            self?.showLiveUpdateHint = false
        }
        liveHintWorkItem = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: work)
    }

    deinit {
        stopLiveUpdates()
    }
}
