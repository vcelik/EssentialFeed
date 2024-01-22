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
    let url:URL
    
    init(url:URL,client:HTTPClient){
        self.url=url
        self.client=client
    }
    
    func load(){
        client.get(from:url)
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
        let url=URL(string: "https://a-url.com")!
        let client=HTTPClientSpy()
        //HTTPClient.shared=client
        _ = RemoteFeedLoader(url:url,client:client)
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestDataFromURL(){
        let url=URL(string: "https://a-given-url.com")!
        let client=HTTPClientSpy()
        //HTTPClient.shared=client
        let sut=RemoteFeedLoader(url:url,client:client)
        
        sut.load()
        
        XCTAssertEqual(client.requestedURL,url)

    }
    
    

}
