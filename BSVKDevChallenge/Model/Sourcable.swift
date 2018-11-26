//
//  NameDescibable.swift
//  BSVKDevChallenge
//
//  Created by bbb on 11/10/18.
//  Copyright © 2018 bbb. All rights reserved.
//

import Foundation

protocol Sourcable: class {
    var fullName: String { get }
    var imageURLPath: String? { get }
}
