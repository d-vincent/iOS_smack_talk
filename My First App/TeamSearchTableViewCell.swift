//
//  TeamSearchTableViewCell.swift
//  Smack Talk
//
//  Created by Drew McDonald on 11/10/17.
//  Copyright © 2017 Drew McDonald. All rights reserved.
//

import UIKit

class TeamSearchTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    @IBOutlet weak var teamLogo: UIImageView!
    @IBOutlet weak var TeamName: UILabel!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
