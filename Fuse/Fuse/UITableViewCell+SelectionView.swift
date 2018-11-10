//
//  UITableViewCell+SelectionView.swift
//  Fuse
//
//  Created by Bailey Seymour on 11/8/18.
//  Copyright © 2018 Bailey Seymour. All rights reserved.
//

import UIKit

extension UITableViewCell {
    func setupSelectionView() {
        selectedBackgroundView = UIView()
        if UIColor.fuseIsDark {
            selectedBackgroundView?.backgroundColor = UIColor.darkGray
        } else {
            selectedBackgroundView?.backgroundColor = UIColor.fuseTint.withAlphaComponent(0.5)
        }
    }
}
