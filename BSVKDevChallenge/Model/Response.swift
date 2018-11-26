//
//  Responso.swift
//  BSVKDevChallenge
//
//  Created by bbb on 11/10/18.
//  Copyright © 2018 bbb. All rights reserved.
//

import Foundation

final class Response<T: Decodable>: Decodable {
    var response: T?
}
