//
//  ReorderManager.swift
//  Fuse
//
//  Created by Bailey Seymour on 11/1/18.
//  Copyright © 2018 Bailey Seymour. All rights reserved.
//
// Bailey Seymour
// DVP4 1811

// TODO: Delete this file as it is no longer in use

import Foundation
import SwiftyJSON

// Represents a reorderable track
struct ReorderableTrack {
    var from: Int
    var to: Int
    var trackId: String
    var cancelled: Bool = false
}

private let appDelegate = UIApplication.shared.delegate as! AppDelegate

class ReorderManager {
    var tracks: [ReorderableTrack] = []
    var playlistId: String
    
    init(playlistId: String) {
        self.playlistId = playlistId
    }
    
    func move(track: Track, at: IndexPath,  to: IndexPath) {
        guard let trackId = track.id else {return}
        var rTrack = ReorderableTrack(from: at.row, to: to.row, trackId: trackId, cancelled: false)
        
        // We need to modify the index based on
        // whether it was going back or forward
        if rTrack.to > rTrack.from {
            rTrack.to += 1
        }
        
        tracks.append(rTrack)
    }
    
    func trackWasDeleted(withId: String) {
        for (i, retrack) in self.tracks.enumerated() {
            if retrack.trackId == withId {
                self.tracks[i].cancelled = true
                return
            }
        }
    }
    
    func reorder() {
        // Initiate the reorder if we have some tracks
        if tracks.count > 0 {
            requestReorder(tracks[0], indexInArray: 0, snapshotId: nil, completion: afterReorderDidSucceed(_:_:))
        }
    }
    
    private func afterReorderDidSucceed(_ indexInArray: Int, _ snapshotId: String?) {
        // Continue in order by trying the next index
        let nextIndexToTry = indexInArray+1
        if nextIndexToTry  < self.tracks.count {
            let track = self.tracks[nextIndexToTry]
            self.requestReorder(track, indexInArray: nextIndexToTry, snapshotId: snapshotId, completion: afterReorderDidSucceed(_:_:))
        } else {
            // Out of bounds so we are done
            tracks.removeAll()
        }
    }
    
    
    private func requestReorder(_ track: ReorderableTrack, indexInArray: Int, snapshotId: String?, completion: @escaping (_ indexInArray: Int, _ snapshotId: String)->()) {
        
        if track.cancelled == true {
            afterReorderDidSucceed(indexInArray, snapshotId)
            return
        }
        
        var json = [String: Any]()
        json["range_start"] = track.from
        json["range_length"] = 1
        json["insert_before"] = track.to
        
        
        

//        if let snapshotId = snapshotId {
//            json["snapshot_id"] = snapshotId
//        }

        let requestData = json
        print("\n\n"+requestData.description+"\n\n")
        
        _ = appDelegate.oauthswift!.client.request("https://api.spotify.com/v1/playlists/\(playlistId)/tracks", method: .PUT,
                                                   headers: ["Accept": "application/json", "Content-Type":"application/json"], body: try? JSON(requestData).rawData(), checkTokenExpiration: true, success: { (response) in
                                                    do {
                                                        let responseJson = try response.jsonObject() as? [String: Any]
                                                        if let responseObj = responseJson, let snapshotId = responseObj["snapshot_id"] as? String {
                                                            // Handle response
                                                            completion(indexInArray, snapshotId)
                                                        } else {
                                                            print("Error getting snapshot_id")
                                                        }
                                                    } catch {
                                                        print("Exception getting snapshot_id")
                                                    }
        }) { (error) in
            appDelegate.oauthErrorHandler(error: error) {
                // Retry this very method with the same params
                self.requestReorder(track, indexInArray: indexInArray, snapshotId: snapshotId, completion: completion)
            }
        }
        
        
    }
}
