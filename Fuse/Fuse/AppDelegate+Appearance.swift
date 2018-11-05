//
//  AppDelegate+Appearance.swift
//  Fuse
//
//  Created by Bailey Seymour on 11/5/18.
//  Copyright © 2018 Bailey Seymour. All rights reserved.
//

import Foundation
import UIKit

extension AppDelegate {
    func setupAppearance() {
        UIControl.appearance().tintColor = UIColor(named: "secondary")
        UITableView.appearance().backgroundColor = UIColor(named: "primary")
        UITableView.appearance().separatorColor = .darkGray
        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = UIColor(named: "secondary")
        UIBarButtonItem.appearance().tintColor = UIColor(named: "secondary")
    }
}
