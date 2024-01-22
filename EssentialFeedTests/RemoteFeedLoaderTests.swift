//
//  EssentialFeedTests.swift
//  EssentialFeedTests
//
//  Created by Volkan Celik on 15/01/2024.
//

import XCTest
import EssentialFeed


final class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL(){
        //HTTPClient.shared=client
        let (_,client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestsDataFromURL(){
        let url=URL(string: "https://a-given-url.com")!
        //HTTPClient.shared=client
        let (sut,client)=makeSUT(url:url)
        
        sut.load{_ in}
        
        XCTAssertEqual(client.requestedURLs,[url])
    }
    
    func test_loadTwice_requestsDataFromURLTwice(){
        let url=URL(string: "https://a-given-url.com")!
        //HTTPClient.shared=client
        let (sut,client)=makeSUT(url:url)
        
        sut.load{_ in}
        sut.load{_ in}
        
        //XCTAssertEqual(client.requestedURLCallCount,2)
        XCTAssertEqual(client.requestedURLs,[url,url])
    }
    
    func test_load_deliversErrorOnClientError(){
        let (sut,client)=makeSUT()  //Arange
        
        var capturedErrors=[RemoteFeedLoader.Error]()  //Act
        sut.load{
            capturedErrors.append($0)
        }
        
        let clientError=NSError(domain: "Test", code: 0)
        client.complete(with: clientError)
        //client.completions[0](clientError)             //Act  //completion happens after u invoke load
        
        XCTAssertEqual(capturedErrors, [.connectivity])
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse(){
        let (sut,client)=makeSUT()  //Arange
        
        var capturedErrors=[RemoteFeedLoader.Error]()  //Act
        sut.load{
            capturedErrors.append($0)
        }
        
        client.complete(withStatusCode: 400)
        //client.completions[0](clientError)             //Act  //completion happens after u invoke load
        
        XCTAssertEqual(capturedErrors, [.invalidData])
    }
    
    //MARK: - Helpers
    
    private func makeSUT(url:URL=URL(string: "https://a-url.com")!)->(sut:RemoteFeedLoader,client:HTTPClientSpy){
        let client=HTTPClientSpy()
        let sut=RemoteFeedLoader(url: url, client: client)
        return (sut,client)
    }
    
    private class HTTPClientSpy:HTTPClient{
        
        //var requestedURL:URL?
        //var requestedURLCallCount=0
        //var error:Error?
        //var completions=[(Error)->Void]()
        
        var requestedURLs:[URL]{
            messages.map{$0.url}
        }
        
        private var messages=[(url:URL,completion:(Error?,HTTPURLResponse?) -> Void)]()
        func get(from url: URL, completion: @escaping (Error?,HTTPURLResponse?) -> Void) {
            messages.append((url,completion))
            //completions.append(completion)
            //requestedURLs.append(url)
        }
        
        func complete(with error:Error,at index:Int=0){
            messages[index].completion(error,nil)
        }
        
        func complete(withStatusCode code:Int,at index:Int=0){
            let response=HTTPURLResponse(
                url: requestedURLs[index],
                statusCode: code,
                httpVersion: nil,
                headerFields: nil
            )
            messages[index].completion(nil,response)
        }
    }
    
    

}
