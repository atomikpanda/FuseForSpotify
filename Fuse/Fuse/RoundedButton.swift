//
//  RoundedButton.swift
//  Fuse
//
//  Created by Bailey Seymour on 11/3/18.
//  Copyright © 2018 Bailey Seymour. All rights reserved.
//

import UIKit

class RoundedButton: UIButton {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    override func layoutSubviews() {
        super.layoutSubviews()
        
       layer.cornerRadius = 10.0
    }
}
