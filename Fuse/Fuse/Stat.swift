//
//  Stat.swift
//  Fuse
//
//  Created by Bailey Seymour on 11/3/18.
//  Copyright © 2018 Bailey Seymour. All rights reserved.
//
// Bailey Seymour
// DVP4 1811

import UIKit

/// Stat for percent based items
class Stat {
    // MARK: - Instance variable
    var name: String
    var percent: Double
    var color: UIColor
    var suffix: String = "%"
    
    init(name: String, percent: Double, color: UIColor) {
        self.name = name
        self.percent = percent
        self.color = color
    }
}

/// Stat for things that show the raw amount rather than a percent
class RawStat: Stat {
    var rawValue: Int
    
    init(name: String, percent: Double, color: UIColor, rawValue: Int) {
        self.rawValue = rawValue
        
        super.init(name: name, percent: percent, color: color)
        
        self.suffix = " BPM"
    }
}
