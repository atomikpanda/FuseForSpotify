//
//  StatsViewController.swift
//  Fuse
//
//  Created by Bailey Seymour on 11/3/18.
//  Copyright © 2018 Bailey Seymour. All rights reserved.
//

import UIKit

class StatsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var tableView: UITableView!
    var stats: [Stat] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stats = [RawStat(name: "Average Tempo", percent: 0.65, color: .blue, rawValue: 112), Stat(name: "Energy Level", percent: 0.45, color: .yellow)]
        
        tableView.dataSource = self
        tableView.delegate = self
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       let cell = tableView.dequeueReusableCell(withIdentifier: "statCell", for: indexPath) as! StatTableViewCell
        
        let stat = stats[indexPath.row]
        
        if let rawStat = stat as? RawStat {
            cell.statLabel.text = "\(rawStat.name): \(rawStat.rawValue)\(rawStat.suffix)"
        } else {
            var percent = Int(stat.percent*100.0)
            if percent > 100 {
                percent = 100
            }
            cell.statLabel.text = "\(stat.name): \(percent)\(stat.suffix)"
        }
        
        cell.progressView.progress = Float(stat.percent)
        cell.progressView.tintColor = stat.color
        
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
