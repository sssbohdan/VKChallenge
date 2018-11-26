//
//  FeedStrategy.swift
//  BSVKDevChallenge
//
//  Created by bbb on 11/10/18.
//  Copyright © 2018 bbb. All rights reserved.
//

import Foundation

/// - warning: Abstract - don't create instance of this class.
class FeedStrategy {
    let networkManager: NetworkManager
    lazy var nextFrom: String? = "0"
    var totalCount: Int?
    lazy var feedItems = [FeedItem]()
    
    var requireFeedLoading: Bool { return false }
    
    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
    }
    
    func loadFeed(success: ((Feeds) -> Void)?, failure: ((Error?) -> Void)?) {}
    
    func update(with feeds: Feeds) {
        self.totalCount = feeds.totalCount
        self.nextFrom = feeds.nextFrom
        self.feedItems.append(contentsOf: feeds.items)
    }
}
