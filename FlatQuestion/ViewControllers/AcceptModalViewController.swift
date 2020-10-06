import UIKit

protocol AcceptModalViewControllerProtocol: AnyObject  {
    func inviteSuccessfullySended()
}

public enum RequestStatus: String, Codable {
    case New = "New"
    case Approved = "Approved"
    case Declined = "Declined"
    
}
class AcceptModalViewController: UIViewController {

    @IBOutlet var mainView: UIView!
    @IBOutlet fileprivate weak var contentView: UIView!
    @IBOutlet fileprivate weak var sendButton: DarkGradientButton!
    @IBOutlet fileprivate weak var declineButton: UIButton!
    @IBOutlet fileprivate weak var writeMessageLabel: UILabel!
    @IBOutlet fileprivate weak var descriptionLabel: UILabel!
    @IBOutlet fileprivate weak var connectToFlatLabel: UILabel!
    @IBOutlet fileprivate weak var writeMessageView: UIView!
    @IBOutlet fileprivate weak var textView: UITextView!
    
    fileprivate var flat: FlatModel!
    
    weak var delegate: AcceptModalViewControllerProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        localize()
    }
    
    init(delegate: AcceptModalViewControllerProtocol?, flat: FlatModel) {
        super.init(nibName: String(describing: AcceptModalViewController.self), bundle: nil)
        self.modalPresentationStyle = .custom
        self.delegate = delegate
        self.flat = flat
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func localize() {
        sendButton.setTitle("Присоедениться", for: .normal)
        declineButton.titleLabel?.text = "Отмена".localized
        writeMessageLabel.text = "Написать сообщение".localized
        descriptionLabel.text = "Организатор получит уведомление о вашем желании присоединиться".localized
        connectToFlatLabel.text = "Присоединиться к вечеринке".localized
    }
    
    private func setupView() {
//        view.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        mainView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tap(_:))))
        mainView.isUserInteractionEnabled = true
        contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tapOnContent(_:))))
        contentView.isUserInteractionEnabled = true
        declineButton.addCorner(with: 20, with: .black)
        writeMessageView.addCorner(with: 10, with: .black)
    }
    
    @objc func tap(_ gestureRecognizer: UITapGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func tapOnContent(_ gestureRecognizer: UITapGestureRecognizer) {
        self.textView.becomeFirstResponder()
    }

    @IBAction func sendRequest(_ sender: Any) {
        self.showLoadingIndicator()
        FireBaseHelper().getUserById(id: flat.userId) { (result) in
            switch result {
            case .success(let owner):
                let userInfo = UserInfo(id: UserSettings.appUser!.id!, status: .New, message: self.textView.text, fullName: "\(String(describing: UserSettings.appUser!.fullName!))", photoLink: UserSettings.appUser!.avatarUrl!, date: Date().timeIntervalSince1970)

                let requestModel = FlatRequestModel(id: self.flat.id, requests: [userInfo], ownerId: self.flat.userId, ownerPhotoLink: owner.avatarUrl!, fullName: owner.fullName!, flatPhotoLink: self.flat.images![0], flatName: self.flat.name)
                
                FireBaseHelper.init().updateRequestsForFlat(model: requestModel) { (result) in
                    self.hideLoadingableIndicator()
                    switch result {
                    case .success(()): let vc = SuccessViewController(delegate: self)
                    DispatchQueue.global(qos: .userInitiated).async {
                        FireBaseHelper().sendNotification(to: self.flat.userId, title: "Туса-Джуса", body: "Эй, кто-то хочет к тебе на тусовку!")
                    }
                    vc.transitioningDelegate = self
                    self.present(vc, animated: true, completion: nil)
                    case .failure(let error):
                        self.showErrorAlert(message: error.localizedDescription)
                    }
                }
            case .failure(let error): self.showErrorAlert(message: error.localizedDescription)
                                      self.hideLoadingableIndicator()
            }
        }
    }
    
    @IBAction func declineButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension AcceptModalViewController: UIViewControllerTransitioningDelegate {
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

extension AcceptModalViewController: SuccessViewControllerProtocol {
    func successScreenWillClose() {
        self.dismiss(animated: true, completion: nil)
    }

}
