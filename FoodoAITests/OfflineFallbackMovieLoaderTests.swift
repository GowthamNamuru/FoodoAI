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
        let _ = makeSUT(remote: remote, local: local)

        XCTAssertTrue(remote.receivedLoad.isEmpty)
        XCTAssertTrue(local.receivedLoad.isEmpty)
    }

    func test_shouldLoadFromRemoteWhenOnline() {
        let remote = MovieLoaderSpy()
        let sut = makeSUT(remote: remote)
        let exp = expectation(description: "Wait for load")
        sut.load { receivedResult in
            switch receivedResult {
            case let .success(payload):
                XCTAssertTrue(payload.source == .remote)
            default:
                XCTFail("Expected success, got \(receivedResult)")
            }
            exp.fulfill()
        }
        XCTAssertFalse(remote.receivedLoad.isEmpty)
        remote.completeLoad(with: .success([]))
        wait(for: [exp], timeout: 1.0)
    }

    func test_shouldLoadFromLocalWhenOffline() {
        let local = MovieLoaderSpy()
        let networkSpy = NetworkMonitoringSpy()
        networkSpy.update(state: false)
        let sut = makeSUT(local: local, network: networkSpy)
        let exp = expectation(description: "Wait for load")
        sut.load { receivedResult in
            switch receivedResult {
            case let .success(payload):
                XCTAssertTrue(payload.source == .local)
            default:
                XCTFail("Expected success, got \(receivedResult)")
            }
            exp.fulfill()
        }

        XCTAssertFalse(local.receivedLoad.isEmpty)
        local.completeLoad(with: .success([]))
        wait(for: [exp], timeout: 1.0)
    }
}

// MARK: - Helpers
private extension OfflineFallbackMovieLoaderTests {
    func makeSUT(remote: MovieLoader = MovieLoaderSpy(), local: MovieLoader = MovieLoaderSpy(), network: NetworkMonitoringSpy = NetworkMonitoringSpy()) -> OfflineFallbackMovieLoader {
        .init(remoteLoader: remote, localLoader: local, network: network)
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

    final class NetworkMonitoringSpy: NetworkMonitoring {
        private(set) var isReachable: Bool = true

        func update(state: Bool) {
            isReachable = state
        }
    }
}
