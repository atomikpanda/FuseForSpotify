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

extension PlaylistListViewController {
    // MARK: - UITableView Data Source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "playlistCell", for: indexPath) as! PlaylistTableViewCell
        
        guard playlists.count > indexPath.row else { return cell}
        
        // Configure cell
        cell.playlistTitleLabel.text = playlists[indexPath.row].name
        let numTracks = playlists[indexPath.row].numberOfTracks ?? 0
        cell.tracksLabel.text = "\(numTracks) Tracks"
        
        cell.playlistImageView.image = #imageLiteral(resourceName: "playlistPlaceholder")
        
        // Set up the image to load asynchronously
        if let imageURLString = playlists[indexPath.row].images?.last?.url,
            let imageURL = URL(string: imageURLString) {
            
            let task = session.dataTask(with: URLRequest(url: imageURL)){ (data, response, error) in
                guard let data = data else {return}
                DispatchQueue.main.async {
                    cell.playlistImageView.image = UIImage(data: data)
                }
            }
            task.resume()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Go to the tracks for this playlist
        if shouldPerformSegue(withIdentifier: "toTracks", sender: self) {
            performSegue(withIdentifier: "toTracks", sender: self)
        }
    }
}
