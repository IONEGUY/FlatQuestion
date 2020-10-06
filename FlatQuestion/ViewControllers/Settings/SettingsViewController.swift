import UIKit
import MessageUI
class SettingsViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    enum SettingsType {
        case language, security, support, logout
    }
    private let settingTypes: [SettingsType] = [.language, .security, .support, .logout]
    
    @IBOutlet weak var navigationBarView: UIImageView!
    enum LanguageType {
        case russian, english, german
        func getText() -> String {
            switch self {
            case .russian:
                return "Русский"
            case .german:
                return "German"
            case .english:
                return "English"
            }
        }
    }
    private let languageTypes: [LanguageType] = [.russian, .english, .german]
    private var currentLanguageType: LanguageType = .russian
    @IBOutlet weak var tableView: UITableView!
    private var pickerView = UIPickerView()
    private var picker = UIView()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupData()
        setupView()
        //setupPickerView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.navigationBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let colorView = UIView(frame: navigationBarView.frame)
        colorView.backgroundColor = UIColor(hex: 0x191D29)
        navigationBarView.image = UIImage(view: colorView)
        navigationBarView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        navigationBarView.clipsToBounds = true
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }

    func setupView() {
        titleLabel.text = "Настройки".localized
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 32, left: 0, bottom: 0, right: 0)
        self.view.layoutSubviews()
        
    }
    
    func setupPickerView() {
        picker = UIView(frame: CGRect(x: 0, y: view.frame.height - 260, width: view.frame.width, height: 260))

         // Toolbar

        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(toolBarDoneButtonPressed))
        doneButton.tintColor = .white
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
         let barAccessory = UIToolbar(frame: CGRect(x: 0, y: 0, width: picker.frame.width, height: 44))
        barAccessory.barTintColor = UIColor(hexString: "0x03CCE0")!
         barAccessory.barStyle = .default
         barAccessory.isTranslucent = false
         barAccessory.items = [spacer, doneButton]
         picker.addSubview(barAccessory)

         // Month UIPIckerView
         pickerView = UIPickerView(frame: CGRect(x: 0, y: barAccessory.frame.height, width: view.frame.width, height: picker.frame.height-barAccessory.frame.height))
        pickerView.backgroundColor = .gray
         pickerView.delegate = self
         pickerView.dataSource = self
         pickerView.backgroundColor = UIColor.white
         picker.addSubview(pickerView)
        self.view.addSubview(picker)
    }
    
    func setupData() {
        tableView.register(UINib(nibName: SettingsReportTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: SettingsReportTableViewCell.identifier)
        tableView.register(UINib(nibName: SettingsLanguageTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: SettingsLanguageTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
        
        pickerView.dataSource = self
        pickerView.delegate = self
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        //self.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
}

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingTypes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch settingTypes[indexPath.row] {
        case .language:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingsLanguageTableViewCell.identifier, for: indexPath) as? SettingsLanguageTableViewCell else {return UITableViewCell()}
            cell.languageKindLabel.text = currentLanguageType.getText()
            return cell
        case .logout:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingsReportTableViewCell.identifier, for: indexPath) as? SettingsReportTableViewCell else {return UITableViewCell()}
            cell.nameLabel.text = "Выйти".localized
            return cell
        case .security:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingsReportTableViewCell.identifier, for: indexPath) as? SettingsReportTableViewCell else {return UITableViewCell()}
            cell.arrowImage.isHidden = false
            cell.nameLabel.text = "Безопасность".localized
            return cell
        case .support:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingsReportTableViewCell.identifier, for: indexPath) as? SettingsReportTableViewCell else {return UITableViewCell()}
            cell.nameLabel.text = "Служба поддержки".localized
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch settingTypes[indexPath.row] {
        case .language:
            UIView.animate(withDuration: 0.2) {
                self.setupPickerView()
            }
        case .support:
            openReportScreen()
        case .security:
            print("Security")
        case .logout:
   
            let vc = QuestionModalViewController(delegate: self, titleText: "Выход из аккаунта".localized, questionText: "Вы уверенны, что хотите выйти из аккаунта?".localized, acceptButtonText: "Выйти".localized)
                vc.transitioningDelegate = self
                present(vc, animated: true, completion: nil)

        }
    }
    
    @objc func toolBarDoneButtonPressed() {
        UIView.animate(withDuration: 0.2) {
            self.picker.removeFromSuperview()
            self.currentLanguageType = self.languageTypes[self.pickerView.selectedRow(inComponent: 0)]
            self.tableView.reloadData()
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func datePickerClose() {
        view.endEditing(true)
    }
    
    func openReportScreen() {
        let mailVC = configureMailCompose()
        if MFMailComposeViewController.canSendMail() {
            self.present(mailVC, animated: true, completion: nil)
        }
    }
    
    
}

extension SettingsViewController:MFMailComposeViewControllerDelegate {
    func configureMailCompose() -> MFMailComposeViewController {
        let mail = MFMailComposeViewController()
        mail.mailComposeDelegate = self
        mail.setToRecipients([MailHelper.email])
        mail.setMessageBody("", isHTML: true)
        mail.setSubject("Reporting")
        return mail
    }
}

extension SettingsViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if presented is AcceptModalViewController || presented is ModalPopUpViewController || presented is QuestionModalViewController{
            return TransparentBackgroundModalPresenter(isPush: true, originFrame: UIScreen.main.bounds)
        } else {
        return SuccessModalPresenter(isPush: true, originFrame: UIScreen.main.bounds)
        }
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if dismissed is AcceptModalViewController || dismissed is ModalPopUpViewController || dismissed is QuestionModalViewController{
        return TransparentBackgroundModalPresenter(isPush: false)
        } else {
            return SuccessModalPresenter(isPush: false)
        }
    }
}

extension SettingsViewController: UIPickerViewDelegate, UIPickerViewDataSource {

        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return 1
        }
        
        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            return languageTypes.count
        }
        
        func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            return languageTypes[row].getText()
        }
        
        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            
        }
        
}

extension SettingsViewController: QuestionModalViewControllerProtocol {
    func acceptButtonPressed() {
        let userId = UserSettings.appUser?.id
        DispatchQueue.global(qos: .userInitiated).async {
            FireBaseHelper().updateFCMToken(fcmTokenGroup: FCMTokenGroup(userId: (userId)!, fcmToken: "")) { (result) in
                print("Fcm Token Updated")
            }
        }
        UserSettings.clearAppUser()
        navigateToLoginVC()
    }
}
