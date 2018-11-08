//
//  PlaylistListViewController+Reachability.swift
//  Fuse
//
//  Created by Bailey Seymour on 11/8/18.
//  Copyright © 2018 Bailey Seymour. All rights reserved.
//
// Bailey Seymour
// DVP4 1811

import Foundation

extension PlaylistListViewController {
    func configureAndStartReachability() {
        
        // When we have a connection
        reachability.whenReachable = { reachability in
            if reachability.connection != .none {
                self.isReachable = true
            }
            else {
                self.isReachable = false
            }
        }
        
        // When we don't have a collection
        reachability.whenUnreachable = { reachability in
            if reachability.connection != .none {
                self.isReachable = true
            }
            else {
                self.isReachable = false
                if self.refreshControl.isRefreshing {
                    self.refreshControl.endRefreshing()
                }
            }
        }
        
        // Start the notifier
        do {
            try reachability.startNotifier()
        } catch {
            print("Failed to start reachability")
        }
    }
}
