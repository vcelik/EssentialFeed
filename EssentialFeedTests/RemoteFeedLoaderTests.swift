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
        
        expect(sut, toCompleteWith: .failure(.connectivity)) {
            let clientError=NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
            //client.completions[0](clientError)             //Act  //completion happens after u invoke load
        }
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse(){
        let (sut,client)=makeSUT()  //Arange
        let samples=[199,201,300,400,500].enumerated()
        samples.forEach { index,code in
            expect(sut, toCompleteWith: .failure(.invalidData)) {
                let json=makeItemsJSON([])
                client.complete(withStatusCode: code,data:json,at:index)
            }
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON(){
        let (sut,client)=makeSUT()
        
        expect(sut, toCompleteWith: .failure(.invalidData)) {
            let invalidJSON=Data(bytes: "invalid json".utf8)
            client.complete(withStatusCode: 200,data:invalidJSON)
        }
    }
    
    func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSONList(){
        let (sut,client)=makeSUT()
        
        
        expect(sut, toCompleteWith: .success([])) {
            let emptyListJSON=makeItemsJSON([])
            client.complete(withStatusCode: 200,data:emptyListJSON)
        }
    }
    
    func test_load_deliversItemson200HTTPResponseWithJSONItems(){
        let (sut,client)=makeSUT()
        
        let item1=makeItem(
            id: UUID(),
            imageURL: URL(string: "http://a-url.com")!
        )
        
        
        let item2=makeItem(
            id: UUID(),
            description: "a description",
            location: "a location",
            imageURL: URL(string:"http://another-url.com")!
        )
        
        let items=[item1.model,item2.model]
        
        expect(sut, toCompleteWith: .success(items)) {
            let json=makeItemsJSON([item1.json,item2.json])
            client.complete(withStatusCode: 200,data: json)
        }
    }
    
    
    //MARK: - Helpers
    
    private func makeSUT(url:URL=URL(string: "https://a-url.com")!,file:StaticString=#file,line:UInt=#line)->(sut:RemoteFeedLoader,client:HTTPClientSpy){
        let client=HTTPClientSpy()
        let sut=RemoteFeedLoader(url: url, client: client)
        trackForMemoryLeaks(sut)
        trackForMemoryLeaks(client)
        return (sut,client)
    }
    
    private func trackForMemoryLeaks(_ instance:AnyObject,file:StaticString=#file,line:UInt=#line){
        addTeardownBlock { [weak instance] in     //when every test finishes tear down block runs
            XCTAssertNil(instance,"Instance should have been deallocated.Potential memory leak",file:file,line:line)
        }
    }
    
    private func makeItem(id:UUID,description:String?=nil,location:String?=nil,imageURL:URL)->(model:FeedItem,json:[String:Any]){
        let item=FeedItem(id: id, description: description, location: location, imageURL: imageURL)
        let json=[
            "id":id.uuidString,
            "description":description,
            "location":location,
            "image":imageURL.absoluteString
        ].reduce(into: [String:Any]()) { acc, e in
            if let value=e.value{
                acc[e.key]=value
            }
        }
        
        return (item,json)
    }
    
    private func makeItemsJSON(_ items:[[String:Any]])->Data{
        let json=["items":items]
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    private func expect(_ sut:RemoteFeedLoader,toCompleteWith result:RemoteFeedLoader.Result,when action:()->Void,file:StaticString=#file,line:UInt=#line){
        var capturedResults=[RemoteFeedLoader.Result]()
        sut.load{
            capturedResults.append($0)
        }
        action()
        XCTAssertEqual(capturedResults, [result],file: file,line: line)
    }
    
    private class HTTPClientSpy:HTTPClient{
        
        //var requestedURL:URL?
        //var requestedURLCallCount=0
        //var error:Error?
        //var completions=[(Error)->Void]()
        
        var requestedURLs:[URL]{
            messages.map{$0.url}
        }
        
        private var messages=[(url:URL,completion:(HTTPClientResult) -> Void)]()
        func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
            messages.append((url,completion))
            //completions.append(completion)
            //requestedURLs.append(url)
        }
        
        func complete(with error:Error,at index:Int=0){
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code:Int,data:Data,at index:Int=0){
            let response=HTTPURLResponse(
                url: requestedURLs[index],
                statusCode: code,
                httpVersion: nil,
                headerFields: nil
            )!
            messages[index].completion(.success(data,response))
        }
    }
    
    

}
