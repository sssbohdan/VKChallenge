//
//  DataLoader.swift
//  BSVKDevChallenge
//
//  Created by bbb on 11/9/18.
//  Copyright © 2018 bbb. All rights reserved.
//

import Foundation

enum LoadingError: Swift.Error {
    case unknown
}

protocol DataLoader {
    @discardableResult
    func loadData(urlRequest: RequestConvertible, success: @escaping ((Data) -> Void), failure: ((Error?) -> Void)?) -> Cancelable
}

final class DataLoaderImpl: DataLoader {
    private let urlSession: URLSession
    
    init(urlSession: URLSession) {
        self.urlSession = urlSession
    }
    
    @discardableResult
    func loadData(urlRequest: RequestConvertible, success: @escaping ((Data) -> Void), failure: ((Error?) -> Void)?) -> Cancelable {
        let dataTask = self.urlSession.dataTask(with: urlRequest.request()) { data, response, error in
            if let error = error {
                failure?(error)
            } else if let data = data {
                success(data)
            } else {
                failure?(LoadingError.unknown)
            }
        }
        
        dataTask.resume()
        
        return dataTask
    }
}

protocol Cancelable {
    func cancel()
}

extension URLSessionTask: Cancelable { }
