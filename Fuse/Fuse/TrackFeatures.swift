//
//  TrackFeatures.swift
//  Fuse
//
//  Created by Bailey Seymour on 10/29/18.
//  Copyright © 2018 Bailey Seymour. All rights reserved.
//

import Foundation
import ObjectMapper

/***
 See https://developer.spotify.com/documentation/web-api/reference/tracks/get-audio-features/ for more info.
 ***/

class TrackFeatures: Mappable {
    var trackId: String?
    var danceability: Double?
    var energy: Double?
    var instrumentalness: Double?
    var key: Int?
    var tempo: Double?
    var valence: Double?
    var trackUri: String?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        trackId <- map["id"]
        danceability <- map["danceability"]
        energy <- map["energy"]
        instrumentalness <- map["instrumentalness"]
        key <- map["key"]
        tempo <- map["tempo"]
        valence <- map["valence"]
        trackUri <- map["uri"]
    }
}
