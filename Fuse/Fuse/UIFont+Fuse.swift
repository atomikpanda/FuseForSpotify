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

enum FuseFontSize : Int {
    case small = 0
    case regular = 1
    case large = 2
}

extension UIFont {
    
    static var fuseFontSize: FuseFontSize {
        if UserDefaults.standard.object(forKey: "fontSize") != nil {
            return FuseFontSize(rawValue: UserDefaults.standard.integer(forKey: "fontSize")) ?? .regular
        }
        return .regular
    }
    
    class func adjustedForFuse(regular: CGFloat, preference: FuseFontSize = fuseFontSize, margin: Int = 3) -> UIFont {
        var adjustment: CGFloat = 0
        
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
