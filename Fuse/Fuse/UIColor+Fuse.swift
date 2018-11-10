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

extension UIColor {
    static var fuseIsDark: Bool {
        return true
    }
    
    static var fuseTint: UIColor {
//        return UIColor(hue:0.118, saturation:0.991, brightness:0.999, alpha:1.000)
        return UIColor(hue:0.392, saturation:0.840, brightness:0.725, alpha:1.000)
    }
    
    static var fuseBackground: UIColor {
        return fuseIsDark ? .black : .white
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
