//
//  ViewController.swift
//  Uber
//
//  Created by Gerry on 20-11-17.
//  Copyright © 2017 Gerry Procee. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController {
    
    @IBOutlet weak var driverLabel: UILabel!
    @IBOutlet weak var riderLabel: UILabel!
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var topButton: UIButton!
    @IBOutlet weak var bottomButton: UIButton!
    @IBOutlet weak var riderDriverSwitch: UISwitch!
    
    var signUpMode = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func topTapped(_ sender: Any) {
        
        if emailField.text == "" || passwordField.text == "" {
            displayAlert(title: "Missing information", message: "You must provide both a email and password!")
        } else {
            if let email = emailField.text {
                if let password = passwordField.text {
                    if signUpMode {
                        // try to sign up
                        Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
                            if error != nil {
                                self.displayAlert(title: "Error", message: error!.localizedDescription)
                            } else {
                                if self.riderDriverSwitch.isOn {
                                    // DRIVER
                                    let req = Auth.auth().currentUser?.createProfileChangeRequest()
                                    req?.displayName = "Driver"
                                    req?.commitChanges(completion: nil)
                                    print("Marked as as driver")
                                    self.performSegue(withIdentifier: "driverSegue", sender: nil)
                                } else {
                                    // RIDER
                                    let req = Auth.auth().currentUser?.createProfileChangeRequest()
                                    req?.displayName = "Rider"
                                    req?.commitChanges(completion: nil)
                                    print("Marked as as rider")
                                    self.performSegue(withIdentifier: "riderSegue", sender: nil)
                                }
                            }
                        })
                    } else {
                        // try to log in
                        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
                            if error != nil {
                                self.displayAlert(title: "Error", message: error!.localizedDescription)
                            } else {
                                if user?.displayName == "Driver" {
                                    // DRIVER
                                    self.performSegue(withIdentifier: "driverSegue", sender: nil)
                                } else {
                                    self.performSegue(withIdentifier: "riderSegue", sender: nil)
                                }
                            }
                        })
                    }
                }
            }
        }
    }
    
    func displayAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func bottomTapped(_ sender: Any) {
        if signUpMode {
            signUpMode=false
            topButton.setTitle("Log In", for: .normal)
            bottomButton.setTitle("Switch To Sign Up", for: .normal)
            riderLabel.isHidden = true
            driverLabel.isHidden = true
            riderDriverSwitch.isHidden = true
        } else {
            signUpMode=true
            topButton.setTitle("Sign Up", for: .normal)
            bottomButton.setTitle("Switch To Log In", for: .normal)
            riderLabel.isHidden = false
            driverLabel.isHidden = false
            riderDriverSwitch.isHidden = false
        }
    }
}

