//
//  UserRequest.swift
//  BSVKDevChallenge
//
//  Created by bbb on 11/10/18.
//  Copyright © 2018 bbb. All rights reserved.
//

import Foundation

struct UserRequest: RequestConvertible {
    var path: String {
        return "/method/users.get"
    }
    let userId: Int
    
    func request() -> URLRequest {
        var components = self.components
        components.queryItems?.append(URLQueryItem(name: "fields", value: "photo_50,verified"))
        components.queryItems?.append(URLQueryItem(name: "user_ids", value: "\(self.userId)"))
        components.queryItems?.append(URLQueryItem(name: "name_case", value: "Nom"))

        let url = components.url!
        
        return URLRequest(url: url)
    }
}
