//
//  EmptyMovieView.swift
//  FoodoAI
//
//  Created by Gowtham Namuru on 31/01/26.
//

import SwiftUI

struct EmptyMoviesView: View {
    let retryAction: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "film")
                .font(.system(size: 48))
                .foregroundColor(.secondary)

            Text("No movies found")
                .font(.headline)

            Text("Try again later or check back soon.")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Button("Retry", action: retryAction)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}
