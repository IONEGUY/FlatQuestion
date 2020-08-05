//
//  SettingsViewController.swift
//  FlatQuestion
//
//  Created by Андрей Олесов on 8/2/20.
//  Copyright © 2020 Андрей Олесов. All rights reserved.
//

import UIKit
import MessageUI
class SettingsViewController: UIViewController {

    enum TypeOfSettingCell {
        case language
        case report
    }
    
    var cells: [TypeOfSettingCell] = [.report]
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupData()
    }

    
    func setupData() {
        tableView.register(UINib(nibName: SettingsReportTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: SettingsReportTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
    }
}

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch cells[indexPath.row] {
        case .language:
            return UITableViewCell()
        case .report:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingsReportTableViewCell.identifier, for: indexPath) as? SettingsReportTableViewCell else {return UITableViewCell()}
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch cells[indexPath.row] {
        case .language:
            print("Language")
        case .report:
            openReportScreen()
        default:
            print("Error")
        }
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
        if presented is AcceptModalViewController || presented is ModalPopUpViewController {
            return TransparentBackgroundModalPresenter(isPush: true, originFrame: UIScreen.main.bounds)
        } else {
        return SuccessModalPresenter(isPush: true, originFrame: UIScreen.main.bounds)
        }
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if dismissed is AcceptModalViewController || dismissed is ModalPopUpViewController {
        return TransparentBackgroundModalPresenter(isPush: false)
        } else {
            return SuccessModalPresenter(isPush: false)
        }
    }
}
