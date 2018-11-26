//
//  Feeds.swift
//  BSVKDevChallenge
//
//  Created by bbb on 11/9/18.
//  Copyright © 2018 bbb. All rights reserved.
//

import Foundation

final class Feeds: Decodable {
    enum CodingKeys: String, CodingKey {
        case items,
        groups,
        profiles,
        nextFrom = "next_from",
        totalCount = "total_count"
    }
    
    var items = [FeedItem]()
    var groups = [Group]()
    var profiles = [User]()
    var nextFrom: String?
    var totalCount: Int?
    
    init(items: [FeedItem], groups: [Group], profiles: [User], nextFrom: String?, totalCount: Int?) {
        self.items = items
        self.groups = groups
        self.profiles = profiles
        self.nextFrom = nextFrom
        self.totalCount = totalCount
    }
    
    required convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let items = try container.decode([FeedItem].self, forKey: .items)
        let groups = try container.decode([Group].self, forKey: .groups)
        let profiles = try container.decode([User].self, forKey: .profiles)
        let nextFrom = try? container.decode(String.self, forKey: .nextFrom)
        let totalCount = try? container.decode(Int.self, forKey: .totalCount)
        
        self.init(items: items, groups: groups, profiles: profiles, nextFrom: nextFrom, totalCount: totalCount)
    }
}
