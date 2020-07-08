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
    @IBOutlet weak var emailTextField: PaddedTextField!
    @IBOutlet weak var emailErrorMessage: UILabel!
    @IBOutlet weak var resetPasswordButton: UIButton!
    @IBOutlet weak var resetPasswordLabel: UILabel!
    
    @IBAction func resetPasswordButtonTapped(_ sender: Any) {
        guard validateCredantials() else { return; }
        ActivityIndicatorHelper.show(in: self.view)
        Auth.auth().sendPasswordReset(withEmail: emailTextField.text!) { error in
            ActivityIndicatorHelper.dismiss()
            if error != nil {
                self.showErrorAlert(message: error!.localizedDescription)
            } else {
                self.showAlert(title: "", message: "Ссылка для сброса пароля отправлена на указанный email".localized) { (UIAlertAction)
                    in
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        emailTextField.delegate = self
        
        addStylesTo(emailTextField)
        setupShadow(resetPasswordButton, UIColor(hex: "#615CBF"))
        
        resetPasswordButton.applyGradient(colours: [UIColor(hex: "#615CBF"), UIColor(hex: "#1C2F4B")])
        
        let tapGestureBackground = UITapGestureRecognizer(target: self, action: #selector(self.backgroundTapped(_:)))
        self.view.addGestureRecognizer(tapGestureBackground)
    }
    
    func localize() {
        resetPasswordLabel.text = "Восстановление пароля".localized
    }
    @objc func backgroundTapped(_ sender: UITapGestureRecognizer)
    {
        emailTextField.endEditing(true)
    }
    
    private func addStylesTo(_ paddedTextField: PaddedTextField, _ rightTextMargin: CGFloat = 10) {
        setupShadow(paddedTextField)
        paddedTextField.frame.size.height = 40
        paddedTextField.layer.cornerRadius = 10
        paddedTextField.layer.borderWidth = 1
        paddedTextField.layer.borderColor = UIColor.clear.cgColor
        paddedTextField.textInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: rightTextMargin)
    }
    
    private func setupShadow(_ view: UIView, _ color: UIColor = UIColor.gray, _ cornerRadius: CGFloat = 25) {
        view.layer.cornerRadius = cornerRadius
        view.addShadow(shadowColor: color.cgColor,
                         shadowOffset: CGSize(width: 0, height: 20),
                         shadowOpacity: 0.3,
                         shadowRadius: 20.0)
    }
    
    private func isEmailHasValidFormat(_ email: String?) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    private func validateCredantials() -> Bool {
        var validationStatus = true;
        emailErrorMessage.isHidden = true
        emailTextField.layer.borderColor = UIColor.clear.cgColor
        if (emailTextField.text ?? "").isEmpty {
            validationStatus = false
            emailTextField.layer.borderColor = UIColor.red.cgColor
            emailErrorMessage.isHidden = false
            emailErrorMessage.text = "Email не должен быть пустым".localized
        } else if !isEmailHasValidFormat(emailTextField.text) {
            validationStatus = false
            emailTextField.layer.borderColor = UIColor.red.cgColor
            emailErrorMessage.isHidden = false
            emailErrorMessage.text = "Неверный формат email".localized
        }
        
        return validationStatus;
    }
}

extension ResetPasswordViewController : UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        (textField as! PaddedTextField).layer.borderColor = UIColor(hex: "#5B58B4").cgColor
        emailErrorMessage.isHidden = true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        (textField as! PaddedTextField).layer.borderColor = UIColor.clear.cgColor
        emailErrorMessage.isHidden = true
    }
}
