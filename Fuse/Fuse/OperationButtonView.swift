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
            imageView.tintColor = UIColor(named: "secondary")
            label.textColor = UIColor(named: "secondary")
        } else {
            imageView.tintColor = .white
            label.textColor = .white
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
