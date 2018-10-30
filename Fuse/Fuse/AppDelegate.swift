//
//  AppDelegate.swift
//  Fuse
//
//  Created by Bailey Seymour on 10/29/18.
//  Copyright © 2018 Bailey Seymour. All rights reserved.
//

import UIKit
import Alamofire
import OAuthSwift
import OAuthSwiftAlamofire

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var oauthswift: OAuth2Swift?
    var sessionManager = SessionManager.default

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        oauthswift = OAuth2SwiftWorkaround(
            consumerKey:    "b798e6bd7c154a6497778e08d58bd938",
            consumerSecret: "d4227806dfdf497ca1934511abd31178",
            authorizeUrl:   "https://accounts.spotify.com/authorize",
            accessTokenUrl: "https://accounts.spotify.com/api/token",
            responseType:   "code"
        )
        
        
        if let oauthToken = UserDefaults.standard.value(forKey: "oauthToken") as? String {
            oauthswift?.client.credential.oauthToken = oauthToken
        }
        if  let oauthTokenSecret = UserDefaults.standard.value(forKey: "oauthTokenSecret") as? String {
            oauthswift?.client.credential.oauthTokenSecret = oauthTokenSecret
        }
        if  let oauthRefreshToken = UserDefaults.standard.value(forKey: "oauthRefreshToken") as? String {
            oauthswift?.client.credential.oauthRefreshToken = oauthRefreshToken
        }
        
        sessionManager.adapter = oauthswift?.requestAdapter
        sessionManager.retrier = oauthswift?.requestAdapter
        
        UIView.appearance().tintColor = UIColor(named: "secondary")
        UITableView.appearance().backgroundColor = UIColor(named: "primary")

        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if url.host == "oauth-callback" {
            OAuthSwift.handle(url: url)
        }
        return true
    }
    
//    public func refreshTokenIfExpired(completion: @escaping () -> ()) {
//
//        if let cred = oauthswift?.client.credential {
//            if cred.isTokenExpired() {
//                print("Token is expired")
//                oauthswift?.renewAccessToken(withRefreshToken: cred.oauthRefreshToken, success: { (newCred, response, params) in
//
//                    print(newCred.oauthToken)
//                    UserDefaults.standard.set(newCred.oauthToken, forKey: "oauthToken")
//                    UserDefaults.standard.set(newCred.oauthTokenSecret, forKey: "oauthTokenSecret")
//
//                    completion()
//                }, failure: { (error) in
//                    print(error.localizedDescription)
//                })
//            } else {
//                completion()
//                print("Token not expired")
//            }
//        } else {
//            print("No credentials")
//        }
//    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        if let credential = oauthswift?.client.credential {
            // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
            UserDefaults.standard.set(credential.oauthToken, forKey: "oauthToken")
            UserDefaults.standard.set(credential.oauthTokenSecret, forKey: "oauthTokenSecret")
            UserDefaults.standard.set(credential.oauthRefreshToken, forKey: "oauthRefreshToken")
            
        }
    }
    
    class OAuth2SwiftWorkaround: OAuth2Swift {
        override func renewAccessToken(withRefreshToken refreshToken: String, parameters: OAuthSwift.Parameters?, headers: OAuthSwift.Headers?, success: @escaping OAuthSwift.TokenSuccessHandler, failure: OAuthSwift.FailureHandler?) -> OAuthSwiftRequestHandle? {
            
            print("reset access_token")
            client.credential.oauthToken = ""
            client.credential.oauthTokenExpiresAt = nil
            
            return super.renewAccessToken(withRefreshToken: client.credential.oauthRefreshToken, parameters: parameters, headers: headers, success: { (credential, response, successParameters) in
                
                UserDefaults.standard.set(credential.oauthToken, forKey: "oauthToken")
                UserDefaults.standard.set(credential.oauthTokenSecret, forKey: "oauthTokenSecret")
                UserDefaults.standard.set(credential.oauthRefreshToken, forKey: "oauthRefreshToken")
                
                success(credential, response, successParameters)
            }, failure: failure)
        }
    }

}
