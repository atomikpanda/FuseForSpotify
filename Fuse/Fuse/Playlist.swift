//
//  Playlist.swift
//  Fuse
//
//  Created by Bailey Seymour on 10/29/18.
//  Copyright © 2018 Bailey Seymour. All rights reserved.
//

import Foundation
import ObjectMapper
import Alamofire
import AlamofireObjectMapper
import OAuthSwiftAlamofire
import OAuthSwift
import SwiftyJSON

/***
 See https://developer.spotify.com/documentation/web-api/reference/playlists/get-playlist/
 for more info
 ***/

private let appDelegate = UIApplication.shared.delegate as! AppDelegate

class Playlist: Mappable {
    
    var name: String?
    var id: String?
    var numberOfTracks: Int?
    var tracks: [Track]? = []
    var uri: String?
    var owner: User?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        name <- map["name"]
        id <- map["id"]
        numberOfTracks <- map["tracks.total"]
        uri <- map["uri"]
        owner <- map["owner"]
    }
    
    // MARK: - Track Loading
    
    func loadTracks(loaded: @escaping (Paging, [Track]?) -> Void) {
        guard let playlistId = id else { return }
        _ = appDelegate.oauthswift!.client.get("https://api.spotify.com/v1/playlists/\(playlistId)/tracks", parameters: ["limit": "100", "offset": "0", "fields": "fields=items(track(name,href,artists))"], headers: nil, success: { response in
            
            self.tracks?.removeAll()
            // Handle our tracks response
            self.handleTracksResponse(response: response, loaded: loaded)
            
        }) { error in
            appDelegate.oauthErrorHandler(error: error as! OAuthSwiftError) {
                // Retry this very method with the same params
                self.loadTracks(loaded: loaded)
            }
        }
    }
    
    private func handleTracksResponse(response: OAuthSwiftResponse, loaded: @escaping (Paging, [Track]?) -> Void) {
        do {
            let rootObj = try JSON(data: response.data)
            
            // Get our paging object
            if let rootDict = rootObj.dictionaryObject,
                let paging = Paging(JSON: rootDict) {
                
                // Make sure we have items in the paging object
                guard let items = paging.items as? [[String: Any]] else { return }
                
                
                // Get each playlist item from our items and convert it
                for item in items {
                    if let trackProp = item["track"],
                        let trackDict = JSON(trackProp).dictionaryObject {
                        
                        guard let track = Track(JSON: trackDict) else { continue }
                        tracks?.append(track)
                    }
                }
                
                // Notify callback
                loaded(paging, self.tracks)
                
                guard let next = paging.next else { return }
                // Handle next page
                self.getNextTrack(next: next, loaded: loaded)
                
            }
            
        } catch {
            print("JSON ERROR: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Track Deletion
    
    func deleteTracks(_ tracks: [TrackAtPosition], completion: @escaping ()->()) {
        guard let playlistId = id else { return }
        
        var json = [[String: Any]]()
        for track in tracks {
            if let uri = track.track.uri {
                json.append(["uri": uri, "positions": track.positions])
            }
        }
        
        let requestData = ["tracks": json]
        
        _ = appDelegate.oauthswift!.client.request("https://api.spotify.com/v1/playlists/\(playlistId)/tracks", method: .DELETE,
                                                             headers: ["Accept": "application/json", "Content-Type":"application/json"], body: try? JSON(requestData).rawData(), checkTokenExpiration: true, success: { (response) in
                                                                // Handle response
                                                                completion()
        }) { (error) in
            appDelegate.oauthErrorHandler(error: error) {
                // Retry this very method with the same params
                self.deleteTracks(tracks, completion: completion)
            }
        }
        
        
    }
    
    private func getNextTrack(next: String, loaded: @escaping (Paging, [Track]?) -> Void) {
        _ = appDelegate.oauthswift!.client.get(next, parameters: [:], headers: nil, success: { response in
            // Successfully got the next page so handle it
            self.handleTracksResponse(response: response, loaded: loaded)
        }) { error in
            
            appDelegate.oauthErrorHandler(error: error as! OAuthSwiftError) {
                // Retry getting the same playlists if we needed to renew
                self.getNextTrack(next: next, loaded: loaded)
            }
        }
    }
    
    // MARK: - Playlist Loading
    
    class func loadUserPlaylists(loaded: @escaping (Paging, [Playlist]?) -> Void) {

        _ = appDelegate.oauthswift!.client.get("https://api.spotify.com/v1/me/playlists", parameters: ["limit": "50", "offset": "0"], headers: nil, success: { response in
            
            // Handle our playlist response
            self.handlePlaylistsResponse(response: response, loaded: loaded)

        }) { error in
            appDelegate.oauthErrorHandler(error: error as! OAuthSwiftError) {
                // Retry this very method with the same params
                loadUserPlaylists(loaded: loaded)
            }
            
        }
    }
    
    private class func handlePlaylistsResponse(response: OAuthSwiftResponse, loaded: @escaping (Paging, [Playlist]?) -> Void) {
        do {
            let rootObj = try JSON(data: response.data)
            
            // Get our paging object
            if let rootDict = rootObj.dictionaryObject,
                let paging = Paging(JSON: rootDict) {
                
                // Make sure we have items in the paging object
                guard let items = paging.items as? [[String: Any]] else { return }
                
                var playlists: [Playlist] = []
                
                // Get each playlist item from our items and convert it
                for item in items {
                    guard let plist = Playlist(JSON: item) else { continue }
                    playlists.append(plist)
                }
                
                // Notify callback
                loaded(paging, playlists)
                
                guard let next = paging.next else { return }
                // Handle next page
                getNextPlaylist(next: next, loaded: loaded)
                
            }
            
        } catch {
            print("JSON ERROR: \(error.localizedDescription)")
        }
    }
    
    private class func getNextPlaylist(next: String, loaded: @escaping (Paging, [Playlist]?) -> Void) {
        _ = appDelegate.oauthswift!.client.get(next, parameters: [:], headers: nil, success: { response in
            // Successfully got the next page so handle it
            handlePlaylistsResponse(response: response, loaded: loaded)
        }) { error in
            
            appDelegate.oauthErrorHandler(error: error as! OAuthSwiftError) {
                // Retry getting the same playlists if we needed to renew
                getNextPlaylist(next: next, loaded: loaded)
            }
        }
    }
    
    var pendingUris: [[String]]?
    
    public func replaceTracksWithCurrent() {
        guard let playlistId = id, let allUris = self.urisFromTracks() else { return }
        
        pendingUris = allUris.batches(by: 100)
        guard let firstBatch = self.pendingUris?.first else {return}
        
        var json = [String: Any]()
        json["uris"] = firstBatch
        
        let requestData = json
        print("\n\n"+requestData.description+"\n\n")
        
        
        _ = appDelegate.oauthswift!.client.request("https://api.spotify.com/v1/playlists/\(playlistId)/tracks", method: .PUT,
                                                   headers: ["Accept": "application/json", "Content-Type":"application/json"], body: try? JSON(requestData).rawData(), checkTokenExpiration: true, success: { (response) in
                                                    self.pendingUris?.removeFirst()
                                                   self.appendPendingTracksToPlaylist()
        }) { (error) in
            appDelegate.oauthErrorHandler(error: error) {
                // Retry this very method with the same params
                self.replaceTracksWithCurrent()
                return
            }
        }
        
    }
    
    private func appendPendingTracksToPlaylist() {
        guard let playlistId = id, let uris = pendingUris?.first else { return }
        
        var json = [String: Any]()
        json["uris"] = uris
        
        _ = appDelegate.oauthswift!.client.request("https://api.spotify.com/v1/playlists/\(playlistId)/tracks", method: .POST,
                                                   headers: ["Accept": "application/json", "Content-Type":"application/json"], body: try? JSON(json).rawData(), checkTokenExpiration: true, success: { (response) in
                                                    self.pendingUris?.removeFirst()
                                                    self.appendPendingTracksToPlaylist()
        }) { (error) in
            appDelegate.oauthErrorHandler(error: error) {
                // Retry this very method with the same params
                self.appendPendingTracksToPlaylist()
                return
            }
        }
    }
    
    private func urisFromTracks() -> [String]? {
        guard let allTracks = self.tracks else { return nil }
        var uris: [String] = []
        
        for track in allTracks {
            guard let uri = track.uri else {continue}
            uris.append(uri)
        }
        
        return uris
    }
}
