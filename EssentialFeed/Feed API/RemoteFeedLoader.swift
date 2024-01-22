//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Volkan Celik on 22/01/2024.
//

import Foundation

public protocol HTTPClient{
    
    //static var shared=HTTPClient()
    //private init(){}
    
    func get(from url:URL)

}

public final class RemoteFeedLoader{
    
    private let url:URL
    private let client:HTTPClient

    
    public init(url:URL,client:HTTPClient){
        self.url=url
        self.client=client
    }
    
    public func load(){
        client.get(from:url)
    }
}
