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
        
            Auth.auth().addStateDidChangeListener { auth, user in
                if let user = user {
                    self.performSegue(withIdentifier: "goToMessages", sender: self)
                } else {
                    // No user is signed in.
                }
            }
        
        super.viewDidLoad()
        
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
    
    @IBAction func continueButton(_ sender: Any) {
        
        self.phoneNumber = phoneNumberTextField.text!
        let components =
            phoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted)
        self.phoneNumber = components.joined()
        
        self.phoneNumber = self.phoneNumber.replacingOccurrences(of: "-", with: "")
        self.phoneNumber = self.phoneNumber.replacingOccurrences(of: "(", with: "")
        self.phoneNumber = self.phoneNumber.replacingOccurrences(of: ")", with: "")

        checkCount(phoneNumber: self.phoneNumber)
        
        let alert  = UIAlertController(title: "Phone Number", message: "Is this you number?\n\(self.phoneNumber)", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Yes", style: .default) { (UIAlertAction) in
            PhoneAuthProvider.provider().verifyPhoneNumber(self.phoneNumber, uiDelegate: nil) {
                (verificationID, error) in
                
                if error != nil {
                    SVProgressHUD.dismiss()
                    print("error: \(error!)")
                } else {
                    
                    SVProgressHUD.show()
                    
                    UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
                    let verificationID = UserDefaults.standard.string(forKey: "authVerificationID")
                    
                    SVProgressHUD.dismiss()
                    self.performSegue(withIdentifier: "goToVerification", sender: self)
                }
                
                
            }
        }
        
        let cancel = UIAlertAction(title: "No", style: .cancel, handler: nil)
        alert.addAction(action)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
        
        
    }
    
    func showAlert(error : String) {
        let alert = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: { _ in alert.dismiss(animated: true, completion: nil)} )
        
    }
    
    func checkCount(phoneNumber : String) {
            if phoneNumber.count == 11 {
                self.phoneNumber = "+" + phoneNumber
            }
            else if phoneNumber.count == 10 {
                self.phoneNumber = "+1" + phoneNumber
            }
    }
    
    
    
}
