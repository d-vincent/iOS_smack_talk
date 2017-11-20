//
//  SelectLogoViewController.swift
//  Smack Talk
//
//  Created by Drew McDonald on 11/13/17.
//  Copyright © 2017 Drew McDonald. All rights reserved.
//

import UIKit
import Firebase

class SelectLogoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    

    @IBOutlet weak var logosTableView: UITableView!
    @IBOutlet weak var logoSearchBar: UISearchBar!
    var teams = [LogoObject]()
    var foundTeams = [LogoObject]()
    var ref : DatabaseReference!
    var prevTerm = ""
    
    var profileId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
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
        
        ref.child("teams").observe(DataEventType.childAdded, with: {(teamSnap) in
            
            var team = LogoObject()
            
            team.id = teamSnap.key
            team.searchName = (teamSnap.childSnapshot(forPath: "tag").value as! String)
            
            weakself?.teams.append(team)
            
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
        let cell = logosTableView.dequeueReusableCell(withIdentifier: "logoCell", for: indexPath) as! TeamSearchTableViewCell
        
        let team = foundTeams[indexPath.row]
        cell.teamLogo.image = (UIImage (named: "logo_" + team.id!))
        cell.TeamName.text = team.searchName
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let path = logosTableView.indexPathForSelectedRow?.row
        
        var logo = foundTeams[path!]
        
        ref.child("profiles").child(profileId).child("preferredTeamId").setValue(logo.id)
        ref.child("profiles").child(profileId).child("preferredTeamName").setValue(logo.searchName)
        
        self.navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foundTeams.count
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if (searchText.count < 1){
            foundTeams.removeAll()
            logosTableView.reloadData()
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
        logosTableView.reloadData()
    }
}
