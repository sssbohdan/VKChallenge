//
//  SearchFeed.swift
//  BSVKDevChallenge
//
//  Created by bbb on 11/10/18.
//  Copyright © 2018 bbb. All rights reserved.
//

import Foundation

final class SearchFeedStrategy: FeedStrategy {
    private let query: String
    
    init(networkManager: NetworkManager, query: String) {
        self.query = query
        super.init(networkManager: networkManager)
    }
    
    override var requireFeedLoading: Bool { return true }
    
    override func loadFeed(success: ((Feeds) -> Void)?, failure: ((Error?) -> Void)?) {
        guard let from = self.nextFrom else {
            return
        }
        
        self.networkManager.feedSearch(query: self.query, from: from, success: { [weak self] feeds in
            guard let `self` = self else { return }
            
            self.update(with: feeds)
            success?(feeds)
        }, failure: failure)
    }
}
