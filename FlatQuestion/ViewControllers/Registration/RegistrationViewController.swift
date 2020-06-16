//
//  RegistrationViewController.swift
//  FlatQuestion
//
//  Created by MacBook on 5/18/20.
//  Copyright © 2020 Андрей Олесов. All rights reserved.
//

import UIKit
import FirebaseAuth

class RegistrationViewController: UIViewController {

    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    @IBAction func RegistrationTapped(_ sender: Any) {
        if (firstNameTextField.text ?? "").isEmpty ||
           (lastNameTextField.text ?? "").isEmpty ||
           (emailTextField.text ?? "").isEmpty ||
           (passwordTextField.text ?? "").isEmpty ||
           (confirmPasswordTextField.text ?? "").isEmpty {
            showErrorAlert(message: "Please, input valid email and password")
            return;
        }
        
        Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) {
            [weak self] authResult, error in
            guard let strongSelf = self else { return }
            if error != nil {
                strongSelf.showErrorAlert(message: error!.localizedDescription)
            } else {
                // push to firebase database first last name, id and avatar url
                //navigate to tab vc
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
