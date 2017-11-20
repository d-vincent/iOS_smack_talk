//
//  ThreadViewController.swift
//  Smack Talk
//
//  Created by Drew McDonald on 10/19/17.
//  Copyright © 2017 Drew McDonald. All rights reserved.
//

import UIKit
import Firebase

var threadCount = 0

class ThreadViewController: UIViewController,  UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var post: UIBarButtonItem!
    @objc var ref: DatabaseReference!
    var gameId = ""
    var profileId = ""
    var smacks = [SmackObject]()

    @IBOutlet weak var awayLogo: UIImageView!
    @IBOutlet weak var smacksTableView: UITableView!
    @IBOutlet weak var homeLogo: UIImageView!
    @IBOutlet weak var awayScoreLabel: UILabel!
    @IBOutlet weak var homeScoreLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    
    @IBAction func goToPostScreen(sender: UIBarButtonItem){
        performSegue(withIdentifier: "newPost", sender: gameId)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        threadCount = threadCount + 1
        print("Added new ThreadViewController to memory. (count = \(threadCount)")
        
        let preferences = UserDefaults.standard
        let uniqueIdKey = "uniqueIdKey"

        
        if preferences.object(forKey: uniqueIdKey) == nil {
            //  Doesn't exist
            profileId = UUID().uuidString
            preferences.set(profileId, forKey: uniqueIdKey)
            
        } else {
            profileId = (preferences.string(forKey: uniqueIdKey))!
        }
        
        
        weak var weakSelf = self
        
        ref = Database.database().reference()
        
        ref.child("archive").child(gameId).observeSingleEvent(of: DataEventType.value, with: {(snapshot) in
            
            if (snapshot.exists()){
                
                let homeScoreSnap = snapshot.childSnapshot(forPath: "homeScore")
                if (homeScoreSnap.exists()){
                    var homeScore = homeScoreSnap.value as! UInt64
                    weakSelf?.homeScoreLabel.text = String(homeScoreSnap.value as! UInt64)
                }else {
                    weakSelf?.homeScoreLabel.text = "0"
                }
                
                let awayScoreSnap = snapshot.childSnapshot(forPath: "awayScore")
                if (awayScoreSnap.exists()){
                    var awayScore = awayScoreSnap.value as! UInt64
                    weakSelf?.awayScoreLabel.text = String(awayScoreSnap.value as! UInt64)
                }else {
                    weakSelf?.awayScoreLabel.text = "0"
                }
                
                let awayId = snapshot.childSnapshot(forPath: "awayId").value as! UInt64
                let homeId = snapshot.childSnapshot(forPath: "homeId").value as! UInt64
                
                weakSelf?.awayLogo.image = UIImage (named: "logo_" + String(awayId))

                weakSelf?.homeLogo.image = UIImage (named: "logo_" + String(homeId))
                
                weakSelf?.timeLabel.text = "0:00"
                
            }else {
                weakSelf?.ref.child("games").child((weakSelf?.gameId)!).observe(DataEventType.value, with: {(gamesnap) in
                    
                    let homeScoreSnap = gamesnap.childSnapshot(forPath: "homeScore")
                    if (homeScoreSnap.exists()){
                        weakSelf?.homeScoreLabel.text = homeScoreSnap.value as? String
                    }else {
                        weakSelf?.homeScoreLabel.text = "0"
                    }
                    
                    let awayScoreSnap = gamesnap.childSnapshot(forPath: "awayScore")
                    if (awayScoreSnap.exists()){
                        weakSelf?.awayScoreLabel.text = awayScoreSnap.value as? String
                    }else {
                        weakSelf?.awayScoreLabel.text = "0"
                    }
                    
                    let awayId = gamesnap.childSnapshot(forPath: "awayId").value as! UInt64
                    let homeId = gamesnap.childSnapshot(forPath: "homeId").value as! UInt64
                    
                    weakSelf?.awayLogo.image = UIImage (named: "logo_" + String(awayId))
                    
                    weakSelf?.homeLogo.image = UIImage (named: "logo_" + String(homeId))
                    
                
                    weakSelf?.timeLabel.text = "0:00"
                    
                    
                    
                })
                
            }
            
            
        })

        ref.child("smacks").queryOrdered(byChild: "threadId").queryEqual(toValue: gameId).observe(DataEventType.childAdded) { (snapshot) in

            var smack = SmackObject();

            if (snapshot.childSnapshot(forPath: "username").exists()){
                smack.userName = (snapshot.childSnapshot(forPath: "username").value as! String)
                
            }

            smack.authorId = (snapshot.childSnapshot(forPath: "authorId").value as! String)
            smack.content = (snapshot.childSnapshot(forPath: "content").value as! String)
            smack.replyCount = (snapshot.childSnapshot(forPath: "replyCount").value as! Int64)
            smack.timestamp = (snapshot.childSnapshot(forPath: "timestamp").value as! Int64)
            smack.voteCount = (snapshot.childSnapshot(forPath: "voteCount").value as! Int64)
            smack.id = snapshot.key

            weakSelf?.ref.child("profiles").child((weakSelf?.profileId)!).child("votes").child(snapshot.key).observeSingleEvent(of: DataEventType.value, with: { (voteSnap) in

                if (voteSnap.exists()){
                smack.voteStatus = (voteSnap.value as! Int)
                }else {
                    smack.voteStatus = 0;
                }

                weakSelf?.ref.child("profiles").child(smack.authorId!).child("preferredTeamId").observeSingleEvent(of:DataEventType.value, with: { (logoSnap) in

                    if (logoSnap.exists()){
                    smack.authorLogo = (logoSnap.value as! String)
                    }
                    weakSelf?.smacks.append(smack)
                    
                   
                        
                    weakSelf?.smacks.sort(by: { (lhs: SmackObject, rhs: SmackObject) -> Bool in
                        return lhs.timestamp! > rhs.timestamp!
                    })
                    
                    DispatchQueue.main.async {
                        weakSelf?.smacksTableView.reloadData()
                    }


                })


            })


        }

        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if (sender is UIBarButtonItem){
           
            if ((sender as! UIBarButtonItem).tag == 0){
                
                let guest = segue.destination as! PlaceBetViewController
                guest.gameId = gameId
                guest.profileId = profileId
                
            }else {
                let guest = segue.destination as! NewPostViewController
                
                guest.gameId = gameId
            }
            
            
        } else if (sender is UIButton){
            let guest = segue.destination as! ReplyViewController
            
            guest.smackId = smacks[(sender as! UIButton).tag].id!
        }
        
    }
    
    @objc func upVote(_ sender: UIButton){
        
        weak var weakSelf = self
        var smack = smacks[sender.tag]
        
        var cell: SmackTableViewCell
        cell = (smacksTableView.cellForRow(at: IndexPath(row:sender.tag, section: 0)) ) as! SmackTableViewCell
        
        switch smack.voteStatus! {
        case 0:
            sender.setImage(UIImage(named: "up_white"), for: UIControlState.normal)
            cell.downVoteButton.setImage(UIImage(named:"down_gray"), for: UIControlState.normal)
            cell.voteBackground.backgroundColor = UIColor .green
            
            smacks[sender.tag].voteStatus = 1
            smacks[sender.tag].voteCount = smack.voteCount! + 1
            cell.voteCount.text = String(smacks[sender.tag].voteCount!)
            
            weakSelf?.ref.child("profiles").child(profileId).child("votes").child(smack.id!).setValue(1)
            
            changeVoteCount(smackId: smack.id!, amount: 1)
            changeKarma(userId: smack.authorId!, amount: 1)
            changeKarma(userId: profileId, amount: 1)
            
            DispatchQueue.main.async {
                weakSelf?.smacksTableView.reloadData()
            }
            
        case 1:
            sender.setImage(UIImage(named: "up_gray"), for: UIControlState.normal)
            cell.downVoteButton.setImage(UIImage(named:"down_gray"), for: UIControlState.normal)
            cell.voteBackground.backgroundColor = UIColor .lightGray
            
            smacks[sender.tag].voteStatus = 0
            smacks[sender.tag].voteCount = smack.voteCount! - 1
            cell.voteCount.text = String(smacks[sender.tag].voteCount!)
            
            weakSelf?.ref.child("profiles").child(profileId).child("votes").child(smack.id!).setValue(0)
            
            changeVoteCount(smackId: smack.id!, amount: -1)
            changeKarma(userId: smack.authorId!, amount: -1)
            changeKarma(userId: profileId, amount: -1)
            
            DispatchQueue.main.async {
                weakSelf?.smacksTableView.reloadData()
            }
            
            
        case -1:
            sender.setImage(UIImage(named: "up_white"), for: UIControlState.normal)
            cell.downVoteButton.setImage(UIImage(named:"down_gray"), for: UIControlState.normal)
            cell.voteBackground.backgroundColor = UIColor .green
            
            smacks[sender.tag].voteStatus = 1
            smacks[sender.tag].voteCount = smack.voteCount! + 2
            cell.voteCount.text = String(smacks[sender.tag].voteCount!)
            
            weakSelf?.ref.child("profiles").child(profileId).child("votes").child(smack.id!).setValue(1)
            
            changeVoteCount(smackId: smack.id!, amount: 2)
            changeKarma(userId: smack.authorId!, amount: 2)
            changeKarma(userId: profileId, amount: 2)
            
            DispatchQueue.main.async {
                weakSelf?.smacksTableView.reloadData()
            }
        
        default:
            print("titties")
        }
        
    }
    
    @objc func downVote(_ sender: UIButton){
        
        weak var weakSelf = self
        var smack = smacks[sender.tag]
        
        var cell: SmackTableViewCell
        cell = (smacksTableView.cellForRow(at: IndexPath(row:sender.tag, section: 0)) ) as! SmackTableViewCell
        
        switch smack.voteStatus! {
        case 0:
            sender.setImage(UIImage(named: "down_white"), for: UIControlState.normal)
            cell.upVoteButton.setImage(UIImage(named:"up_gray"), for: UIControlState.normal)
            cell.voteBackground.backgroundColor = UIColor .red
            
            smacks[sender.tag].voteStatus = -1
            smacks[sender.tag].voteCount = smack.voteCount! - 1
            cell.voteCount.text = String(smacks[sender.tag].voteCount!)
            
            weakSelf?.ref.child("profiles").child(profileId).child("votes").child(smack.id!).setValue(-1)
            
            changeVoteCount(smackId: smack.id!, amount: -1)
            changeKarma(userId: smack.authorId!, amount: -1)
            changeKarma(userId: profileId, amount: -1)
            
            DispatchQueue.main.async {
                weakSelf?.smacksTableView.reloadData()
            }
            
        case 1:
            sender.setImage(UIImage(named: "down_white"), for: UIControlState.normal)
            cell.upVoteButton.setImage(UIImage(named:"up_gray"), for: UIControlState.normal)
            
            cell.voteBackground.backgroundColor = UIColor .red
            
            smacks[sender.tag].voteStatus = -1
            smacks[sender.tag].voteCount = smack.voteCount! - 2
            cell.voteCount.text = String(smacks[sender.tag].voteCount!)
            
            weakSelf?.ref.child("profiles").child(profileId).child("votes").child(smack.id!).setValue(-1)
            
            changeVoteCount(smackId: smack.id!, amount: -2)
            changeKarma(userId: smack.authorId!, amount: -2)
            changeKarma(userId: profileId, amount: -2)
            
            
            DispatchQueue.main.async {
                weakSelf?.smacksTableView.reloadData()
            }
            
        case -1:
            sender.setImage(UIImage(named: "down_gray"), for: UIControlState.normal)
            cell.upVoteButton.setImage(UIImage(named:"up_gray"), for: UIControlState.normal)
            cell.voteBackground.backgroundColor = UIColor .lightGray
            
            smacks[sender.tag].voteStatus = 0
            smacks[sender.tag].voteCount = smack.voteCount! + 1
            cell.voteCount.text = String(smacks[sender.tag].voteCount!)
            
            weakSelf?.ref.child("profiles").child(profileId).child("votes").child(smack.id!).setValue(0)
            
            changeVoteCount(smackId: smack.id!, amount: 1)
            changeKarma(userId: smack.authorId!, amount: 1)
            changeKarma(userId: profileId, amount: 1)
            
            DispatchQueue.main.async {
                weakSelf?.smacksTableView.reloadData()
            }
            
        default:
            print("titties")
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return smacks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let smack = smacks[indexPath.row]
        
        let cell = smacksTableView.dequeueReusableCell(withIdentifier: "smackCell", for: indexPath) as! SmackTableViewCell
        
        if (smack.voteStatus == 1){
            cell.upVoteButton.setImage(UIImage(named:"up_white"), for: UIControlState.normal)
            cell.downVoteButton.setImage(UIImage(named:"down_gray"), for: UIControlState.normal)
            cell.voteBackground.backgroundColor = UIColor .green
        }else if (smack.voteStatus == -1){
            cell.upVoteButton.setImage(UIImage(named:"up_gray"), for: UIControlState.normal)
            cell.downVoteButton.setImage(UIImage(named:"down_white"), for: UIControlState.normal)
            cell.voteBackground.backgroundColor = UIColor .red
        }else {
            cell.upVoteButton.setImage(UIImage(named:"up_gray"), for: UIControlState.normal)
            cell.downVoteButton.setImage(UIImage(named:"down_gray"), for: UIControlState.normal)
            cell.voteBackground.backgroundColor = UIColor .lightGray
        }
        cell.voteCount.text = String(smacks[indexPath.row].voteCount!)
        
        cell.content.text = smack.content
        cell.authorName.text = smack.userName
        
        let timeago = Date().toMillis() - smack.timestamp!
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
        if (smack.authorLogo != nil){
        cell.authorLogo.image = UIImage(named:"logo_" + smack.authorLogo!)
        }else {
            cell.authorLogo.image = nil
        }
//        cell.timeSince
        
        cell.upVoteButton.tag = indexPath.row
        cell.upVoteButton.addTarget(self, action: #selector(upVote(_:)), for: .touchUpInside)
         
        cell.downVoteButton.tag = indexPath.row
        cell.downVoteButton.addTarget(self, action: #selector(downVote(_:)), for: .touchUpInside)
        
        cell.replyButton.tag = indexPath.row
        cell.replyCount.text = String(smack.replyCount!)
        
        
        return cell
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
        
        self.ref.child("smacks").child(id).child("voteCount").observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            var voteCount = (snapshot.value) as! Int64
            voteCount += amount
            self.ref.child("smacks").child(id).child("voteCount").setValue(voteCount)
            
        })
        
    }
    

    
    deinit {
        threadCount = threadCount - 1
        print("Released view controller from memory. (count = \(threadCount)")
    }
}

extension Date{
    func toMillis() -> Int64{
        return Int64(self.timeIntervalSince1970 * 1000)
    }
}
