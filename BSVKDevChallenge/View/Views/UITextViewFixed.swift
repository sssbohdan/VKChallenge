//
//  UITextViewFixed.swift
//  BSVKDevChallenge
//
//  Created by bbb on 11/10/18.
//  Copyright © 2018 bbb. All rights reserved.
//

import UIKit

@IBDesignable class UITextViewFixed: UITextView {
    override func layoutSubviews() {
        super.layoutSubviews()
        self.setup()
    }
    
    func setup() {
        textContainerInset = UIEdgeInsets.zero
        textContainer.lineFragmentPadding = 0
    }
}
