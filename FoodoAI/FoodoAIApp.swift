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
        }
    }
}

private enum ViewModelComposer {
    static func composeViewModel() -> MovieViewModel {
        let client = URLSessionHTTPClient()
        let remoteMovieLoader = RemoteMovieLoader(url: URL.moviesURL, client: client)
        let localMovieLoader = LocalMovieLoader(store: FileMovieStore(storeURL: URL(string: "")!), currentDate: Date.init)
        let offlineFallbackLoader = OfflineFallbackMovieLoader(remoteLoader: remoteMovieLoader, localLoader: localMovieLoader)
        return MovieViewModel(movieAPILoader: offlineFallbackLoader)
    }
}
