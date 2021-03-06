//
//  OperationButtonView.swift
//  Fuse
//
//  Created by Bailey Seymour on 11/2/18.
//  Copyright © 2018 Bailey Seymour. All rights reserved.
//
// Bailey Seymour
// DVP4 1811

import UIKit

class OperationButtonView: UIView {

    // MARK: - Outlets & Vars
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    // Represents whether or not the button is selected
    private(set) var isSelected: Bool = false
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        updateView()
    }
    
    private func updateView() {
        
        if isSelected {
            // Use primary tint color
            imageView.tintColor = .fuseTint
            label.textColor = .fuseTint
        } else {
            
            if !UIColor.fuseIsDark {
                // Make sure we can read the non-selected items when in light mode
                imageView.tintColor = .darkGray
                label.textColor = .darkGray
            } else {
                imageView.tintColor = .fuseTextPrimary
                label.textColor = .fuseTextPrimary
            }
        }
        
    }

    func setSelected(_ selected: Bool) {
        self.isSelected = selected
        
        // Animate the update
        UIView.animate(withDuration: 0.3) {
            self.updateView()
        }
        
    }
}
