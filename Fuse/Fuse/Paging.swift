//
//  Paging.swift
//  Fuse
//
//  Created by Bailey Seymour on 10/29/18.
//  Copyright © 2018 Bailey Seymour. All rights reserved.
//
// Bailey Seymour
// DVP4 1811

import Foundation
import ObjectMapper

/***
 See bottom of https://developer.spotify.com/documentation/web-api/reference/playlists/get-playlists-tracks/
 or whatever endpoint you are requesting...
 ***/

class Paging: Mappable {
    
    var items: [AnyObject]?
    var limit: Int?
    var next: String?
    var offset: Int?
    var previous: String?
    var total: Int?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        items <- map["items"]
        limit <- map["limit"]
        next <- map["next"]
        offset <- map["offset"]
        previous <- map["previous"]
        total <- map["total"]
    }
    
}
