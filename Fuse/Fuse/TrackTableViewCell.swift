//
//  TrackTableViewCell.swift
//  Fuse
//
//  Created by Bailey Seymour on 10/30/18.
//  Copyright © 2018 Bailey Seymour. All rights reserved.
//
// Bailey Seymour
// DVP4 1811

import UIKit

class TrackTableViewCell: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet weak var trackLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectedBackgroundView = UIView()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Set up the appearance
        setupSelectionView()
        trackLabel.textColor = .fuseTextPrimary
        artistLabel.textColor = .fuseTextSecondary
        infoLabel.textColor = .fuseTint
        backgroundColor = .fuseCell
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
