//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Volkan Celik on 15/01/2024.
//

import Foundation

enum LoadFeedResult{
    case success([FeedItem])
    case failure
}
protocol FeedLoader{
    func load(completion:@escaping(LoadFeedResult)->Void)
}
