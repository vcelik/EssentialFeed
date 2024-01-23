//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Volkan Celik on 23/01/2024.
//

import XCTest
import EssentialFeed

//protocol HTTPSession{    //abstractions for the tests not for the outside
//    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPSessionTask
//}
//
//protocol HTTPSessionTask{
//    func resume()
//}

class URLSessionHTTPClient{
    private let session:URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func get(from url:URL,completion:@escaping(HTTPClientResult)->Void){
        session.dataTask(with: url) { _, _, error in
            if let error=error{
                completion(.failure(error))
            }
        }.resume()
    }
}

final class URLSessionHTTPClientTests: XCTestCase {
    
//    func test_getfromURL_createsDataTaskWithURL(){
//        let url=URL(string: "http://any-url.com")!
//        let session=URLSessionSpy()
//        let sut=URLSessionHTTPClient(session:session)
//        
//        sut.get(from:url)
//        
//        XCTAssertEqual(session.receivedURLs, [url])
//    }
    
//    func test_getfromURL_resumesDataTaskWithURL(){
//        let url=URL(string: "http://any-url.com")!
//        //let session=HTTPSessionSpy()
//        //let task=URLSessionDataTaskSpy()
//        //session.stub(url:url,task:task)
//
//        let sut=URLSessionHTTPClient()
//        
//        sut.get(from:url){_ in}
//        
//        XCTAssertEqual(task.resumeCallCount, 1)
//    }
    
    func test_getFromURL_failsOnRequestError(){
        URLProtocolStub.startInterceptingRequests()
        let url=URL(string: "http://any-url.com")!
        let error=NSError(domain: "any error", code: 1)
        //let session=HTTPSessionSpy()
        //let task=URLSessionDataTaskSpy()
        URLProtocolStub.stub(url:url,error:error)
        
        let sut=URLSessionHTTPClient()
        
        let exp=expectation(description: "Wait for completion")
        sut.get(from:url){result in
            switch result {
            case let .failure(receivedError as NSError):
                XCTAssertEqual(receivedError, error)
            default:
                XCTFail("Expected failure with error \(error),got \(result) instead")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        URLProtocolStub.stopInterceptingRequests()
    }
    
    //MARK: - Helpers
    
    private class URLProtocolStub:URLProtocol{
        //var receivedURLs=[URL]()
        private static var stubs=[URL:Stub]()
        
        private struct Stub{
            //let task:HTTPSessionTask
            let error:Error?
        }
        
//        func stub(url:URL,task:HTTPSessionTask=FakeURLSessionDataTask(),error:Error?=nil){
//            stubs[url]=Stub(task: task, error: error)
//        }
        
        static func stub(url:URL,error:Error?=nil){
            stubs[url]=Stub(error: error)
        }
        
        static func startInterceptingRequests(){
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequests(){
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stubs=[:]
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            // if we return True, we can handle this request
            //we will instantiate the class,if only we can handle the request
            guard let url=request.url else {return false}  //we cannot handle it
            return stubs[url] != nil
            
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            //instance method->we are gonna handle this request
            guard let url=request.url,let stub=URLProtocolStub.stubs[url] else {return}
            
            if let error=stub.error{
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {
            //if we dont implement it,we will get a crash at runtime
        }
        
//        func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPSessionTask {
//            //receivedURLs.append(url)
//            guard let stub=stubs[url] else {
//                fatalError("Couldnt find stub for \(url)")
//            }
//            completionHandler(nil,nil,stub.error)
//            return stub.task
//        }
    }
    
//    private class FakeURLSessionDataTask:HTTPSessionTask{
//        func resume() {
//        }
//    }
//    
//    private class URLSessionDataTaskSpy:HTTPSessionTask{
//        var resumeCallCount=0
//        
//        func resume() {
//            resumeCallCount+=1
//        }
//    }



}
