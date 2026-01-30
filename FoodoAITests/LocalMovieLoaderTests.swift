//
//  LocalMovieLoaderTests.swift
//  FoodoAITests
//
//  Created by Gowtham Namuru on 30/01/26.
//

import XCTest
@testable import FoodoAI

final class LocalMovieLoaderTests: XCTestCase {
    func test_load_requestsCacheRetrieval() {
        let (sut, store) = makeSUT()

        sut.load { _ in }

        XCTAssertEqual(store.receivedMessage, [.retrieval])
    }

    func test_load_hasNoSideEffectsOnRetrievalError() {
        let (sut, store) = makeSUT()

        sut.load {_ in }

        store.completeRetrieval(with: NSError(domain: "any error", code: 1))

        XCTAssertEqual(store.receivedMessage, [.retrieval])
    }

    func test_load_hasNoSideEffectsOnEmptyCache() {
        let (sut, store) = makeSUT()

        sut.load {_ in }

        store.completeRetrievalWithEmptyCache()

        XCTAssertEqual(store.receivedMessage, [.retrieval])
    }

    func test_load_doesNotDeliverResultAfterSUTBeingDeallocated() {
        let store = MovieStoreSpy()
        var sut: LocalMovieLoader? = LocalMovieLoader(store: store, currentDate: Date.init)

        var receivedMessage = [LocalMovieLoader.LoadResult]()
        sut?.load { receivedMessage.append($0) }

        sut = nil
        store.completeRetrievalWithEmptyCache()

        XCTAssert(receivedMessage.isEmpty)
    }

    func test_load_deliversCachedMovies() {
        let movies = uniqueMovies()
        let fixedCurrentDate = Date()
        let (sut, store) = makeSUT()

        let exp = expectation(description: "Wait for retrieval to complete")
        sut.load { receivedResult in
            switch receivedResult {
            case let .success(receivedImages):
                XCTAssertEqual(receivedImages, movies.models)
            default:
                XCTFail("Expected \(String(describing: movies.models)), got \(String(describing: receivedResult)) instead")
            }
            exp.fulfill()
        }
        store.completeRetrieval(with: movies.local, timestamp: fixedCurrentDate)
        wait(for: [exp], timeout: 1.0)
    }

    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath,
                         line: UInt = #line) -> (sut: LocalMovieLoader, store: MovieStoreSpy) {
        let store = MovieStoreSpy()
        let sut = LocalMovieLoader(store: store, currentDate: currentDate)
        return (sut, store)
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

private class MovieStoreSpy: MovieStore {
    enum ReceivedMessage: Equatable {
        case insert([LocalMovieItem], Date)
        case retrieval
    }

    private(set) var receivedMessage = [ReceivedMessage]()

    private var insertionCompletions = [InsertionCompletion]()
    private var retrievalCompletions: [RetrievalCompletion] = []

    func insert(_ feed: [LocalMovieItem], timestamp: Date, completion: @escaping InsertionCompletion) {
        insertionCompletions.append(completion)
        receivedMessage.append(.insert(feed, timestamp))
    }

    func retrieve(completion: @escaping RetrievalCompletion) {
        retrievalCompletions.append(completion)
        receivedMessage.append(.retrieval)
    }

    func completeRetrieval(with error: Error, at index: Int = 0) {
        retrievalCompletions[index](.failure(error))
    }

    func completeRetrievalWithEmptyCache(at index: Int = 0) {
        retrievalCompletions[index](.success(.none))
    }

    func completeRetrieval(with feed: [LocalMovieItem], timestamp: Date, at index: Int = 0) {
        retrievalCompletions[index](.success(CachedMovies(movies: feed, timestamp: timestamp)))
    }
}
