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
        // Do any additional setup after loading the view, typically from a nib.
        if let oauthswift = appDelegate.oauthswift {
            if !oauthswift.client.credential.oauthToken.isEmpty {
                
                performSegue(withIdentifier: "toPlaylistsNoAnimate", sender: self)
                
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        beginAuthorization()
    }
    
    @IBAction func loadTracks(_ sender: AnyObject) {
//        appDelegate.oauthswift!.renewAccessToken(withRefreshToken: appDelegate.oauthswift!.client.credential.oauthRefreshToken, success: {(cred,response, param) in
//            print("SUCCESS")
//
//        }) { (error) in
//            print("EEEE: \(error.localizedDescription)")
//        }
            // TESTING PURPOSES ONLY
            let track = Track(map: Map(mappingType: .fromJSON, JSON: [:]))
            track!.id = "4JpKVNYnVcJ8tuMKjAj50A"
            let track2 = Track(map: Map(mappingType: .fromJSON, JSON: [:]))
            track2!.id = "0FgVuueVnlwy2HMwrL7itl"
            
            TrackFeatures.loadFeatures(for: [track!, track2!]) { tracks in
                // Now the track's `features` variable is populated
            }
            
            Playlist.loadUserPlaylists { (paging, playlist) in
                
            }
        
        
    }
    
    func beginAuthorization() {
       return
        let oauthswift = appDelegate.oauthswift!
        oauthswift.authorizeURLHandler = SafariURLHandler(viewController: self, oauthSwift: oauthswift)
       //user-read-private+playlist-modify-private+playlist-read-private+playlist-read-collaborative
        oauthswift.authorize(withCallbackURL: URL(string: "fuse-auth://oauth-callback/spotify")!,
            scope: "playlist-read-private", state:"SPOTIFY",
            success: { credential, response, parameters in
                print(credential.oauthToken)
                
                UserDefaults.standard.set(credential.oauthToken, forKey: "oauthToken")
                UserDefaults.standard.set(credential.oauthTokenSecret, forKey: "oauthTokenSecret")
                UserDefaults.standard.set(credential.oauthRefreshToken, forKey: "oauthRefreshToken")
                
                if !credential.oauthToken.isEmpty {
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "toPlaylists", sender: self)
                    }
                }
                
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

