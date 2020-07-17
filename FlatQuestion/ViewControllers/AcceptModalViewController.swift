//
//  AcceptModalViewController.swift
//  FlatQuestion
//
//  Created by Андрей Олесов on 7/16/20.
//  Copyright © 2020 Андрей Олесов. All rights reserved.
//

import UIKit

protocol AcceptModalViewControllerProtocol: AnyObject  {
    func inviteSuccessfullySended()
}

enum RequestStatus: String, Codable {
    case New = "New"
    case Approved = "Approved"
    case Declined = "Declined"
    
}
class AcceptModalViewController: UIViewController {

    @IBOutlet fileprivate weak var contentView: UIView!
    @IBOutlet fileprivate weak var sendButton: DarkGradientButton!
    @IBOutlet fileprivate weak var declineButton: UIButton!
    @IBOutlet fileprivate weak var writeMessageLabel: UILabel!
    @IBOutlet fileprivate weak var descriptionLabel: UILabel!
    @IBOutlet fileprivate weak var connectToFlatLabel: UILabel!
    @IBOutlet fileprivate weak var writeMessageView: UIView!
    @IBOutlet fileprivate weak var textView: UITextView!
    
    fileprivate var flatId: Int!
    
    weak var delegate: AcceptModalViewControllerProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        localize()
    }
    
    init(delegate: AcceptModalViewControllerProtocol?, flatId: Int) {
        super.init(nibName: String(describing: AcceptModalViewController.self), bundle: nil)
        self.modalPresentationStyle = .custom
        self.delegate = delegate
        self.flatId = flatId
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func localize() {
        sendButton.titleLabel?.text = "Отправить".localized
        declineButton.titleLabel?.text = "Отмена".localized
        writeMessageLabel.text = "Написать сообщение".localized
        descriptionLabel.text = "Организатор получит уведомление о вашем желании присоединиться".localized
        connectToFlatLabel.text = "Присоединиться к вечеринке".localized
    }
    
    private func setupView() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        declineButton.addCorner(with: 20, with: .black)
        writeMessageView.addCorner(with: 10, with: .black)
    }

    @IBAction func sendRequest(_ sender: Any) {
        let userInfo = UserInfo(id: UserSettings.appUser.id!, status: .New, message: textView.text)

        let requestModel = FlatRequestModel(id: flatId, requests: [userInfo])
        self.showLoadingIndicator()
        FireBaseHelper.init().updateRequestsForFlat(model: requestModel) { (result) in
            self.hideLoadingableIndicator()
            switch result {
            case .success(()): let vc = SuccessViewController(delegate: self)
            vc.transitioningDelegate = self
            self.present(vc, animated: true, completion: nil)
            case .failure(let error):
                self.showErrorAlert(message: error.localizedDescription)
            }
        }
    }
    
    @IBAction func declineButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension AcceptModalViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return TransparentBackgroundModalPresenter(isPush: true, originFrame: UIScreen.main.bounds)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return TransparentBackgroundModalPresenter(isPush: false)
    }
}

extension AcceptModalViewController: SuccessViewControllerProtocol {
    func successScreenWillClose() {
        self.dismiss(animated: true, completion: nil)
    }

}
