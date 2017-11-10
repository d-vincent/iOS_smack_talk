//
//  MyBetsViewController.swift
//  Smack Talk
//
//  Created by Drew McDonald on 11/8/17.
//  Copyright © 2017 Drew McDonald. All rights reserved.
//

import UIKit
import Firebase

class MyBetsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var ref : DatabaseReference!
    var profileId = ""
    var bets = [BetObject]()

    @IBOutlet weak var myBetsTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        weak var weakself = self
        
        let preferences = UserDefaults.standard
        let uniqueIdKey = "uniqueIdKey"
        
        
        if preferences.object(forKey: uniqueIdKey) == nil {
            //  Doesn't exist
            profileId = UUID().uuidString
            preferences.set(profileId, forKey: uniqueIdKey)
            
        } else {
            profileId = (preferences.string(forKey: uniqueIdKey))!
        }

        ref = Database.database().reference()
        
        ref.child("bets").queryOrdered(byChild: "authorId").queryEqual(toValue: profileId).observe(DataEventType.childAdded, with: {(snapshot) in
            
            
            var bet = BetObject()
            bet.awayId = ((snapshot.childSnapshot(forPath: "awayTeamId").value) as! Int)
            bet.homeId = (snapshot.childSnapshot(forPath: "homeTeamId").value as! Int)
            bet.homeTeamBet = (snapshot.childSnapshot(forPath: "homeTeamBet").value as! Bool)
            bet.payout = (snapshot.childSnapshot(forPath: "payoutAmount").value as! Int)
            bet.betAmount = (snapshot.childSnapshot(forPath: "betAmount").value as! Int)
            bet.gameId = (snapshot.childSnapshot(forPath: "gameId").value as! String)
            bet.teamName = (snapshot.childSnapshot(forPath: "teamName").value as! String)
            
            weakself?.bets.append(bet)
            DispatchQueue.main.async {
                weakself?.myBetsTableView.reloadData()
            }
        
            
        })
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = myBetsTableView.dequeueReusableCell(withIdentifier: "bet", for: indexPath) as! BetTableViewCell
        
        let bet = bets[indexPath.row]
    
        cell.betContent.text = (String(bet.betAmount!) + "karma on " + bet.teamName!)
        cell.payoutContent.text = ("Payout: " + String(bet.payout!))
        if (bet.homeTeamBet!){
        cell.teamLogo.image = (UIImage (named: "logo_" + String(bet.homeId!)))
        }else {
            
        }
        
        return cell
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("TIDDIES")
        return bets.count
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
