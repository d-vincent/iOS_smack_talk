//
//  ProfileViewController.swift
//  Smack Talk
//
//  Created by Drew McDonald on 11/8/17.
//  Copyright © 2017 Drew McDonald. All rights reserved.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController {

    var ref : DatabaseReference!
    var profileId = ""
    
    @IBOutlet weak var karmaValueLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        weak var weakSelf = self
        
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
        
        ref.child("profiles").child(profileId).child("karma").observe(DataEventType.value, with: {(karmaSnap) in
            if (karmaSnap.exists()){
                weakSelf?.karmaValueLabel.text = String(describing: karmaSnap.value!)
            }
            
            
        })
        
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
