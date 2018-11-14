//
//  ColorCollectionViewCell.swift
//  Fuse
//
//  Created by Bailey Seymour on 11/11/18.
//  Copyright © 2018 Bailey Seymour. All rights reserved.
//
// Bailey Seymour
// DVP4 1811

import UIKit

class ColorCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var colorView: UIView!
    
    override var isSelected: Bool {
        didSet {
            // Show a white border when selected
            if isSelected == true {
                colorView.layer.borderWidth = 4.0
                colorView.layer.borderColor = UIColor.fuseTextPrimary.cgColor
            } else {
                // Disable the white border when deselected
                colorView.layer.borderWidth = 0.0
                colorView.layer.borderColor = nil
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        colorView.layer.cornerRadius = bounds.size.width / 2.0
    }
}
