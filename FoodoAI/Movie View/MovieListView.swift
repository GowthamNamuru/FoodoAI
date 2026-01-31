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
        VStack {
            if viewModel.showLiveUpdateHint {
                LiveUpdateBanner(text: viewModel.lastLiveUpdateText)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }

            content
                .navigationTitle("Movies")
                .onAppear {
                    // This can be refactored
                    if viewModel.movies.isEmpty {
                        viewModel.load()
                    }
                }
        }
        .animation(.easeInOut(duration: 0.25), value: viewModel.showLiveUpdateHint)
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
                if viewModel.isOfflineData {
                    Text("Offline data")
                        .font(.footnote)
                        .padding(8)
                        .frame(maxWidth: .infinity)
                        .background(.red.opacity(0.25))
                }
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

struct LiveUpdateBanner: View {
    let text: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "bolt.fill")
            Text(text)
                .font(.footnote)
                .lineLimit(1)
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(.thinMaterial)
        .overlay(
            Divider(),
            alignment: .bottom
        )
    }
}
