//
//  ViewController.swift
//  My First App
//
//  Created by Drew McDonald on 10/12/17.
//  Copyright © 2017 Drew McDonald. All rights reserved.
//

import UIKit
import Firebase

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @objc var ref: DatabaseReference!
    @objc let dateFormatter = DateFormatter()
    
    var matches = [MatchObject]()
    
    var profileId = ""
    
    @objc let matchCell = "matchCell"
    

    //@IBOutlet weak var liveGamesCollectionView: UICollectionView!
    @IBOutlet weak var upcomingMatchesTableView: UITableView!
    
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
        
        dateFormatter.dateFormat = "yyyy-MM-dd'T'kk:m:ss"
        
        ref = Database.database().reference()

        ref.child("games").observe(DataEventType.childAdded, with: {(snapshot) in
        
        
            var match : MatchObject
            match = MatchObject();
            match.gameId = snapshot.key as String
            match.awayId = (snapshot.childSnapshot(forPath: "awayId").value as! UInt64)
            match.homeId = (snapshot.childSnapshot(forPath: "homeId").value as! UInt64)
            match.awayScore = (snapshot.childSnapshot(forPath: "awayScore").value as! UInt64)
            match.homeScore = (snapshot.childSnapshot(forPath: "homeScore").value as! UInt64)
            match.city = (snapshot.childSnapshot(forPath: "city").value as! String)
            match.date = self.dateFormatter.date(from: snapshot.childSnapshot(forPath: "scheduledStart").value as! String)!
            match.status = (snapshot.childSnapshot(forPath: "status").value as! String)
            match.awayScore = (snapshot.childSnapshot(forPath: "awayScore").value as! UInt64)
            match.homeScore = (snapshot.childSnapshot(forPath: "homeScore").value as! UInt64)
            
            weakself?.ref.child("teams").child(String(describing: match.awayId!)).observeSingleEvent(of: DataEventType.value, with: {(teamSnap) in
            
                match.awayTeam = (teamSnap.childSnapshot(forPath: "tag").value as! String)
                match.awayConference = (teamSnap.childSnapshot(forPath: "con").value as! String)
            
                weakself?.ref.child("teams").child(String(describing: match.homeId!)).observeSingleEvent(of: DataEventType.value, with: {(teamsnap) in
                    
                    match.homeTeam = (teamSnap.childSnapshot(forPath: "tag").value as! String)
                    match.homeConference = (teamSnap.childSnapshot(forPath: "con").value as! String)
                    
                    weakself?.matches.append(match)
                    DispatchQueue.main.async {
                        weakself?.upcomingMatchesTableView.reloadData()
                    }
                    
                    
                
                    
                })
            
            })
        
        })
        // Do any additional setup after loading the view, typically from a 
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matches.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = upcomingMatchesTableView.dequeueReusableCell(withIdentifier: matchCell, for: indexPath) as! MatchTableViewCell
        let game = matches[indexPath.row]
        cell.home.text = game.homeTeam
        cell.opponent.text = game.awayTeam
        let awayId = game.awayId
        let homeId = game.homeId
        cell.awayLogo.image = UIImage(named: "logo_"+String(awayId!))
        cell.homeLogo.image = UIImage(named: "logo_"+String(homeId!))
        
        
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "Titties", sender: matches[indexPath.row].gameId)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        let guest = segue.destination as! ThreadViewController

        guest.gameId = sender as! String
    }
    
    }
    
    


