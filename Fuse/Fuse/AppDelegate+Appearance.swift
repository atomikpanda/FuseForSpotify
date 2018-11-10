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
        
        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = .fuseTint
        UIBarButtonItem.appearance().tintColor = .fuseTint
        
        if UIColor.fuseIsDark {
            UINavigationBar.appearance().barStyle = .black
            UITableView.appearance().separatorColor = UIColor(hue:0.667, saturation:0.050, brightness:0.187, alpha:1.000)
        } else {
            UINavigationBar.appearance().barStyle = .default
            UIVisualEffectView.appearance().effect = UIBlurEffect(style: .extraLight)
            UIToolbar.appearance().barStyle = .default
        }
        
        
    }
}
