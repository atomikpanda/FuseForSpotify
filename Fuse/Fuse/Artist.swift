//
//  Artist.swift
//  Fuse
//
//  Created by Bailey Seymour on 10/30/18.
//  Copyright © 2018 Bailey Seymour. All rights reserved.
//

import Foundation
import ObjectMapper

class Artist: Mappable {
    var name: String?
    var id: String?
    var uri: String?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        
        name <- map["name"]
        id <- map["id"]
        uri <- map["uri"]
    }
}
