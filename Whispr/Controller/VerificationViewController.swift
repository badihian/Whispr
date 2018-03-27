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
    @IBAction func enterCodeButton(_ sender: Any) {
        
        let verificationDefaults = UserDefaults.standard
        
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationDefaults.string(forKey: "authVerificationID")!, verificationCode: verificationTextField.text!)
        
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
                if user?.displayName != nil {
                    
                    self.performSegue(withIdentifier: "goToMessages", sender: self)
                }
                else {
                    
                    self.performSegue(withIdentifier: "goToAddName", sender: self)
                }
            }
        }
        
    }
    func showAlert(error : String) {
        let alert = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: { _ in alert.dismiss(animated: true, completion: nil)} )
        
    }
    
}
