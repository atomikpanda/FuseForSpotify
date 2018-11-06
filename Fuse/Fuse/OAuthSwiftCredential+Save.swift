//
//  OAuthSwiftCredential+Save.swift
//  Fuse
//
//  Created by Bailey Seymour on 10/30/18.
//  Copyright © 2018 Bailey Seymour. All rights reserved.
//
// Bailey Seymour
// DVP4 1811

import Foundation
import OAuthSwift

extension OAuthSwiftCredential {
    func save() {
        // Save the session info
        UserDefaults.standard.set(oauthToken, forKey: "oauthToken")
        UserDefaults.standard.set(oauthTokenSecret, forKey: "oauthTokenSecret")
        UserDefaults.standard.set(oauthRefreshToken, forKey: "oauthRefreshToken")
    }
    
    func clearSavedForLogout() {
        // Clear all session info
        UserDefaults.standard.removeObject(forKey: "oauthToken")
        UserDefaults.standard.removeObject(forKey: "oauthTokenSecret")
        UserDefaults.standard.removeObject(forKey: "oauthRefreshToken")
        self.oauthToken = ""
        self.oauthTokenSecret = ""
        self.oauthRefreshToken = ""
    }

    func load() {
        // Load all session info from the filesystem
        if let oauthToken = UserDefaults.standard.value(forKey: "oauthToken") as? String {
            self.oauthToken = oauthToken
        }
        if let oauthTokenSecret = UserDefaults.standard.value(forKey: "oauthTokenSecret") as? String {
            self.oauthTokenSecret = oauthTokenSecret
        }
        if let oauthRefreshToken = UserDefaults.standard.value(forKey: "oauthRefreshToken") as? String {
            self.oauthRefreshToken = oauthRefreshToken
        }
    }
}
