//
//  RegistrationViewController.swift
//  FlatQuestion
//
//  Created by MacBook on 5/18/20.
//  Copyright © 2020 Андрей Олесов. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

class RegistrationViewController: UIViewController {
    @IBOutlet weak var firstNameTextField: PaddedTextField!
    @IBOutlet weak var lastNameTextField: PaddedTextField!
    @IBOutlet weak var emailTextField: PaddedTextField!
    @IBOutlet weak var passwordTextField: PaddedTextField!
    @IBOutlet weak var confirmPasswordTextField: PaddedTextField!
    @IBOutlet weak var firstNameErrorMessage: UILabel!
    @IBOutlet weak var lastNameErrorMessage: UILabel!
    @IBOutlet weak var emailErrorMessage: UILabel!
    @IBOutlet weak var passwordErrorMessage: UILabel!
    @IBOutlet weak var confirmPasswordErrorMessage: UILabel!
    @IBOutlet weak var registerButton: UIButton!
    
    @IBAction func passwordEyeButtonTapped(_ sender: UIButton) {
        changeEyeButtonAppearance(sender, passwordTextField)
    }
    
    @IBAction func confirmPasswordEyeButtonTapped(_ sender: UIButton) {
        changeEyeButtonAppearance(sender, confirmPasswordTextField)
    }
    
    @IBAction func RegistrationTapped(_ sender: Any) {
        guard validateCredantials() else { return; }
        ActivityIndicatorHelper.show(in: self.view)
        Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) {
            authResult, error in
            if error != nil {
                ActivityIndicatorHelper.dismiss()
                self.showErrorAlert(message: error!.localizedDescription)
            } else {
                let user = AppUser(id: authResult?.user.uid,
                                   firstName: self.firstNameTextField.text,
                                   lastName: self.lastNameTextField.text,
                                   email: self.emailTextField.text,
                                   avatarUrl: Constants.defaultAvatarUrl)
                self.createUser(user: user) { error in
                    ActivityIndicatorHelper.dismiss()
                    if error != nil {
                        self.showErrorAlert(message: error!.localizedDescription)
                    } else {
                        self.showAlert(title: "", message: "Регистрация прошла успешно") { (UIAlertAction) in
                            UserSettings.appUser = user
                            
                            self.navigateToMainVC()
                        }
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self
        
        addStylesTo(firstNameTextField)
        addStylesTo(lastNameTextField)
        addStylesTo(emailTextField)
        addStylesTo(passwordTextField, 36)
        addStylesTo(confirmPasswordTextField, 36)
        
        setupShadow(registerButton, UIColor(hex: "#615CBF"))
        
        registerButton.applyGradient(colours: [UIColor(hex: "#615CBF"), UIColor(hex: "#1C2F4B")])
        
        let tapGestureBackground = UITapGestureRecognizer(target: self, action: #selector(self.backgroundTapped(_:)))
        self.view.addGestureRecognizer(tapGestureBackground)
    }
    
     private func createUser(user: AppUser, completion: @escaping ((Error?) -> Void)) {
        Firestore.firestore().collection("users").addDocument(data:
            ["id": user.id!,
             "firstName": user.firstName!,
             "lastName": user.lastName!,
             "email": user.email!,
             "avatarUrl": Constants.defaultAvatarUrl],
        completion: completion)
    }
    
    private func changeEyeButtonAppearance(_ eyeButton: UIButton, _ textField: PaddedTextField) {
        let imageName = textField.isSecureTextEntry ? "eye.slash.fill" : "eye.fill"
        eyeButton.setImage(UIImage(systemName: imageName), for: .normal)
        textField.isSecureTextEntry = !textField.isSecureTextEntry
    }
    
    private func setupShadow(_ view: UIView, _ color: UIColor = UIColor.gray, _ cornerRadius: CGFloat = 25) {
        view.layer.cornerRadius = cornerRadius
        view.addShadow(shadowColor: color.cgColor,
                         shadowOffset: CGSize(width: 0, height: 20),
                         shadowOpacity: 0.3,
                         shadowRadius: 20.0)
    }
    
    private func addStylesTo(_ paddedTextField: PaddedTextField, _ rightTextMargin: CGFloat = 10) {
        setupShadow(paddedTextField)
        paddedTextField.frame.size.height = 40
        paddedTextField.layer.cornerRadius = 10
        paddedTextField.layer.borderWidth = 1
        paddedTextField.layer.borderColor = UIColor.clear.cgColor
        paddedTextField.textInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: rightTextMargin)
    }
    
    @objc func backgroundTapped(_ sender: UITapGestureRecognizer)
    {
        firstNameTextField.endEditing(true)
        lastNameTextField.endEditing(true)
        emailTextField.endEditing(true)
        passwordTextField.endEditing(true)
        confirmPasswordTextField.endEditing(true)
    }
    
    private func validateCredantials() -> Bool {
        var validationStatus = true;
        firstNameErrorMessage.isHidden = true
        lastNameErrorMessage.isHidden = true
        emailErrorMessage.isHidden = true
        passwordErrorMessage.isHidden = true
        confirmPasswordErrorMessage.isHidden = true
        firstNameTextField.layer.borderColor = UIColor.clear.cgColor
        lastNameTextField.layer.borderColor = UIColor.clear.cgColor
        emailTextField.layer.borderColor = UIColor.clear.cgColor
        passwordErrorMessage.layer.borderColor = UIColor.clear.cgColor
        confirmPasswordTextField.layer.borderColor = UIColor.clear.cgColor
        if (firstNameTextField.text ?? "").isEmpty {
            validationStatus = false
            firstNameTextField.layer.borderColor = UIColor.red.cgColor
            firstNameErrorMessage.isHidden = false
            firstNameErrorMessage.text = "Имя не должен быть пустым"
        }
        if (lastNameTextField.text ?? "").isEmpty {
            validationStatus = false
            lastNameTextField.layer.borderColor = UIColor.red.cgColor
            lastNameErrorMessage.isHidden = false
            lastNameErrorMessage.text = "Фамилия не должна быть пустой"
        }
        if (emailTextField.text ?? "").isEmpty {
            validationStatus = false
            emailTextField.layer.borderColor = UIColor.red.cgColor
            emailErrorMessage.isHidden = false
            emailErrorMessage.text = "Email не должен быть пустым"
        } else if !isEmailHasValidFormat(emailTextField.text) {
            validationStatus = false
            emailTextField.layer.borderColor = UIColor.red.cgColor
            emailErrorMessage.isHidden = false
            emailErrorMessage.text = "Неверный формат email"
        }
        if (passwordTextField.text ?? "").isEmpty {
            validationStatus = false
            passwordTextField.layer.borderColor = UIColor.red.cgColor
            passwordErrorMessage.isHidden = false
            passwordErrorMessage.text = "Пароль не должен быть пустым"
        }
        if (confirmPasswordTextField.text ?? "").isEmpty {
            validationStatus = false
            confirmPasswordTextField.layer.borderColor = UIColor.red.cgColor
            confirmPasswordErrorMessage.isHidden = false
            confirmPasswordErrorMessage.text = "Пароль не должен быть пустым"
        } else if passwordTextField.text != confirmPasswordTextField.text {
            validationStatus = false
            confirmPasswordTextField.layer.borderColor = UIColor.red.cgColor
            confirmPasswordErrorMessage.isHidden = false
            confirmPasswordErrorMessage.text = "Пароли не совпадают"
        }
        
        return validationStatus;
    }
    
    private func isEmailHasValidFormat(_ email: String?) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}

extension RegistrationViewController : UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        (textField as! PaddedTextField).layer.borderColor = UIColor(hex: "#5B58B4").cgColor
        hideErrorMessage(textField)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        (textField as! PaddedTextField).layer.borderColor = UIColor.clear.cgColor
        hideErrorMessage(textField)
    }
    
    private func hideErrorMessage(_ textField: UITextField) {
        if textField.accessibilityIdentifier == "firstName" {
            firstNameErrorMessage.isHidden = true
        }
        if textField.accessibilityIdentifier == "lastName" {
            lastNameErrorMessage.isHidden = true
        }
        if textField.accessibilityIdentifier == "email" {
            emailErrorMessage.isHidden = true
        }
        if textField.accessibilityIdentifier == "password" {
            passwordErrorMessage.isHidden = true
        }
        if textField.accessibilityIdentifier == "confirmPassword" {
            confirmPasswordErrorMessage.isHidden = true
        }
    }
}
