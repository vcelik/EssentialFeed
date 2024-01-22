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
        HTTPClient.shared.get(from:URL(string: "https://a-url.com")!)
    }
}

class HTTPClient{
    
    static var shared=HTTPClient()
    //private init(){}
    
    func get(from url:URL){}

}

class HTTPClientSpy:HTTPClient{
    
    var requestedURL:URL?
    
    override func get(from url:URL) {
        requestedURL=url
    }
}

final class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL(){
        let client=HTTPClientSpy()
        HTTPClient.shared=client
        _ = RemoteFeedLoader()
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestDataFromURL(){
        let client=HTTPClientSpy()
        HTTPClient.shared=client
        let sut=RemoteFeedLoader()
        
        sut.load()
        
        XCTAssertNotNil(client.requestedURL)

    }
    
    

}
