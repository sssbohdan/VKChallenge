//
//  FeedItem.swift
//  BSVKDevChallenge
//
//  Created by bbb on 11/9/18.
//  Copyright © 2018 bbb. All rights reserved.
//

import Foundation

final class FeedItem: Decodable {
    enum CodingKeys: String, CodingKey {
        case type,
        sourceId = "source_id",
        ownerId = "owner_id",
        dateRaw = "date",
        postType = "post_type",
        text,
        attachments,
        likes = "likes",
        comments = "comments",
        reposts = "reposts",
        views = "views",
        count
    }
    
    let type: String?
    let sourceId: Int
    let dateRaw: TimeInterval
    let postType: String
    var text = ""
    var attachments = [Attachment]()
    var photos = [Photo]()
    lazy var date = Date()
    
    var likes: Int? = 0
    var comments: Int? = 0
    var reposts: Int? = 0
    var views: Int? = 0
    
    required convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try? container.decode(String.self, forKey: .type)
        let sourceId = try? container.decode(Int.self, forKey: .sourceId)
        let ownerId = try? container.decode(Int.self, forKey: .ownerId)
        let dateRaw = try container.decode(TimeInterval.self, forKey: .dateRaw)
        let postType = try container.decode(String.self, forKey: .postType)
        let text = try container.decode(String.self, forKey: .text)
        let attachments = try container.decodeIfPresent([Attachment].self, forKey: .attachments) ?? []
        
        let likes = try? container.nestedContainer(keyedBy: CodingKeys.self, forKey: .likes)
        let likesCount = try likes?.decodeIfPresent(Int.self, forKey: .count)
        
        let comments = try? container.nestedContainer(keyedBy: CodingKeys.self, forKey: .comments)
        let commentsCount = try comments?.decodeIfPresent(Int.self, forKey: .count)

        let reposts = try? container.nestedContainer(keyedBy: CodingKeys.self, forKey: .reposts)
        let repostsCount = try reposts?.decodeIfPresent(Int.self, forKey: .count)

        let views = try? container.nestedContainer(keyedBy: CodingKeys.self, forKey: .views)
        let viewsCount = try views?.decodeIfPresent(Int.self, forKey: .count)
        
        self.init(type: type, sourceId: sourceId ?? ownerId ?? 0, dateRaw: dateRaw, postType: postType, text: text, attachments: attachments,
                  likes: likesCount,
                  comments: commentsCount,
                  reposts: repostsCount,
                  views: viewsCount)
    }
    
    init(type: String?,
         sourceId: Int,
         dateRaw: TimeInterval,
         postType: String,
         text: String,
         attachments: [Attachment],
         likes: Int?,
         comments: Int?,
         reposts: Int?,
         views: Int?) {
        self.type = type
        self.sourceId = sourceId
        self.dateRaw = dateRaw
        self.postType = postType
        self.text = text
        self.attachments = attachments.filter { $0.photo != nil }
        
        self.likes = likes
        self.comments = comments
        self.reposts = reposts
        self.views = views
        self.date = Date(timeIntervalSince1970: dateRaw)
        
        if self.attachments.isEmpty {
            self.text = self.text.isEmpty
                ? "Unsupported attachments"
                : self.text
        }
        
        self.photos = self.attachments
            .compactMap { $0.photo }
    }
}
