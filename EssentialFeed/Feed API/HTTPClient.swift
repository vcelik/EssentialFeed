//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Volkan Celik on 22/01/2024.
//

import Foundation

public enum HTTPClientResult{
    case success(Data,HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient{
    
    //static var shared=HTTPClient()
    //private init(){}
    
    func get(from url:URL,completion:@escaping(HTTPClientResult)->Void)
}
