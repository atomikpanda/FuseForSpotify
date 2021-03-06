//
//  PlaylistListViewController.swift
//  Fuse
//
//  Created by Bailey Seymour on 10/30/18.
//  Copyright © 2018 Bailey Seymour. All rights reserved.
//
// Bailey Seymour
// DVP4 1811

import UIKit
import Reachability

class PlaylistListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // Refresh
    let refreshControl: UIRefreshControl = UIRefreshControl()
    var shouldBeginRefreshing = false
    
    // Playlists
    var playlists: [Playlist] = []
    var loadingPlaylists: [Playlist] = []
    
    // Our user
    var currentUser: User?
    
    // Reachability
    let reachability = Reachability()!
    var isReachable: Bool = false
    
    // For image loading
    let session = URLSession(configuration: .default)
    
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up table view
        tableView.dataSource = self
        tableView.delegate = self
        tableView.refreshControl = refreshControl
        refreshControl.tintColor = .lightGray
        
        configureAndStartReachability()
        
        refreshControl.addTarget(self, action: #selector(loadData), for: .valueChanged)
        shouldBeginRefreshing = true
        
        loadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupFuseAppearance()
    }
    
    
    @IBAction func unwindToPlaylistsFromSettings(_ unwindSegue: UIStoryboardSegue) {
        
//        print("SETUP")
        self.appDelegate.setupAppearance(nav: self.navigationController, tableView: tableView)
        setupFuseAppearance()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Listen for failure in our AppDelegate
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(self, selector: #selector(failedToLoad),
                                               name: NSNotification.Name(rawValue: "failedToLoad"), object: nil)
        
        if shouldBeginRefreshing {
            animateRefresh()
        }
    }
    
    func animateRefresh() {
        // Automatically animate a refresh
        UIView.animate(withDuration: 0.3, animations: {
            self.tableView.setContentOffset(CGPoint(x: 0, y: -1), animated: false)
            self.tableView.setContentOffset(CGPoint(x: 0, y: 0-self.refreshControl.frame.size.height), animated: true)
        }, completion: { _ in
            self.refreshControl.beginRefreshing()
            self.shouldBeginRefreshing = false
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        refreshControl.endRefreshing()
        
        // Deselect the item that was selected when we go to a different view controller
        guard let indexPath = tableView.indexPathForSelectedRow else {return}
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @objc func failedToLoad() {
        BSLog.D("received")
        refreshControl.endRefreshing()
    }
    
    // MARK: - Loading
    
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
        
        // Fixed when loading finishes before viewDidAppear
        // (user doesn't have many playlists and a fast connection)
        shouldBeginRefreshing = false
        
        BSLog.D("Loaded all playlists")
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
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
        if let source = unwindSegue.source as? OperationViewController {
            // Perform the operation that was selected
            // in the source view controller
            prepareForOperation(source: source)
        }
    }
    
}
