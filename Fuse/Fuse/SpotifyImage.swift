//
//  SpotifyImage.swift
//  Fuse
//
//  Created by Bailey Seymour on 11/6/18.
//  Copyright © 2018 Bailey Seymour. All rights reserved.
//
// Bailey Seymour
// DVP4 1811

import Foundation
import ObjectMapper

class SpotifyImage: Mappable {
    var width: Int?
    var height: Int?
    var size: CGSize? {
        guard let h = height, let w = width else { return nil }
        
        return CGSize(width: w, height: h)
    }
    
    var url: String?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        width <- map["width"]
        height <- map["height"]
        url <- map["url"]
    }
}
