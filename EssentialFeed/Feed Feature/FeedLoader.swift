//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Volkan Celik on 15/01/2024.
//

import Foundation

public enum LoadFeedResult{
    case success([FeedItem])
    case failure(Error)
}

//extension LoadFeedResult:Equatable where Error:Equatable{
//    
//}

public protocol FeedLoader{
    //associatedtype Error:Swift.Error
    func load(completion:@escaping(LoadFeedResult)->Void)
}
