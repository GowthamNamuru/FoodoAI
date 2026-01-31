//
//  MovieItemView.swift
//  FoodoAI
//
//  Created by Gowtham Namuru on 31/01/26.
//

import SwiftUI

struct MovieItemView: View {
    let movie: Movie

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            AsyncImage(url: movie.posterURL) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Color.gray.opacity(0.3)
            }
            .frame(width: 60, height: 90)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 6) {
                Text(movie.name)
                    .font(.headline)

                Text(movie.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
            }
        }
        .padding(.vertical, 6)
    }
}
