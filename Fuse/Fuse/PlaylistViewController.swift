//
//  PlaylistViewController.swift
//  Fuse
//
//  Created by Bailey Seymour on 10/30/18.
//  Copyright © 2018 Bailey Seymour. All rights reserved.
//
// Bailey Seymour
// DVP4 1811

import UIKit

class PlaylistViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Outlets & Vars
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var progressView: UIProgressView!
    var playlists: [Playlist]?
    
    var playlist: Playlist?
    var tracks: [Track] = []
    var loadingTracks: [Track] = []
    var needsToUpdateRemote: Bool = false
    let session = URLSession(configuration: .default)
    
    // Toolbar buttons
    
    var leftBarButtonItem: UIBarButtonItem? {
        get {
            return toolbar.items?[0]
        } set {
            if let btn = newValue {
                toolbar.items?[0] = btn
            }
        }
    }
    
    var centerBarButtonItem: UIBarButtonItem? {
        get {
            return toolbar.items?[2]
        } set {
            if let btn = newValue {
                toolbar.items?[2] = btn
            }
        }
    }
    
    var rightBarButtonItem: UIBarButtonItem? {
        get {
            return toolbar.items?[4]
        } set {
            if let btn = newValue {
                toolbar.items?[4] = btn
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let headerNib = UINib(nibName: "PlaylistHeaderView", bundle: Bundle.main)
        tableView.register(headerNib, forHeaderFooterViewReuseIdentifier: "playlistHeaderCell")
        
        // Set up table view
        tableView.dataSource = self
        tableView.delegate = self
        
        self.title = ""
        
        #if MILESTONE3
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "statsIcon"), style: .plain, target: self, action: #selector(openStats(_:)))
        #endif
        
        // Load the non-edit items
        normalToolbarItems()
        
        // Start loading the tracks
        loadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        // Save data if we are in edit mode
        if self.tableView.isEditing && self.needsToUpdateRemote {
            self.editTapped(nil)
        }
    }
    
    func loadData() {
        // Initiate the load
        progressView.setProgress(0, animated: false)
        loadingTracks.removeAll()
        playlist?.loadTracks(loaded: trackBatchDidLoad(_:_:))
    }
    
    func trackBatchDidLoad(_ paging: Paging, _ tracks: [Track]?) {
        guard let loadedTracks = tracks else { return }
        
        // Load the audio features after we just loaded this batch
        AudioFeatures.loadFeatures(for: loadedTracks, completion: featureBatchDidLoad(_:))
        
    }
    
    func featureBatchDidLoad(_ tracks: [Track]?) {
        guard let loadedTracks = tracks else { return }
        
        self.loadingTracks.append(contentsOf: loadedTracks)
        
        // Update the progress bar
        if let total = self.playlist?.numberOfTracks {
            let progress = Float(self.loadingTracks.count)/Float(total)
            DispatchQueue.main.async {
                
                if progress > 0 {
                    
                    CATransaction.begin()
                    // Update the progress bar to 0 after animating
                    CATransaction.setCompletionBlock {
                        if progress == 1.0 {
                            self.progressView.setProgress(0.0, animated: false)
                        }
                    }
                    self.progressView.setProgress(progress, animated: true)
                    CATransaction.commit()
                    
                }
            }
        }
        
        print("loaded: \(self.loadingTracks.count) of \(playlist?.numberOfTracks ?? 0)")
        
        // Check if we are done loading everything
        if self.loadingTracks.count == self.playlist?.numberOfTracks ?? 0 {
            self.finishedLoadingAllBatches()
        } else {
            // We are not done yet
            // Set the tracks we have so far and reload the table view
            self.tracks = loadingTracks
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func finishedLoadingAllBatches() {
        self.tracks = loadingTracks
        self.loadingTracks.removeAll()
        
        // Start loading the audio features for each track
        
        DispatchQueue.main.async {
            
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Actions
    
    @IBAction func editTapped(_ sender: UIBarButtonItem?) {
        tableView.setEditing(!tableView.isEditing, animated: true)
        
        if tableView.isEditing {
            // Now we are in edit mode
            needsToUpdateRemote = false
            
            editToolbarItems()
            
        } else {
            // Now we are in normal mode
            
            if needsToUpdateRemote == true {
                // If the user made a change update the tracks in a playlist
                // with the current tracks property of the playlist we are in
                self.playlist?.tracks = self.tracks
                self.playlist?.replaceTracksWithCurrent()
            }
            
            // Now that we've submitted the request we don't need to update again if the user presses the back button
            self.needsToUpdateRemote = false
            
            normalToolbarItems()
            
        }
    }
    
    func editToolbarItems() {
        // Update toolbar items edit mode
        centerBarButtonItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(editTapped(_:)))
        rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(trashTapped(_:)))
    }
    
    func normalToolbarItems() {
        // Update toolbar items for normal mdoe
        leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editTapped(_:)))
        
        #if MILESTONE2
        centerBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "operationIcon"), style: .plain, target: self, action: #selector(doOperation(_:)))
        #endif
        
        #if MILESTONE3
        rightBarButtonItem = UIBarButtonItem(title: "Open Spotify", style: .plain, target: self, action: #selector(openSpotify(_:)))
        #else
        rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        #endif
    }
    
    @IBAction func doOperation(_ sender: AnyObject) {
        // Center button to show the operation view controller
        performSegue(withIdentifier: "toOperation", sender: self)
    }
    
    @IBAction func openStats(_ sender: AnyObject) {
        performSegue(withIdentifier: "toStats", sender: self)
    }
    
    @IBAction func trashTapped(_ sender: AnyObject) {
        
        guard var selectedIndexPaths = self.tableView.indexPathsForSelectedRows else {return}
        
        confirmDelete {
            
            // Reverse sort for deletion indexes
            selectedIndexPaths.sort {
                $0.row > $1.row
            }
            
            for indexPath in selectedIndexPaths {
                self.tracks.remove(at: indexPath.row)
                self.needsToUpdateRemote = true
            }
            self.playlist?.tracks = self.tracks
            
            DispatchQueue.main.async {
                // Update the table view on the main thread
                self.tableView.deleteRows(at: selectedIndexPaths, with: .left)
                self.tableView.reloadData()
                
                // Go back to normal mode and submit the request to save
                // by programmatically pressing the done button
                self.editTapped(nil)
            }
            
        }
    }
    
    @IBAction func openSpotify(_ sender: AnyObject) {
        print("TODO: implement \(#function)")
    }
    
    func confirmDelete(onDeletePressed: @escaping () -> ()) {
        // Show alert before deletion
        let alert = UIAlertController(title: "Delete Items", message: "Are you sure you want to delete these items?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            // Run delete code
            onDeletePressed()
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toOperation", let nav = segue.destination as? UINavigationController, let dest = nav.topViewController as? OperationViewController {
            dest.playlists = playlists
            dest.playlistA = self.playlist
        }
     }

}
