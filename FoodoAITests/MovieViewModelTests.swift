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
        RunLoop.current.run(until: Date())

        XCTAssertEqual(sut.viewState, .failed)
    }

    func test_onLoadSuccess_viewStateShouldBeSuccess() {
        let remoteStoreMock = MovieLoaderSpy()

        let sut = makeSUT(remoteStore: remoteStoreMock)

        sut.load()
        XCTAssertEqual(sut.viewState, .loading)

        remoteStoreMock.completeLoad(with: .success(MoviesPayload(movies: [], source: .remote)))
        RunLoop.current.run(until: Date())

        XCTAssertEqual(sut.viewState, .success(isEmpty: true))
    }

    func test_onLoadSuccess_shouldReceivesMoviesList() {
        let remoteStoreMock = MovieLoaderSpy()
        let sut = makeSUT(remoteStore: remoteStoreMock)

        sut.load()

        remoteStoreMock.completeLoad(with: .success(uniqueMovies()))
        RunLoop.current.run(until: Date())

        XCTAssertEqual(sut.movies, uniqueMovies().movies)
    }

    func test_onLoadSuccess_shouldNotUpdateMoviesList_onDeallocation() {
        let remoteStoreMock = MovieLoaderSpy()
        var sut: MovieViewModel? = makeSUT(remoteStore: remoteStoreMock)

        sut?.load()
        sut = nil

        remoteStoreMock.completeLoad(with: .success(uniqueMovies()))

        XCTAssertTrue(remoteStoreMock.receivedLoad.isEmpty)
    }
}

private extension MovieViewModelTests {
    func makeSUT(remoteStore: MoviesLoading) -> MovieViewModel {
        .init(movieAPILoader: remoteStore, movieStore: MovieStoreSpy())
    }

    func uniqueMovies(with source: MoviesSource = .remote) -> MoviesPayload {
        return MoviesPayload(movies:[Movie(id: 12, description: "any", name: "any", url: "/some-param"), Movie(id: 14, description: "any", name: "any", url: "/some-param-two")], source: source)
    }

    final class MovieLoaderSpy: MoviesLoading {
        private(set) var receivedLoad: [(MoviesLoading.Result) -> Void] = []

        func load(_ completion: @escaping (MoviesLoading.Result) -> Void) {
            receivedLoad.append(completion)
        }

        func completeLoad(with result: MoviesLoading.Result, at index: Int = 0) {
            receivedLoad[index](result)
            receivedLoad.remove(at: index)
        }
    }
}
