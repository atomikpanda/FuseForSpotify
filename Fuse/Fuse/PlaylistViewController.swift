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
        let track = playlist?.tracks?[indexPath.row]
        cell.textLabel?.text = track?.name
        cell.detailTextLabel?.text = "\(Int(track?.features?.tempo?.rounded() ?? 0))"
        return cell
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
