//
//  PlaylistHeaderView.swift
//  Fuse
//
//  Created by Bailey Seymour on 11/6/18.
//  Copyright © 2018 Bailey Seymour. All rights reserved.
//
// Bailey Seymour
// DVP4 1811

import UIKit

class PlaylistHeaderViewCell: UITableViewHeaderFooterView {

    // MARK: - Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tracksLabel: UILabel!
    @IBOutlet weak var privacyLabel: UILabel!
    @IBOutlet weak var privacyImageView: UIImageView!
    @IBOutlet weak var playlistImageView: UIImageView!
    @IBOutlet weak var visualEffectView: UIVisualEffectView!

    func setupFuseAppearance() {
        // Set up the header's appearance
        titleLabel.textColor = .fuseTextPrimary
        tracksLabel.textColor = .fuseTextSecondary
        privacyLabel.textColor = .fuseTint
        privacyImageView.tintColor = .fuseTint
    }
   
    func setIsPublic(isPublic: Bool) {
        // Configure the header
        privacyLabel.text = isPublic ? "Public" : "Private"
        privacyImageView.image = isPublic ? #imageLiteral(resourceName: "privacyPublicIcon") : #imageLiteral(resourceName: "privacyPrivateIcon")
        privacyImageView.tintColor = .fuseTint
    }

}
