//
//  ResetPasswordViewController.swift
//  FlatQuestion
//
//  Created by MacBook on 5/28/20.
//  Copyright © 2020 Андрей Олесов. All rights reserved.
//

import UIKit
import Firebase

class ResetPasswordViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBAction func resetPasswordButtonTapped(_ sender: Any) {
        Auth.auth().sendPasswordReset(withEmail: emailTextField.text!) { error in
            if error != nil {
                self.showErrorAlert(message: error!.localizedDescription)
            } else {
                self.showAlert(title: "Alert", message: "Email with reset password link was sent")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
