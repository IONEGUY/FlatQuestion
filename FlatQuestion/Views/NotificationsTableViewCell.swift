//
//  NotificationsTableViewCell.swift
//  FlatQuestion
//
//  Created by Андрей Олесов on 7/18/20.
//  Copyright © 2020 Андрей Олесов. All rights reserved.
//

import UIKit

class NotificationsTableViewCell: UITableViewCell {

    @IBOutlet weak var approveButton: DarkGradientButton!
    @IBOutlet weak var declineButton: UIButton!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var photoImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    @IBAction func btn(_ sender: Any) {
    }
    
    func setupCell(flatId: Int, userInfo: UserInfo) {
        fullNameLabel.text = userInfo.fullName
        photoImage.sd_setImage(with: URL(string: userInfo.photoLink)!, completed: nil)
        messageLabel.text = userInfo.message
        declineButton.addCorner(with: 20, with: .black)
        modify(status: userInfo.status)
        
    }
    
    @IBAction func declineButtonPressed(_ sender: Any) {
        UIView.animate(withDuration: 1, delay: 1, options: .allowAnimatedContent, animations: {
                        self.approveButton.addCorner(with: 20, with: .black)
            self.declineButton.addCorner(with: 20, with: .black)
            
            self.approveButton.setTitleColor(UIColor(hex: 0x8F8F8F), for: .normal)
            self.approveButton.backgroundColor = .white
        }, completion: nil)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        let padding = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        bounds.inset(by: padding)
    }
    
    @IBAction func approveRequest(_ sender: Any) {
        self.approveButton.setTitle("Принято".localized, for: .normal)
        DispatchQueue.main.async {
            self.approveButton.layer.cornerRadius = 0
            self.approveButton.clipsToBounds = false
            self.approveButton.removeSublayers()
            self.layoutSubviews()
            self.approveButton.addCorner(with: 20, with: .black)
            
            self.approveButton.setTitleColor(UIColor(hex: 0x8F8F8F), for: .normal)
            self.approveButton.backgroundColor = .white
            
             self.declineButton.setAttributedTitle(NSAttributedString(string: "Удалить".localized, attributes: [NSAttributedString.Key.font: UIFont(name: "SFProDisplay-Regular", size: 15.0), NSAttributedString.Key.foregroundColor: UIColor(hex: 0xF11616)]), for: .normal)
             self.descriptionLabel.text = "добавлен(а) к участникам вечеринке".localized
        }
    }
    
    
    func modify(status: RequestStatus) {
        switch status {
        case .New:
            self.approveButton.setTitle("Принять".localized, for: .normal)
            self.declineButton.setTitle("Отказать".localized, for: .normal)
            self.descriptionLabel.text = "желает присоединиться к вечеринке".localized
            
        case .Approved:
            
            self.approveButton.setTitle("Принято".localized, for: .normal)
            self.approveButton.backgroundColor = .white
            self.declineButton.setAttributedTitle(NSAttributedString(string: "Удалить".localized, attributes: [NSAttributedString.Key.font: UIFont(name: "SFProDisplay-Regular", size: 15.0), NSAttributedString.Key.foregroundColor: UIColor(hex: 0xF11616)]), for: .normal)
            self.descriptionLabel.text = "добавлен(а) к участникам вечеринке".localized
            
        default:
            print("Declined")
        }
    }
    
}

extension NotificationsTableViewCell: ReuseIdentifierProtocol {
    static var identifier: String {
        get {
            return "NotificationsTableViewCell"
        }
    }
}
