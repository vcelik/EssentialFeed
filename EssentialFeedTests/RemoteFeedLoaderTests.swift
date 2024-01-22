//
//  EssentialFeedTests.swift
//  EssentialFeedTests
//
//  Created by Volkan Celik on 15/01/2024.
//

import XCTest
@testable import EssentialFeed

class RemoteFeedLoader{
    
    let client:HTTPClient
    
    init(client:HTTPClient){
        self.client=client
    }
    
    func load(){
        client.get(from:URL(string: "https://a-url.com")!)
    }
}

protocol HTTPClient{
    
    //static var shared=HTTPClient()
    //private init(){}
    
    func get(from url:URL)

}

class HTTPClientSpy:HTTPClient{
    
    var requestedURL:URL?
    
    func get(from url:URL) {
        requestedURL=url
    }
}

final class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL(){
        let client=HTTPClientSpy()
        //HTTPClient.shared=client
        _ = RemoteFeedLoader(client:client)
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestDataFromURL(){
        let client=HTTPClientSpy()
        //HTTPClient.shared=client
        let sut=RemoteFeedLoader(client:client)
        
        sut.load()
        
        XCTAssertNotNil(client.requestedURL)

    }
    
    

}
