//
//  MovieDetailView.swift
//  FoodoAI
//
//  Created by Gowtham Namuru on 31/01/26.
//

import SwiftUI

struct MovieDetailView: View {
    let movie: Movie
    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 16) {
                AsyncImage(url: movie.posterURL) { image in
                    image
                        .resizable()
                        .scaledToFit()
                } placeholder: {
                    Color.gray.opacity(0.25)
                }
                .frame(height: 320)
                .clipped()

                VStack(alignment: .leading, spacing: 10) {
                    Text(movie.name)
                        .font(.title)
                        .bold()

                    if !movie.description.isEmpty {
                        Text(movie.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                    } else {
                        Text("No overview available.")
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}
