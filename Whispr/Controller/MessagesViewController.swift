//
//  MessagesViewController.swift
//  Blabber
//
//  Created by Neema Badihian on 3/12/18.
//  Copyright © 2018 Neema Badihian. All rights reserved.
//

import UIKit
import Contacts
import Firebase
import RealmSwift

class MessagesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var messageSearchBar: UISearchBar!
    @IBOutlet weak var conversationsTableView: UITableView!
    @IBOutlet weak var conversationsTableViewTopConstraint: NSLayoutConstraint!
    
    let user = Auth.auth().currentUser
    var contactInfo = [contactsUsed]()
    var conversationArray = [ChatMessages]()
    var cellContactNumber = String()
    var cellContactName = String()
    
    let realm = try! Realm()
    
    var composePressed = Bool()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        conversationsTableView.separatorStyle = .none
        
        self.cellContactNumber.removeAll()
        self.cellContactName.removeAll()
        self.conversationArray.removeAll()
        
        conversationsTableView.delegate = self
        conversationsTableView.dataSource = self
        conversationsTableView.register(UINib(nibName: "ConversationsTableViewCell", bundle:nil), forCellReuseIdentifier: "customConversationsCell")
        
        messageSearchBar.isHidden = true
        self.conversationsTableView.reloadData()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        self.cellContactNumber.removeAll()
        self.cellContactName.removeAll()
        self.conversationArray.removeAll()
        self.composePressed = false
        
        self.conversationsTableView.reloadData()
        
        configureTableView()
        retrieveMessages()
        
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
    @IBAction func searchButton(_ sender: Any) {
        if messageSearchBar.isHidden == true {
            messageSearchBar.isHidden = false
            self.conversationsTableViewTopConstraint.constant += 56
        }
        else if messageSearchBar.isHidden == false {
            messageSearchBar.isHidden = true
            
            self.conversationsTableViewTopConstraint.constant -= 56
            tableViewTapped()
        }
        
    }
    @IBAction func editButton(_ sender: Any) {
    }
    @IBAction func composeButton(_ sender: Any) {
        self.composePressed = true
        
        self.view.layoutIfNeeded()
        
        performSegue(withIdentifier: "goToChat", sender: self)
        
    }
    
    @objc func tableViewTapped() {
        
        self.messageSearchBar.endEditing(true)
        UIView.animate(withDuration: 0.2){
//            
//            self.composeToolbarBottomConstraint.constant = self.view.safeAreaInsets.bottom - 34
            self.view.layoutIfNeeded()
        }
        
    }
    
    // MARK: - TableView
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customConversationsCell", for: indexPath) as! ConversationsTableViewCell
        
        cell.messageLabel.text = conversationArray[indexPath.row].messageBody
        cell.contactLabel.text = conversationArray[indexPath.row].contactName
        print("sender: \(conversationArray[indexPath.row].sender)")
        print("currentUser: \(Auth.auth().currentUser?.phoneNumber)")
        
        if Auth.auth().currentUser?.phoneNumber == conversationArray[(indexPath.row)].sender {
            
            cell.contactLabel.textColor = UIColor(rgb: 0x88FBFD)
            print("This is true")
            
        }
        
        self.view.layoutIfNeeded()
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let indexPath = tableView.indexPathForSelectedRow
        let cell = tableView.cellForRow(at: indexPath!) as! ConversationsTableViewCell
        if conversationArray[(indexPath?.row)!].sender == Auth.auth().currentUser?.phoneNumber {
            
            self.cellContactNumber = conversationArray[(indexPath?.row)!].recipient
            self.cellContactName = conversationArray[(indexPath?.row)!].contactName
        }
        else if conversationArray[(indexPath?.row)!].sender != Auth.auth().currentUser?.phoneNumber {
            self.cellContactName = conversationArray[(indexPath?.row)!].contactName
            self.cellContactNumber = conversationArray[(indexPath?.row)!].recipient
        }
        performSegue(withIdentifier: "goToChat", sender: self)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.conversationArray.count
    }
    
    
    func configureTableView() {
        conversationsTableView.rowHeight = UITableViewAutomaticDimension
        conversationsTableView.estimatedRowHeight = 120.0
        
        self.view.layoutIfNeeded()
    }
    
    func retrieveMessages() {
        
        if let user = user {
            var userNumber = user.phoneNumber!
            userNumber = String(describing: userNumber)
            
            let messagesDB = Database.database().reference().child("Conversations").child("user").child(userNumber).child("all")
            let contactsDB = Database.database().reference().child("Conversations").child("user").child(userNumber).child("contacts")
            messagesDB.observe(.childAdded) { (snapshot) in
                contactsDB.observe(.childAdded) { (snapContact) in
                    let snapshotValue = snapshot.key
                    let snapContactValue = snapContact.key
                    let contactNumber = String(describing: snapContactValue)
                    let messagesContactNumber = String(describing: snapshotValue)
                    
                    
                    if contactNumber == messagesContactNumber {
                        messagesDB.child(String(describing: snapshotValue)).queryLimited(toLast: 1).observe(.childAdded) { (snapshot) in
                            let snapshotValue = snapshot.value as! Dictionary<String, String>
                            
                            let text = snapshotValue["MessageBody"]!
                            contactsDB.child(String(describing: snapContactValue)).queryLimited(toLast: 1).observe(.childAdded) { (contShot) in
                                let contShotValue = contShot.value as! Dictionary<String, String>
                                let contactName = contShotValue["Name"]!
                                let sender = snapshotValue["Sender"]!
                                let timeStamp = snapshotValue["Timestamp"]!
                                
                                
                                let chatMessage = ChatMessages()
                                chatMessage.messageBody = text
                                chatMessage.contactName = contactName
                                chatMessage.sender = sender
                                chatMessage.recipient = contactNumber
                                chatMessage.timeStamp = timeStamp
                                
                                self.conversationArray.append(chatMessage)
                                self.conversationArray.sort { $0.timeStamp == $1.timeStamp ? $0.contactName > $1.contactName : $0.timeStamp > $1.timeStamp }
                                
                                self.configureTableView()
                                self.conversationsTableView.reloadData()
                            }
                        }
                    }
                }
            }
        }
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToChat"
        {
            
            if  let nextScene = segue.destination as? ChatViewController {
                if self.composePressed == true {
                    
                    nextScene.isComposePressed = false
                    
                }
                
                if !cellContactNumber.isEmpty {
                    nextScene.isComposePressed = true
                    nextScene.cellContactNumber = cellContactNumber
                    nextScene.cellContactName = cellContactName
                }
            }
            
            
            
        }
    }
    
}
