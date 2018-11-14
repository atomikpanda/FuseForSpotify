//
//  AudioFeatures.swift
//  Fuse
//
//  Created by Bailey Seymour on 10/29/18.
//  Copyright © 2018 Bailey Seymour. All rights reserved.
//
// Bailey Seymour
// DVP4 1811

import Foundation
import ObjectMapper
import SwiftyJSON
import OAuthSwift

/***
 See https://developer.spotify.com/documentation/web-api/reference/tracks/get-audio-features/ for more info.
 ***/

private let appDelegate = UIApplication.shared.delegate as! AppDelegate

class AudioFeatures: Mappable {
    
    // MARK: - Variables
    var trackId: String?
    var danceability: Double?
    var energy: Double?
    var instrumentalness: Double?
    var key: Key?
    var mode: Mode?
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
        mode <- map["mode"]
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


extension Array where Element == Track {
    
    /// Creates a Stat or RawStat object for a specific feature in this [Track]
    ///
    /// - Parameters:
    ///   - statName: The name for the Stat object eg. Energy Level
    ///   - color: color for the Stat
    ///   - value: The value to use in calculation which is usually the property on the AudioFeatures object we are using
    ///   - rawStatCalc: The way to find the raw stats display value or BPM for tempo
    /// - Returns: A new fully configured Stat or RawStat object
    func sumFeatures<ReturnType>(statName: String, color: UIColor, value: (AudioFeatures)->(Double?), rawStatCalc: ((_ avg: Double)->(Double))?=nil) -> ReturnType where ReturnType : Stat {
        
        var totalCount: Int = 0
        var total: Double = 0
        
        for track in self {
            if let features = track.features {
                if let doubleValue = value(features) {
                    total += doubleValue
                    totalCount += 1
                }
            }
        }
        
        if totalCount == 0 {
            totalCount = 1
        }
        
        let average = total/Double(totalCount)
        
        if ReturnType.self == RawStat.self {
            let calc = rawStatCalc ?? {_ in return 0}
            
            return RawStat(name: statName, percent: calc(average), color: color, rawValue: Int(total/Double(totalCount))) as! ReturnType
        }
        
        return Stat(name: statName, percent: average, color: color) as! ReturnType
    }
}
