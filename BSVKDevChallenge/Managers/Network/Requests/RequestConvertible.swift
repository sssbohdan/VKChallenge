//
//  RequestConvertible.swift
//  BSVKDevChallenge
//
//  Created by bbb on 11/9/18.
//  Copyright © 2018 bbb. All rights reserved.
//

import Foundation

protocol RequestConvertible {
    var scheme: String { get }
    var host: String { get }
    var path: String { get }
    
    func request() -> URLRequest
}

extension RequestConvertible {
    var scheme: String {
        return "https"
    }
    var host: String {
        return "api.vk.com"
    }
    var path: String {
        return "method/"
    }
    
    var components: URLComponents {
        var urlComponents = URLComponents()
        
        urlComponents.scheme = scheme
        urlComponents.host = host
        urlComponents.path = path
        urlComponents.queryItems = [URLQueryItem(name: "access_token", value: VKSDKManager.shared.accessToken),
                                    URLQueryItem(name: "v", value: GlobalConstants.VK.apiVersion)]
        
        return urlComponents
    }
    
    func request() -> URLRequest {
        let url = components.url!
        
        return URLRequest(url: url)
    }
}
