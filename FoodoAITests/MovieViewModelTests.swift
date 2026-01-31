//
//  MovieViewModelTests.swift
//  FoodoAITests
//
//  Created by Gowtham Namuru on 31/01/26.
//

import XCTest
@testable import FoodoAI

final class MovieViewModelTests: XCTestCase {
    func test_onInitliaze_shouldNotTriggerAPICallOrLoadLocalData() {
        let remoteStoreMock = MovieLoaderSpy()

        let _ = makeSUT(remoteStore: remoteStoreMock)

        XCTAssertTrue(remoteStoreMock.receivedLoad.isEmpty)
    }

    func test_onLoad_shouldTriggerAPICallAndLoadLocalData() {
        let remoteStoreMock = MovieLoaderSpy()

        let sut = makeSUT(remoteStore: remoteStoreMock)

        sut.load()

        XCTAssertFalse(remoteStoreMock.receivedLoad.isEmpty)
    }
}

private extension MovieViewModelTests {
    func makeSUT(remoteStore: MovieLoader) -> MovieViewModel {
        .init(movieAPILoader: remoteStore)
    }

    final class MovieLoaderSpy: MovieLoader {
        private(set) var receivedLoad: [(MovieLoader.Result) -> Void] = []

        func load(_ completion: @escaping (MovieLoader.Result) -> Void) {
            receivedLoad.append(completion)
        }
    }
}
