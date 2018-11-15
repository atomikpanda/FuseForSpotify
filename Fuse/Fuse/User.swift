//
//  User.swift
//  Fuse
//
//  Created by Bailey Seymour on 10/30/18.
//  Copyright © 2018 Bailey Seymour. All rights reserved.
//
// Bailey Seymour
// DVP4 1811

import Foundation
import ObjectMapper
import OAuthSwift
import SwiftyJSON

/***
 See https://developer.spotify.com/documentation/web-api/reference/object-model/#user-object-public
 for more info
 ***/

private let appDelegate = UIApplication.shared.delegate as! AppDelegate

class User: Mappable {
    var name: String?
    var id: String?
    var uri: String?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        name <- map["display_name"]
        id <- map["id"]
        uri <- map["uri"]
    }
    
    class func me(completion: @escaping (User) -> Void) {
        _ = appDelegate.oauthswift!.client.get("https://api.spotify.com/v1/me", parameters: [:], headers: nil, success: { response in

            do {
                // Get the json
                let rootObj = try JSON(data: response.data)

                if let userObject = rootObj.dictionaryObject {
                    // Use ObjectMapper to map the response to a user object
                    if let user = User(JSON: userObject) {
                        
                        // Done. pass the user to the completion handler
                        completion(user)
                    }
                }
            } catch {
                BSLog.E("JSON ERROR: \(error.localizedDescription)")
            }

        }) { error in
            appDelegate.oauthErrorHandler(error: error as! OAuthSwiftError) {
                // Retry getting the same info after renewal
                me(completion: completion)
            }
        }
    }
}
