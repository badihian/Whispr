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
    
    @IBAction func addNameButton(_ sender: Any) {
        SVProgressHUD.show()
        
        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
        changeRequest?.displayName = displayNameTextField.text
        changeRequest?.commitChanges(completion: { (error) in
            if error != nil {
                
                SVProgressHUD.dismiss()
                self.showAlert(error: String(describing: error))
                print("error: \(error!)")
            }
            else {
                
                self.performSegue(withIdentifier: "goToMessages", sender: self)
                SVProgressHUD.dismiss()
                
            }
        })
        
    }
    
    func showAlert(error : String) {
        let alert = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: { _ in alert.dismiss(animated: true, completion: nil)} )
        
    }
    

}
