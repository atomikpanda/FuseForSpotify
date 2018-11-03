//
//  Stat.swift
//  Fuse
//
//  Created by Bailey Seymour on 11/3/18.
//  Copyright © 2018 Bailey Seymour. All rights reserved.
//

import UIKit

class Stat {
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

class RawStat: Stat {
    var rawValue: Int
    
    init(name: String, percent: Double, color: UIColor, rawValue: Int) {
        self.rawValue = rawValue
        
        super.init(name: name, percent: percent, color: color)
        
        self.suffix = " BPM"
    }
}
