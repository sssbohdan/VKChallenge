//
//  FeedRequest.swift
//  BSVKDevChallenge
//
//  Created by bbb on 11/9/18.
//  Copyright © 2018 bbb. All rights reserved.
//

import Foundation

struct FeedRequest: RequestConvertible {
    private let from: String
    private let amount = 50
    private var returnBanned = false
    
    var path: String {
        return "/method/newsfeed.get"
    }
    
    init(from: String, returnBanned: Bool = false) {
        self.from = from
        self.returnBanned = returnBanned
    }
    
    func request() -> URLRequest {
        var components = self.components
        components.queryItems?.append(URLQueryItem(name: "filters", value: "post"))
        components.queryItems?.append(URLQueryItem(name: "return_banned", value: self.returnBanned ? "1" : "0"))
        components.queryItems?.append(URLQueryItem(name: "count", value: "\(self.amount)"))
        components.queryItems?.append(URLQueryItem(name: "start_from", value: self.from))
        
        let url = components.url!
        
        return URLRequest(url: url)
    }
}
