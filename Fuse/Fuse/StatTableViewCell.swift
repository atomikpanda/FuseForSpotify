//
//  StatTableViewCell.swift
//  Fuse
//
//  Created by Bailey Seymour on 11/3/18.
//  Copyright © 2018 Bailey Seymour. All rights reserved.
//
// Bailey Seymour
// DVP4 1811

import UIKit

class StatTableViewCell: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var statLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Set up the appearance
        statLabel.textColor = .fuseTextPrimary
        backgroundColor = .fuseBackground
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
