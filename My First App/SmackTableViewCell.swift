//
//  SmackTableViewCell.swift
//  Smack Talk
//
//  Created by Drew McDonald on 10/23/17.
//  Copyright © 2017 Drew McDonald. All rights reserved.
//

import UIKit

class SmackTableViewCell: UITableViewCell{
    
    @IBOutlet weak var content: UILabel!
    @IBOutlet weak var authorName: UILabel!
    
    @IBOutlet weak var voteBackground: UIView!
    @IBOutlet weak var authorLogo: UIImageView!
    
    @IBOutlet weak var upVoteButton: UIButton!
    @IBOutlet weak var downVoteButton: UIButton!
    
    @IBOutlet weak var replyCount: UILabel!
    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet weak var timeSince: UILabel!
    @IBOutlet weak var voteCount: UILabel!
    
    @objc func upVote(_ sender: Any){
        print("We upvotin' fam")
    }
}
