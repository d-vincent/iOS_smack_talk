//
//  PlaceBetViewController.swift
//  Smack Talk
//
//  Created by Drew McDonald on 11/17/17.
//  Copyright © 2017 Drew McDonald. All rights reserved.
//

import UIKit
import Firebase



class PlaceBetViewController: UIViewController {

    
    @IBOutlet weak var homeLogo: UIButton!
    
    @IBOutlet weak var awayLogo: UIButton!
    @IBOutlet weak var betLabel: UILabel!
    @IBOutlet weak var betSlider: UISlider!
    @IBOutlet weak var payoutLabel: UILabel!
    
    var gameId = ""
    var home = false
    var homePositiveMoneyLine = false
    var betAmount : Int64 = 0
    var moneyLine : Int64 = 0
    var hasOdds = true
    
    
    var profileId = ""
    
    var homeString = ""
    var awayString = ""
    
    var homeId : Int64 = 0
    var awayId : Int64 = 0
    
    var betPayout : Int64 = 0
    var karmaAmount : Int64 = 0
    
    var ref : DatabaseReference!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        homeLogo.layer.borderWidth = 2.0
        awayLogo.layer.borderWidth = 2.0
        
        betSlider.value = 0

        ref = Database.database().reference()
        
        ref.child("profiles").child(profileId).child("karma").observeSingleEvent(of: DataEventType.value, with: {(snapshot) in
            
            if (snapshot.exists()){
                self.karmaAmount = snapshot.value as! Int64
            }
            
        })
        
        ref.child("games").child(gameId).observeSingleEvent(of: DataEventType.value, with: {(snapshot) in
            
            var awayMoneyLine : Int64 = -1
            var homeMoneyLine : Int64 = -1
            
            if (snapshot.childSnapshot(forPath: "awayMoneyLine").exists()){
                awayMoneyLine = snapshot.childSnapshot(forPath: "awayMoneyLine").value as! Int64
            }
            
            if (snapshot.childSnapshot(forPath: "homeMoneyLine").exists()){
                homeMoneyLine = snapshot.childSnapshot(forPath: "homeMoneyLine").value as! Int64
            }
            
            if (awayMoneyLine == 0){
                self.moneyLine = homeMoneyLine
                self.homePositiveMoneyLine = true
            }else if (homeMoneyLine == 0){
                self.moneyLine = awayMoneyLine
                self.homePositiveMoneyLine = false
            }else {
                self.hasOdds = false
                self.betLabel.text = "There are no betting odds available for this game, bitch"
                
            }
            
            self.homeString = snapshot.childSnapshot(forPath: "home").value as! String
            self.awayString = snapshot.childSnapshot(forPath: "away").value as! String
            
            self.homeId = snapshot.childSnapshot(forPath: "homeId").value as! Int64
            self.awayId = snapshot.childSnapshot(forPath: "awayId").value as! Int64
            
            self.homeLogo.setImage(UIImage (named: "logo_" + String(self.homeId)), for: .normal)
            self.awayLogo.setImage(UIImage (named: "logo_" + String(self.awayId)), for: .normal)
            
        })
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sliderValueChanged(_ sender: Any) {
        
        let karmaPercent = Int64(Float(self.karmaAmount) * betSlider.value)
        var payout : Int64 = 0
        
        if (home){
            if (homePositiveMoneyLine){
                let ratio = (Double(moneyLine) / 100)
                let amountToAdd = Double(karmaPercent) * ratio
                let roundedAmount : Int64 = Int64(round(amountToAdd))
                
                payout = karmaPercent + roundedAmount
            }
            else {
                let ratio = (Double(100) / Double(moneyLine))
                let eh = Double(karmaPercent) * ratio
                let roundedEh : Int64 = Int64(round(eh))
                payout = karmaPercent + roundedEh
            }
        }else {
            if (homePositiveMoneyLine){
                let ratio = (Double(100) / Double(moneyLine))
                let eh = Double(karmaPercent) * ratio
                let roundedEh : Int64 = Int64(round(eh))
                payout = karmaPercent + roundedEh
                
                
            }else {
                let ratio = (Double(moneyLine) / 100)
                let amountToAdd = Double(karmaPercent) * ratio
                let roundedAmount : Int64 = Int64(round(amountToAdd))
                
                payout = karmaPercent + roundedAmount
                
            }
        }
        
        betAmount = karmaPercent
        betLabel.text = ("Betting " + String(karmaPercent) + " Karma")
        
        payoutLabel.text = ("Payout: " + String(payout) + " Karma")
        betPayout = payout
        
    }
    
    
    @IBAction func selectHome(_ sender: Any) {
        home = true
        
        homeLogo.layer.borderColor = UIColor.green.cgColor
        awayLogo.layer.borderColor = UIColor.lightGray.cgColor
        
        
        
        let karmaPercent = Int64(Float(self.karmaAmount) * betSlider.value)
        var payout : Int64 = 0
        
        if (home){
            if (homePositiveMoneyLine){
                let ratio = (Double(moneyLine) / 100)
                let amountToAdd = Double(karmaPercent) * ratio
                let roundedAmount : Int64 = Int64(round(amountToAdd))
                
                payout = karmaPercent + roundedAmount
            }
            else {
                let ratio =  (Double(100) / Double(moneyLine))
                let eh = Double(karmaPercent) * ratio
                let roundedEh : Int64 = Int64(round(eh))
                payout = karmaPercent + roundedEh
            }
        }else {
            if (homePositiveMoneyLine){
                let ratio = (Double(100) / Double(moneyLine))
                let eh = Double(karmaPercent) * ratio
                let roundedEh : Int64 = Int64(round(eh))
                payout = karmaPercent + roundedEh
                
                
            }else {
                let ratio = (Double(moneyLine) / 100)
                let amountToAdd = Double(karmaPercent) * ratio
                let roundedAmount : Int64 = Int64(round(amountToAdd))
                
                payout = karmaPercent + roundedAmount
                
            }
        }
        
        payoutLabel.text = ("Payout: " + String(payout) + " Karma")
        betPayout = payout
        
        
    }
    
    @IBAction func selectAway(_ sender: Any) {
        home = false
        
        homeLogo.layer.borderColor = UIColor.lightGray.cgColor
        awayLogo.layer.borderColor = UIColor.green.cgColor
        
        
        
        let karmaPercent = Int64(Float(self.karmaAmount) * betSlider.value)
        var payout : Int64 = 0
        
        if (home){
            if (homePositiveMoneyLine){
                let ratio = (Double(moneyLine) / 100)
                let amountToAdd = Double(karmaPercent) * ratio
                let roundedAmount : Int64 = Int64(round(amountToAdd))
                
                payout = karmaPercent + roundedAmount
            }
            else {
                let ratio = (Double(100) / Double(moneyLine))
                let eh = Double(karmaPercent) * ratio
                let roundedEh : Int64 = Int64(round(eh))
                payout = karmaPercent + roundedEh
            }
        }else {
            if (homePositiveMoneyLine){
                let ratio = (Double(100) / Double(moneyLine))
                let eh = Double(karmaPercent) * ratio
                let roundedEh : Int64 = Int64(round(eh))
                payout = karmaPercent + roundedEh
                
                
            }else {
                let ratio = (Double(moneyLine) / 100)
                let amountToAdd = Double(karmaPercent) * ratio
                let roundedAmount : Int64 = Int64(round(amountToAdd))
                
                payout = karmaPercent + roundedAmount
                
            }
        }
        
        payoutLabel.text = ("Payout: " + String(payout) + " Karma")
        betPayout = payout
        
        
    }
    
    @IBAction func placeBet(_ sender: Any) {
        
        if (betSlider.value == 0){
            
        }else {
            
        
        
        
        
        let alertController = UIAlertController(title: "Confirm", message: "Are you sure you'd like to place this bet?", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Yes", style: .default) { (_) in
            
             var betMap = [String : Any]()
            
            betMap["authorId"] = self.profileId
            betMap["homeTeamBet"] = self.home
            betMap["homeTeamId"] = self.homeId
            betMap["awayTeamId"] = self.awayId
            betMap["betAmount"] = self.betAmount
            betMap["payoutAmount"] = self.betPayout
            betMap["gameId"] = self.gameId
            if (self.home){
                betMap["teamName"] = self.homeString
            }else {
                betMap["teamName"] = self.awayString
            }
            
            self.ref.child("profiles").child(self.profileId).child("karma").observeSingleEvent(of: DataEventType.value, with: {(snapshot) in
                
                if (snapshot.exists()){
                    let karma : Int64 = snapshot.value as! Int64
                    let newKarma = karma - self.betAmount
                    
                    self.ref.child("profiles").child(self.profileId).child("karma").setValue(newKarma)
                }
                
            })

            self.navigationController?.popViewController(animated: true)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
        }
        
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
