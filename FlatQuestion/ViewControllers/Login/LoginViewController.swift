import UIKit
import FirebaseAuth
import Firebase
import AuthenticationServices
import SwiftyVK

class LoginViewController: UIViewController{
    @IBOutlet weak var loginBackground: UIImageView!
    @IBOutlet weak var emailTextField: PaddedTextField!
    @IBOutlet weak var passwordTextField: PaddedTextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var vkView: UIView!
    @IBOutlet weak var googleView: UIView!
    @IBOutlet weak var emailErrorMessage: UILabel!
    @IBOutlet weak var passwordErrorMessage: UILabel!
    
    @IBOutlet weak var enterLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var orLabel: UILabel!
    @IBOutlet weak var dontHaveAccountLabel: UILabel!
    @IBOutlet weak var registrationLabel: UIButton!
    @IBOutlet weak var forgetPassButton: UIButton!
    
    
    @IBAction func eyeButtonPressed(_ sender: Any) {
        let imageName = passwordTextField.isSecureTextEntry ? "eye.slash.fill" : "eye.fill"
        (sender as! UIButton).setImage(UIImage(systemName: imageName), for: .normal)
        passwordTextField.isSecureTextEntry = !passwordTextField.isSecureTextEntry
    }
    
    @IBAction func signInButtonTapped(_ sender: Any) {
        guard validateCredantials() else { return; }
        showLoadingIndicator()
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) {
            authResult, error in
            self.hideLoadingableIndicator()
            if error != nil {
                self.showErrorAlert(message: error!.localizedDescription)
            } else {
                let vc = SuccessViewController(delegate: self)
                vc.transitioningDelegate = self
                self.present(vc, animated: true, completion: nil)
                    self.fetchUser(id: authResult!.user.uid) { () in
                        DispatchQueue.global(qos: .userInitiated).async {
                            FireBaseHelper().updateFCMToken(fcmTokenGroup: FCMTokenGroup(userId: (UserSettings.appUser?.id)!, fcmToken: FireBaseHelper().fcmToken)) { (result) in
                                print("Fcm Token Updated")
                            }
                        }
                        
                    }
            }
        }
    }
    
    @IBAction func forgotPasswordTapped(_ sender: Any) {
        unfocusAllTextFields()
        let vc = ResetPasswordViewController(nibName: "ResetPasswordViewController", bundle: nil)
        self.present(vc, animated:true, completion:nil)
    }
    
    @IBAction func createNewAccountTapped(_ sender: Any) {
        unfocusAllTextFields()
        let vc = RegistrationViewController(nibName: "RegistrationViewController", bundle: nil)
        self.present(vc, animated:true, completion:nil)
    }
    
    @IBAction func authWithVk(_ sender: Any) {
        handleVkAuth()
    }
    
    @IBAction func AuthWithAppleId(_ sender: Any) {
        handleAppleIdAuth()
    }
    
    @IBAction func authWithGoogle(_ sender: Any) {
        
    }
    
    func localize() {
        enterLabel.text = "Вход".localized
        passwordLabel.text = "Пароль".localized
        orLabel.text = "Или".localized
        dontHaveAccountLabel.text = "Еще нет аккаунта?".localized
        registrationLabel.titleLabel?.text = "Регистрация".localized
        forgetPassButton.setTitle("Забыли пароль?".localized, for: .normal)
        signInButton.setTitle("Войти".localized, for: .normal)
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let colorView = UIView(frame: loginBackground.frame)
        colorView.backgroundColor = UIColor(hex: 0x191D29)
        loginBackground.image = UIImage(view: colorView)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        localize()
        
        configureVkAuthProvider()
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        addStylesTo(emailTextField)
        addStylesTo(passwordTextField, 36)
        
        //setupShadow(vkView)
        //setupShadow(googleView)
        setupShadow(signInButton, UIColor(hex: "#03CCE0"), 21)
        
        
        let tapGestureBackground = UITapGestureRecognizer(target: self, action: #selector(self.backgroundTapped(_:)))
        self.view.addGestureRecognizer(tapGestureBackground)
        
        let toolbar = UIToolbar()
        toolbar.barTintColor = UIColor(hexString: "0x03CCE0")!
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonClicked))
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        doneButton.tintColor = .white
        toolbar.setItems([spacer,doneButton], animated: true)
        emailTextField.inputAccessoryView = toolbar
        passwordTextField.inputAccessoryView = toolbar
        
    }
    
    @objc func doneButtonClicked() {
        self.view.endEditing(true)
    }
    @objc func backgroundTapped(_ sender: UITapGestureRecognizer)
    {
        unfocusAllTextFields()
    }
    
    private func fetchUser(id: String, completion: @escaping () -> Void) {
        Firestore.firestore().collection("users").whereField("id", isEqualTo: id)
          .getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                let data = querySnapshot!.documents.first!.data()
                let user = DecodeHelper.decodeFromDictionary(dictionary: data, type: AppUser.self)
                
                UserSettings.appUser = user
                
                completion()
            }
        }
    }
    
    private func unfocusAllTextFields() {
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
            setupShadow(emailTextField, .red, 10)
            emailErrorMessage.isHidden = false
            emailErrorMessage.text = "Email не должен быть пустым".localized
        } else if !isEmailHasValidFormat(emailTextField.text) {
            validationStatus = false
            emailTextField.layer.borderColor = UIColor.red.cgColor
            setupShadow(emailTextField, .red, 10)
            emailErrorMessage.isHidden = false
            emailErrorMessage.text = "Неверный формат email".localized
        }
        
        if (passwordTextField.text ?? "").isEmpty {
            validationStatus = false
            passwordTextField.layer.borderColor = UIColor.red.cgColor
            passwordErrorMessage.isHidden = false
            passwordErrorMessage.text = "Пароль не должен быть пустым".localized
            setupShadow(passwordTextField, .red, 10)
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
                         shadowOffset: CGSize(width: 0, height: 8),
                         shadowOpacity: 0.3,
                         shadowRadius: 10.0)
    }
    
    private func removeShadow(_ view: UIView){
        view.addShadow(shadowColor: UIColor.clear.cgColor,
                         shadowOffset: CGSize(width: 0, height: 0),
                         shadowOpacity: 0,
                         shadowRadius: 0)
    }
    private func addStylesTo(_ paddedTextField: PaddedTextField, _ rightTextMargin: CGFloat = 10) {
        paddedTextField.frame.size.height = 40
        paddedTextField.layer.cornerRadius = 10
        paddedTextField.layer.borderWidth = 1.5
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
//        VK.sessions.default.logOut()
//        VK.sessions.default.logIn(
//            onSuccess: { _ in
//                VK.API.Account.getProfileInfo([.firstName: "firstName", .lastName: "lastName"])
//                    .configure(with: Config.init(httpMethod: .POST))
//                    .onSuccess {
//                        let vkUser = try JSONDecoder().decode(VkUser.self, from: $0)
//                        self.handleDataFromAuthProviders(appUser:
//                            AppUser(firstName: vkUser.firstName, lastName: vkUser.lastName));
//                    }
//                    .send()
//            },
//            onError: { error in
//                self.showAlert(title: "VK login error", message: error.localizedDescription)
//            }
//        )
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
        (textField as! PaddedTextField).layer.borderWidth = 1.5
        (textField as! PaddedTextField).layer.borderColor = UIColor(hex: "#03CCE0").cgColor
        setupShadow(textField, UIColor(hex: "#03CCE0"), 10)
        hideErrorMessage(textField)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        (textField as! PaddedTextField).layer.borderColor = UIColor.clear.cgColor
        hideErrorMessage(textField)
        removeShadow(textField)
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

extension LoginViewController: SuccessViewControllerProtocol {
    func successScreenWillClose() {
        self.navigateToMainVC()
    }
}

extension LoginViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if presented is AcceptModalViewController {
            return TransparentBackgroundModalPresenter(isPush: true, originFrame: UIScreen.main.bounds)
        } else {
        return SuccessModalPresenter(isPush: true, originFrame: UIScreen.main.bounds)
        }
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if dismissed is AcceptModalViewController {
        return TransparentBackgroundModalPresenter(isPush: false)
        } else {
            return SuccessModalPresenter(isPush: false)
        }
    }
}
