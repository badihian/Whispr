//
//  ChatViewController.swift
//  Blabber
//
//  Created by Neema Badihian on 3/12/18.
//  Copyright © 2018 Neema Badihian. All rights reserved.
//

import UIKit
import Firebase
import Contacts
import ContactsUI
import ChameleonFramework

struct contactsUsed {
    
    var firstName : String
    var phoneNumber : String
    var phoneCount : Int
    
    mutating func checkCount() {
        for _ in 0...phoneCount - 1 {
            if self.phoneCount == 11 {
                self.phoneNumber = "+" + self.phoneNumber
                self.phoneCount += 1
            }
            else if self.phoneCount == 10 {
                self.phoneNumber = "+1" + self.phoneNumber
                self.phoneCount += 2
            }
        }
    }
    
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}

class ChatViewController: UIViewController, CNContactPickerDelegate, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, UIToolbarDelegate, UITextFieldDelegate, UITextViewDelegate {
    @IBOutlet weak var chatSearchBar: UISearchBar!
    @IBOutlet weak var contactNameView: UIView!
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var contactTextField: UITextField!
    @IBOutlet weak var composeTextView: UITextView!
    @IBOutlet weak var composeToolbar: UIToolbar!
    @IBOutlet weak var composeViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var sendButton: UIBarButtonItem!
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    @IBOutlet weak var chatTableViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var composeTextItem: UIBarButtonItem!
    @IBOutlet weak var composeViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var composeUIView: UIView!
    
    var contactInfo = [contactsUsed]()
    var isComposePressed = Bool()
    let contactStore = CNContactStore()
    var contacts = [CNContact]()
    let keys = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName), CNContactPhoneNumbersKey] as [Any]
    var messageArray : [ChatMessages] = [ChatMessages]()
    var receivingArray : [ReceivingContact] = [ReceivingContact]()
    let user = Auth.auth().currentUser
    var cellContactName = String()
    var cellContactNumber = String()
    var recipientNumber = String()
    var contactName = String()
    var dataArray = String()
    var multipleSelection = false
    var oldNumLines = CGFloat()
    
    func scrollToBottom() {
        
        let numberOfSections = self.chatTableView.numberOfSections
        let numberOfRows = self.chatTableView.numberOfRows(inSection: numberOfSections-1)
        if numberOfRows > 1{
            let indexPath = IndexPath(row: numberOfRows-1 , section: numberOfSections-1)
            
            self.chatTableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.bottom, animated: false)
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        print("Test viewDidAppear")
        
        scrollToBottom()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sendButton.isEnabled = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        
        self.chatTableView.allowsMultipleSelectionDuringEditing = true
        deleteButton.tintColor = UIColor.black
        
        chatSearchBar.isHidden = true
        
        contactNameView.isHidden = isComposePressed
        
        chatTableView.delegate = self
        chatTableView.dataSource = self
        contactTextField.delegate = self
        composeTextView.delegate = self
        composeToolbar.delegate = self
        
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        chatTableView.addGestureRecognizer(tapGesture2)
        chatTableView.register(UINib(nibName: "ChatMessagesTableViewCell", bundle:nil), forCellReuseIdentifier: "customChatCell")
        
        configureTableView()
        retrieveMessages()
        
        chatTableView.separatorStyle = .none
        
        print("messageArray count: \(self.messageArray.count)")
        
        self.view.layoutIfNeeded()
        
        composeTextView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        
        self.oldNumLines = 1.97521627308861
    }
    
    
    // MARK: - Observer for composeTextView
    
    deinit {
        composeTextView.removeObserver(self, forKeyPath: "contentSize")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        let newNumLines = composeTextView.contentSize.height / (composeTextView.font?.lineHeight)!
        
        let diffNumLines = newNumLines - oldNumLines
        
        var heightChange = (diffNumLines * (composeTextView.font?.lineHeight)!)
        
        if heightChange > 67 {
            heightChange = 67
        }
        if heightChange < -67 {
            heightChange = -67
        }
        
        if diffNumLines > 0.75 {
            if composeTextView.frame.size.height < (5 * (composeTextView.font?.lineHeight)!) {
                composeTextView.frame.size.height += heightChange
                composeViewHeightConstraint.constant += heightChange
            }
        }
        
        if composeTextView.frame.size.height > 33 {
            if diffNumLines < -0.75 {
                
                if newNumLines > 1.97521627308861 && composeTextView.frame.size.height < (5 * (composeTextView.font?.lineHeight)!) {
                    composeTextView.frame.size.height += heightChange
                    composeViewHeightConstraint.constant += heightChange
                }
            }
            
            if composeTextView.frame.size.height >= (5 * (composeTextView.font?.lineHeight)!) && composeTextView.frame.size.height < (6 * (composeTextView.font?.lineHeight)!) && diffNumLines < -0.75 {
                
                composeTextView.frame.size.height += heightChange
                composeViewHeightConstraint.constant += heightChange
            }
        }
        
        self.oldNumLines = newNumLines
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
    
    
    // MARK: - TableView
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customChatCell", for: indexPath) as! ChatMessagesTableViewCell
        
        self.chatTableView.directionalPressGestureRecognizer.cancelsTouchesInView = false
        if let user = user {
            var userNumber = user.phoneNumber!
            
            userNumber = String(describing: userNumber)
            cell.messageBody.text = messageArray[indexPath.row].messageBody
            cell.senderName.text = messageArray[indexPath.row].contactName
            
            if messageArray[indexPath.row].sender == userNumber as String! {
                
                //            cell.senderBackground.backgroundColor = UIColor(rgb: 0x0119B5)
                //                cell.messageBackground.backgroundColor = UIColor(rgb: 0x01196E)
                //                cell.chatCellLeadingConstraint.constant = 28
                //                cell.chatCellTrailingConstraint.constant = 0
                
                if cell.cellMessageBodyLeadingConstraint != nil{
                    cell.cellMessageBodyLeadingConstraint.isActive = false
                    cell.cellMessageBodyTrailingConstraint.constant = 8
                }
                
                if cell.cellMessageBodyTrailingConstraint != nil {
                    cell.cellMessageBodyTrailingConstraint.isActive = true
                }
                
                cell.senderName.textAlignment = .right
                
            } else {
                
                if cell.cellMessageBodyTrailingConstraint != nil {
                    cell.cellMessageBodyTrailingConstraint.isActive = false
                    cell.cellMessageBodyLeadingConstraint.constant = 8
                }
                
                if cell.cellMessageBodyLeadingConstraint != nil {
                    cell.cellMessageBodyLeadingConstraint.isActive = true
                }
                
                cell.messageBody.textAlignment = .left
                cell.senderName.textAlignment = .left
                cell.messageBody.textColor = UIColor.white
                //            UIColor.flatSkyBlue()
                //            cell.senderBackground.backgroundColor = UIColor(rgb: 0xff33cc)
                //                cell.messageBackground.backgroundColor = UIColor(rgb: 0x0033cc)
            }
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedCellCount = updateCellCount()
        if selectedCellCount > 0 {
            self.deleteButton.isEnabled = true
        } else if selectedCellCount == 0{
            self.deleteButton.isEnabled = false
        }
        
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        let selectedCellCount = updateCellCount()
        if selectedCellCount > 0 {
            self.deleteButton.isEnabled = true
        } else if selectedCellCount == 0{
            self.deleteButton.isEnabled = false
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }
    
    @objc func tableViewTapped() {
        
        self.contactTextField.endEditing(true)
        self.composeTextView.endEditing(true)
        self.chatSearchBar.endEditing(true)
        UIView.animate(withDuration: 0.2){
            
            self.composeViewBottomConstraint.constant = self.view.safeAreaInsets.bottom - 34
            self.view.layoutIfNeeded()
        }
        
    }
    
    func configureTableView() {
        self.chatTableView.rowHeight = UITableViewAutomaticDimension
        self.chatTableView.estimatedRowHeight = 20.0
        
    }
    
    func updateCellCount() -> Int{
        
        var listCount = 0
        
        if let list = chatTableView.indexPathsForSelectedRows as [NSIndexPath]? {
            
            if list.count > 0 {
                
                listCount = list.count
            }
        }
        
        return listCount
    }
    
    // MARK: - Keyboard
    
    
    @objc func keyboardWillShow(notification: Notification) {
        let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        
        let keyboardHeight = keyboardSize?.height
        
        print("In keyboardWillShow composeViewBottomConstraint.constant = \(composeViewBottomConstraint.constant)")
        
        if #available(iOS 11.0, *){
            
            self.composeViewBottomConstraint.constant = keyboardHeight! - view.safeAreaInsets.bottom
        }
        else {
            self.composeViewBottomConstraint.constant = view.safeAreaInsets.bottom
        }
        
        self.view.layoutIfNeeded()
        
    }
    
    
    
    func textViewDidChange(_ textView: UITextView) {
        
        
        if self.composeTextView.text == "" {
            self.sendButton.isEnabled = false
        }
        else {
            self.sendButton.isEnabled = true
        }
    }
    
    func adjustUITextViewHeight(arg: UITextView) {
        arg.translatesAutoresizingMaskIntoConstraints = true
        arg.sizeToFit()
        arg.isScrollEnabled = false
    }
    
    
    // MARK: - Send Messages
    
    @IBAction func sendPressed(_ sender: Any) {
        
        var ref: DatabaseReference!
        
        ref = Database.database().reference()
        
        self.contactTextField.endEditing(true)
        
        contactNameView.isHidden = true
        sendButton.isEnabled = false
        
        let messagesDB = Database.database().reference().child("Conversations").child("ChatMessages")
        if let user = user {
            var userNumber = user.phoneNumber!
            
            userNumber = String(describing: userNumber)
            
            
            if !self.contactInfo.isEmpty{
                self.recipientNumber = self.contactInfo[0].phoneNumber
                
                self.contactName = self.contactInfo[0].firstName
            }
            
            if self.contactInfo.isEmpty {
                self.recipientNumber = cellContactNumber
                self.contactName = cellContactName
            }
            
            if self.contactInfo.count > 1{
                for contact in 1...self.contactInfo.count - 1{
                    
                    self.recipientNumber += ", \(self.contactInfo[contact].phoneNumber)"
                    self.contactName += ", \(self.contactInfo[contact].firstName)"
                    
                }
            }
            
            
            let timeStamp = String(describing: Date())
            
            
            let contactDictionary = ["Name" : self.contactName]
            
            let key = ref.child("Conversations").childByAutoId().key
            print("sendKey: \(key)")
            
            let recipientDictionary = ["Recipient" : self.recipientNumber]
            let messageDictionary = ["Sender" : String(describing: userNumber), "MessageBody" : composeTextView.text!, "Recipient" : self.recipientNumber, "Name" : self.contactName, "Timestamp" : timeStamp, "UID" : key]
            
            let childUpdatesInfo = ["/posts/\(key)": recipientDictionary, "/user/\(userNumber)/contacts/\(self.recipientNumber)/\(key)": contactDictionary]
            let childUpdatesSenderAll = ["/posts/\(key)": recipientDictionary, "/user/\(userNumber)/all/\(self.recipientNumber)/\(key)/": messageDictionary]
            let childUpdatesRecipientAll = ["/posts/\(key)": recipientDictionary, "/user/\(self.recipientNumber)/all/\(userNumber)/\(key)/": messageDictionary]
            let childUpdatesSent = ["/posts/\(key)": recipientDictionary, "/user/\(userNumber)/sent/\(self.recipientNumber)/\(key)/": messageDictionary]
            let childUpdatesReceived = ["/posts/\(key)": recipientDictionary, "/user/\(self.recipientNumber)/received/\(userNumber)/\(key)/": messageDictionary]
            ref.child("Conversations").updateChildValues(childUpdatesInfo)
            ref.child("Conversations").updateChildValues(childUpdatesSenderAll)
            ref.child("Conversations").updateChildValues(childUpdatesRecipientAll)
            ref.child("Conversations").updateChildValues(childUpdatesSent)
            ref.child("Conversations").updateChildValues(childUpdatesReceived)
            
            
            messagesDB.childByAutoId().setValue(messageDictionary) {
                
                (error, reference) in
                
                if error != nil {
                    print("\(error!)")
                } else {
                    print("Message saved successfully!")
                    
                    self.composeTextView.isEditable = true
                    
                    self.composeTextView.text = ""
                }
            }
        }
    }
    
    func retrieveMessages() {
        
        if let user = user {
            var userNumber = user.phoneNumber!
            userNumber = String(describing: userNumber)
            var recipient = String()
            
            if !self.contactInfo.isEmpty {
                
                recipient = self.recipientNumber
            }
            if !self.cellContactNumber.isEmpty {
                
                recipient = self.cellContactNumber
            }
            
            if !recipient.isEmpty{
                
                let messagesDB = Database.database().reference().child("Conversations").child("user").child(userNumber).child("all").child(recipient)
                
                messagesDB.observe(.childAdded) { (snapshot) in
                    
                    let snapshotValue = snapshot.value as! Dictionary<String, String>
                    
                    let text = snapshotValue["MessageBody"]!
                    let sender = snapshotValue["Sender"]!
                    let uid = snapshot.key
                    var senderName = String()
                    
                    if sender == Auth.auth().currentUser?.phoneNumber{
                        senderName = (Auth.auth().currentUser?.displayName)!
                    } else {
                        senderName = snapshotValue["Name"]!
                    }
                    
                    let chatMessage = ChatMessages()
                    chatMessage.messageBody = text
                    chatMessage.sender = sender
                    chatMessage.contactName = senderName
                    chatMessage.uid = uid
                    //                        chatMessage.recipient = recipient
                    
                    self.messageArray.append(chatMessage)
                    self.configureTableView()
                    self.chatTableView.reloadData()
                    
                    self.scrollToBottom()
                }
                messagesDB.observe(.childRemoved) { (snapshot) in
                    
                    let uid = snapshot.key
                    
                    
                    let arrayCount = (self.messageArray.count - 1)
                    for index in 0...arrayCount {
                        if self.messageArray[index].uid == uid {
                            self.messageArray.remove(at: index)
                            break
                        }
                    }
                    self.configureTableView()
                    self.chatTableView.reloadData()
                }
            }
        }
    }
    
    // MARK:- Edit Messages
    
    
    @IBAction func editPressed(_ sender: Any) {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        chatTableView.addGestureRecognizer(tapGesture)
        
        if self.multipleSelection == false {
            
            deleteButton.tintColor = UIColor.lightGray
            self.chatTableView.setEditing(true, animated: true)
            tapGesture.cancelsTouchesInView = false
            self.chatTableView.visibleCells.forEach { cell in
                if let cell = cell as? ChatMessagesTableViewCell {
                    cell.selectionStyle = UITableViewCellSelectionStyle.blue
                }
            }
            self.multipleSelection = true
        }
        else if self.multipleSelection == true {
            
            deleteButton.tintColor = UIColor.black
            
            self.chatTableView.visibleCells.forEach { cell in
                if let cell = cell as? ChatMessagesTableViewCell {
                    cell.selectionStyle = UITableViewCellSelectionStyle.none
                }
            }
            self.chatTableView.setEditing(false, animated: true)
            tapGesture.cancelsTouchesInView = true
            self.multipleSelection = false
        }
    }
    
    
    
    @IBAction func deletePressed(_ sender: Any) {
        
        self.deleteButton.isEnabled = false
        deleteButton.tintColor = UIColor.black
        
        print("messageArray.count1: \(messageArray.count)")
        if let paths = chatTableView.indexPathsForSelectedRows {
            
            if let user = user {
                var userNumber = user.phoneNumber!
                userNumber = String(describing: userNumber)
                var recipient = String()
                
                if !self.contactInfo.isEmpty {
                    
                    recipient = self.recipientNumber
                }
                if !self.cellContactNumber.isEmpty {
                    
                    recipient = self.cellContactNumber
                }
                
                let messagesDB = Database.database().reference().child("Conversations").child("user").child(userNumber).child("all").child(recipient)
                print("paths: \(paths)")
                
                for path in paths {
                    print("path: \(path)")
                    
                    
                    let deleteObserver = messagesDB.observe(.childAdded) { (snapshot) in
                        
                        print("snapshot.key: \(snapshot.key)")
                        
                        print("messageArray.uid: \(self.messageArray[path.row].uid)")
                        if snapshot.key == self.messageArray[path.row].uid {
                            messagesDB.child(self.messageArray[path.row].uid).removeValue()
                            print("messageArray.count2: \(self.messageArray.count)")
                        }
                    }
                    messagesDB.removeObserver(withHandle: deleteObserver)
                    
                }
            }
            
        }
        
        self.chatTableView.visibleCells.forEach { cell in
            if let cell = cell as? ChatMessagesTableViewCell {
                cell.selectionStyle = UITableViewCellSelectionStyle.none
            }
        }
        self.chatTableView.setEditing(false, animated: true)
        self.multipleSelection = false
        
        
    }
    
    
    @IBAction func searchButton(_ sender: Any) {
        if chatSearchBar.isHidden == true {
            chatSearchBar.isHidden = false
            
            self.chatTableViewTopConstraint.constant += 56
        }
        else if chatSearchBar.isHidden == false {
            chatSearchBar.isHidden = true
            self.chatTableViewTopConstraint.constant -= 56
        }
    }
    
    // MARK: - Add Contact
    
    @IBAction func addContactButton(_ sender: Any) {
        self.contactTextField.endEditing(true)
        self.composeTextView.endEditing(true)
        
        UIView.animate(withDuration: 0.2){
            self.composeViewBottomConstraint.constant = self.view.safeAreaInsets.bottom - 34
            self.view.layoutIfNeeded()
        }
        
        let entityType = CNEntityType.contacts
        let authStatus = CNContactStore.authorizationStatus(for: entityType)
        
        if authStatus == CNAuthorizationStatus.notDetermined {
            
            let contactStore = CNContactStore.init()
            contactStore.requestAccess(for: entityType, completionHandler: { (success, nil) in
                
                if success{
                    
                    self.openContacts()
                    
                } else {
                    print("Not Authorized")
                }
                
            })
            
        }
        else if authStatus == CNAuthorizationStatus.authorized {
            
            self.openContacts()
            
        }
        
    }
    
    func openContacts() {
        
        let contactPicker = CNContactPickerViewController.init()
        contactPicker.delegate = self
        self.present(contactPicker, animated: true, completion: nil)
        
        
        
    }
    
    func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
        
        picker.dismiss(animated: true) {
            
        }
        
        
    }
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        //User selected contact
        
        var phoneNumber = ""
        var firstName = ""
        
        if !contact.phoneNumbers.isEmpty {
            firstName = "\(contact.givenName)"
            
            let phoneNumberString = ((((contact.phoneNumbers[0] as AnyObject).value(forKey: "labelValuePair") as AnyObject).value(forKey: "value") as AnyObject).value(forKey: "stringValue"))
            
            phoneNumber = phoneNumberString! as! String
            
            let components =
                phoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted)
            phoneNumber = components.joined()
            phoneNumber = phoneNumber.replacingOccurrences(of: "-", with: "")
            phoneNumber = phoneNumber.replacingOccurrences(of: "(", with: "")
            phoneNumber = phoneNumber.replacingOccurrences(of: ")", with: "")
            
            if !self.contactInfo.isEmpty || phoneNumber == ""{
                
                var isDuplicate = false
                
                for name in self.contactInfo {
                    if name.firstName == firstName{
                        print("That name was already entered.")
                        isDuplicate = true
                    }
                }
                
                for number in self.contactInfo {
                    if number.phoneNumber == phoneNumber{
                        print("That number was already entered.")
                        isDuplicate = true
                    }
                }
                
                if isDuplicate == false {
                    self.contactInfo.append(contactsUsed(firstName: "\(firstName)", phoneNumber: "\(phoneNumber)", phoneCount: phoneNumber.count))
                    self.contactTextField.text = self.contactTextField.text! + "  \(firstName)"
                }
                isDuplicate = false
            }
                
            else if self.contactInfo.isEmpty{
                self.contactInfo.append(contactsUsed(firstName: "\(firstName)", phoneNumber: "\(phoneNumber)", phoneCount: phoneNumber.count))
                //                receivingArray.append(phoneNumber)
                self.contactTextField.text = self.contactTextField.text! + "  \(firstName)"
            }
        }
        else {
            print("No number")
        }
        
        for number in 0...self.contactInfo.count - 1 {
            self.contactInfo[number].checkCount()
        }
        
        self.contactInfo.sort { $0.phoneNumber == $1.phoneNumber ? $0.firstName < $1.firstName : $0.phoneNumber < $1.phoneNumber }
        
        print(self.contactInfo)
        
        messageArray.removeAll()
        chatTableView.reloadData()
        
        self.recipientNumber = contactInfo[0].phoneNumber
        
        if contactInfo.count > 1{
            for contact in 1...self.contactInfo.count - 1{
                
                self.recipientNumber += ", \(self.contactInfo[contact].phoneNumber)"
                
            }
        }
        
        retrieveMessages()
        
        self.view.layoutIfNeeded()
        
    }
    
}
