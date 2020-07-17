//
//  SuccessViewController.swift
//  FlatQuestion
//
//  Created by Андрей Олесов on 7/16/20.
//  Copyright © 2020 Андрей Олесов. All rights reserved.
//

import UIKit

protocol SuccessViewControllerProtocol: AnyObject {
    func successScreenWillClose()
}

class SuccessViewController: UIViewController {

    weak var delegate: SuccessViewControllerProtocol?
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        // Do any additional setup after loading the view.
    }

    init(delegate: SuccessViewControllerProtocol?) {
        super.init(nibName: String(describing: SuccessViewController.self), bundle: nil)
        self.modalPresentationStyle = .custom
        self.delegate = delegate
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.dismiss(animated: true) {
                self.delegate?.successScreenWillClose()
            }
        }
    }
}
