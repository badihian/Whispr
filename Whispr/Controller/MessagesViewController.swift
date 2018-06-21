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
    
    let user = Auth.auth().currentUser // Firebase object to access current user's data
    var contactInfo = [contactsUsed]() // struct contactsUsed is defined in ChatViewController.swift
    var conversationArray = [ChatMessages]() // class ChatMessages is defined in ChatMessages.swift
    var cellContactNumber = String()
    var cellContactName = String()
    
    let realm = try! Realm() // initialize Realm instance
    
    var composePressed = Bool()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        conversationsTableView.separatorStyle = .none // remove lines from table view
        
        self.cellContactNumber.removeAll() // reset cellContactNumber
        self.cellContactName.removeAll() // reset cellContactName
        self.conversationArray.removeAll() // reset conversationArray
        
        conversationsTableView.delegate = self
        conversationsTableView.dataSource = self
        
//        get cell design from ConversationsTableViewCell.swift
        conversationsTableView.register(UINib(nibName: "ConversationsTableViewCell", bundle:nil), forCellReuseIdentifier: "customConversationsCell")
        
        messageSearchBar.isHidden = true // hide search bar
        self.conversationsTableView.reloadData() // reload table view
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.cellContactNumber.removeAll() // reset cellContactNumber
        self.cellContactName.removeAll() // reset cellContactName
        self.conversationArray.removeAll() // reset conversationArray
        self.composePressed = false // start with the app believing the compose button was not pressed
        
        self.conversationsTableView.reloadData() // reload table view
        
        configureTableView() // set height of table view
        retrieveMessages() // populate the table view with data from Firebase
    }
    
//    toggle the search bar's visibility
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
    
//    perform when the edit button is pressed
    @IBAction func editButton(_ sender: Any) {
    }
    
//    create a new conversation and segue to ChatViewController when the compose button is pressed
    @IBAction func composeButton(_ sender: Any) {
        self.composePressed = true
        self.view.layoutIfNeeded()
        performSegue(withIdentifier: "goToChat", sender: self)
    }
    
//    hide the keyboard if the table view is tapped
    @objc func tableViewTapped() {
        self.messageSearchBar.endEditing(true)
        UIView.animate(withDuration: 0.2){
//            self.composeToolbarBottomConstraint.constant = self.view.safeAreaInsets.bottom - 34
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: - TableView
    
//    this function populates the table view's cells with the data in conversationArray which was filled by retrieveMessages()
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
    
//    this function gets the contact info of the conversation selected to open the chat with selected contact in ChatViewController
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
    
//    this function sets the number of rows of the table view based on the count of conversations in conversationArray
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.conversationArray.count
    }
    
//    this function configures the table view's height
    func configureTableView() {
        conversationsTableView.rowHeight = UITableViewAutomaticDimension
        conversationsTableView.estimatedRowHeight = 120.0
        self.view.layoutIfNeeded()
    }
    
    // MARK: - Database
    
//    this function gets all the last messages of each contact (sent or received) and adds them to an array
//    which is used to populate the table view so users can choose which conversation to go to
    func retrieveMessages() {
        if let user = user { // check if user is populated
            var userNumber = user.phoneNumber! // get the user's phone number
            userNumber = String(describing: userNumber) // turn the user's phone number into a string
            
            let messagesDB = Database.database().reference().child("Conversations").child("user").child(userNumber).child("all") // set a reference to the messages database of the user
            let contactsDB = Database.database().reference().child("Conversations").child("user").child(userNumber).child("contacts") // set a reference to the contacts database of the user
            messagesDB.observe(.childAdded) { (snapshot) in // listen for changes in messagesDB
                contactsDB.observe(.childAdded) { (snapContact) in // listen for changes in contactsDB
                    let snapshotValue = snapshot.key // the snapshot key for the change in messagesDB
                    let snapContactValue = snapContact.key // the snapshot key for the change in contactsDB
                    let contactNumber = String(describing: snapContactValue) // turn the contactsDB snapshot key into a string
                    let messagesContactNumber = String(describing: snapshotValue) // turn the messagesDB snapshot key into a string
                    
                    if contactNumber == messagesContactNumber { // check if both snapshot keys are equal, if so, perform the following
//                        get the last message in the database
                        messagesDB.child(messagesContactNumber).queryLimited(toLast: 1).observe(.childAdded) { (snapshot) in
                            let snapshotValue = snapshot.value as! Dictionary<String, String>
                            let text = snapshotValue["MessageBody"]!
//                            get the last contact name, sender name, and timestamp in the database
                            contactsDB.child(contactNumber).queryLimited(toLast: 1).observe(.childAdded) { (contShot) in
                                let contShotValue = contShot.value as! Dictionary<String, String>
                                let contactName = contShotValue["Name"]!
                                let sender = snapshotValue["Sender"]!
                                let timeStamp = snapshotValue["Timestamp"]!
                                
                                let chatMessage = ChatMessages() // declare a new object of class ChatMessages()
                                chatMessage.messageBody = text // set the messageBody property to the last message in the database
                                chatMessage.contactName = contactName // set the contactName property to the last contact name in the database
                                chatMessage.sender = sender // set the sender property to the last sender name in the database
                                chatMessage.recipient = contactNumber // set the contactNumber property to the snapshot key string value of contactsDB's child added
                                chatMessage.timeStamp = timeStamp // set the timestamp to the last timestamp in the database
                                
                                self.conversationArray.append(chatMessage) // add the values of chatMessage to conversationArray
                                self.conversationArray.sort { $0.timeStamp == $1.timeStamp ? $0.contactName > $1.contactName : $0.timeStamp > $1.timeStamp } // sort the array by the timestamp
                                
                                self.configureTableView() // configure the table view's height
                                self.conversationsTableView.reloadData() // reload the table view's data
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
//                    transfer the selected contact number and name to the ChatViewController
                    nextScene.cellContactNumber = cellContactNumber
                    nextScene.cellContactName = cellContactName
                }
            }
        }
    }
}
