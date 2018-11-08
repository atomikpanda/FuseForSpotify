//
//  PlaylistViewController+TableView.swift
//  Fuse
//
//  Created by Bailey Seymour on 11/8/18.
//  Copyright © 2018 Bailey Seymour. All rights reserved.
//
// Bailey Seymour
// DVP4 1811

import UIKit

extension PlaylistViewController {
    // MARK: - Table View Data Source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tracks.count
    }
    
    // MARK: - Reordering / Rearranging
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let track = tracks[sourceIndexPath.row]
        
        // Modify data model to reflect the new position
        tracks.remove(at: sourceIndexPath.row)
        tracks.insert(track, at: destinationIndexPath.row)
        self.playlist?.tracks = tracks
        
        // We need to update the remote data source when the user presses done or back
        self.needsToUpdateRemote = true
        
        print("index: \(sourceIndexPath.row) to \(destinationIndexPath.row)")
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "trackCell") as! TrackTableViewCell
        
        // Configure cell
        let track = tracks[indexPath.row]
        cell.trackLabel.text = track.name
        cell.artistLabel.text = track.artists?.first?.name
        
        // TODO: Milestone 3
        #if MILESTONE3
        cell.infoLabel.text = "\(Int(track.features?.tempo?.rounded() ?? 0))"
        #else
        cell.infoLabel.text = ""
        #endif
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "playlistHeaderCell") as! PlaylistHeaderViewCell
        
        header.titleLabel.text = self.playlist?.name
        header.tracksLabel.text = "\(self.tracks.count) Tracks"
        
        if let isPublic = self.playlist?.isPublic {
            header.privacyLabel.text = isPublic ? "Public" : "Private"
            header.privacyImageView.image = isPublic ? #imageLiteral(resourceName: "privacyPublicIcon") : #imageLiteral(resourceName: "privacyPrivateIcon")
        } else {
            header.privacyLabel.text = "Private"
            header.privacyImageView.image = #imageLiteral(resourceName: "privacyPrivateIcon")
        }
        
        guard header.playlistImageView.image == #imageLiteral(resourceName: "playlistPlaceholderLarge") else { return header }
        
        header.playlistImageView.image = #imageLiteral(resourceName: "playlistPlaceholderLarge")
        var imageURL: URL? = nil
        
        if self.playlist?.images?.count ?? 0 > 1, let imageURLString = self.playlist?.images?[1].url
        {
            imageURL = URL(string: imageURLString)
            
        } else if self.playlist?.images?.count ?? 0 > 0, let imageURLString = self.playlist?.images?.first?.url
        {
            imageURL = URL(string: imageURLString)
        }
        
        if let url = imageURL {
            let task = session.dataTask(with: URLRequest(url: url)){ (data, response, error) in
                guard let data = data else {return}
                DispatchQueue.main.async {
                    header.playlistImageView.image = UIImage(data: data)
                }
            }
            task.resume()
        }
        
        
        return header
    }
    
    // MARK: - Editing / Swipe to Delete
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            // Get the track
            let track = tracks[indexPath.row]
            
            
            
            // Get the track at the position so that we don't delete other occurrences
            let trackAtPosition = TrackAtPosition(track: track, positions: [indexPath.row])
            
            // Send the request to delete our track with the id and specified position
            playlist?.deleteTracks([trackAtPosition], completion: {
                // Deleted successfully from remote server
                
                print("deleted...")
                
                // Remove it from our data model
                self.tracks.remove(at: indexPath.row)
                self.playlist?.tracks = self.tracks
                
                DispatchQueue.main.async {
                    // Delete the row and reload
                    self.tableView.deleteRows(at: [indexPath], with: .left)
                    self.tableView.reloadData()
                }
                
            })
            
            
        }
    }
}
