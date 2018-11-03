//
//  PlaylistSelectionViewController.swift
//  Fuse
//
//  Created by Bailey Seymour on 11/3/18.
//  Copyright © 2018 Bailey Seymour. All rights reserved.
//

import UIKit

class PlaylistSelectionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    var playlists: [Playlist] = []
    var selectedIndexPath: IndexPath?
    var selectedPlaylist: Playlist?
    var playlistAName: String?
    var operationType: OperationType?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
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
        // Do any additional setup after loading the view.
    }
    
    @IBAction func cancelTapped(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
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
        
        if indexPath == selectedIndexPath {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard indexPath != selectedIndexPath else {return}
        
        
        selectedPlaylist = playlists[indexPath.row]
        
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .checkmark
        }
        
        if let prevIndexPath = selectedIndexPath,  let prevCell = tableView.cellForRow(at: prevIndexPath) {
            prevCell.accessoryType = .none
        }
        
        selectedIndexPath = indexPath
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        checkForDone()
    }
    
    func checkForDone() {
        if selectedPlaylist != nil {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneTapped(_:)))
        } else {
            navigationItem.rightBarButtonItem = nil
        }
        
    }
    
    @objc func doneTapped(_ sender: Any?) {
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
