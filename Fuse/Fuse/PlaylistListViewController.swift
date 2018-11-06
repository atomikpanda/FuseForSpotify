//
//  PlaylistListViewController.swift
//  Fuse
//
//  Created by Bailey Seymour on 10/30/18.
//  Copyright © 2018 Bailey Seymour. All rights reserved.
//

import UIKit
import Reachability

class PlaylistListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    let refreshControl: UIRefreshControl = UIRefreshControl()
    var playlists: [Playlist] = []
    var loadingPlaylists: [Playlist] = []
    var currentUser: User?
    let reachability = Reachability()!
    var isReachable: Bool = false
    let session = URLSession(configuration: .default)
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up table view
        tableView.dataSource = self
        tableView.delegate = self
        tableView.refreshControl = refreshControl
        
        reachability.whenReachable = { reachability in
            if reachability.connection != .none {
                self.isReachable = true
            }
            else {
                self.isReachable = false
            }
        }
        
        reachability.whenUnreachable = { reachability in
            if reachability.connection != .none {
                self.isReachable = true
            }
            else {
                self.isReachable = false
            }
        }
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Failed to start reachability")
        }
        
        refreshControl.addTarget(self, action: #selector(loadData), for: .valueChanged)
        
        loadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(self, selector: #selector(failedToLoad),
                                               name: NSNotification.Name(rawValue: "failedToLoad"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        refreshControl.endRefreshing()
        
        guard let indexPath = tableView.indexPathForSelectedRow else {return}
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @objc func failedToLoad() {
        print("refceived")
        refreshControl.endRefreshing()
    }
    
    @objc func loadData() {
        
        // Load user data
        User.me(completion: doneLoadingUser(_:))
        
    }
    
    func doneLoadingUser(_ user: User) {
        self.currentUser = user
        
        // Make sure we have our user data first
        // so then we load the playlists in batches
        Playlist.loadUserPlaylists(loaded: loadedPlaylistBatch(_:_:))
    }
    
    func loadedPlaylistBatch(_ paging: Paging, _ playlists: [Playlist]?) {
        
        if let loadedPlaylists = playlists {
            // Add the playlists we just loaded to our loaded playlists array
            self.loadingPlaylists.append(contentsOf: loadedPlaylists)
            
            // Check if we have loaded all batches
            if self.loadingPlaylists.count == paging.total ?? 0 {
                finishedLoadingAllBatches()
            }
        }
    }
    
    func finishedLoadingAllBatches() {
        
        // Only current user's own playlists
        self.loadingPlaylists = self.loadingPlaylists.filter({ (aPlaylist) -> Bool in
            return aPlaylist.owner?.id == self.currentUser?.id
        })
        
        // Load it into our Table View's data source and clear the loading array
        self.playlists = loadingPlaylists
        self.loadingPlaylists.removeAll()
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
        }
    }
    
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
    
    @IBAction func logout(_ sender: AnyObject) {
        
        // Confirmation before logout
        let confirmAlert = UIAlertController(title: "Log Out?", message: "Are you sure you want to log out?", preferredStyle: .alert)
        
        confirmAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        confirmAlert.addAction(UIAlertAction(title: "Logout", style: .default, handler: { _ in
            self.performSegue(withIdentifier: "unwindToWelcome", sender: self)
        }))
        
        present(confirmAlert, animated: true, completion: nil)
        
    }
    
    // MARK: - Navigation
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        
        // Check to make sure we don't show the tracks if we don't have a connection or proper data
        if identifier == "toTracks", let selectedIndex = tableView.indexPathsForSelectedRows?.first {
            if self.isReachable == false || !(playlists.count > selectedIndex.row) {
                
                let alert = UIAlertController(title: "Could not load playlist.", message: "Check your internet connection and try reloading.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                present(alert, animated: true, completion: nil)
                
                // Failed to segue so deselect
                tableView.deselectRow(at: selectedIndex, animated: true)
                
                return false
            }
        }
        
        return true
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toTracks",
            let dest = segue.destination as? PlaylistViewController,
            let selectedIndex = tableView.indexPathsForSelectedRows?.first {
            
            // Pass over our playlist object that was selected
            dest.playlist = playlists[selectedIndex.row]
            dest.playlists = playlists
            
        }
    }
    
    @IBAction func unwindToPlaylistList(_ unwindSegue: UIStoryboardSegue) {
        if let source = unwindSegue.source as? OperationViewController, let user = self.currentUser, let name = source.newPlaylistName,
            let a = source.playlistA, let b = source.playlistB {
            
            // Load the tracks in playlist B
            b.loadTracks(loaded: { (paging, tracks) in
                guard let numberLoaded = b.tracks?.count, let numberOfTracks = b.numberOfTracks else {return}
                
                // If we now have all tracks
                if numberLoaded == numberOfTracks {
                    
                    // Create new playlist
                    Playlist.create(user: user, name: name, success: { playlist in
                        
                        // Call the callback method
                        self.playlistWasCreated(playlist, operationToPerform: source.operationType, playlistA: a, playlistB: b)
                    })
                }
            })
        }
    }
    
    func playlistWasCreated(_ newPlaylist: Playlist, operationToPerform: OperationType, playlistA: Playlist, playlistB: Playlist) {
        
        var uris: [String] = []
        
        switch operationToPerform {
        case .combine:
            if let aUris = playlistA.urisFromTracks(), let bUris = playlistB.urisFromTracks() {
                print("COMBINE: \(playlistA.name!) with \(playlistB.name!)")
                uris.append(contentsOf: aUris)
                uris.append(contentsOf: bUris)
            }
            break
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
            newPlaylist.replaceTracksWithTracks(uris: uris)
        }
        
        loadData()
    }
    
}
