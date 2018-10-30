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
    
    class func loadUserPlaylists(loaded: @escaping (Paging, [Playlist]?) -> ()) {
        // TODO: Implement loading playlists from /me/playlists
        // maybe use a closure as a param for this method to handle each paging request?
        
        Alamofire.request("https://api.spotify.com/v1/me/playlists", method: .get, parameters: ["limit": "50", "offset": "0"],
                          encoding: URLEncoding(destination: .queryString),
                          headers: nil).responseObject(queue: nil, keyPath: nil, context: nil, completionHandler:
            { (response: DataResponse<Paging>) in
                let paging: Paging? = response.result.value
                var playlists: [Playlist]? = []
                if let items = paging?.items as? [[String: Any]] {
                    for item in items {
                        if let plist = Playlist(JSON: item) {
                            playlists?.append(plist)
                        }
                    }
                }
                
                if let paging = paging, let playlists = playlists {
                    loaded(paging, playlists)
                }
        })
    }
}
