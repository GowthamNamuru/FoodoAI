//
//  OfflineFallbackMovieLoaderTests.swift
//  FoodoAITests
//
//  Created by Gowtham Namuru on 31/01/26.
//

import XCTest
@testable import FoodoAI

final class OfflineFallbackMovieLoaderTests: XCTestCase {
    func test_onInit_ShouldNotLoadMovies() {
        let remote = MovieLoaderSpy()
        let local = MovieLoaderSpy()
        let sut = makeSUT(remote: remote, local: local)

        XCTAssertTrue(remote.receivedLoad.isEmpty)
        XCTAssertTrue(local.receivedLoad.isEmpty)
    }
}

// MARK: - Helpers
private extension OfflineFallbackMovieLoaderTests {
    func makeSUT(remote: MovieLoader = MovieLoaderSpy(), local: MovieLoader = MovieLoaderSpy()) -> OfflineFallbackMovieLoader {
        .init(remoteLoader: remote, localLoader: local)
    }

    final class MovieLoaderSpy: MovieLoader {
        private(set) var receivedLoad: [(MovieLoader.Result) -> Void] = []

        func load(_ completion: @escaping (MovieLoader.Result) -> Void) {
            receivedLoad.append(completion)
        }

        func completeLoad(with result: MovieLoader.Result, at index: Int = 0) {
            receivedLoad[index](result)
            receivedLoad.remove(at: index)
        }
    }
}
