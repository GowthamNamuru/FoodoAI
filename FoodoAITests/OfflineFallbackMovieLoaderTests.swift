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
        let sut = makeSUT()
        
        XCTAssertFalse(sut.isLoading)
    }
}

// MARK: - Helpers
private extension OfflineFallbackMovieLoaderTests {
    func makeSUT() -> OfflineFallbackMovieLoader {
        .init()
    }
}
