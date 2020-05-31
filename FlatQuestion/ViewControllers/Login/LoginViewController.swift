//
//  LoginViewController.swift
//  FlatQuestion
//
//  Created by MacBook on 5/18/20.
//  Copyright © 2020 Андрей Олесов. All rights reserved.
//

import UIKit
import FirebaseAuth
import AuthenticationServices
import SwiftyVK

class LoginViewController: UIViewController {
    @IBOutlet weak var emailTextField: PaddedTextField!
    @IBOutlet weak var passwordTextField: PaddedTextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var vkView: UIView!
    @IBOutlet weak var googleView: UIView!
    @IBOutlet weak var emailErrorMessage: UILabel!
    @IBOutlet weak var passwordErrorMessage: UILabel!
    
    @IBAction func eyeButtonPressed(_ sender: Any) {
        passwordTextField.isSecureTextEntry = !passwordTextField.isSecureTextEntry
        let imageName = passwordTextField.isSecureTextEntry ? "eye.slash.fill" : "eye.fill"
        (sender as! UIButton).setImage(UIImage(systemName: imageName), for: .normal)
    }
    
    @IBAction func signInButtonTapped(_ sender: Any) {
        guard validateCredantials() else { return; }
        
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) {
            [weak self] authResult, error in
            guard let strongSelf = self else { return }
            if error != nil {
                strongSelf.showErrorAlert(message: error!.localizedDescription)
            } else {
                //fetch first, last name and avatar url, fill AppUser and navigate to tab view controller
            }
        }
    }
    
    @IBAction func forgotPasswordTapped(_ sender: Any) {
        pushModalVC(name: R.nib.resetPasswordViewController.name)
    }
    
    @IBAction func createNewAccountTapped(_ sender: Any) {
        pushModalVC(name: R.nib.registrationViewController.name)
    }
    
    @IBAction func authWithVk(_ sender: Any) {
        handleVkAuth()
    }
    
    @IBAction func AuthWithAppleId(_ sender: Any) {
        handleAppleIdAuth()
    }
    
    @IBAction func authWithGoogle(_ sender: Any) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureVkAuthProvider()
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        addStylesTo(emailTextField)
        addStylesTo(passwordTextField, 36)
        
        setupShadow(vkView)
        setupShadow(googleView)
        setupShadow(signInButton, UIColor(hex: "#615CBF"))
        
        signInButton.applyGradient(colours: [UIColor(hex: "#615CBF"), UIColor(hex: "#1C2F4B")])
        
        let tapGestureBackground = UITapGestureRecognizer(target: self, action: #selector(self.backgroundTapped(_:)))
        self.view.addGestureRecognizer(tapGestureBackground)
    }
    
    @objc func backgroundTapped(_ sender: UITapGestureRecognizer)
    {
        emailTextField.endEditing(true)
        passwordTextField.endEditing(true)
    }
    
    private func validateCredantials() -> Bool {
        var validationStatus = true;
        emailErrorMessage.isHidden = true
        passwordErrorMessage.isHidden = true
        emailTextField.layer.borderColor = UIColor.clear.cgColor
        passwordErrorMessage.layer.borderColor = UIColor.clear.cgColor
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
        
        return validationStatus;
    }
    
    private func isEmailHasValidFormat(_ email: String?) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
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
    
    private func handleDataFromAuthProviders(appUser: AppUser) {
        
    }
}

//extension for auth with VK
extension LoginViewController : SwiftyVKDelegate {
    func vkNeedsScopes(for sessionId: String) -> Scopes {
        return [.email];
    }
    
    func vkNeedToPresent(viewController: VKViewController) {
        if let rootController = UIApplication.shared.keyWindow?.rootViewController {
            rootController.present(viewController, animated: true)
        }
    }
    
    private func configureVkAuthProvider() {
        VK.setUp(appId: "7474739", delegate: self)
    }
    
    private func handleVkAuth() {
        VK.sessions.default.logOut()
        VK.sessions.default.logIn(
            onSuccess: { _ in
                VK.API.Account.getProfileInfo([.firstName: "firstName", .lastName: "lastName"])
                    .configure(with: Config.init(httpMethod: .POST))
                    .onSuccess {
                        let vkUser = try JSONDecoder().decode(VkUser.self, from: $0)
                        self.handleDataFromAuthProviders(appUser:
                            AppUser(firstName: vkUser.firstName, lastName: vkUser.lastName));
                    }
                    .send()
            },
            onError: { error in
                self.showAlert(title: "VK login error", message: error.localizedDescription)
            }
        )
    }
}

//extension for auth with AppleId
extension LoginViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let userIdentifier = appleIDCredential.user
            let fullName = appleIDCredential.fullName
            let email = appleIDCredential.email
            
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
    }
    
    private func handleAppleIdAuth() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        let appleIdAuthorizationController = ASAuthorizationController(authorizationRequests: [request])
        appleIdAuthorizationController.delegate = self
        appleIdAuthorizationController.performRequests()
    }
}

extension LoginViewController : UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        (textField as! PaddedTextField).layer.borderColor = UIColor(hex: "#5B58B4").cgColor
        hideErrorMessage(textField)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        (textField as! PaddedTextField).layer.borderColor = UIColor.clear.cgColor
        hideErrorMessage(textField)
    }
    
    private func hideErrorMessage(_ textField: UITextField) {
        if textField.accessibilityIdentifier == "email" {
            emailErrorMessage.isHidden = true
        }
        if textField.accessibilityIdentifier == "password" {
            passwordErrorMessage.isHidden = true
        }
    }
}