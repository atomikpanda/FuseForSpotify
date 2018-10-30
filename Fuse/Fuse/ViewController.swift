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
       
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        beginAuthorization()
    }
    
    @IBAction func loadTracks(_ sender: AnyObject) {
        
            // TESTING PURPOSES ONLY
            let track = Track(map: Map(mappingType: .fromJSON, JSON: [:]))
            track!.id = "4JpKVNYnVcJ8tuMKjAj50A"
            let track2 = Track(map: Map(mappingType: .fromJSON, JSON: [:]))
            track2!.id = "0FgVuueVnlwy2HMwrL7itl"
            
            TrackFeatures.loadFeatures(for: [track!, track2!]) {
                // Now the track's `features` variable is populated
            }
            
            Playlist.loadUserPlaylists { (paging, playlist) in
                
            }
        
        
    }
    
    func beginAuthorization() {
        return
        let oauthswift = appDelegate.oauthswift!
        oauthswift.authorizeURLHandler = SafariURLHandler(viewController: self, oauthSwift: oauthswift)
       
        oauthswift.authorize(withCallbackURL: URL(string: "fuse-auth://oauth-callback/spotify")!,
            scope: "user-read-private+playlist-modify-private+playlist-read-private+playlist-read-collaborative", state:"SPOTIFY",
            success: { credential, response, parameters in
                print(credential.oauthToken)
                
                UserDefaults.standard.set(credential.oauthToken, forKey: "oauthToken")
                UserDefaults.standard.set(credential.oauthTokenSecret, forKey: "oauthTokenSecret")
                
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

}

