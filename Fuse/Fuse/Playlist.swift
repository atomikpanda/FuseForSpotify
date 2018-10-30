//
//  Playlist.swift
//  Fuse
//
//  Created by Bailey Seymour on 10/29/18.
//  Copyright © 2018 Bailey Seymour. All rights reserved.
//

import Foundation
import ObjectMapper
import Alamofire
import AlamofireObjectMapper
import OAuthSwiftAlamofire
import OAuthSwift
import SwiftyJSON

/***
 See https://developer.spotify.com/documentation/web-api/reference/playlists/get-playlist/
 for more info
 ***/

private let appDelegate = UIApplication.shared.delegate as! AppDelegate

class Playlist: Mappable {
    
    var name: String?
    var id: String?
    var numberOfTracks: Int?
    var tracks: [Track]?
    var uri: String?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        name <- map["name"]
        id <- map["id"]
        numberOfTracks <- map["tracks.total"]
        uri <- map["uri"]
    }
    
    func loadTracks() {
        
    }
    
    class func loadUserPlaylists(loaded: @escaping (Paging, [Playlist]?) -> Void) {
        // TODO: Implement loading playlists from /me/playlists
        // maybe use a closure as a param for this method to handle each paging request?

        _ = appDelegate.oauthswift!.startAuthorizedRequest("https://api.spotify.com/v1/me/playlists", method: .GET, parameters: ["limit": "50", "offset": "0"], headers: nil, success: { response in
            
            self.handlePlaylistsResponse(response: response, loaded: loaded)

        }) { error in
            print("OAUTH Request Error: \(error.localizedDescription)")
        }
    }
    
    private class func handlePlaylistsResponse(response: OAuthSwiftResponse, loaded: @escaping (Paging, [Playlist]?) -> Void) {
        do {
            let rootObj = try JSON(data: response.data)
            
            // Get our paging object
            if let rootDict = rootObj.dictionaryObject,
                let paging = Paging(JSON: rootDict) {
                
                // Make sure we have items in the paging object
                guard let items = paging.items as? [[String: Any]] else { return }
                
                var playlists: [Playlist] = []
                
                // Get each playlist item from our items and convert it
                for item in items {
                    guard let plist = Playlist(JSON: item) else { continue }
                    playlists.append(plist)
                }
                
                // Notify callback
                loaded(paging, playlists)
                
                guard let next = paging.next else { return }
                // Handle next page
                _ = appDelegate.oauthswift!.startAuthorizedRequest(next, method: .GET, parameters: [:], headers: nil, success: { response in
                    handlePlaylistsResponse(response: response, loaded: loaded)
                }) { error in
                    print("OAUTH Request Error: \(error.localizedDescription)")
                }
                
            }
            
        } catch {
            print("JSON ERROR: \(error.localizedDescription)")
        }
    }
}
