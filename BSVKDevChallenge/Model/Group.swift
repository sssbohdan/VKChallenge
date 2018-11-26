//
//  Group.swift
//  BSVKDevChallenge
//
//  Created by bbb on 11/9/18.
//  Copyright © 2018 bbb. All rights reserved.
//

import Foundation

final class Group: Decodable, Sourcable {
    enum CodingKeys: String, CodingKey {
        case id,
        name,
        photo50URLString = "photo_50",
        photo100URLString = "photo_100",
        photo200URLString = "photo_200"
    }
    
    let id: Int
    let name: String
    let photo50URLString: String?
    let photo100URLString: String?
    let photo200URLString: String?
    var fullName: String { return name }
    var imageURLPath: String? { return photo50URLString }

    
    init(id: Int, name: String, photo50URLString: String?, photo100URLString: String?, photo200URLString: String?) {
        self.id = id
        self.name = name
        self.photo50URLString = photo50URLString
        self.photo100URLString = photo100URLString
        self.photo200URLString = photo200URLString
    }
    
    required convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(Int.self, forKey: .id)
        let name = try container.decode(String.self, forKey: .name)
        let photo50URLString = try? container.decode(String.self, forKey: .photo50URLString)
        let photo100URLString = try? container.decode(String.self, forKey: .photo100URLString)
        let photo200URLString = try? container.decode(String.self, forKey: .photo200URLString)

        
        self.init(id: id, name: name, photo50URLString: photo50URLString, photo100URLString: photo100URLString, photo200URLString: photo200URLString)
    }
}

extension Group: Hashable {
    var hashValue: Int {
        return self.id.hashValue
    }
    
    static func == (lhs: Group, rhs: Group) -> Bool {
        return lhs.id == rhs.id
    }
}
