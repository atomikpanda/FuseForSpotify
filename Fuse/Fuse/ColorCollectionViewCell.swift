//
//  ColorCollectionViewCell.swift
//  Fuse
//
//  Created by Bailey Seymour on 11/11/18.
//  Copyright © 2018 Bailey Seymour. All rights reserved.
//

import UIKit

class ColorCollectionViewCell: UICollectionViewCell {
   @IBOutlet weak var colorView: UIView!
    
    override var isSelected: Bool {
        didSet {
            if isSelected == true {
                colorView.layer.borderWidth = 4.0
                colorView.layer.borderColor = UIColor.fuseTextPrimary.cgColor
            } else {
                colorView.layer.borderWidth = 0.0
                colorView.layer.borderColor = nil
            }
        }
    }
}
