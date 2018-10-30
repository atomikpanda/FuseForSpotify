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
import SwiftyJSON

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
    
    class func loadFeatures(for tracks: [Track], completion: @escaping ([Track]) -> ()) {
        var ids: [String] = []
        for track in tracks {
            guard let id = track.id else { continue }
            ids.append(id)
        }
        let params = ["ids": ids.joined(separator: ",")]
        
        _ = appDelegate.oauthswift!.client.get("https://api.spotify.com/v1/audio-features", parameters: params, headers: nil, success: { (response) in
            
            do {
                let rootObj = try JSON(data: response.data)
                
                if let audioFeatures = rootObj["audio_features"].array {
                    for (i, feature) in audioFeatures.enumerated() {
                        guard let featureJson = feature.dictionaryObject else { continue }
                        tracks[i].features = TrackFeatures(JSON: featureJson)
                    }
                    completion(tracks)
                }
            } catch {
                print("JSON ERROR: \(error.localizedDescription)")
            }
            
        }) { (error) in
            print("err: \(error.localizedDescription)")
        }
        
    }
}
