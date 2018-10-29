//
//  Playlist.swift
//  Fuse
//
//  Created by Bailey Seymour on 10/29/18.
//  Copyright © 2018 Bailey Seymour. All rights reserved.
//

import Foundation
import ObjectMapper

/***
 See https://developer.spotify.com/documentation/web-api/reference/playlists/get-playlist/
 for more info
 ***/
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
}
