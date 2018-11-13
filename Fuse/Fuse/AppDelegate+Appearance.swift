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
    func setupAppearance(nav: UINavigationController?=nil, tableView: UITableView?=nil) {
        
        UIControl.appearance().tintColor = .fuseTint
        UISwitch.appearance().onTintColor = .fuseTint
        UITableView.appearance().backgroundColor = .fuseBackground
        tableView?.backgroundColor = .fuseBackground
        UILabel.appearance(whenContainedInInstancesOf: [SettingsViewController.self]).textColor = .fuseTextPrimary
        
        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = .fuseTint(type: UIColor.fuseTintColorType, isDark: false)
        UIBarButtonItem.appearance().tintColor = .fuseTint
        
        if UIColor.fuseIsDark {
            UINavigationBar.appearance().barStyle = .black
            UIToolbar.appearance().barStyle = .black
            UITableView.appearance().separatorColor = UIColor(hue:0.667, saturation:0.050, brightness:0.187, alpha:1.000)
            tableView?.separatorColor = UIColor(hue:0.667, saturation:0.050, brightness:0.187, alpha:1.000)
            
            UIVisualEffectView.appearance(whenContainedInInstancesOf: [PlaylistHeaderViewCell.self]).effect = UIBlurEffect(style: .dark)
            
            nav?.navigationBar.barStyle = .black
        } else {
            UINavigationBar.appearance().barStyle = .default
            UIVisualEffectView.appearance(whenContainedInInstancesOf: [PlaylistHeaderViewCell.self]).effect = UIBlurEffect(style: .extraLight)
            UIToolbar.appearance().barStyle = .default
            UITableView.appearance().separatorColor = nil
            tableView?.separatorColor = nil
            
            nav?.navigationBar.barStyle = .default
        }
        
        tableView?.reloadData()
        
    }
}
