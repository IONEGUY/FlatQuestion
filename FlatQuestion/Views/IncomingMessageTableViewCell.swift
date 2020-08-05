//
//  IncomingMessageTableViewCell.swift
//  FlatQuestion
//
//  Created by MacBook on 7/28/20.
//  Copyright © 2020 Андрей Олесов. All rights reserved.
//

import UIKit
import SDWebImage

class IncomingMessageTableViewCell: UITableViewCell {
    @IBOutlet weak var senderAvatarImageView: UIImageView!
    @IBOutlet weak var messageTextContainer: UIView!
    @IBOutlet weak var messageText: UILabel!
    @IBOutlet weak var sentTime: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.senderAvatarImageView.applyCircledStyle()
        
        messageTextContainer.layer.cornerRadius = 10
        messageTextContainer.layer.borderWidth = 1.5
        messageTextContainer.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1).cgColor
    }

    func initialize(withData data: MessageCellModel) {
        self.senderAvatarImageView.sd_setImage(with: URL(string: data.avatarUrl!), completed: nil)
        self.messageText.text = data.messageText
        self.sentTime.text = data.sentTime
    }
}
