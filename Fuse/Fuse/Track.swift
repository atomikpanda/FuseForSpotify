//
//  Track.swift
//  Fuse
//
//  Created by Bailey Seymour on 10/29/18.
//  Copyright © 2018 Bailey Seymour. All rights reserved.
//

import Foundation
import ObjectMapper

/***
 See https://developer.spotify.com/documentation/web-api/reference/tracks/get-track/
 for more info
 ***/

class Track: Mappable {
    var name: String?
    var id: String?
    var artists: [Artist]?
    var uri: String?
    var features: AudioFeatures?

    required init?(map: Map) {}

    func mapping(map: Map) {
        
        name <- map["name"]
        id <- map["id"]
        artists <- map["artists"]
        uri <- map["uri"]
    }
}

// Represents a track at a specific position
struct TrackAtPosition {
    var track: Track
    var positions: [Int]
}
