//
//  EssentialFeedTests.swift
//  EssentialFeedTests
//
//  Created by Volkan Celik on 15/01/2024.
//

import XCTest
@testable import EssentialFeed

class RemoteFeedLoader{
    func load(){
        HTTPClient.shared.requestedURL=URL(string: "https://a-url.com")
    }
}

class HTTPClient{
    static let shared=HTTPClient()
    private init(){}
    var requestedURL:URL?
}

final class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL(){
        let client=HTTPClient.shared
        _ = RemoteFeedLoader()
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestDataFromURL(){
        let client=HTTPClient.shared
        let sut=RemoteFeedLoader()
        
        sut.load()
        
        XCTAssertNotNil(client.requestedURL)

    }
    
    

}
