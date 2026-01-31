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
        let localStoreMock = MovieStoreSpy()
        let remoteStoreMock = MovieStoreSpy()

        let _ = makeSUT(remoteStore: remoteStoreMock)
        
        XCTAssertTrue(remoteStoreMock.receivedMessage.isEmpty)
        XCTAssertTrue(localStoreMock.receivedMessage.isEmpty)
    }
}

private extension MovieViewModelTests {
    func makeSUT(remoteStore: MovieStore) -> MovieViewModel {
        .init(movieAPILoader: remoteStore)
    }
}
