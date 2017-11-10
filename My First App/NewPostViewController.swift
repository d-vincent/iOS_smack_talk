//
//  NewPostViewController.swift
//  Smack Talk
//
//  Created by Drew McDonald on 10/24/17.
//  Copyright © 2017 Drew McDonald. All rights reserved.
//

import UIKit
import Firebase


class NewPostViewController: UIViewController {
    
     @objc var ref: DatabaseReference!
    var gameId = ""
    var profileId = ""

    @IBOutlet weak var newPostContent: UITextView!
    @IBAction func sendSmack(_ sender: Any) {
        
        let content : String = newPostContent.text
        
        if (content.count < 1){
         return
        }
        
      ref.child("profiles").child(profileId).child("lastSmackTime").observe(DataEventType.value) { (snapshot) in
            var isTooSoon = false
            
            if (snapshot.exists()){
                let lastTimeStamp = snapshot.value as! Int64
                let currentTime = Date().toMillis()
                if ((currentTime - lastTimeStamp) < 60000){
                    isTooSoon = true;
                }
            }
            
            if (isTooSoon){
                //user posted too recently
            }
            else {
                var smackMap = [String : Any]()
            
                smackMap["content"] = self.newPostContent.text
                smackMap["timestamp"] = Date().toMillis()
                smackMap["voteCount"] = 1
                smackMap["replyCount"] = 0
                smackMap["authorId"] = self.profileId
                smackMap["threadId"] = self.gameId
                
                let smackId = self.ref.child("smacks").childByAutoId().key
                
                self.ref.child("smacks").child(smackId).setValue(smackMap)
                self.ref.child("threads").child(self.gameId).child("smacks").child(smackId).setValue(true)
                self.ref.child("profiles").child(self.profileId).child("smacks").child(smackId).setValue(true)
                self.ref.child("profiles").child(self.profileId).child("votes").child(smackId).setValue(1)
                self.ref.child("profiles").child(self.profileId).child("lastSmackTime").setValue(Date().toMillis())
                
                self.navigationController?.popViewController(animated: true)
                
            }
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        let borderColor : UIColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0)
        
        newPostContent.layer.borderWidth = 0.5
        newPostContent.layer.borderColor = borderColor.cgColor
        newPostContent.layer.cornerRadius = 5.0

        // Do any additional setup after loading the view.
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

}
