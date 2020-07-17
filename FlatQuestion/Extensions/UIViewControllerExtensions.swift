//
//  UIViewControllerExtensions.swift
//  FlatQuestion
//
//  Created by MacBook on 5/26/20.
//  Copyright © 2020 Андрей Олесов. All rights reserved.
//

import UIKit

extension UIViewController {
    func showAlert(title: String, message: String, handler: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: handler))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showErrorAlert(message: String) {
        showAlert(title: "Error", message: message);
    }
    
    func pushModalVC(name: String) {
        let vc = UIViewController(nibName: name, bundle: nil)
        self.present(vc, animated:true, completion:nil)
    }
    
    func pushFullContextVC(name: String) {
        let vc = UIViewController(nibName: name, bundle: nil)
        self.present(vc, animated:true, completion:nil)
    }
    
    func navigateToMainVC() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "main")
        newViewController.modalPresentationStyle = .fullScreen
        if UserSettings.appUser.sex != nil {
            self.present(newViewController, animated: true, completion: nil)
        } else {
            self.present(newViewController, animated: false) {
                let vc = EditProfileViewController(nibName: "EditProfileViewController", bundle: nil)
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true, completion: nil)
                newViewController.present(vc, animated: true, completion: nil)
            }
        }
        
        
    }
    
    func navigateToRegistrationVC() {
                let vc = EditProfileViewController(nibName: "EditProfileViewController", bundle: nil)
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true, completion: nil)
    }
}
