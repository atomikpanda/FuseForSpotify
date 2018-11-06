//
//  AppDelegate.swift
//  Fuse
//
//  Created by Bailey Seymour on 10/29/18.
//  Copyright © 2018 Bailey Seymour. All rights reserved.
//
// Bailey Seymour
// DVP4 1811

import UIKit
import OAuthSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    // MARK: - Instance Variables
    var window: UIWindow?
    var oauthswift: OAuth2Swift?
    var alert: UIAlertController?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Create our authentication manager
        setupOAuth()

        // Customize UIKit appearance
        setupAppearance()

        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        // Handle the spotify callback
        if url.host == "oauth-callback" {
            OAuthSwift.handle(url: url)
        }
        
        return true
    }
    
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
        oauthswift?.client.credential.save()
    }
    
    func oauthErrorHandler(error: OAuthSwiftError, afterRefresh: (()->())?=nil) {
        
        // An error occurred with the request
        print("OAUTH Request Error: \(error.localizedDescription)")
        
        // Get the error details
        if case .requestError = error,
            let err = error.errorUserInfo["error"] as? NSError {
            
            // No network
            if err.code == -1009 {
                showErrorAlert(error: err)
            }
        }
        
        
        if case .tokenExpired = error {
            // Formulate the request to renew our token
            var headers: OAuthSwift.Headers = [:]
            var params: OAuthSwift.Parameters = [:]
            
            // Spotify requires extra info
            params["redirect_uri"] = "fuse-auth://oauth-callback/spotify"
            params["grant_type"] = "authorization_code"
            params["code"] = oauthswift!.client.credential.oauthToken
            
            // Create the authorization header
            let authVal = "b798e6bd7c154a6497778e08d58bd938:d4227806dfdf497ca1934511abd31178".data(using: .utf8)!.base64EncodedString()
            headers["Authorization"] = "Basic \(authVal)"
            
            // Submit
            oauthswift!.renewAccessToken(withRefreshToken: oauthswift!.client.credential.oauthRefreshToken, parameters: params, headers: headers, success: { (newCred, response, params) in
                // Save the new token
                newCred.save()
                // Done. notify that the token was renewed
                afterRefresh?()
            }) { (error) in
                print("Error refreshing token: \(error.localizedDescription)")
            }
        }
    }
    
    func showErrorAlert(error: NSError) {
        DispatchQueue.main.async {
            // Create an alert
            if self.alert == nil {
                self.alert = UIAlertController(title: "Failed to load.", message: error.localizedDescription, preferredStyle: .alert)
                
                self.alert?.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                    
                    // Post the notification
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "failedToLoad"), object: nil, userInfo: nil)
                    self.alert = nil
                }))
                
                // Present the alert
                self.window?.rootViewController?.present(self.alert!, animated: true, completion: nil)
            }
        }
    }
}
