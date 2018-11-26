//
//  UIColor.swift
//  Rolique
//
//  Created by Bohdan Savych on 8/16/17.
//  Copyright © 2017 Rolique. All rights reserved.
//

import UIKit

//https://flatuicolors.com/
extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
    
    static var random: UIColor {
        let red = 0.1 + (Double(arc4random_uniform(74)) / 100)
        let green = 0.1 + (Double(arc4random_uniform(74)) / 100)
        let blue = 0.1 + (Double(arc4random_uniform(74)) / 100)
        
        return UIColor(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: 1)
    }
    
    struct Feeds {
        static var background: UIColor {
            return UIColor(red:0.89, green:0.90, blue:0.91, alpha:1.00)
        }
        
        static var statsImage: UIColor {
            return UIColor(red:0.51, green:0.55, blue:0.60, alpha:1.00)
        }
    }
    
    struct SearchCell {
        static var searchBackground: UIColor {
            return UIColor(red:0.87, green:0.88, blue:0.89, alpha:1.00)
        }
    }
    
    struct PhotoView {
        static var currentPageIndicatorTintColor: UIColor {
            return UIColor(red:0.33, green:0.51, blue:0.71, alpha:1.00)
        }
        
        static var pageIndicatorTintColor: UIColor {
            return UIColor(red:0.78, green:0.84, blue:0.91, alpha:1.00)
        }
    }
    
    struct FeedItemCell {
        static var plainText: UIColor {
            return UIColor(red:0.16, green:0.18, blue:0.19, alpha:1.00)
        }
        
        static var text: UIColor {
            return UIColor(red:0.23, green:0.24, blue:0.25, alpha:1.00)
        }
        
        static var highlighTextForeground: UIColor {
            return UIColor(red:0.74, green:0.53, blue:0.20, alpha:1.00)
        }
        
        static var highlighTextBackground: UIColor {
            return UIColor(red:1.00, green:0.96, blue:0.88, alpha:1.00)
        }
        
        static var views: UIColor {
            return UIColor(red:0.66, green:0.68, blue:0.70, alpha:1.00)
        }
        
        static var likes: UIColor {
            return UIColor(red:0.51, green:0.55, blue:0.60, alpha:1.00)
        }
        
        static var username: UIColor {
            return UIColor(red:0.17, green:0.18, blue:0.18, alpha:1.00)
        }
        
        static var date: UIColor {
            return UIColor(red:0.51, green:0.55, blue:0.60, alpha:1.00)
        }
    }
}
