//
//  JuegoTableViewCell.swift
//  FinalCM
//
//  Created by Antonio Santiago on 11/14/15.
//  Copyright © 2015 Abner Castro Aguilar. All rights reserved.
//

import UIKit

class JuegoTableViewCell: UITableViewCell {

    // MARK: PROPERTIES
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var about: UILabel!
    @IBOutlet weak var thumbnail: UIImageView!
    
    
    // MARK: METHODS
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
