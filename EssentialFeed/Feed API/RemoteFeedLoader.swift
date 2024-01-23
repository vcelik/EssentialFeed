//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Volkan Celik on 22/01/2024.
//

import Foundation


public final class RemoteFeedLoader{
    
    private let url:URL
    private let client:HTTPClient

    public enum Error:Swift.Error{
        case connectivity
        case invalidData
    }
    
    public enum Result:Equatable{
        case success([FeedItem])
        case failure(Error)
    }
    
    public init(url:URL,client:HTTPClient){
        self.url=url
        self.client=client
    }
    
    public func load(completion:@escaping(Result)->Void){
        client.get(from: url) { [weak self] result in    //after sut has been deallocated now captured results can be empty
            //guard let self=self else {return}    if it was deallocated,the last part wasnt going to be executed
            guard self != nil else {return}
            switch result{
            case let .success(data,response):
                completion(FeedItemsMapper.map(data, from: response))
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
}



