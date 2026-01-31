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
            VStack(alignment: .leading, spacing: 16) {
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
