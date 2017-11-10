//
//  ReplyTableViewCell.swift
//  Smack Talk
//
//  Created by Drew McDonald on 10/31/17.
//  Copyright © 2017 Drew McDonald. All rights reserved.
//

import UIKit


class ReplyTableViewCell: UITableViewCell{
    
    
    @IBOutlet weak var authorName: UILabel!
    
    @IBOutlet weak var authorLogo: UIImageView!
    @IBOutlet weak var content: UITextView!
    
    @IBOutlet weak var timeSince: UILabel!
    @IBOutlet weak var voteBackground: UIView!
    @IBOutlet weak var replyContent: UITextView!
    @IBOutlet weak var upVoteButton: UIButton!
    @IBOutlet weak var downVoteButton: UIButton!
    @IBOutlet weak var voteCount: UILabel!
}
