//
//  PastGamesViewController.swift
//  Smack Talk
//
//  Created by Drew McDonald on 11/13/17.
//  Copyright © 2017 Drew McDonald. All rights reserved.
//

import UIKit
import Firebase

class PastGamesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var pastGamesTableView: UITableView!
    
    var matches = [MatchObject]()
    var ref : DatabaseReference!
    var teamId : Int!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        weak var weakself = self
        
        ref.child("archive").queryOrdered(byChild: "awayId").queryEqual(toValue: teamId).observe(DataEventType.childAdded, with: {(snapshot) in
            
            var match = MatchObject()
            match.awayName = (snapshot.childSnapshot(forPath: "away").value as! String)
            match.homeName = (snapshot.childSnapshot(forPath: "home").value as! String)
            
            match.awayId = (snapshot.childSnapshot(forPath: "awayId").value as! UInt64)
            match.homeId = (snapshot.childSnapshot(forPath: "homeId").value as! UInt64)
            match.gameId = snapshot.key
            
            weakself?.matches.append(match)
            
            DispatchQueue.main.async {
                weakself?.pastGamesTableView.reloadData()
            }
        })
        
        ref.child("archive").queryOrdered(byChild: "homeId").queryEqual(toValue: teamId).observe(DataEventType.childAdded, with: {(snapshot) in
            var match = MatchObject()
            match.awayName = (snapshot.childSnapshot(forPath: "away").value as! String)
            match.homeName = (snapshot.childSnapshot(forPath: "home").value as! String)
            
            match.awayId = (snapshot.childSnapshot(forPath: "awayId").value as! UInt64)
            match.homeId = (snapshot.childSnapshot(forPath: "homeId").value as! UInt64)
            match.gameId = snapshot.key
            
            weakself?.matches.append(match)
            
            DispatchQueue.main.async {
                weakself?.pastGamesTableView.reloadData()
            }
            
            
            
            
            
        })

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = pastGamesTableView.dequeueReusableCell(withIdentifier: "pastGame", for: indexPath) as! MatchTableViewCell
        
        let match = matches[indexPath.row]
        
        cell.awayLogo.image = (UIImage (named: "logo_" + String(match.awayId!)))
        cell.homeLogo.image = (UIImage (named: "logo_" + String(match.homeId!)))
        cell.home.text = match.homeName
        cell.opponent.text = match.awayName
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matches.count
    }

   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   
        let path = pastGamesTableView.indexPathForSelectedRow?.row
        (segue.destination as! ThreadViewController).gameId = (matches[path!]).gameId!
      
        
    }
    

}
