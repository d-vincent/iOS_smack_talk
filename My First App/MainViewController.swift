//
//  ViewController.swift
//  My First App
//
//  Created by Drew McDonald on 10/12/17.
//  Copyright © 2017 Drew McDonald. All rights reserved.
//

import UIKit
import Firebase

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @objc var ref: DatabaseReference!
    @objc let dateFormatter = DateFormatter()
    
    @IBOutlet weak var upcomingSearchBar: UISearchBar!
    @IBOutlet weak var conferenceTextField: UITextView!
    
    let conferencePicker = UIPickerView()
    var matches = [MatchObject]()
    var sortedMatches = [MatchObject]()
    
    var profileId = ""
    var prevTerm = ""
    
    var conferences = ["All Conferences", "American Aethletic Conference", "Atlantic Coast Conference","Colonial Athletic Association", "Patriot League", "Big Ten", "Big 12","Pac 12","Big South Conference", "Big Sky Conference" , "Southland Conference" , "Southwestern Athletic Conference" , "Southeastern Conference" , "Southern Conference", "Conference USA", "Mountain West", "Mid American Conference" , "Sun Belt Conference" , "FBS Independents" , "Missouri Valley Conference" , "Mid-Eastern Athletic Conference" , "Northeast Conference" , "Ohio Valley Conference"]

    var foundTeams = [MatchObject]()
    @objc let matchCell = "matchCell"
    

    //@IBOutlet weak var liveGamesCollectionView: UICollectionView!
    @IBOutlet weak var upcomingMatchesTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createDayPicker()
        createToolBar()
        
        
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
            let homeScoreSnap = snapshot.childSnapshot(forPath: "homeScore")
            let awayScoreSnap = snapshot.childSnapshot(forPath: "awayScore")
            if (awayScoreSnap).exists(){
            match.awayScore = (snapshot.childSnapshot(forPath: "awayScore").value as! UInt64)
            }else {
                match.awayScore = 0
            }
            
            if (homeScoreSnap.exists()){
                match.homeScore = (snapshot.childSnapshot(forPath: "homeScore").value as! UInt64)
            }else {
                match.homeScore = 0
            }
            
            match.city = (snapshot.childSnapshot(forPath: "city").value as! String)
            match.date = self.dateFormatter.date(from: snapshot.childSnapshot(forPath: "scheduledStart").value as! String)!
            match.status = (snapshot.childSnapshot(forPath: "status").value as! String)
            
            weakself?.ref.child("teams").child(String(describing: match.awayId!)).observeSingleEvent(of: DataEventType.value, with: {(teamSnap) in
            
                match.awayTeam = (teamSnap.childSnapshot(forPath: "tag").value as! String)
                match.awayConference = (teamSnap.childSnapshot(forPath: "con").value as! String)
            
                weakself?.ref.child("teams").child(String(describing: match.homeId!)).observeSingleEvent(of: DataEventType.value, with: {(homesnap) in
                    
                    match.homeTeam = (homesnap.childSnapshot(forPath: "tag").value as! String)
                    match.homeConference = (homesnap.childSnapshot(forPath: "con").value as! String)
                    
                    weakself?.matches.append(match)
                    weakself?.sortedMatches.append(match)
                    DispatchQueue.main.async {
                        weakself?.upcomingMatchesTableView.reloadData()
                    }
                    
                    
                
                    
                })
            
            })
        
        })
        // Do any additional setup after loading the view, typically from a 
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortedMatches.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = upcomingMatchesTableView.dequeueReusableCell(withIdentifier: matchCell, for: indexPath) as! MatchTableViewCell
        let game = sortedMatches[indexPath.row]
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
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        conferencePicker.selectRow(0, inComponent: 0, animated: false)
        conferenceTextField.text = "All Conferences"
        
    
        
        if (searchText.count < 1){
            sortedMatches.removeAll()
            sortedMatches = matches
            upcomingMatchesTableView.reloadData()
            return
        }
        
        if (searchText.count > prevTerm.count){
            if (sortedMatches.count == 0){
                sortedMatches = foundLogosSearch(matches, searchTerm: searchText)
            }else {
                sortedMatches = foundLogosSearch(sortedMatches, searchTerm: searchText)
            }
            
        }
        else {
            sortedMatches.removeAll()
            for logo in matches{
                let tempName = logo.awayTeam
                let homeName = logo.homeTeam
                if ((tempName?.lowercased().contains(searchText.lowercased()))! || (homeName?.lowercased().contains(searchText.lowercased()))!){
                    sortedMatches.append(logo)
                }
                
            }
            
        }
        prevTerm = searchText
        upcomingMatchesTableView.reloadData()
    }
    
    func foundLogosSearch(_ listToSearch: [MatchObject], searchTerm: String ) -> [MatchObject]{
        
        var foundLogos = [MatchObject]()
        
        for logo in listToSearch{
            
            let tempName = logo.awayTeam!
            let homeName = logo.homeTeam!
            
            var lowercaseAwayName = tempName.lowercased()
            var lowercaseHomeNAme = homeName.lowercased()
            
            if (lowercaseAwayName.contains(searchTerm.lowercased()) || lowercaseHomeNAme.contains(searchTerm.lowercased())){
                foundLogos.append(logo)
            }
            
        }
        
        return foundLogos
        
    }
    
    func createDayPicker(){
        
        conferencePicker.delegate = self
        
        conferenceTextField.inputView = conferencePicker
        
        
        
    }
    
    func createToolBar(){
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style : .plain, target : self, action : #selector(self.dismissKeyboard))
        toolBar.setItems([doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        conferenceTextField.inputAccessoryView = toolBar
        
    }
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return conferences.count
    
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return conferences[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        conferenceTextField.text = conferences[row]
        
        upcomingSearchBar.text = ""
        
        if (row == 0){
            sortedMatches = matches
            upcomingMatchesTableView.reloadData()
        }else {
            
            var conference = conferences[row]
            sortedMatches.removeAll()
            for match in matches{
                if ((match.awayConference?.contains(conference))! || (match.homeConference?.contains(conference))!){
                    sortedMatches.append(match)
                }
            }
            
            upcomingMatchesTableView.reloadData()
        }
        
    }
    
    }
    
    


