//
//  Photo.swift
//  BSVKDevChallenge
//
//  Created by bbb on 11/9/18.
//  Copyright © 2018 bbb. All rights reserved.
//

import Foundation

final class Photo: Decodable {
    enum CodingKeys: String, CodingKey {
        case id,
        userId = "user_id",
        ownerId = "owner_id",
        sizes
    }
    
    let id: Int
    let userId: Int?
    let ownerId: Int
    var sizes = [PhotoSize]()
    var averageSize: PhotoSize?
    
    required convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(Int.self, forKey: .id)
        let userId = try container.decodeIfPresent(Int.self, forKey: .userId)
        let ownerId = try container.decode(Int.self, forKey: .ownerId)
        let sizes = try container.decode([PhotoSize].self, forKey: .sizes)
        self.init(id: id, userId: userId, ownerId: ownerId, sizes: sizes)
    }
    
    init(id: Int, userId: Int?, ownerId: Int, sizes: [PhotoSize]) {
        self.id = id
        self.userId = userId
        self.ownerId = ownerId
        self.sizes = sizes
        let sortedSizes = sizes.sorted(by: { size1, size2 in
            return size1.width < size2.width && size1.height < size2.height
        })
//        let avg = Int(Double(sortedSizes.count) / 2)
//        self.averageSize = sortedSizes[safe: avg]
        self.averageSize = sortedSizes.last
    }
}
