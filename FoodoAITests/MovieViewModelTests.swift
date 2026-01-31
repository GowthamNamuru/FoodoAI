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

    func test_onLoadFailure_viewStateShouldBeFailed() {
        let remoteStoreMock = MovieLoaderSpy()

        let sut = makeSUT(remoteStore: remoteStoreMock)

        sut.load()
        XCTAssertEqual(sut.viewState, .loading)

        remoteStoreMock.completeLoad(with: .failure(NSError(domain: "Some Error", code: 404)))

        XCTAssertEqual(sut.viewState, .failed)
    }

    func test_onLoadSuccess_viewStateShouldBeSuccess() {
        let remoteStoreMock = MovieLoaderSpy()

        let sut = makeSUT(remoteStore: remoteStoreMock)

        sut.load()
        XCTAssertEqual(sut.viewState, .loading)

        remoteStoreMock.completeLoad(with: .success([]))

        XCTAssertEqual(sut.viewState, .success)
    }

    func test_onLoadSuccess_shouldReceivesMoviesList() {
        let remoteStoreMock = MovieLoaderSpy()
        let sut = makeSUT(remoteStore: remoteStoreMock)

        sut.load()

        remoteStoreMock.completeLoad(with: .success(uniqueMovies()))

        XCTAssertEqual(sut.movies, uniqueMovies())
    }
}

private extension MovieViewModelTests {
    func makeSUT(remoteStore: MovieLoader) -> MovieViewModel {
        .init(movieAPILoader: remoteStore)
    }

    func uniqueMovies() -> [Movie] {
        return [Movie(id: 12, description: "any", name: "any", url: "/some-param"), Movie(id: 14, description: "any", name: "any", url: "/some-param-two")]
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
