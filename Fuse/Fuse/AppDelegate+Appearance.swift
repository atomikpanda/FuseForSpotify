//
//  AppDelegate+Appearance.swift
//  Fuse
//
//  Created by Bailey Seymour on 11/5/18.
//  Copyright © 2018 Bailey Seymour. All rights reserved.
//
// Bailey Seymour
// DVP4 1811

import Foundation
import UIKit

extension AppDelegate {
    func setupAppearance() {
        UIControl.appearance().tintColor = .fuseTint
        UITableView.appearance().backgroundColor = .fuseBackground
        UITableView.appearance().separatorColor = .fuseTextSecondary
        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = .fuseTint
        UIBarButtonItem.appearance().tintColor = .fuseTint
    }
}
