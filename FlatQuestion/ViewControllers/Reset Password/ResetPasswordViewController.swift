import UIKit
import Firebase

class ResetPasswordViewController: UIViewController {
    @IBOutlet weak var emailTextField: PaddedTextField!
    @IBOutlet weak var emailErrorMessage: UILabel!
    @IBOutlet weak var resetPasswordButton: UIButton!
    @IBOutlet weak var resetPasswordLabel: UILabel!
    @IBOutlet weak var loginBackground: UIImageView!
    
    @IBAction func resetPasswordButtonTapped(_ sender: Any) {
        guard validateCredantials() else { return; }
        showLoadingIndicator()
        Auth.auth().sendPasswordReset(withEmail: emailTextField.text!) { error in
            self.hideLoadingableIndicator()
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
        
        //addStylesTo(emailTextField)
        setupShadow(resetPasswordButton, UIColor(hex: "#03CCE0"), 21)
        
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
    }
    
    @objc func doneButtonClicked() {
        self.view.endEditing(true)
    }
    func localize() {
        resetPasswordLabel.text = "Восстановление пароля".localized
    }
    @objc func backgroundTapped(_ sender: UITapGestureRecognizer)
    {
        emailTextField.endEditing(true)
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let colorView = UIView(frame: loginBackground.frame)
        colorView.backgroundColor = UIColor(hex: 0x191D29)
        loginBackground.image = UIImage(view: colorView)
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
                         shadowOffset: CGSize(width: 0, height: 8),
                         shadowOpacity: 0.3,
                         shadowRadius: 10)
    }
    
    private func removeShadow(_ view: UIView){
        view.addShadow(shadowColor: UIColor.clear.cgColor,
                         shadowOffset: CGSize(width: 0, height: 0),
                         shadowOpacity: 0,
                         shadowRadius: 0)
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
            setupShadow(emailTextField, .red, 10)
        } else if !isEmailHasValidFormat(emailTextField.text) {
            validationStatus = false
            emailTextField.layer.borderColor = UIColor.red.cgColor
            emailErrorMessage.isHidden = false
            emailErrorMessage.text = "Неверный формат email".localized
            setupShadow(emailTextField, .red, 10)
        }
        
        return validationStatus;
    }
}

extension ResetPasswordViewController : UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        (textField as! PaddedTextField).layer.borderWidth = 1.5
        (textField as! PaddedTextField).layer.borderColor = UIColor(hex: "#03CCE0").cgColor
        setupShadow(textField, UIColor(hex: "#03CCE0"), 10)
        hideErrorMessage(textField)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        (textField as! PaddedTextField).layer.borderColor = UIColor.clear.cgColor
        removeShadow(textField)
        hideErrorMessage(textField)
    }
    private func hideErrorMessage(_ textField: UITextField) {
        if textField.accessibilityIdentifier == "email" {
            emailErrorMessage.isHidden = true
        }
    }
}
