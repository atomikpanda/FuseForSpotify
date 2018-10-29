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
    }
    
    func beginAuthorization() {
        let oauthswift = appDelegate.oauthswift!
        oauthswift.authorizeURLHandler = SafariURLHandler(viewController: self, oauthSwift: oauthswift)
       
        oauthswift.authorize(withCallbackURL: URL(string: "fuse-auth://oauth-callback/spotify")!,
            scope: "user-read-private+playlist-modify-private+playlist-read-private+playlist-read-collaborative", state:"SPOTIFY",
            success: { credential, response, parameters in
                print(credential.oauthToken)
                
                let tok = "\(credential.oauthToken)"
                
                let headers: HTTPHeaders = [
                    "Authorization": "Authorization: Bearer \(tok)",
                    "Accept": "application/json"
                ]
                
                appDelegate.authorizationHeaders = headers
        },  failure: { error in
            print(error.localizedDescription)
        })
        
    }

}

