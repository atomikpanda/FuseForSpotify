//
//  RoundedButton.swift
//  Fuse
//
//  Created by Bailey Seymour on 11/3/18.
//  Copyright © 2018 Bailey Seymour. All rights reserved.
//
// Bailey Seymour
// DVP4 1811

import UIKit

class RoundedButton: UIButton {
    
    override func layoutSubviews() {
        super.layoutSubviews()

        // Round all corners
        layer.cornerRadius = 10.0
    }
}
