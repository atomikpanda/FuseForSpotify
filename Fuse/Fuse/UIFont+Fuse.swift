//
//  UIFont+Fuse.swift
//  Fuse
//
//  Created by Bailey Seymour on 11/11/18.
//  Copyright © 2018 Bailey Seymour. All rights reserved.
//
// Bailey Seymour
// DVP4 1811

import UIKit

/// Font Size Representation
enum FuseFontSize : Int {
    case small = 0
    /// Normal or Default
    case regular = 1
    case large = 2
}

extension UIFont {
    
    static var fuseFontSize: FuseFontSize {
        return UserDefaults.standard.enumValue(forKey: "fontSize", default: .regular)
    }
    
    class func adjustedForFuse(regular: CGFloat, preference: FuseFontSize = fuseFontSize, margin: Int = 3) -> UIFont {
        var adjustment: CGFloat = 0
        
        // Adjust based on preference
        switch preference {
        case .small:
            adjustment = CGFloat(-margin)
        case .regular:
            adjustment = 0
        case .large:
            adjustment = CGFloat(margin)
        }
        
        return UIFont.systemFont(ofSize: regular + adjustment)
    }
}
