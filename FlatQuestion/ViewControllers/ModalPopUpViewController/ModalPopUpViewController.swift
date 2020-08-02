//
//  ModalPopUpViewController.swift
//  FlatQuestion
//
//  Created by Андрей Олесов on 8/2/20.
//  Copyright © 2020 Андрей Олесов. All rights reserved.
//

import UIKit

protocol ModalPopUpViewControllerProtocol: AnyObject  {
    func createButtonPressed(text: String)
}

class ModalPopUpViewController: UIViewController {

    @IBOutlet weak var writeMessageView: UIView!
    @IBOutlet weak var writeMessageLabel: UILabel!
    @IBOutlet weak var declineButton: UIButton!
    @IBOutlet weak var createButton: DarkGradientButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    weak var delegate: ModalPopUpViewControllerProtocol?
    var titleString: String?
    var descriptionString: String?
    var createButtonString: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        localize()
    }

    init(delegate: ModalPopUpViewControllerProtocol?, title: String?, description: String?, createButtonText: String?) {
          super.init(nibName: String(describing: ModalPopUpViewController.self), bundle: nil)
        titleString = title
        descriptionString = description
        createButtonString = createButtonText
          self.modalPresentationStyle = .custom
          self.delegate = delegate
      }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
        private func localize() {
            createButton.titleLabel?.text = createButtonString?.localized
            declineButton.titleLabel?.text = "Отмена".localized
            writeMessageLabel.text = "Написать сообщение".localized
            descriptionLabel.text = descriptionString?.localized
            titleLabel.text = titleString?.localized
        }
        
        private func setupView() {
            declineButton.addCorner(with: 20, with: .black)
            writeMessageView.addCorner(with: 10, with: .black)
        }
    
    @IBAction func declineButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func createButtonPressed(_ sender: UIButton) {
        delegate?.createButtonPressed(text: textView.text)
    }
    
}

