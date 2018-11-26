//
//  FeedSearchRequst.swift
//  BSVKDevChallenge
//
//  Created by bbb on 11/10/18.
//  Copyright © 2018 bbb. All rights reserved.
//

import Foundation

struct FeedSearchRequest: RequestConvertible {
    var path: String {
        return "/method/newsfeed.search"
    }
    
    let query: String
    private let count = 20
    let from: String
    
    func request() -> URLRequest {
        var components = self.components
        components.queryItems?.append(URLQueryItem(name: "extended", value: "1"))
        components.queryItems?.append(URLQueryItem(name: "q", value: self.query))
        components.queryItems?.append(URLQueryItem(name: "count", value: "\(self.count)"))
        components.queryItems?.append(URLQueryItem(name: "start_from", value: self.from))
        let url = components.url!
        
        return URLRequest(url: url)
    }
}
