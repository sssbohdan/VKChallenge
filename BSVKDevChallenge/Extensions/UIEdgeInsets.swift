//
//  UIEdgeInsets.swift
//  BSVKDevChallenge
//
//  Created by bbb on 11/9/18.
//  Copyright © 2018 bbb. All rights reserved.
//

import UIKit

extension UIEdgeInsets {
    var horizontal: CGFloat {
        return top + bottom
    }
    
    var vertical: CGFloat {
        return left + right
    }
    
    init(side: CGFloat) {
        self.init(top: side, left: side, bottom: side, right: side)
    }
}
