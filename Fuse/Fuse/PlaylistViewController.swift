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
    
    var playlist: Playlist?
    var needsToUpdateRemote: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up table view
        tableView.dataSource = self
        tableView.delegate = self
        
        self.title = playlist?.name
        
        // Start loading the tracks
        playlist?.loadTracks { (paging, loadedTracks) in
            guard let loadedTracks = loadedTracks else { return }
            
            // Start loading the audio features for each track
            AudioFeatures.loadFeatures(for: loadedTracks, completion: { (tracks) in
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            })
            
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        // Save data if we are in edit mode
        if self.tableView.isEditing && self.needsToUpdateRemote {
            self.editTapped(nil)
        }
    }
    
    // MARK: - Table View Data Source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlist?.tracks?.count ?? 0
    }
    
    // MARK: - Reordering / Rearranging
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard let track = self.playlist?.tracks?[sourceIndexPath.row] else {return}
        
        // Modify data model to reflect the new position
        playlist?.tracks?.remove(at: sourceIndexPath.row)
        playlist?.tracks?.insert(track, at: destinationIndexPath.row)
        
        // We need to update the remote data source when the user presses done or back
        self.needsToUpdateRemote = true
        
        print("index: \(sourceIndexPath.row) to \(destinationIndexPath.row)")
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "trackCell") as! TrackTableViewCell
        
        // Configure cell
        let track = playlist?.tracks?[indexPath.row]
        cell.trackLabel.text = track?.name
        cell.artistLabel.text = track?.artists?.first?.name
        
        // TODO: Milestone 2
        cell.infoLabel.text = "\(Int(track?.features?.tempo?.rounded() ?? 0))"
        
        return cell
    }
    
    // MARK: - Editing / Swipe to Delete
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            // Get the track
            let track = self.playlist?.tracks?[indexPath.row]
            
            if let trackToDelete = track {
                
                // Get the track at the position so that we don't delete other occurrences
                let trackAtPosition = TrackAtPosition(track: trackToDelete, positions: [indexPath.row])
                
                // Send the request to delete our track with the id and specified position
                playlist?.deleteTracks([trackAtPosition], completion: {
                    // Deleted successfully from remote server
                    
                    print("deleted...")
                    
                    // Remove it from our data model
                    self.playlist?.tracks?.remove(at: indexPath.row)
                    
                    DispatchQueue.main.async {
                        // Delete the row and reload
                        self.tableView.deleteRows(at: [indexPath], with: .left)
                        self.tableView.reloadData()
                    }
                    
                })
            }
            
        }
    }
    
    // MARK: - Actions
    
    @IBAction func editTapped(_ sender: UIBarButtonItem?) {
        tableView.setEditing(!tableView.isEditing, animated: true)
        
        if tableView.isEditing {
            // Now we are in edit mode
            needsToUpdateRemote = false
            
            // Update toolbar items edit mode
            toolbar.items?[2] = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
            toolbar.items?[0] = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(editTapped(_:)))
            toolbar.items?[4] = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(trashTapped(_:)))
        } else {
            // Now we are in normal mode
            
            if needsToUpdateRemote == true {
                // If the user made a change update the tracks in a playlist
                // with the current tracks property of the playlist we are in
                self.playlist?.replaceTracksWithCurrent()
            }
            
            // Now that we've submitted the request we don't need to update again if the user presses the back button
            self.needsToUpdateRemote = false
            
            // Update toolbar items for normal mdoe
            toolbar.items?[0] = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editTapped(_:)))
            
            toolbar.items?[2] = UIBarButtonItem(image: #imageLiteral(resourceName: "operationIcon"), style: .plain, target: self, action: #selector(doOperation(_:)))
            
            toolbar.items?[4] = UIBarButtonItem(title: "Open Spotify", style: .plain, target: self, action: #selector(openSpotify(_:)))
            
            toolbar.items?[4] = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
            toolbar.items?[2] = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
            
        }
    }
    
    @IBAction func doOperation(_ sender: AnyObject) {
        // Center button to show the operation view controller
        print("TODO: implement \(#function)")
    }
    
    @IBAction func trashTapped(_ sender: AnyObject) {
        
        guard var selectedIndexPaths = self.tableView.indexPathsForSelectedRows else {return}
        
        confirmDelete {
            
            // Reverse sort for deletion indexes
            selectedIndexPaths.sort {
                $0.row > $1.row
            }
            
            for indexPath in selectedIndexPaths {
                self.playlist?.tracks?.remove(at: indexPath.row)
                self.needsToUpdateRemote = true
            }
            
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
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
