//
//  Playlist.swift
//  Fuse
//
//  Created by Bailey Seymour on 10/29/18.
//  Copyright © 2018 Bailey Seymour. All rights reserved.
//
// Bailey Seymour
// DVP4 1811

import Foundation
import ObjectMapper
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
    var images: [SpotifyImage]?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        name <- map["name"]
        id <- map["id"]
        numberOfTracks <- map["tracks.total"]
        uri <- map["uri"]
        owner <- map["owner"]
        images <- map["images"]
    }
    
    // MARK: - Track Loading
    
    func loadTracks(loaded: @escaping (Paging, [Track]?) -> Void) {
        guard let playlistId = id else { return }
        
        // Send the initial request to load the first 100 tracks
        _ = appDelegate.oauthswift!.client.get("https://api.spotify.com/v1/playlists/\(playlistId)/tracks", parameters: ["limit": "100", "offset": "0", "fields": "fields=items(track(name,href,artists))"], headers: nil, success: { response in
            
            // Remove all old tracks
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
            
            // Get the json from the response
            let rootObj = try JSON(data: response.data)
            
            // Get our paging object
            if let rootDict = rootObj.dictionaryObject,
                let paging = Paging(JSON: rootDict) {
                
                // Make sure we have items in the paging object
                guard let items = paging.items as? [[String: Any]] else { return }
                
                
                // Get each playlist item from our items and convert it
                var tracksInThisBatch: [Track] = []
                for item in items {
                    if let trackProp = item["track"],
                        let trackDict = JSON(trackProp).dictionaryObject {
                        
                        // Convert the json to a Track object
                        guard let track = Track(JSON: trackDict) else { continue }
                        tracksInThisBatch.append(track)
                    }
                }
                
                tracks?.append(contentsOf: tracksInThisBatch)
                
                // Notify callback
                loaded(paging, tracksInThisBatch)
                
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
        
        // Formulate the json params
        var json = [[String: Any]]()
        for track in tracks {
            if let uri = track.track.uri {
                json.append(["uri": uri, "positions": track.positions])
            }
        }
        
        let requestData = ["tracks": json]
        
        // Submit the request to delete the specified tracks
        _ = appDelegate.oauthswift!.client.request("https://api.spotify.com/v1/playlists/\(playlistId)/tracks", method: .DELETE,
                                                   headers: ["Accept": "application/json", "Content-Type":"application/json"], body: try? JSON(requestData).rawData(), checkTokenExpiration: true, success: { (response) in
                                                    
                                                    // Handle success
                                                    completion()
                                                    
        }) { (error) in
            appDelegate.oauthErrorHandler(error: error) {
                // Retry this very method with the same params
                self.deleteTracks(tracks, completion: completion)
            }
        }
        
        
    }
    
    private func getNextTrack(next: String, loaded: @escaping (Paging, [Track]?) -> Void) {
        
        // Gets the next items
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

        // Get the list of user playlists
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
    
    // Holds the uris that need to be submitted
    
    var pendingUris: [[String]]?
    
    public func replaceTracksWithCurrent() {
        replaceTracksWithTracks(uris: self.urisFromTracks())
    }
    
    public func replaceTracksWithTracks(uris: [String]?) {
        guard let playlistId = id, let allUris = uris else { return }
        
        // Get the uris in batches of 100
        pendingUris = allUris.batches(by: 100)
        guard let firstBatch = self.pendingUris?.first else {return}
        
        // Formulate json
        var json = [String: Any]()
        json["uris"] = firstBatch
        
        // Debug print
        let requestData = json
        print("\n\n"+requestData.description+"\n\n")
        
        
        _ = appDelegate.oauthswift!.client.request("https://api.spotify.com/v1/playlists/\(playlistId)/tracks", method: .PUT,
                                                   headers: ["Accept": "application/json", "Content-Type":"application/json"], body: try? JSON(requestData).rawData(), checkTokenExpiration: true, success: { (response) in
                                                    // Remove the batch that was completed
                                                    self.pendingUris?.removeFirst()
                                                    
                                                    // Submit the next request to load the next uris that were not in this batch
                                                    self.appendPendingTracksToPlaylist()
        }) { (error) in
            appDelegate.oauthErrorHandler(error: error) {
                // Retry this very method with the same params
                self.replaceTracksWithTracks(uris: uris)
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
                                                    // Remove the batch that was completed
                                                    self.pendingUris?.removeFirst()
                                                    // Submit the next request to load the next uris that were not in this batch
                                                    self.appendPendingTracksToPlaylist()
        }) { (error) in
            appDelegate.oauthErrorHandler(error: error) {
                // Retry this very method with the same params
                self.appendPendingTracksToPlaylist()
                return
            }
        }
    }
    
    // Gets all uris from self.tracks
    public func urisFromTracks() -> [String]? {
        guard let allTracks = self.tracks else { return nil }
        var uris: [String] = []
        
        for track in allTracks {
            guard let uri = track.uri else {continue}
            uris.append(uri)
        }
        
        return uris
    }
    
    public class func create(user: User, name: String?, success: @escaping (Playlist)->()) {
        guard let userId = user.id, let name = name else {return}
        let json = ["name": name]
        _ = appDelegate.oauthswift!.client.request("https://api.spotify.com/v1/users/\(userId)/playlists", method: .POST,
                                                   headers: ["Accept": "application/json", "Content-Type":"application/json"], body: try? JSON(json).rawData(), checkTokenExpiration: true, success: { (response) in
                                                    do {
                                                        let rootObj = try JSON(data: response.data)
                                                        
                                                        // Get our paging object
                                                        if let rootDict = rootObj.dictionaryObject {
                                                            
                                                            guard let plist = Playlist(JSON: rootDict) else { return }
                                                            success(plist)
                                                        }
                                                        
                                                    } catch {
                                                        print("JSON ERROR: \(error.localizedDescription)")
                                                    }
        }) { (error) in
            appDelegate.oauthErrorHandler(error: error) {
                // Retry this very method with the same params
                self.create(user: user, name: name, success: success)
                return
            }
        }
    }
}
