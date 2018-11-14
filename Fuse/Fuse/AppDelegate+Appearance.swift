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
    
    /// Load the initial theme for the application
    func setupAppearance(nav: UINavigationController?=nil, tableView currentTableView: UITableView?=nil) {
        
        // Get all appearance proxy objects
        let control = UIControl.appearance()
        let switches = UISwitch.appearance()
        let tableViewAppearance = UITableView.appearance()
        let viewInAlerts = UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self])
        let navbar = UINavigationBar.appearance()
        let blurView = UIVisualEffectView.appearance(whenContainedInInstancesOf: [PlaylistHeaderViewCell.self])
        let toolbar = UIToolbar.appearance()
        let separatorColor = UIColor(hue:0.667, saturation:0.050, brightness:0.187, alpha:1.000)
        
        // General UI Elements
        control.tintColor = .fuseTint
        switches.onTintColor = .fuseTint
        viewInAlerts.tintColor = .fuseTint(type: UIColor.fuseTintColorType, isDark: false)
        UIBarButtonItem.appearance().tintColor = .fuseTint
        
        // Table Views
        tableViewAppearance.backgroundColor = .fuseBackground
        currentTableView?.backgroundColor = .fuseBackground
        
        // Settings view controller
        UILabel.appearance(whenContainedInInstancesOf: [SettingsViewController.self]).textColor = .fuseTextPrimary
        
        if UIColor.fuseIsDark {
            // Configure navbar style
            navbar.barStyle = .black
            nav?.navigationBar.barStyle = .black
            toolbar.barStyle = .black
            
            blurView.effect = UIBlurEffect(style: .dark)
            
            // TableView
            tableViewAppearance.separatorColor = separatorColor
            currentTableView?.separatorColor = separatorColor
        
        } else {
            // Navbar style light
            navbar.barStyle = .default
            nav?.navigationBar.barStyle = .default
            toolbar.barStyle = .default
            
            blurView.effect = UIBlurEffect(style: .extraLight)
            
            // TableView
            tableViewAppearance.separatorColor = nil
            currentTableView?.separatorColor = nil
        }
        
        // Finally reload
        currentTableView?.reloadData()
        
    }
}
