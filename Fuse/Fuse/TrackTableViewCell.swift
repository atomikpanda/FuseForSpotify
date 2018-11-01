//
//  TrackTableViewCell.swift
//  Fuse
//
//  Created by Bailey Seymour on 10/30/18.
//  Copyright © 2018 Bailey Seymour. All rights reserved.
//

import UIKit

class TrackTableViewCell: UITableViewCell {

    @IBOutlet weak var trackLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectedBackgroundView = UIView()
        selectedBackgroundView?.backgroundColor = UIColor.darkGray
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
