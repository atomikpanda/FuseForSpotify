//
//  PlaylistListViewController+TableView.swift
//  Fuse
//
//  Created by Bailey Seymour on 11/8/18.
//  Copyright © 2018 Bailey Seymour. All rights reserved.
//
// Bailey Seymour
// DVP4 1811

import UIKit

fileprivate let cellId = "playlistCell"

extension PlaylistListViewController {
    // MARK: - UITableView Data Source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! PlaylistTableViewCell
        
        guard playlists.count > indexPath.row else { return cell}
        
        // Configure cell
        cell.playlistTitleLabel?.text = playlists[indexPath.row].name
        let numTracks = playlists[indexPath.row].numberOfTracks ?? 0
        cell.tracksLabel?.text = "\(numTracks) Tracks"
        
        // Use different base font sizes for iPad
        if traitCollection.isRegularRegular {
            cell.playlistTitleLabel.font = UIFont.adjustedForFuse(regular: 20)
            cell.tracksLabel.font = UIFont.adjustedForFuse(regular: 18)
        }
        else {
            cell.playlistTitleLabel.font = UIFont.adjustedForFuse(regular: 17)
            cell.tracksLabel.font = UIFont.adjustedForFuse(regular: 15)
        }
        
        
        cell.playlistImageView.image = #imageLiteral(resourceName: "playlistPlaceholder")
        
        // Set up the image to load asynchronously
        if let imageURLString = playlists[indexPath.row].getPreferredImage(ofSize: traitCollection.isRegularRegular ? .medium : .small)?.url
        {
            UIImage.download(url: URL(string: imageURLString), session: session) { (image) in
                DispatchQueue.main.async {
                    cell.playlistImageView.image = image
                }
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Go to the tracks for this playlist
        if shouldPerformSegue(withIdentifier: "toTracks", sender: self) {
            performSegue(withIdentifier: "toTracks", sender: self)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if traitCollection.isRegularRegular && UIFont.fuseFontSize != .small {
            return 80
        } else if !traitCollection.isRegularRegular && UIFont.fuseFontSize == .small {
            return 45
        }
        
        return 60
    }
    
}
