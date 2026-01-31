//
//  MovieListView.swift
//  FoodoAI
//
//  Created by Gowtham Namuru on 31/01/26.
//

import SwiftUI

struct MovieListView: View {
    @StateObject private var viewModel: MovieViewModel

    init(viewModel: MovieViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        content
            .navigationTitle("Movies")
            .onAppear {
                // This can be refactored
                if viewModel.movies.isEmpty {
                    viewModel.load()
                }
            }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.viewState {
        case .loading:
            ProgressView("Loading movies...")
                .frame(maxWidth: .infinity, maxHeight: .infinity)

        case .failed:
            VStack(spacing: 16) {
                Text("Failed to load movies 😕")
                    .font(.headline)

                Button("Retry") {
                    viewModel.load()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

        case let .success(isEmpty):
            if isEmpty {
                EmptyMoviesView {
                    viewModel.load()
                }
            } else {
                List(viewModel.movies) { movie in
                    NavigationLink {
                        MovieDetailView(movie: movie)
                    } label: {
                        MovieItemView(movie: movie)
                    }
                }
                .refreshable {
                    viewModel.load()
                }
            }
        }
    }
}
