//
//  User.swift
//  Fuse
//
//  Created by Bailey Seymour on 10/30/18.
//  Copyright © 2018 Bailey Seymour. All rights reserved.
//

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
        _ = appDelegate.oauthswift!.startAuthorizedRequest("https://api.spotify.com/v1/me", method: .GET, parameters: [:], headers: nil, success: { response in

            do {
                let rootObj = try JSON(data: response.data)

                if let userObject = rootObj.dictionaryObject {
                    if let user = User(JSON: userObject) {
                        completion(user)
                    }
                }
            } catch {
                print("JSON ERROR: \(error.localizedDescription)")
            }

        }) { error in
            print("OAUTH Request Error: \(error.localizedDescription)")
        }
    }
}
