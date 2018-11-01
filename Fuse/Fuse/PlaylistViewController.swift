//
//  PlaylistViewController.swift
//  Fuse
//
//  Created by Bailey Seymour on 10/30/18.
//  Copyright © 2018 Bailey Seymour. All rights reserved.
//

import UIKit

class PlaylistViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var toolbar: UIToolbar!
    
    var playlist: Playlist?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        // Do any additional setup after loading the view.
        self.title = playlist?.name
        playlist?.loadTracks { (paging, loadedTracks) in
            guard let loadedTracks = loadedTracks else { return }
            AudioFeatures.loadFeatures(for: loadedTracks, completion: { (tracks) in
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            })
            
        }
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlist?.tracks?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "trackCell") as! TrackTableViewCell
        
        // Configure cell
        let track = playlist?.tracks?[indexPath.row]
        cell.trackLabel.text = track?.name
        cell.artistLabel.text = track?.artists?.first?.name
        
        // TODO: Milestone 2
        cell.infoLabel.text = ""
//        cell.infoLabel.text = "\(Int(track?.features?.tempo?.rounded() ?? 0))"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let track = self.playlist?.tracks?[indexPath.row]
            if let trackToDelete = track {
                let trackAtPosition = TrackAtPosition(track: trackToDelete, positions: [indexPath.row])
                playlist?.deleteTracks([trackAtPosition], completion: {
                    print("deleted...")
                    
                    self.playlist?.tracks?.remove(at: indexPath.row)
                    
                    DispatchQueue.main.async {
                        self.tableView.deleteRows(at: [indexPath], with: .left)
                        self.tableView.reloadData()
                    }
                    
                })
            }
            
        }
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
    
    @IBAction func editTapped(_ sender: UIBarButtonItem?) {
        tableView.setEditing(!tableView.isEditing, animated: true)
        
        if tableView.isEditing {
            // Now we are in edit mode
            toolbar.items?[2] = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
            
            toolbar.items?[0] = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(editTapped(_:)))
            toolbar.items?[4] = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(trashTapped(_:)))
        } else {
            toolbar.items?[0] = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editTapped(_:)))
            // Now we are in normal mode
            toolbar.items?[2] = UIBarButtonItem(image: #imageLiteral(resourceName: "operationIcon"), style: .plain, target: self, action: #selector(doOperation(_:)))
            toolbar.items?[4] = UIBarButtonItem(title: "Open Spotify", style: .plain, target: self, action: #selector(openSpotify(_:)))
        }
    }
    
    @IBAction func doOperation(_ sender: AnyObject) {
        // Center button to show the operation view controller
        print("TODO: implement \(#function)")
    }
    
    @IBAction func trashTapped(_ sender: AnyObject) {
        print("TODO: implement \(#function)")
        guard var selectedIndexPaths = self.tableView.indexPathsForSelectedRows else {return}
        confirmDelete {
            
            selectedIndexPaths.sort {
                $0.row > $1.row
            }
            
            var tracksAtPositions: [TrackAtPosition] = []
            for indexPath in selectedIndexPaths {
                let track = self.playlist?.tracks?[indexPath.row]
                
                if let trackToDelete = track {
                     tracksAtPositions.append(TrackAtPosition(track: trackToDelete, positions: [indexPath.row]))
                }
                
            }
            
            self.playlist?.deleteTracks(tracksAtPositions, completion: {
                print("deleted...")
                
                for indexPath in selectedIndexPaths {
                    self.playlist?.tracks?.remove(at: indexPath.row)
                }
                
                DispatchQueue.main.async {
                    self.tableView.deleteRows(at: selectedIndexPaths, with: .left)
                    self.tableView.reloadData()
                    self.editTapped(nil)
                }
                
            })
        }
    }
    
    @IBAction func openSpotify(_ sender: AnyObject) {
        print("TODO: implement \(#function)")
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
