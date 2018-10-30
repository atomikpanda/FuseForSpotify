//
//  ViewController.swift
//  Fuse
//
//  Created by Bailey Seymour on 10/29/18.
//  Copyright © 2018 Bailey Seymour. All rights reserved.
//

import UIKit
import AlamofireObjectMapper
import Alamofire
import ObjectMapper
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        beginAuthorization()
    }
    
    @IBAction func loadTracks(_: AnyObject) {
        // TESTING PURPOSES ONLY
        let track = Track(map: Map(mappingType: .fromJSON, JSON: [:]))
        track!.id = "4JpKVNYnVcJ8tuMKjAj50A"
        let track2 = Track(map: Map(mappingType: .fromJSON, JSON: [:]))
        track2!.id = "0FgVuueVnlwy2HMwrL7itl"

        TrackFeatures.loadFeatures(for: [track!, track2!]) { _ in
            // Now the track's `features` variable is populated
        }
    }

    func beginAuthorization() {
        return
        
        // Set our handler to use the SFSafariViewController
        let oauthswift = appDelegate.oauthswift!
        oauthswift.authorizeURLHandler = SafariURLHandler(viewController: self, oauthSwift: oauthswift)
       //user-read-private+playlist-modify-private+playlist-read-private+playlist-read-collaborative
        // Authorize for the current user
        oauthswift.authorize(withCallbackURL: URL(string: "fuse-auth://oauth-callback/spotify")!,
            scope: "playlist-read-private", state:"SPOTIFY",
            success: { credential, response, parameters in
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

        },  failure: { error in
            print(error.localizedDescription)
        })
        
    }

    @IBAction func unwindToWelcome(_ unwindSegue: UIStoryboardSegue) {
        
    }
}

