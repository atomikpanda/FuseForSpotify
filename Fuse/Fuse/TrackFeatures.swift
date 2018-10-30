//
//  TrackFeatures.swift
//  Fuse
//
//  Created by Bailey Seymour on 10/29/18.
//  Copyright © 2018 Bailey Seymour. All rights reserved.
//

import Foundation
import ObjectMapper
import Alamofire
import AlamofireObjectMapper

/***
 See https://developer.spotify.com/documentation/web-api/reference/tracks/get-audio-features/ for more info.
 ***/

private let appDelegate = UIApplication.shared.delegate as! AppDelegate

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
    
    class func loadFeatures(for tracks: [Track], completion: @escaping () -> ()) {
        var ids: [String] = []
        for track in tracks {
            guard let id = track.id else { continue }
            ids.append(id)
        }
        let params = ["ids": ids.joined(separator: ",")]
        
        Alamofire.request("https://api.spotify.com/v1/audio-features", method: .get, parameters: params, encoding: URLEncoding(destination: .queryString), headers: nil).responseArray(queue: nil, keyPath: "audio_features", context: nil, completionHandler:
            { (response: DataResponse<[TrackFeatures]>) in
                let features: [TrackFeatures]? = response.result.value
                
                if let features = features {
                    for (i, feature) in features.enumerated() {
                        tracks[i].features = feature
                    }
                    completion()
                }
        })
    }
}
