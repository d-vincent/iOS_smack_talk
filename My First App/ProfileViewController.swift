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
    
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var karmaValueLabel: UILabel!
    
    @IBOutlet weak var preferredLogo: UIButton!
    override func viewDidAppear(_ animated: Bool) {
        ref.child("profiles").child(profileId).child("preferredTeamId").observeSingleEvent(of: DataEventType.value, with: {(snapshot) in
            
            if (snapshot.exists()){
                self.preferredLogo.setImage(UIImage (named: "logo_" + (snapshot.value as! String)), for: .normal)
            }
            
        })
        
        ref.child("profiles").child(profileId).child("username").observeSingleEvent(of: DataEventType.value, with: {(snapshot) in
            
            if (snapshot.exists()){
                let usernameValue = (snapshot.value as! String)
                if (usernameValue.count == 0){
                    self.username.text = "Choose username..."
                }else {
                    self.username.text = usernameValue
                }
            }
            
        })
    }
    
    
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
    
    @IBAction func changeUsername(_ sender: Any) {
        
        let alertController = UIAlertController(title: "Username", message: "Please input your desired name:", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { (_) in
            if let field = alertController.textFields?[0] {
                
                self.ref.child("usernames").child(field.text!.lowercased()).observeSingleEvent(of: DataEventType.value, with: {(snapshot) in
                    
                    var isTaken = false
                    
                    if (snapshot.exists()){
                        isTaken = (snapshot.value as! Bool)
                    }
                    
                    if (isTaken){
                        
                        self.showToast(message: "Username is taken")
                        return
                        
                    }else {
                        
                        
                        self.username.text = field.text
                        
                        self.ref.child("profiles").child(self.profileId).child("username").observeSingleEvent(of: DataEventType.value, with: {(namesnap) in
                            
                            if (namesnap.exists()){
                                self.ref.child("usernames").child((namesnap.value as! String)).setValue(false)
                            }
                            
                            self.ref.child("profiles").child(self.profileId).child("username").setValue(field.text)
                            self.ref.child("usernames").child(field.text!.lowercased()).setValue(true)
                            
                        })
                    }
                    
                })
                
                // store your data
                
                
            } else {
                // user did not fill field
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Email"
        }
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    func showToast(message : String) {
        
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-100, width: 150, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
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
