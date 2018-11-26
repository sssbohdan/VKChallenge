//
//  NSAttributedString.swift
//  BSVKDevChallenge
//
//  Created by bbb on 11/9/18.
//  Copyright © 2018 bbb. All rights reserved.
//

import UIKit

extension NSAttributedString {
    convenience init(base: String,
                     keyWords: [String],
                     foregroundColor: UIColor,
                     font: UIFont,
                     highlightForeground: UIColor,
                     highlighBackground: UIColor) {
        let baseAttributed = NSMutableAttributedString(string: base, attributes: [NSAttributedString.Key.font: font,
                                                                                  NSAttributedString.Key.foregroundColor: foregroundColor])
        let range = NSRange(location: 0, length: base.utf16.count)
        for word in keyWords {
            guard let regex = try? NSRegularExpression(pattern: word, options: .caseInsensitive) else {
                continue
            }
            
            regex
                .matches(in: base, options: .withTransparentBounds, range: range)
                .forEach { baseAttributed
                    .addAttributes([NSAttributedString.Key.backgroundColor: highlighBackground,
                                    NSAttributedString.Key.foregroundColor: highlightForeground],
                                   range: $0.range) }
        }
        self.init(attributedString: baseAttributed)
    }
}
