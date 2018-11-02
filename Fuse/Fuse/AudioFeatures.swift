//
//  AudioFeatures.swift
//  Fuse
//
//  Created by Bailey Seymour on 10/29/18.
//  Copyright © 2018 Bailey Seymour. All rights reserved.
//

import Foundation
import ObjectMapper
import SwiftyJSON
import OAuthSwift

/***
 See https://developer.spotify.com/documentation/web-api/reference/tracks/get-audio-features/ for more info.
 ***/

private let appDelegate = UIApplication.shared.delegate as! AppDelegate

class AudioFeatures: Mappable {
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
    
    class func loadFeatures(for allTracks: [Track], completion: @escaping ([Track]) -> ()) {
        
       // Split in batches of 100
        let batches = allTracks.batches(by: 100)
        
        // For each 100 tracks or 1 batch
        for tracks in batches {
            
            // get all ids in this batch
            var ids: [String] = []
            for track in tracks {
                guard let id = track.id else { continue }
                ids.append(id)
                
            }
            
            // Formulate params
            let params = ["ids": ids.joined(separator: ",")]
            
            // Submit the request
            _ = appDelegate.oauthswift!.client.get("https://api.spotify.com/v1/audio-features", parameters: params, headers: nil, success: { (response) in
                
                do {
                    let rootObj = try JSON(data: response.data)
                    
                    // Get the audio features from the JSON and set each track's .features property
                    if let audioFeatures = rootObj["audio_features"].array {
                        for (i, feature) in audioFeatures.enumerated() {
                            guard let featureJson = feature.dictionaryObject else { continue }
                            tracks[i].features = AudioFeatures(JSON: featureJson)
                        }
                        
                        // Done with this batch
                        completion(tracks)
                    }
                } catch {
                    print("JSON ERROR: \(error.localizedDescription)")
                }
                
            }) { (error) in
                appDelegate.oauthErrorHandler(error: error as! OAuthSwiftError) {
                    // Retry this same request after renewal
                    loadFeatures(for: tracks, completion: completion)
                }
            }
        }
    }
}
