//
//  OperationButtonView.swift
//  Fuse
//
//  Created by Bailey Seymour on 11/2/18.
//  Copyright © 2018 Bailey Seymour. All rights reserved.
//

import UIKit

class OperationButtonView: UIView {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    private(set) var isSelected: Bool = false
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        updateView()
    }
    
    private func updateView() {
        
        if isSelected {
            imageView.tintColor = UIColor(named: "secondary")
            label.textColor = UIColor(named: "secondary")
        } else {
            imageView.tintColor = .white
            label.textColor = .white
        }
        
    }

    func setSelected(_ selected: Bool) {
        self.isSelected = selected
        UIView.animate(withDuration: 0.3) {
            self.updateView()
        }
        
    }
}
