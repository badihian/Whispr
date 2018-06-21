//
//  SettingsViewController.swift
//  Blabber
//
//  Created by Neema Badihian on 3/12/18.
//  Copyright © 2018 Neema Badihian. All rights reserved.
//

import UIKit
import Firebase

class SettingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func logoutPressed(_ sender: Any) {
        
        do {
            try Auth.auth().signOut()
            
            performSegue(withIdentifier: "goToLogin", sender: self)
            
        }
        catch {
            print("error, there was a problem signing out.")
        }
    }
    
}
