//
//  OAuthSwiftCredential+Save.swift
//  Fuse
//
//  Created by Bailey Seymour on 10/30/18.
//  Copyright © 2018 Bailey Seymour. All rights reserved.
//

import Foundation
import OAuthSwift

extension OAuthSwiftCredential {
    func save() {
        UserDefaults.standard.set(oauthToken, forKey: "oauthToken")
        UserDefaults.standard.set(oauthTokenSecret, forKey: "oauthTokenSecret")
        UserDefaults.standard.set(oauthRefreshToken, forKey: "oauthRefreshToken")
    }

    func load() {
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
