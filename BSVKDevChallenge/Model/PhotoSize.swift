//
//  PhotoSize.swift
//  BSVKDevChallenge
//
//  Created by bbb on 11/9/18.
//  Copyright © 2018 bbb. All rights reserved.
//

import UIKit

final class PhotoSize: Decodable {
    let type: String
    let url: String
    let width: Double
    let height: Double
    
    var size: CGSize {
        return CGSize(width: self.width, height: self.height)
    }
}
