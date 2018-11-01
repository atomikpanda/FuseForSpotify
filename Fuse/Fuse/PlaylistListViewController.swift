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
    let refreshControl: UIRefreshControl = UIRefreshControl()
    var playlists: [Playlist] = []
    var currentUser: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.refreshControl = refreshControl
        
        NotificationCenter.default.addObserver(self, selector: #selector(failedToLoad),
                                               name: NSNotification.Name(rawValue: "failedToLoad"), object: nil)
        
        refreshControl.addTarget(self, action: #selector(loadData), for: .valueChanged)
        
        loadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func failedToLoad() {
        print("refceived")
        refreshControl.endRefreshing()
    }
    
    @objc func loadData() {
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
                        self.refreshControl.endRefreshing()
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
        guard playlists.count > indexPath.row else { return cell}
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
        let confirmAlert = UIAlertController(title: "Log Out?", message: "Are you sure you want to log out?", preferredStyle: .alert)
        confirmAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        confirmAlert.addAction(UIAlertAction(title: "Logout", style: .default, handler: { _ in
            self.performSegue(withIdentifier: "unwindToWelcome", sender: self)
        }))
        present(confirmAlert, animated: true, completion: nil)
        
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
