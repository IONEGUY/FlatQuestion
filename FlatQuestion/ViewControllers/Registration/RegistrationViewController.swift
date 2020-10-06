import UIKit
import FirebaseAuth
import Firebase

class RegistrationViewController: UIViewController {
    @IBOutlet weak var loginBackground: UIImageView!
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
    
    @IBOutlet weak var registrationLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var secondNameLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var confirmPassword: UILabel!
    @IBOutlet weak var registrationButton: UIButton!
    
    @IBAction func passwordEyeButtonTapped(_ sender: UIButton) {
        changeEyeButtonAppearance(sender, passwordTextField)
    }
    
    @IBAction func confirmPasswordEyeButtonTapped(_ sender: UIButton) {
        changeEyeButtonAppearance(sender, confirmPasswordTextField)
    }
    
    @IBAction func RegistrationTapped(_ sender: Any) {
        guard validateCredantials() else { return; }
        showLoadingIndicator()
        Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) {
            authResult, error in
            self.hideLoadingableIndicator()
            if error != nil {
                self.showErrorAlert(message: error!.localizedDescription)
            } else {
                let user = AppUser(id: authResult?.user.uid,
                                   fullName: nil,
                                   email: self.emailTextField.text,
                                   avatarUrl: Constants.defaultAvatarUrl)
                self.createUser(user: user) { error in
                    if error != nil {
                        self.showErrorAlert(message: error!.localizedDescription)
                    } else {
                        DispatchQueue.global(qos: .userInitiated).async {
                            FireBaseHelper().setFCMToken(fcmTokenGroup: FCMTokenGroup(userId: user.id!, fcmToken: FireBaseHelper().fcmToken)) { (result) in
                                print("FCM Token getted")
                            }
                        }
                        let vc = SuccessViewController(delegate: self)
                        vc.transitioningDelegate = self
                        self.present(vc, animated: true, completion: nil)
                        
                        UserSettings.appUser = user
                        
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        localize()
        emailTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self
        
        //addStylesTo(emailTextField)
        //addStylesTo(passwordTextField, 36)
        //addStylesTo(confirmPasswordTextField, 36)
        
        setupShadow(registerButton, UIColor(hex: "#03CCE0"), 21)
        
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
        confirmPasswordTextField.inputAccessoryView = toolbar
    }
    
    @objc func doneButtonClicked() {
        self.view.endEditing(true)
    }
    
    func localize() {
        registrationLabel.text = "Регистрация".localized
        passwordLabel.text = "Пароль".localized
        confirmPassword.text = "Подтверждение пароля".localized
        registrationButton.setTitle("Регистрация".localized, for: .normal)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let colorView = UIView(frame: loginBackground.frame)
        colorView.backgroundColor = UIColor(hex: 0x191D29)
        loginBackground.image = UIImage(view: colorView)
    }
    
     private func createUser(user: AppUser, completion: @escaping ((Error?) -> Void)) {
        Firestore.firestore().collection("users").addDocument(data:
            ["id": user.id!,
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
        setupShadow(paddedTextField)
        paddedTextField.frame.size.height = 40
        paddedTextField.layer.cornerRadius = 10
        paddedTextField.layer.borderWidth = 1
        paddedTextField.layer.borderColor = UIColor.clear.cgColor
        paddedTextField.textInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: rightTextMargin)
    }
    
    @objc func backgroundTapped(_ sender: UITapGestureRecognizer)
    {
        emailTextField.endEditing(true)
        passwordTextField.endEditing(true)
        confirmPasswordTextField.endEditing(true)
    }
    
    private func validateCredantials() -> Bool {
        var validationStatus = true;
        emailErrorMessage.isHidden = true
        passwordErrorMessage.isHidden = true
        confirmPasswordErrorMessage.isHidden = true
        emailTextField.layer.borderColor = UIColor.clear.cgColor
        passwordErrorMessage.layer.borderColor = UIColor.clear.cgColor
        confirmPasswordTextField.layer.borderColor = UIColor.clear.cgColor
        if (emailTextField.text ?? "").isEmpty {
            validationStatus = false
            emailTextField.layer.borderColor = UIColor.red.cgColor
            emailErrorMessage.isHidden = false
            emailErrorMessage.text = "Email не должен быть пустым".localized
            setupShadow(emailTextField, .red, 10)
        } else if !isEmailHasValidFormat(emailTextField.text) {
            validationStatus = false
            emailTextField.layer.borderColor = UIColor.red.cgColor
            emailErrorMessage.isHidden = false
            emailErrorMessage.text = "Неверный формат email".localized
            setupShadow(emailTextField, .red, 10)
        }
        if (passwordTextField.text ?? "").isEmpty {
            validationStatus = false
            passwordTextField.layer.borderColor = UIColor.red.cgColor
            passwordErrorMessage.isHidden = false
            passwordErrorMessage.text = "Пароль не должен быть пустым".localized
            setupShadow(passwordTextField, .red, 10)
        }
        if (confirmPasswordTextField.text ?? "").isEmpty {
            validationStatus = false
            confirmPasswordTextField.layer.borderColor = UIColor.red.cgColor
            confirmPasswordErrorMessage.isHidden = false
            confirmPasswordErrorMessage.text = "Пароль не должен быть пустым".localized
            setupShadow(confirmPasswordTextField, .red, 10)
        } else if passwordTextField.text != confirmPasswordTextField.text {
            validationStatus = false
            confirmPasswordTextField.layer.borderColor = UIColor.red.cgColor
            confirmPasswordErrorMessage.isHidden = false
            confirmPasswordErrorMessage.text = "Пароли не совпадают".localized
            setupShadow(confirmPasswordTextField, .red, 10)
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

extension RegistrationViewController: SuccessViewControllerProtocol {
    func successScreenWillClose() {
        self.navigateToMainVC()
    }
}

extension RegistrationViewController: UIViewControllerTransitioningDelegate {
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
