//
//  RemoteMovieLoaderTests.swift
//  FoodoAITests
//
//  Created by Gowtham Namuru on 30/01/26.
//

import XCTest
@testable import FoodoAI

final class RemoteMovieLoaderTests: XCTestCase {
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        expect(sut, toCompleteWith: failure(.connectivity)) {
            let clientError = NSError(domain: "Test", code: .zero)
            client.complete(with: clientError)
        }
    }

    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        let samples = [199, 201, 300, 400, 500]
        samples.enumerated().forEach({ index, code in
            expect(sut, toCompleteWith: failure(.invalidData)) {
                let json = makeItemsJSON([])
                client.complete(withStatusCode: code, data: json, at: index)
            }
        })
    }

    func test_load_deliversItemsOn200HTTPResponseWithJSONList() {
        let (sut, client) = makeSUT()

        let (item1, item1JSON) = makeItem(id: 1234, imageURL: "/some-image-poster-path")

        let (item2, item2JSON) = makeItem(id: 12345, description: "a description", name: "some movie name", imageURL: "/some-image-poster-path-two")

        let items = [item1, item2]

        expect(sut, toCompleteWith: .success(items)) {
            let json = makeItemsJSON([item1JSON, item2JSON])
            client.complete(withStatusCode: 200, data: json)
        }
    }


    func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let url = URL(string: "https://example.com/feed")!
        let client = HTTPClientSpy()
        var sut: RemoteMovieLoader? = RemoteMovieLoader(url: url, client: client)

        var capturedResults = [RemoteMovieLoader.Result]()
        sut?.load({ capturedResults.append($0) })

        sut = nil
        client.complete(withStatusCode: 200, data: makeItemsJSON([]))

        XCTAssertTrue(capturedResults.isEmpty)
    }
}

// MARK: - Helpers
private extension RemoteMovieLoaderTests {
    private func makeSUT(url: URL = URL(string: "https://example.com/feed")!, client: HTTPClient = HTTPClientSpy(),
                         file: StaticString = #filePath,
                         line: UInt = #line) -> (sut: RemoteMovieLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteMovieLoader(url: url, client: client)
        return (sut, client)
    }

    func expect(_ sut: RemoteMovieLoader, toCompleteWith expectedResult: RemoteMovieLoader.Result, when action: () -> Void,
                        file: StaticString = #filePath,
                        line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
            case let (.failure(receivedError as RemoteMovieLoader.Error), .failure(expectedError as RemoteMovieLoader.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1.0)
    }

    func failure(_ error: RemoteMovieLoader.Error) -> RemoteMovieLoader.Result {
        .failure(error)
    }

    func makeItemsJSON(_ items: [[String: Any]]) -> Data {
        let itemsJSON = ["results": items]
        let json = try! JSONSerialization.data(withJSONObject: itemsJSON)
        return json
    }

    func makeItem(id: Int, description: String = "", name: String = "", imageURL: String) -> (model: Movie, json: [String: Any]) {
        let item = Movie(id: id, description: description, name: name, url: imageURL)

        let itemJSON = [
            "id": id,
            "title": name,
            "overview": description,
            "poster_path": imageURL
        ] as [String : Any]
        return (item, itemJSON)
    }

}


private class HTTPClientSpy: HTTPClient {
    var requestedURLs: [URL] {
        messages.map(\.url)
    }
    private var messages = [(url: URL, completion: (HTTPClient.Result) -> Void)]()

    func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
        messages.append((url, completion))
    }

    func complete(with error: Error, at index: Int = 0) {
        messages[index].completion(.failure(error))
    }

    func complete(withStatusCode statusCode: Int, data: Data, at index: Int = 0) {
        let response = HTTPURLResponse(url: requestedURLs[index],
                                       statusCode: statusCode,
                                       httpVersion: nil,
                                       headerFields: nil)!
        messages[index].completion(.success((data, response)))
    }
}
