//
//  UITableViewCell+SelectionView.swift
//  Fuse
//
//  Created by Bailey Seymour on 11/8/18.
//  Copyright © 2018 Bailey Seymour. All rights reserved.
//
// Bailey Seymour
// DVP4 1811

import UIKit

extension UITableViewCell {
    func setupSelectionView() {
        
        if UIColor.fuseIsDark {
            selectedBackgroundView?.backgroundColor = UIColor.fuseTint.withAlphaComponent(0.25)
        } else {
            selectedBackgroundView?.backgroundColor = UIColor.fuseTint.withAlphaComponent(0.5)
        }
    }
}
