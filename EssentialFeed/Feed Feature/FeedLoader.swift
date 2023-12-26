//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Volkan Celik on 26/12/2023.
//

import Foundation

enum LoadFeedResult{
    case success([FeedItem])
    case error(Error)
}

protocol FeedLoader{
    func load(completion:@escaping (LoadFeedResult)->Void)
}
