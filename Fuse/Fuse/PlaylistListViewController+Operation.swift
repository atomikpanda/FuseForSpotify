//
//  PlaylistListViewController+Operation.swift
//  Fuse
//
//  Created by Bailey Seymour on 11/8/18.
//  Copyright © 2018 Bailey Seymour. All rights reserved.
//
// Bailey Seymour
// DVP4 1811

import Foundation

extension PlaylistListViewController {
    
    func prepareForOperation(source: OperationViewController) {
        if let user = self.currentUser, let name = source.newPlaylistName,
            let a = source.playlistA, let b = source.playlistB {
            
            shouldBeginRefreshing = true
            // Load the tracks in playlist B
            b.loadTracks(loaded: { (paging, tracks) in
                guard let numberLoaded = b.tracks?.count, let numberOfTracks = b.numberOfTracks else {return}
                
                // If we now have all tracks
                if numberLoaded == numberOfTracks {
                    // Create new playlist
                    Playlist.create(user: user, name: name, success: { playlist in
                        
                        // Call the callback method
                        self.playlistWasCreated(playlist, operationToPerform: source.operationType, playlistA: a, playlistB: b)
                    }, failure: {
                        self.refreshControl.endRefreshing()
                    })
                }
            })
        }
    }
    
    func playlistWasCreated(_ newPlaylist: Playlist, operationToPerform: OperationType, playlistA: Playlist, playlistB: Playlist) {
        
        var uris: [String] = []
        
        switch operationToPerform {
            
            // MARK: - COMBINE
        case .combine:
            if let aUris = playlistA.urisFromTracks(), let bUris = playlistB.urisFromTracks() {
                print("COMBINE: \(playlistA.name!) with \(playlistB.name!)")
                uris.append(contentsOf: aUris)
                uris.append(contentsOf: bUris)
            }
            break
            
            // MARK: - INTERSECT
        case .intersect:
            if let aUris = playlistA.urisFromTracks(), let bUris = playlistB.urisFromTracks() {
                print("INTERSECT: \(playlistA.name!) with \(playlistB.name!)")
                // If we find a uri that exists in A and B
                for uri in aUris {
                    if bUris.contains(uri) {
                        // Append it
                        uris.append(uri)
                    }
                }
            }
            break
            
            // MARK: - SUBTRACT
        case .subtract:
            if let aUris = playlistA.urisFromTracks(), let bUris = playlistB.urisFromTracks() {
                print("SUBTRACT B:\(playlistB.name!) from A: \(playlistA.name!)")
                for uri in aUris {
                    // If it doesn't exist in playlist B, then we can append it
                    if bUris.contains(uri) == false {
                        uris.append(uri)
                    }
                }
            }
            break
        }
        
        // There's no need to submit the request if we don't have anything to add
        if uris.count > 0 {
            newPlaylist.replaceTracksWithTracks(uris: uris, replaceFinished: {
                self.loadData()
            }, replaceFailed: {
                self.loadData()
            })
        } else {
            loadData()
        }
        
        
    }
}
