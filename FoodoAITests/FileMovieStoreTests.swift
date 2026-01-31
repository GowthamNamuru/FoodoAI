//
//  FileMovieStoreTests.swift
//  FoodoAITests
//
//  Created by Gowtham Namuru on 31/01/26.
//

import XCTest
@testable import FoodoAI

final class FileMovieStoreTests: XCTestCase {
    override func setUp() {
        super.setUp()
        deleteStoreArtifacts()
    }

    override func tearDown() {
        super.tearDown()
        deleteStoreArtifacts()
    }

    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()

        let exp = expectation(description: "Wait for cache retrieval")

        sut.retrieve { receivedResult in
            switch receivedResult {
            case .success(.none):
                break
            default:
                XCTFail("Expected to retrieve success with none, got \(receivedResult) instead")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }

    func test_retrieve_deliversFoundValueOnNonEmptyCache() {
        let sut = makeSUT()
        let movies = uniqueMovies().local
        let timestamp = Date()

        // Insert the data
        let exp = expectation(description: "Wait for cache insertion")
        sut.insert(movies, timestamp: timestamp) { receivedInsertionError in
            switch receivedInsertionError {
            case .failure(_):
                XCTFail("Expected to insert without a failure")
            default:
                break
            }
            exp.fulfill()
        }

        let exp2 = expectation(description: "Wait for cache retrieval")

        sut.retrieve { retrievedResult in
            switch retrievedResult {
            case let .success(.some(received)):
                XCTAssertEqual(received.movies, movies)
                XCTAssertEqual(received.timestamp, timestamp)

            default:
                XCTFail("Expected to retrieve data, got \(retrievedResult) instead")
            }
            exp2.fulfill()
        }
        wait(for: [exp, exp2], timeout: 1.0)
    }

    func test_retrive_deliversFailureOnRetrievalError() {
        let storeURL = storeTestsURL()
        let sut = makeSUT(storeURL: storeURL)

        try! "invalid data".write(to: storeTestsURL(), atomically: false, encoding: .utf8)

        let exp2 = expectation(description: "Wait for cache retrieval")
        sut.retrieve { retrievedResult in
            switch retrievedResult {
            case .failure(_):
                break

            default:
                XCTFail("Expected to retrieve data, got \(retrievedResult) instead")
            }
            exp2.fulfill()
        }
        wait(for: [exp2], timeout: 1.0)
    }

    // MARK:- Helpers
    private func makeSUT(storeURL: URL? = nil) -> MovieStore {
        let sut = FileMovieStore(storeURL: storeURL ?? storeTestsURL())
        return sut
    }

    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: storeTestsURL())
    }

    private func storeTestsURL() -> URL {
       return FileManager.default.urls(for: .cachesDirectory,
                                           in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
    }

    func uniqueMovie() -> Movie {
        Movie(id: 12, description: "any", name: "any", url: "/some-param")
    }

    func uniqueMovies() -> (models: [Movie], local: [LocalMovieItem]) {
        let models = [uniqueMovie(), uniqueMovie()]
        let local = models.map { LocalMovieItem(id: $0.id, description: $0.description, name: $0.name, image: $0.url) }
        return (models, local)
    }
}
