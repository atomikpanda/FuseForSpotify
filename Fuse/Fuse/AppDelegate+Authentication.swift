//
//  AppDelegate+Authentication.swift
//  Fuse
//
//  Created by Bailey Seymour on 11/5/18.
//  Copyright © 2018 Bailey Seymour. All rights reserved.
//

import Foundation
import OAuthSwift

extension AppDelegate {
    func setupOAuth() {
        oauthswift = OAuth2Swift(
            consumerKey:    "b798e6bd7c154a6497778e08d58bd938",
            consumerSecret: "d4227806dfdf497ca1934511abd31178",
            authorizeUrl:   "https://accounts.spotify.com/authorize",
            accessTokenUrl: "https://accounts.spotify.com/api/token",
            responseType:   "code"
        )
        
        // Read all saved values
        oauthswift?.client.credential.load()
    }
}
