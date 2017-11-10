//
//  ReplyViewController.swift
//  Smack Talk
//
//  Created by Drew McDonald on 10/31/17.
//  Copyright © 2017 Drew McDonald. All rights reserved.
//

import UIKit
import Firebase

class ReplyViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @objc var ref: DatabaseReference!
    var smackId = ""
    var profileId = ""
    var replies = [ReplyObject]()

    @IBOutlet weak var replyTextField: UITextField!
    @IBOutlet weak var replyTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        weak var weakself = self
        ref = Database.database().reference()
        
        let preferences = UserDefaults.standard
        let uniqueIdKey = "uniqueIdKey"
        
        
        if preferences.object(forKey: uniqueIdKey) == nil {
            //  Doesn't exist
            profileId = UUID().uuidString
            preferences.set(profileId, forKey: uniqueIdKey)
            
        } else {
            profileId = (preferences.string(forKey: uniqueIdKey))!
        }
        
        ref.child("replies").queryOrdered(byChild: "smackId").queryEqual(toValue: smackId).observe(DataEventType.childAdded, with: {(snapshot) in
            
       
            
            var reply = ReplyObject()
            reply.authorId = (snapshot.childSnapshot(forPath: "authorId").value as! String)
            reply.replyId = snapshot.key
            reply.timestamp = (snapshot.childSnapshot(forPath: "timestamp").value as! Int64)
            reply.content = (snapshot.childSnapshot(forPath: "content").value as! String)
            
            if (snapshot.childSnapshot(forPath: "username").exists()){
                reply.username = (snapshot.childSnapshot(forPath: "username").value as! String)
            }
            reply.voteCount = (snapshot.childSnapshot(forPath: "voteCount").value as! Int64)
            
            weakself?.ref.child("profiles").child((weakself?.profileId)!).child("votes").child(snapshot.key).observeSingleEvent(of: DataEventType.value, with: {(voteSnap) in
                
                if (voteSnap.exists()){
                    reply.voteStatus = (voteSnap.value as! Int)
                }else {
                    reply.voteStatus = 0
                }
                weakself?.ref.child("profiles").child(reply.authorId!).child("preferredTeamId").observeSingleEvent(of: DataEventType.value, with: {(logosnap) in
                    
                    
                    if (logosnap.exists()){
                        reply.authorLogo = (logosnap.value as! String)
                    }
                    weakself?.replies.append(reply)
                    DispatchQueue.main.async{
                        weakself?.replyTableView.reloadData()
                    }
                
                })
                
            })
            
        })
        
        // Do any additional setup after loading the view.
    }

    @IBAction func sendReply(_ sender: Any) {
        
       var replyMap = [String : Any]()
        
        replyMap["authorId"] = profileId
        replyMap["smackId"] = smackId
        replyMap["timestamp"] = Date().toMillis()
        replyMap["voteCount"] = 0
        replyMap["content"] = replyTextField.text
        
        let replyKey = ref.child("replies").childByAutoId().key
        ref.child("replies").child(replyKey).setValue(replyMap)
        ref.child("profiles").child(profileId).child("replies").child(replyKey).setValue(true)
        ref.child("smacks").child(smackId).child("replyCount").observeSingleEvent(of: DataEventType.value, with:{(snapshot) in
            
            if (snapshot.exists()){
                var count = (snapshot.value) as! Int
                count = count + 1
                
                self.ref.child("smacks").child(self.smackId).child("replyCount").setValue(count)
            }else {
                self.ref.child("smacks").child(self.smackId).child("replyCount").setValue(1)
            }
        
            self.replyTextField.text = ""
            
            
        })
        
        
        
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return replies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reply = replies[indexPath.row]
        
        let cell = replyTableView.dequeueReusableCell(withIdentifier: "replyCell", for: indexPath) as! ReplyTableViewCell
        
        cell.authorName.text = reply.username
        if (reply.authorLogo != nil){
        cell.authorLogo.image = (UIImage (named: "logo_" + reply.authorLogo!))
        }
        
        if (reply.voteStatus == 1){
            cell.upVoteButton.setImage(UIImage (named: "up_white" ), for: UIControlState.normal)
            cell.downVoteButton.setImage(UIImage (named: "down_gray" ), for: UIControlState.normal)
            cell.voteBackground.backgroundColor = UIColor .green
        }else if (reply.voteStatus == -1){
            cell.upVoteButton.setImage(UIImage (named: "up_gray" ), for: UIControlState.normal)
            cell.downVoteButton.setImage(UIImage (named: "down_white" ), for: UIControlState.normal)
            cell.voteBackground.backgroundColor = UIColor .red
        } else {
            cell.upVoteButton.setImage(UIImage (named: "up_gray" ), for: UIControlState.normal)
            cell.downVoteButton.setImage(UIImage (named: "down_gray" ), for: UIControlState.normal)
            cell.voteBackground.backgroundColor = UIColor .lightGray
        }
        cell.content.text = reply.content
        cell.voteCount.text = String(reply.voteCount!)
        
        let timeago = Date().toMillis() - reply.timestamp!
        let seconds = timeago / 1000
        let minutes = seconds / 60
        let hours = minutes / 60
        let days = hours / 24
        let time : String
        
        if (days > 0){
            time = String(days) + "d"
        }else if(hours > 0){
            time = String(hours) + "h"
        }else {
            time = String(minutes) + "m"
        }
        cell.timeSince.text = time
        
        cell.upVoteButton.tag = indexPath.row
        cell.upVoteButton.addTarget(self, action: #selector(upVote(_:)), for: .touchUpInside)
        
        cell.downVoteButton.tag = indexPath.row
        cell.downVoteButton.addTarget(self, action: #selector(downVote(_:)), for: .touchUpInside)
        
        
        return cell
    }
    
    @objc func upVote(_ sender: UIButton){
        
        weak var weakSelf = self
        let reply = replies[sender.tag]
        
        var cell: ReplyTableViewCell
        cell = (replyTableView.cellForRow(at: IndexPath(row:sender.tag, section: 0)) ) as! ReplyTableViewCell
        
        switch reply.voteStatus! {
        case 0:
            sender.setImage(UIImage(named: "up_white"), for: UIControlState.normal)
            cell.downVoteButton.setImage(UIImage(named:"down_gray"), for: UIControlState.normal)
            cell.voteBackground.backgroundColor = UIColor .green
            
            replies[sender.tag].voteStatus = 1
            replies[sender.tag].voteCount = reply.voteCount! + 1
            cell.voteCount.text = String(replies[sender.tag].voteCount!)
            
            weakSelf?.ref.child("profiles").child(profileId).child("votes").child(reply.replyId!).setValue(1)
            
            changeVoteCount(smackId: reply.replyId!, amount: 1)
            changeKarma(userId: reply.authorId!, amount: 1)
            changeKarma(userId: profileId, amount: 1)
            
            DispatchQueue.main.async {
                weakSelf?.replyTableView.reloadData()
            }
            
        case 1:
            sender.setImage(UIImage(named: "up_gray"), for: UIControlState.normal)
            cell.downVoteButton.setImage(UIImage(named:"down_gray"), for: UIControlState.normal)
            cell.voteBackground.backgroundColor = UIColor .lightGray
            
            replies[sender.tag].voteStatus = 0
            replies[sender.tag].voteCount = reply.voteCount! - 1
            cell.voteCount.text = String(replies[sender.tag].voteCount!)
            
            weakSelf?.ref.child("profiles").child(profileId).child("votes").child(reply.replyId!).setValue(0)
            
            changeVoteCount(smackId: reply.replyId!, amount: -1)
            changeKarma(userId: reply.authorId!, amount: -1)
            changeKarma(userId: profileId, amount: -1)
            
            DispatchQueue.main.async {
                weakSelf?.replyTableView.reloadData()
            }
            
            
        case -1:
            sender.setImage(UIImage(named: "up_white"), for: UIControlState.normal)
            cell.downVoteButton.setImage(UIImage(named:"down_gray"), for: UIControlState.normal)
            cell.voteBackground.backgroundColor = UIColor .green
            
            replies[sender.tag].voteStatus = 1
            replies[sender.tag].voteCount = reply.voteCount! + 2
            cell.voteCount.text = String(replies[sender.tag].voteCount!)
            
            weakSelf?.ref.child("profiles").child(profileId).child("votes").child(reply.replyId!).setValue(1)
            
            changeVoteCount(smackId: reply.replyId!, amount: 2)
            changeKarma(userId: reply.authorId!, amount: 2)
            changeKarma(userId: profileId, amount: 2)
            
            DispatchQueue.main.async {
                weakSelf?.replyTableView.reloadData()
            }
            
        default:
            print("titties")
        }
        
    }
    
    @objc func downVote(_ sender: UIButton){
        
        weak var weakSelf = self
        var reply = replies[sender.tag]
        
        var cell: ReplyTableViewCell
        cell = (replyTableView.cellForRow(at: IndexPath(row:sender.tag, section: 0)) ) as! ReplyTableViewCell
        
        switch reply.voteStatus! {
        case 0:
            sender.setImage(UIImage(named: "down_white"), for: UIControlState.normal)
            cell.upVoteButton.setImage(UIImage(named:"up_gray"), for: UIControlState.normal)
            cell.voteBackground.backgroundColor = UIColor .red
            
            replies[sender.tag].voteStatus = -1
            replies[sender.tag].voteCount = reply.voteCount! - 1
            cell.voteCount.text = String(replies[sender.tag].voteCount!)
            
            weakSelf?.ref.child("profiles").child(profileId).child("votes").child(reply.replyId!).setValue(-1)
            
            changeVoteCount(smackId: reply.replyId!, amount: -1)
            changeKarma(userId: reply.authorId!, amount: -1)
            changeKarma(userId: profileId, amount: -1)
            
            DispatchQueue.main.async {
                weakSelf?.replyTableView.reloadData()
            }
            
        case 1:
            sender.setImage(UIImage(named: "down_white"), for: UIControlState.normal)
            cell.upVoteButton.setImage(UIImage(named:"up_gray"), for: UIControlState.normal)
            
            cell.voteBackground.backgroundColor = UIColor .red
            
            replies[sender.tag].voteStatus = -1
            replies[sender.tag].voteCount = reply.voteCount! - 2
            cell.voteCount.text = String(replies[sender.tag].voteCount!)
            
            weakSelf?.ref.child("profiles").child(profileId).child("votes").child(reply.replyId!).setValue(-1)
            
            changeVoteCount(smackId: reply.replyId!, amount: -2)
            changeKarma(userId: reply.authorId!, amount: -2)
            changeKarma(userId: profileId, amount: -2)
            
            
            DispatchQueue.main.async {
                weakSelf?.replyTableView.reloadData()
            }
            
        case -1:
            sender.setImage(UIImage(named: "down_gray"), for: UIControlState.normal)
            cell.upVoteButton.setImage(UIImage(named:"up_gray"), for: UIControlState.normal)
            cell.voteBackground.backgroundColor = UIColor .lightGray
            
            replies[sender.tag].voteStatus = 0
            replies[sender.tag].voteCount = reply.voteCount! + 1
            cell.voteCount.text = String(replies[sender.tag].voteCount!)
            
            weakSelf?.ref.child("profiles").child(profileId).child("votes").child(reply.replyId!).setValue(0)
            
            changeVoteCount(smackId: reply.replyId!, amount: 1)
            changeKarma(userId: reply.authorId!, amount: 1)
            changeKarma(userId: profileId, amount: 1)
            
            DispatchQueue.main.async {
                weakSelf?.replyTableView.reloadData()
            }
            
        default:
            print("titties")
        }
        
    }
    
    func changeKarma(userId id: String, amount: Int64){
        self.ref.child("profiles").child(id).child("karma").observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            if (snapshot.exists()){
                
                var currentKarma = (snapshot.value) as! Int64
                currentKarma += amount
                
                self.ref.child("profiles").child(id).child("karma").setValue(currentKarma)
                
            }else {
                self.ref.child("profiles").child(id).child("karma").setValue(amount)
            }
        })
    }
    
    func changeVoteCount(smackId id:String, amount: Int64){
        
        self.ref.child("replies").child(id).child("voteCount").observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            var voteCount = (snapshot.value) as! Int64
            voteCount += amount
            self.ref.child("replies").child(id).child("voteCount").setValue(voteCount)
            
        })
        
    }

}
