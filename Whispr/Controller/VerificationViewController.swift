//
//  VerificationViewController.swift
//  Blabber
//
//  Created by Neema Badihian on 3/13/18.
//  Copyright © 2018 Neema Badihian. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class VerificationViewController: UIViewController {
    @IBOutlet weak var verificationTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func enterCodeButton(_ sender: Any) {
        
        let verificationDefaults = UserDefaults.standard // initialize Firebase verification object
        
//        set sign in credentials with user's phone number and the verification key they entered in the text field
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationDefaults.string(forKey: "authVerificationID")!, verificationCode: verificationTextField.text!)
        
//        sign in with the set credentials
        Auth.auth().signIn(with: credential) { (user, error) in
            if error != nil {
                SVProgressHUD.dismiss()
                self.showAlert(error: String(describing: error))
                print("error: \(error!)")
            } else {
                SVProgressHUD.show()
                print("Phone number: \(String(describing: user?.phoneNumber))")
                let userInfo = user?.providerData[0]
                print("Provider ID: \(String(describing: userInfo?.providerID))")
                SVProgressHUD.dismiss()
                let user = Auth.auth().currentUser
                
//                if user has a display name, segue to MessagesViewController
                if user?.displayName != nil {
                    
                    self.performSegue(withIdentifier: "goToMessages", sender: self)
                }
//                if user does NOT have a display name, go to AddNameViewController
                else {
                    
                    self.performSegue(withIdentifier: "goToAddName", sender: self)
                }
            }
        }
        
    }
    
//    create alert message for when user's sign in credentials are inaccurate
    func showAlert(error : String) {
        let alert = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: { _ in alert.dismiss(animated: true, completion: nil)} )
        
    }
    
}
