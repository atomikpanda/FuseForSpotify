//
//  PlaylistSelectionTableViewCell.swift
//  Fuse
//
//  Created by Bailey Seymour on 11/3/18.
//  Copyright © 2018 Bailey Seymour. All rights reserved.
//
// Bailey Seymour
// DVP4 1811

import UIKit

class PlaylistSelectionTableViewCell: UITableViewCell {
    
    // MARK: - Outlets
    @IBOutlet weak var playlistTitleLabel: UILabel!
    @IBOutlet weak var tracksLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectedBackgroundView = UIView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setupSelectionView()
        playlistTitleLabel.textColor = .fuseTextPrimary
        tracksLabel.textColor = .fuseTint
        backgroundColor = .fuseCell
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
