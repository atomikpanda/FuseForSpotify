//
//  PlaylistListViewController.swift
//  Fuse
//
//  Created by Bailey Seymour on 10/30/18.
//  Copyright © 2018 Bailey Seymour. All rights reserved.
//

import UIKit

class PlaylistListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var tableView: UITableView!
    var playlists: [Playlist] = []
    var currentUser: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        
        User.me { user in
            self.currentUser = user
        }
        
        playlists.removeAll()
        Playlist.loadUserPlaylists { (paging, playlists) in
            if let loadedPlaylists = playlists {
                self.playlists.append(contentsOf: loadedPlaylists)
                
                // Only current user's
                self.playlists = self.playlists.filter({ (aPlaylist) -> Bool in
                    return aPlaylist.owner?.id == self.currentUser?.id
                })
                
//                if self.playlists.count == paging.total ?? 0 {
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
//                }
            }
        }
    }
    
    // MARK: - UITableView Data Source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "playlistCell", for: indexPath) as! PlaylistTableViewCell
        cell.playlistTitleLabel.text = playlists[indexPath.row].name
        
        let numTracks = playlists[indexPath.row].numberOfTracks ?? 0
        cell.tracksLabel.text = "\(numTracks) Tracks"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toTracks", sender: self)
//        playlists[indexPath.row].loadTracks { (paging, loadedTracks) in
//            print("l: \(loadedTracks)")
//        }
    }

    @IBAction func logout(_ sender: AnyObject) {
        // TODO: Remove all cookies and saved token data
        performSegue(withIdentifier: "unwindToWelcome", sender: self)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toTracks",
            let dest = segue.destination as? PlaylistViewController,
            let selectedIndex = tableView.indexPathsForSelectedRows?.first {
            dest.playlist = playlists[selectedIndex.row]
        }
    }
    

}
