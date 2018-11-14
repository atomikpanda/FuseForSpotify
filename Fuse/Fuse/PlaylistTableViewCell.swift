//
//  PlaylistTableViewCell.swift
//  Fuse
//
//  Created by Bailey Seymour on 10/30/18.
//  Copyright © 2018 Bailey Seymour. All rights reserved.
//
// Bailey Seymour
// DVP4 1811

import UIKit

class PlaylistTableViewCell: UITableViewCell {
    // MARK: - Outlets

    @IBOutlet var playlistTitleLabel: UILabel!
    @IBOutlet var tracksLabel: UILabel!
    @IBOutlet var playlistImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()

        selectedBackgroundView = UIView()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        // Configure the cell's appearance
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
