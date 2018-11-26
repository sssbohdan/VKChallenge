//
//  NetworkManager.swift
//  BSVKDevChallenge
//
//  Created by bbb on 11/10/18.
//  Copyright © 2018 bbb. All rights reserved.
//

import Foundation

protocol NetworkManager {
    @discardableResult func loadUser(id: Int, success: ((User) -> Void)?, failure: ((Error?) -> Void)?) -> Cancelable
    @discardableResult func loadFeed(from: String, success: ((Feeds) -> Void)?, failure: ((Error?) -> Void)?) -> Cancelable
    @discardableResult func feedSearch(query: String, from: String, success: ((Feeds) -> Void)?, failure: ((Error?) -> Void)?) -> Cancelable
}

final class NetworkManagerImpl: NetworkManager {
    private let dataLoader: DataLoader
    private let decoder = JSONDecoder()
    
    init(dataLoader: DataLoader) {
        self.dataLoader = dataLoader
    }
    
    @discardableResult
    func loadUser(id: Int, success: ((User) -> Void)?, failure: ((Error?) -> Void)?) -> Cancelable {
        let userRequest = UserRequest(userId: id)
        let cancelable = self.dataLoader.loadData(urlRequest: userRequest,
                                                  success: { data in
                                                    do {
                                                        let response = try self.decoder.decode(Response<[User]>.self, from: data)
                                                        guard let user = response.response?.first else {
                                                            failure?(nil)
                                                            return
                                                        }
                                                        success?(user)
                                                    } catch let error {
                                                        print(error.localizedDescription)
                                                        failure?(error)
                                                    }
        },
                                                  failure: failure)
        
        return cancelable
    }
    
    @discardableResult
    func loadFeed(from: String, success: ((Feeds) -> Void)?, failure: ((Error?) -> Void)?) -> Cancelable {
        let feedRequest = FeedRequest(from: from)
        let feedsSuccessFunction = self.produceDataToFeedsFunction(success: success, failure: failure)
        let cancelable = self.dataLoader.loadData(urlRequest: feedRequest,
                                                  success: feedsSuccessFunction,
                                                  failure: failure)
        
        return cancelable
    }
    
    @discardableResult
    func feedSearch(query: String, from: String, success: ((Feeds) -> Void)?, failure: ((Error?) -> Void)?) -> Cancelable {
        let searchRequest = FeedSearchRequest(query: query, from: from)
        let feedsSuccessFunction = self.produceDataToFeedsFunction(success: success, failure: failure)
        return self.dataLoader.loadData(urlRequest: searchRequest, success: feedsSuccessFunction, failure: failure)
    }
}

// MARK: - Private
private extension NetworkManagerImpl {
    func produceDataToFeedsFunction(success: ((Feeds) -> Void)?, failure: ((Error?) -> Void)?) -> ((Data) -> Void) {
        return {
            self.convertDataToFeeds(data: $0, success: success, failure: failure)
        }
    }
    
    func convertDataToFeeds(data: Data, success: ((Feeds) -> Void)?, failure: ((Error?) -> Void)?) {
        do {
            let response = try self.decoder.decode(Response<Feeds>.self, from: data)
            guard let feeds = response.response else {
                failure?(nil)
                return
            }
            success?(feeds)
        } catch let error {
            print(error.localizedDescription)
            failure?(error)
        }
    }
}
