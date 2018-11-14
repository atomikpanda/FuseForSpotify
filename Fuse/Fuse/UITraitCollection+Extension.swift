//
//  UITraitCollection+Extension.swift
//  Fuse
//
//  Created by Bailey Seymour on 11/13/18.
//  Copyright © 2018 Bailey Seymour. All rights reserved.
//
// Bailey Seymour
// DVP4 1811

import UIKit

extension UITraitCollection {
    /// wR hR
    var isRegularRegular: Bool {
        return containsTraits(in: UITraitCollection(verticalSizeClass: .regular)) &&
            containsTraits(in: UITraitCollection(horizontalSizeClass: .regular))
    }
}
