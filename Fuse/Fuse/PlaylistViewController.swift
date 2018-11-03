//
//  PlaylistViewController.swift
//  Fuse
//
//  Created by Bailey Seymour on 10/30/18.
//  Copyright © 2018 Bailey Seymour. All rights reserved.
//

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
        
        // Set up table view
        tableView.dataSource = self
        tableView.delegate = self
        
        self.title = playlist?.name
        
        disableTmpButtons()
        
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
        progressView.setProgress(0, animated: false)
        loadingTracks.removeAll()
        playlist?.loadTracks(loaded: trackBatchDidLoad(_:_:))
    }
    
    func trackBatchDidLoad(_ paging: Paging, _ tracks: [Track]?) {
        guard let loadedTracks = tracks else { return }
        
        self.loadingTracks.append(contentsOf: loadedTracks)
        
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
        
        print("loaded: \(self.loadingTracks.count) of \(paging.total ?? 0)")
        if self.loadingTracks.count == self.playlist?.numberOfTracks ?? 0 {
            self.finishedLoadingAllBatches()
        } else {
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
//        AudioFeatures.loadFeatures(for: loadedTracks, completion: { (tracks) in
//            
//            
//            
//        })
        DispatchQueue.main.async {
            
            self.tableView.reloadData()
        }
    }
    
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
        
        // TODO: Milestone 2
        cell.infoLabel.text = "\(Int(track.features?.tempo?.rounded() ?? 0))"
        
        return cell
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
    
    // MARK: - Actions
    
    @IBAction func editTapped(_ sender: UIBarButtonItem?) {
        tableView.setEditing(!tableView.isEditing, animated: true)
        
        if tableView.isEditing {
            // Now we are in edit mode
            needsToUpdateRemote = false
            
            // Update toolbar items edit mode
            centerBarButtonItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
            leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(editTapped(_:)))
            rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(trashTapped(_:)))
            
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
            
            // Update toolbar items for normal mdoe
            leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editTapped(_:)))
            
            centerBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "operationIcon"), style: .plain, target: self, action: #selector(doOperation(_:)))
            
            rightBarButtonItem = UIBarButtonItem(title: "Open Spotify", style: .plain, target: self, action: #selector(openSpotify(_:)))
            
            disableTmpButtons()
            
        }
    }
    
    func disableTmpButtons() {
        // TODO: Delete this method
        rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
//        centerBarButtonItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        navigationItem.rightBarButtonItem = nil
    }
    
    @IBAction func doOperation(_ sender: AnyObject) {
        // Center button to show the operation view controller
        print("TODO: implement \(#function)")
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
