//
//  FoodoAIApp.swift
//  FoodoAI
//
//  Created by Gowtham Namuru on 30/01/26.
//

import SwiftUI

@main
struct FoodoAIApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                MovieListView(viewModel: ViewModelComposer.composeViewModel())
            }
            .onAppear {
                MovieStoreURL.prepareMovieStore()
            }
        }
    }
}

private enum ViewModelComposer {
    static func composeViewModel() -> MovieViewModel {
        let client = URLSessionHTTPClient()
        let remoteMovieLoader = RemoteMovieLoader(url: URL.moviesURL, client: client)
        let localMovieLoader = LocalMovieLoader(store: FileMovieStore(storeURL: MovieStoreURL.url), currentDate: Date.init)
        let offlineFallbackLoader = OfflineFallbackMovieLoader(remoteLoader: remoteMovieLoader, localLoader: localMovieLoader, network: NetworkMonitor())
        let localMovieStore = FileMovieStore(storeURL: MovieStoreURL.url)
        return MovieViewModel(movieAPILoader: offlineFallbackLoader, movieStore: localMovieStore)
    }
}

enum MovieStoreURL {
    static var url: URL {
        let base = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first!

        return base
            .appendingPathComponent("Movies", isDirectory: true)
            .appendingPathComponent("movies.json", isDirectory: false)
    }

    static func prepareMovieStore() {
        let directory = MovieStoreURL.url.deletingLastPathComponent()

        if !FileManager.default.fileExists(atPath: directory.path) {
            try? FileManager.default.createDirectory(
                at: directory,
                withIntermediateDirectories: true
            )
        }
    }
}
