//
//  UIViewControllerExtensions.swift
//  FlatQuestion
//
//  Created by MacBook on 5/26/20.
//  Copyright © 2020 Андрей Олесов. All rights reserved.
//

import UIKit

extension UIViewController {
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showErrorAlert(message: String) {
        showAlert(title: "Error", message: message);
    }
    
    func pushModalVC(name: String) {
        let vc = RegistrationViewController(nibName: name, bundle: nil)
        self.present(vc, animated:true, completion:nil)
    }
}
