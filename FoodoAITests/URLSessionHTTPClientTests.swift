//
//  URLSessionHTTPClientTests.swift
//  FoodoAITests
//
//  Created by Gowtham Namuru on 30/01/26.
//

import XCTest
@testable import FoodoAI

final class URLSessionHTTPClientTests: XCTestCase {
    override func setUp() {
        super.setUp()
        URLProtocolStub.startInterceptingRequest()
    }

    override func tearDown() {
        URLProtocolStub.stopInterceptingRequest()
        super.tearDown()
    }

    func test_getFromURL_performsGETRequestWithURL() {
        let url = anyURL()
        let exp = expectation(description: "Wait for request")
        URLProtocolStub.observeRequest { request in
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }

        makeSUT().get(from: url) { _ in }
        wait(for: [exp], timeout: 1.0)
    }

    func test_getFromURL_failsOnRequestError() {
        let requestedError = NSError(domain: "any error", code: 1)


        URLProtocolStub.stub(data: nil, response: nil, error: requestedError)
        let exp = expectation(description: "Completion handler called")
        makeSUT().get(from: anyURL()) { result in
            switch result {
            case let .failure(receivedError):
                XCTAssertEqual((receivedError as NSError).code, requestedError.code)
                XCTAssertEqual((receivedError as NSError).domain, requestedError.domain)
            default:
                XCTFail("Expected failure with error, got \(result)")
            }

            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }

    func test_getFromURL_succeedsOnHTTPURLResponseWithData() {
        let requestedData = Data("any data".utf8)
        let requestedResponse = HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)

        URLProtocolStub.stub(data: requestedData, response: requestedResponse, error: nil)
        let exp = expectation(description: "Completion handler called")
        makeSUT().get(from: anyURL()) { result in
            switch result {
            case let .success(receivedValues):
                XCTAssertEqual(receivedValues.0, requestedData)
                XCTAssertEqual(receivedValues.1.url, requestedResponse?.url)
                XCTAssertEqual(receivedValues.1.statusCode, requestedResponse?.statusCode)
            default:
                XCTFail("Expected success, got \(result)")
            }

            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)

    }

    // MARK: - Helper
    private func makeSUT(file: StaticString = #filePath,
                         line: UInt = #line) -> HTTPClient {
        let sut = URLSessionHTTPClient()
        return sut
    }

    private func anyURL() -> URL {
        return URL(string: "http://any-url.com")!
    }
}

// MARK: - URLProtocolStub
private extension URLSessionHTTPClientTests {
    class URLProtocolStub: URLProtocol {
        private static var stub: Stub?
        private static var requestObserver: ((URLRequest) -> Void)?

        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }

        static func stub(data: Data?, response: URLResponse?, error: Error? = nil) {
            stub = Stub(data: data, response: response, error: error)
        }

        static func startInterceptingRequest() {
            URLProtocolStub.registerClass(URLProtocolStub.self)
        }

        static func observeRequest(_ completion: @escaping (URLRequest) -> Void) {
            requestObserver = completion
        }

        static func stopInterceptingRequest() {
            URLProtocolStub.unregisterClass(URLProtocolStub.self)
            stub = nil
            requestObserver = nil
        }

        override class func canInit(with request: URLRequest) -> Bool {
            return true
        }

        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }

        override func startLoading() {
            if let requestObserver = Self.requestObserver {
                client?.urlProtocolDidFinishLoading(self)
                return requestObserver(request)
            }

            if let data = Self.stub?.data {
                client?.urlProtocol(self, didLoad: data)
            }

            if let response = Self.stub?.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }

            if let error = Self.stub?.error {
                client?.urlProtocol(self, didFailWithError: error)
            }

            client?.urlProtocolDidFinishLoading(self)
        }

        override func stopLoading() {}
    }
}
