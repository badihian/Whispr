//
//  RegisterInfoViewController.swift
//  Blabber
//
//  Created by Neema Badihian on 3/12/18.
//  Copyright © 2018 Neema Badihian. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD


class LoginViewController: UIViewController {
    
    
    @IBOutlet weak var phoneNumberTextField: UITextField!
    var phoneNumber = ""
    
    override func viewDidLoad() {
        
//        Check if user is already logged in. If they are logged in, segue to the MessagesViewController.
            Auth.auth().addStateDidChangeListener { auth, user in
                if let user = user {
                    self.performSegue(withIdentifier: "goToMessages", sender: self)
                } else {
//                    No user is signed in. Do nothing.
                }
            }
        super.viewDidLoad()
    }
    
//    perform when the Continue button is pressed
    @IBAction func continueButton(_ sender: Any) {
        
        self.phoneNumber = phoneNumberTextField.text! // get phone user's phone number from what they entered
        let components = phoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted) // separate phoneNumber into its numerical characters
        self.phoneNumber = components.joined() // join numerical characters so that any alphabetical characters are excluded
        
        self.phoneNumber = self.phoneNumber.replacingOccurrences(of: "-", with: "") // remove all '-' from number
        self.phoneNumber = self.phoneNumber.replacingOccurrences(of: "(", with: "") // remove all '(' from number
        self.phoneNumber = self.phoneNumber.replacingOccurrences(of: ")", with: "") // remove all ')' from number

        checkCount(phoneNumber: self.phoneNumber) // check if phoneNumber has '+1' included at beginning, if it does not, add '+1'
        
//        ask user if the phone number they entered is correct
        let alert  = UIAlertController(title: "Phone Number", message: "Is this you number?\n\(self.phoneNumber)", preferredStyle: .alert)
        
//        perform the following if they user clicks 'Yes' when asked if the number shown is the correct number
        let action = UIAlertAction(title: "Yes", style: .default) { (UIAlertAction) in
            PhoneAuthProvider.provider().verifyPhoneNumber(self.phoneNumber, uiDelegate: nil) {
                (verificationID, error) in
                
                if error != nil {
                    SVProgressHUD.dismiss()
                    print("error: \(error!)")
                } else {
                    
                    SVProgressHUD.show()
                    
//                    set verification key
                    UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
                    let verificationID = UserDefaults.standard.string(forKey: "authVerificationID")
                    
//                    segue to VerificationViewController
                    SVProgressHUD.dismiss()
                    self.performSegue(withIdentifier: "goToVerification", sender: self)
                }
                
                
            }
        }
        
        let cancel = UIAlertAction(title: "No", style: .cancel, handler: nil) // add cancel action if user number shown is incorrect
        
//        add action and cancel to the alert
        alert.addAction(action)
        alert.addAction(cancel)
        
//        present alert
        self.present(alert, animated: true, completion: nil)
        
        
    }
    
//    create alert for error
    func showAlert(error : String) {
        let alert = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: { _ in alert.dismiss(animated: true, completion: nil)} )
        
    }
    
//    check if phone number includes '+1' at the beginning based on the count of characters in the string
//    if it doesn't contain '+1', add it to the front of the number
    func checkCount(phoneNumber : String) {
            if phoneNumber.count == 11 {
                self.phoneNumber = "+" + phoneNumber
            }
            else if phoneNumber.count == 10 {
                self.phoneNumber = "+1" + phoneNumber
            }
    }
    
    
    
}
