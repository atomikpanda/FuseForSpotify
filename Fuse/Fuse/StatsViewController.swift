//
//  StatsViewController.swift
//  Fuse
//
//  Created by Bailey Seymour on 11/3/18.
//  Copyright © 2018 Bailey Seymour. All rights reserved.
//
// Bailey Seymour
// DVP4 1811

import UIKit

class StatsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Outlets & Vars
    @IBOutlet weak var tableView: UITableView!
    var stats: [Stat] = []
    let session = URLSession(configuration: .default)
    var playlist: Playlist?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register our header
        let headerNib = UINib(nibName: "PlaylistHeaderView", bundle: Bundle.main)
        tableView.register(headerNib, forHeaderFooterViewReuseIdentifier: "statsHeaderCell")
        
        // Setup tableView
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        setupFuseAppearance()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "statCell", for: indexPath) as! StatTableViewCell
        
        let stat = stats[indexPath.row]
        
        if let rawStat = stat as? RawStat {
            // Use raw stat for tempo
            cell.statLabel.text = "\(rawStat.name): \(rawStat.rawValue)\(rawStat.suffix)"
        } else {
            // Use percent format
            var percent = Int(stat.percent*100.0)
            
            // if percent is somehow greater cap it at 100
            if percent > 100 {
                percent = 100
            }
            cell.statLabel.text = "\(stat.name): \(percent)\(stat.suffix)"
        }
        
        cell.progressView.progress = Float(stat.percent)
        cell.progressView.tintColor = stat.color
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "statsHeaderCell") as! PlaylistHeaderViewCell
        
        header.titleLabel.text = self.playlist?.name
        header.tracksLabel.text = "\(self.playlist?.numberOfTracks ?? 0) Tracks"
        header.setupFuseAppearance()
        
        header.setIsPublic(isPublic: self.playlist?.isPublic ?? false)
        
        guard header.playlistImageView.image == #imageLiteral(resourceName: "playlistPlaceholderLarge") else { return header }
        
        header.playlistImageView.image = #imageLiteral(resourceName: "playlistPlaceholderLarge")
        var imageURL: URL? = nil
        
        if let imageURLString = playlist?.getPreferredImage(ofSize: .medium)?.url
        {
            imageURL = URL(string: imageURLString)
        }
        
        // Load the header image
        UIImage.download(url: imageURL, session: session) { (image) in
            DispatchQueue.main.async {
                header.playlistImageView.image = image
            }
        }
        
        return header
    }
    
}
