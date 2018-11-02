//
//  ViewController.swift
//  Fuse
//
//  Created by Bailey Seymour on 10/29/18.
//  Copyright © 2018 Bailey Seymour. All rights reserved.
//

import UIKit
import OAuthSwift

private let appDelegate = UIApplication.shared.delegate as! AppDelegate

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // If we have our token then show playlists non-animated
        if let oauthswift = appDelegate.oauthswift {
            if !oauthswift.client.credential.oauthToken.isEmpty {
                performSegue(withIdentifier: "toPlaylistsNoAnimate", sender: self)
            }
        }
    }
    
    // MARK: - Authorization
    
    @IBAction func beginAuthorization() {
        
        // Set our handler to use the SFSafariViewController
        let oauthswift = appDelegate.oauthswift!
        oauthswift.authorizeURLHandler = SafariURLHandler(viewController: self, oauthSwift: oauthswift)
        //user-read-private+playlist-modify-private+playlist-read-private+playlist-read-collaborative
        // Authorize for the current user
        let scopes = [
            "user-read-private",
            "playlist-modify-private",
            "playlist-modify-public",
            "playlist-read-private"
            ].joined(separator: "+")
        
        let params: OAuthSwift.Parameters = ["show_dialog": "true"]
        oauthswift.authorize(withCallbackURL: URL(string: "fuse-auth://oauth-callback/spotify")!,
                             scope: scopes, state:"SPOTIFY",
                             parameters: params, headers: nil,
                             success: authorizationDidSucceed(_:_:_:),
                             failure: { error in
                                print(error.localizedDescription)
        })
        
    }
    
    func authorizationDidSucceed(_ credential: OAuthSwiftCredential, _ response: OAuthSwiftResponse?, _ parameters: OAuthSwift.Parameters) {
        print(credential.oauthToken)
        
        // Save tokens for next launch
        credential.save()
        
        // If we got our token then show the Playlists screen
        if !credential.oauthToken.isEmpty {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "toPlaylists", sender: self)
            }
        }
        
        // Debug purposes to show the expiration on first auth
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .medium
        
        if let expiration = credential.oauthTokenExpiresAt {
            print("DATE FOR EXPIRATION: \(formatter.string(from: expiration))")
        } else {
            print("EXPIRATION WAS NIL")
        }
    }
    
    @IBAction func unwindToWelcome(_ unwindSegue: UIStoryboardSegue) {
        appDelegate.oauthswift!.client.credential.clearSavedForLogout()
    }
}

