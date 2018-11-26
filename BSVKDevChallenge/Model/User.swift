//
//  User.swift
//  BSVKDevChallenge
//
//  Created by bbb on 11/10/18.
//  Copyright © 2018 bbb. All rights reserved.
//

import Foundation

final class User: Decodable, Sourcable {
    enum CodingKeys: String, CodingKey {
        case id,
        firstName = "first_name",
        lastName = "last_name",
        photo50 = "photo_50"
    }
    
    let id: Int
    let firstName: String
    let lastName: String
    var photo50: String?
    
    var fullName: String {
        return (self.firstName.isEmpty ? "" : "\(self.firstName) ") + self.lastName
    }
    
    var imageURLPath: String? {
        return self.photo50
    }
}

extension User: Hashable {
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }
    
    var hashValue: Int {
        return self.id.hashValue
    }
}
