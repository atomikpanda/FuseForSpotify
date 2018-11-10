//
//  PlaylistSelectionViewController.swift
//  Fuse
//
//  Created by Bailey Seymour on 11/3/18.
//  Copyright © 2018 Bailey Seymour. All rights reserved.
//
// Bailey Seymour
// DVP4 1811

import UIKit

class PlaylistSelectionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // The playlists to display
    var playlists: [Playlist] = []
    
    // The cell with a checkmark or nil for not selected yet
    var selectedIndexPath: IndexPath?
    
    // The playlist object that was selected
    var selectedPlaylist: Playlist?
    
    // The playlistA's name
    var playlistAName: String?
    
    // The operation with will be performed
    var operationType: OperationType?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the table view
        tableView.delegate = self
        tableView.dataSource = self
        
        // Set up the prompt
        // this helps the user understand what operation
        // will be performed and with what playlists
        switch operationType {
        case .some(.combine):
            navigationItem.prompt = "Choose a playlist to combine \(playlistAName ?? "") with..."
        case .some(.intersect):
            navigationItem.prompt = "Choose a playlist to intersect \(playlistAName ?? "") with..."
        case .some(.subtract):
            navigationItem.prompt = "Choose a playlist to subtract from \(playlistAName ?? "")..."
        default:
            break
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupFuseAppearance()
    }
    
    @IBAction func cancelTapped(_ sender: AnyObject) {
        // Cancel the whole operation
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Table View Data Source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "playlistSelectionCell", for: indexPath) as! PlaylistSelectionTableViewCell
        
        guard playlists.count > indexPath.row else { return cell}
        
        // Configure cell
        cell.playlistTitleLabel.text = playlists[indexPath.row].name
        let numTracks = playlists[indexPath.row].numberOfTracks ?? 0
        cell.tracksLabel.text = "\(numTracks) Tracks"
        
        // If this is the selected cell than show a checkmark
        if indexPath == selectedIndexPath {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // If the same cell was reselected, do nothing
        guard indexPath != selectedIndexPath else {return}
        
        // Save the selected playlist
        selectedPlaylist = playlists[indexPath.row]
        
        // If it's selected then show a checkmark
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .checkmark
        }
        
        // If we have a previous cell
        // we need to deselect it
        if let prevIndexPath = selectedIndexPath,  let prevCell = tableView.cellForRow(at: prevIndexPath) {
            prevCell.accessoryType = .none
        }
        
        // Save the indexPath that was selected
        selectedIndexPath = indexPath
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Check if we should enable the done button
        checkForDone()
    }
    
    func checkForDone() {
        
        // If we have a selection then enable the done button
        if selectedPlaylist != nil {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneTapped(_:)))
        } else {
            navigationItem.rightBarButtonItem = nil
        }
        
    }
    
    @objc func doneTapped(_ sender: Any?) {
        // Go back to the operation screen
        // now that we have all of our data
        performSegue(withIdentifier: "unwindToOperation", sender: self)
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
