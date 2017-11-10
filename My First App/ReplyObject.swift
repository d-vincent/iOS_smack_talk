//
//  ReplyObject.swift
//  Smack Talk
//
//  Created by Drew McDonald on 10/31/17.
//  Copyright © 2017 Drew McDonald. All rights reserved.
//

import Foundation

struct ReplyObject {
    init(){
        
    }
    
    var replyId : String?
    var authorId : String?
    var smackId : String?
    var content : String?
    var timestamp : Int64?
    var username : String?
    var voteCount : Int64?
    var voteStatus: Int?
    var authorLogo : String?
    
}
