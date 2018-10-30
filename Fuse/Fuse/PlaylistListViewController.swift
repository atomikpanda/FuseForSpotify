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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        
        playlists.removeAll()
        Playlist.loadUserPlaylists { (paging, playlists) in
            if let loadedPlaylists = playlists {
                self.playlists.append(contentsOf: loadedPlaylists)
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
        return cell
    }

    @IBAction func logout(_ sender: AnyObject) {
       performSegue(withIdentifier: "unwindToWelcome", sender: self)
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
