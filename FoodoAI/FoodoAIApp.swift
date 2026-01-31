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
        let movieAPILoader = RemoteMovieLoader(url: URL.moviesURL, client: client) // This will be used in next commit.
        let offlineFallbackLoader = OfflineFallbackMovieLoader()
        return MovieViewModel(movieAPILoader: offlineFallbackLoader)
    }
}
