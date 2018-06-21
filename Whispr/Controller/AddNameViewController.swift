//
//  AddNameViewController.swift
//  Blabber
//
//  Created by Neema Badihian on 3/15/18.
//  Copyright © 2018 Neema Badihian. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class AddNameViewController: UIViewController {
    @IBOutlet weak var displayNameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func addNameButton(_ sender: Any) {
        SVProgressHUD.show()
        
//        initialize a Firebase object of class createProfileChangeRequest in order to change the user's display name
        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
//        set the text the user entered in the text field as the display name
        changeRequest?.displayName = displayNameTextField.text
//        commit changes to save the user's new display name
        changeRequest?.commitChanges(completion: { (error) in
            if error != nil {
                SVProgressHUD.dismiss()
                self.showAlert(error: String(describing: error)) // display alert for error
                print("error: \(error!)")
            }
            else {
                self.performSegue(withIdentifier: "goToMessages", sender: self) // segue to MessagesViewController
                SVProgressHUD.dismiss()
            }
        })
        
    }
    
//    create alert message for when Firebase is not able to commit changes to user's display name
    func showAlert(error : String) {
        let alert = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: { _ in alert.dismiss(animated: true, completion: nil)} )
        
    }

}
