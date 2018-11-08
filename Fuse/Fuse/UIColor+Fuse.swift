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
    
    static var fuseTint: UIColor {
        return UIColor(hue:0.392, saturation:0.840, brightness:0.725, alpha:1.000)
    }
    
    static var fuseBackground: UIColor {
        return .black
    }
    
    static var fuseTextPrimary: UIColor {
        return UIColor(hue:0.0, saturation:0.0, brightness:1.0, alpha:1.000)
    }
    
    static var fuseTextSecondary: UIColor {
        return UIColor(hue:0.632, saturation:0.033, brightness:0.644, alpha:1.000)
    }
}
