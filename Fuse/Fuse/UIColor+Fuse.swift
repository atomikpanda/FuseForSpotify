//
//  UIColor+Fuse.swift
//  Fuse
//
//  Created by Bailey Seymour on 11/8/18.
//  Copyright © 2018 Bailey Seymour. All rights reserved.
//
// Bailey Seymour
// DVP4 1811

import UIKit

// Hues
fileprivate let fuseTintHues: [CGFloat] = [
    0.392, 0.58333, 0.8777, 0.997222222, 0.168, 0.513888889
]

enum FuseTintColorType : Int {
    case green = 0
    case blue = 1
    case pink = 2
    case red = 3
    case yellow = 4
    case cyan = 5
}


extension UIColor {
    
    static var fuseTintColorType: FuseTintColorType {
        if UserDefaults.standard.object(forKey: "tintColor") != nil {
            return FuseTintColorType(rawValue: UserDefaults.standard.integer(forKey: "tintColor")) ?? .green
        }
        return .green
    }
    
    static var fuseIsDark: Bool {
        if UserDefaults.standard.object(forKey: "isDark") == nil {
            return true
        }
        return UserDefaults.standard.bool(forKey: "isDark")
    }
    
    static func fuseTint(type: FuseTintColorType, isDark: Bool=fuseIsDark) -> UIColor {
        
        var brightness: CGFloat = 0.843
        var saturation: CGFloat = 0.860
        
        // Improve contrast on light backgrounds
        
        if isDark == false {
            saturation = 0.843
            brightness = 0.725
            
            if type == .yellow {
                return UIColor(hue:0.143, saturation:1.000, brightness:0.900, alpha:1.000)
            }
        }
        
        
        return UIColor(hue: fuseTintHues[type.rawValue], saturation:saturation, brightness:brightness, alpha:1.000)
    }
    
    static var fuseTint: UIColor {
        return fuseTint(type: fuseTintColorType)
    }
    
    static var fuseBackground: UIColor {
        return fuseIsDark ? .black : UIColor(hue:0.663, saturation:0.022, brightness:0.958, alpha:1.000)
    }
    
    static var fuseCell: UIColor {
        return fuseIsDark ? UIColor(hue:0.669, saturation:0.038, brightness:0.114, alpha:1.000) : .white
    }
    
    static var fuseTextPrimary: UIColor {
        return fuseIsDark ? UIColor(hue:0.0, saturation:0.0, brightness:1.0, alpha:1.000) : .black
    }
    
    static var fuseTextSecondary: UIColor {
        return fuseIsDark ? UIColor(hue:0.632, saturation:0.033, brightness:0.644, alpha:1.000) : .darkGray
    }
}
