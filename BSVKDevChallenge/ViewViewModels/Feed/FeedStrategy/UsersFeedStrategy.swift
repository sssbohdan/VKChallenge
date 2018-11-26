//
//  UsersFeed.swift
//  BSVKDevChallenge
//
//  Created by bbb on 11/10/18.
//  Copyright © 2018 bbb. All rights reserved.
//

import Foundation

final class UsersFeedStrategy: FeedStrategy {
    override func loadFeed(success: ((Feeds) -> Void)?, failure: ((Error?) -> Void)?) {
        guard let from = self.nextFrom else {
            return
        }
        
        self.networkManager.loadFeed(from: from,
                                     success: { [weak self] feeds in
                                        guard let `self` = self else { return }
                                        
                                        self.update(with: feeds)
                                        success?(feeds)
        },
                                     failure: failure)
    }
}
