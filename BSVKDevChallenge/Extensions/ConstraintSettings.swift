//
//  ConstraintsSettings.swift
//  GetGrub
//
//  Created by Bohdan Savych on 12/7/17.
//  Copyright © 2017 ROLIQUE. All rights reserved.
//

import UIKit

final class ConstraintsSettings {
    private(set) var left: CGFloat?
    private(set) var right: CGFloat?
    private(set) var top: CGFloat?
    private(set) var bottom: CGFloat?
    private(set) var centerX: CGFloat?
    private(set) var centerY: CGFloat?
    private(set) var width: CGFloat?
    private(set) var height: CGFloat?
    
    convenience init(edgeInsets: UIEdgeInsets = .zero) {
        self.init(left: edgeInsets.left, right: edgeInsets.right, top: edgeInsets.top, bottom: edgeInsets.bottom)
    }
    
    init(width: CGFloat? = nil, height: CGFloat? = nil, left: CGFloat? = nil, right: CGFloat? = nil, top: CGFloat? = nil, bottom: CGFloat? = nil, centerX: CGFloat? = nil, centerY: CGFloat? = nil) {
        self.left = left
        self.right = right
        self.top = top
        self.bottom = bottom
        self.width = width
        self.height = height
        self.centerX = centerX
        self.centerY = centerY
    }
    
    static var zero: ConstraintsSettings {
        return ConstraintsSettings(edgeInsets: .zero)
    }
}

extension UIView {
    typealias FormatFunction = (String) -> Void
    func getAddConstraintFunction(dict: [String: UIView]) -> FormatFunction {
        return { self.addVisualConstraint(format: $0, dict: dict) }
    }
    
    func addSubview(_ subview: UIView, with constraintsSettings: ConstraintsSettings) {
        subview.translatesAutoresizingMaskIntoConstraints = false
        addSubview(subview)
        let dict = ["v": subview]
        let formats = [constraintsSettings.bottom
            .map { "V:[v]-" + "\($0)" + "-|" },
                       constraintsSettings.top
                        .map { "V:|-" + "\($0)" + "-[v]" },
                       constraintsSettings.right
                        .map { "H:[v]-" + "\($0)" + "-|" },
                       constraintsSettings.left
                        .map { "H:|-" + "\($0)" + "-[v]" }
        ]
        let addConstraintFunction = getAddConstraintFunction(dict: dict)
        formats.compactMap(id).forEach(addConstraintFunction)
        
        constraintsSettings.height.map {
            addConstraint(NSLayoutConstraint(item: subview, attribute: .height,
                                             relatedBy: .equal, toItem: nil, attribute: .notAnAttribute,
                                             multiplier: 1, constant: $0))
        }
        
        constraintsSettings.width.map {
            addConstraint(NSLayoutConstraint(item: subview, attribute: .width,
                                             relatedBy: .equal, toItem: nil, attribute: .notAnAttribute,
                                             multiplier: 1, constant: $0))
        }
        
        constraintsSettings.centerY.map {
            addConstraint(NSLayoutConstraint(item: subview, attribute: .centerY,
                                             relatedBy: .equal, toItem: self, attribute: .centerY,
                                             multiplier: 1, constant: $0))
        }
        
        constraintsSettings.centerX.map {
            addConstraint(NSLayoutConstraint(item: subview, attribute: .centerX,
                                             relatedBy: .equal, toItem: self, attribute: .centerX,
                                             multiplier: 1, constant: $0))
        }
    }
    
    private func addVisualConstraint(format: String, dict: [String: UIView]) {
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: [], metrics: nil, views: dict))
    }
}

