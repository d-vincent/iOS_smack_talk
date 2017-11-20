//
//  SearchTeamsViewController.swift
//  Smack Talk
//
//  Created by Drew McDonald on 11/9/17.
//  Copyright © 2017 Drew McDonald. All rights reserved.
//

import UIKit
import Firebase

class SearchTeamsViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var teamSearchTableView: UITableView!
    
    var teams = [LogoObject]()
    var foundTeams = [LogoObject]()
    var ref : DatabaseReference!
    var prevTerm = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ref = Database.database().reference()
        weak var weakself = self
        
        ref.child("teams").observe(DataEventType.childAdded, with: {(teamSnap) in
            
            var team = LogoObject()
            
            team.id = teamSnap.key
            team.searchName = (teamSnap.childSnapshot(forPath: "tag").value as! String)
            
            weakself?.teams.append(team)
            
        })
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
       
        if (searchText.count < 1){
            foundTeams.removeAll()
            teamSearchTableView.reloadData()
            return
        }
        
        if (searchText.count > prevTerm.count){
            if (foundTeams.count == 0){
                foundTeams = foundLogosSearch(teams, searchTerm: searchText)
            }else {
                foundTeams = foundLogosSearch(foundTeams, searchTerm: searchText)
            }
            
        }
        else {
            foundTeams.removeAll()
            for logo in teams{
                    let tempName = logo.searchName
                    if (tempName?.lowercased().contains(searchText.lowercased()))!{
                        foundTeams.append(logo)
                    }
                
            }
            
        }
        prevTerm = searchText
        teamSearchTableView.reloadData()
        
    }

    
   

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let path = self.teamSearchTableView.indexPathForSelectedRow?.row
        (segue.destination as! PastGamesViewController).teamId = Int((foundTeams[path!]).id!)
        
    }
    
    

    
    func foundLogosSearch(_ listToSearch: [LogoObject], searchTerm: String ) -> [LogoObject]{
        
        var foundLogos = [LogoObject]()
        
        for logo in listToSearch{
            
            let tempName = logo.searchName
            
            if (tempName?.lowercased().contains(searchTerm.lowercased()))!{
                foundLogos.append(logo)
            }
            
        }
        
        return foundLogos
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = teamSearchTableView.dequeueReusableCell(withIdentifier: "teamCell", for: indexPath) as! TeamSearchTableViewCell
        
        let team = foundTeams[indexPath.row]
        cell.teamLogo.image = (UIImage (named: "logo_" + team.id!))
        cell.TeamName.text = team.searchName
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foundTeams.count
    }
    

}
