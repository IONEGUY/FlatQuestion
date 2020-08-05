//
//  ChatTableViewCell.swift
//  FlatQuestion
//
//  Created by MacBook on 7/21/20.
//  Copyright © 2020 Андрей Олесов. All rights reserved.
//

import UIKit

class ChatTableViewCell: UITableViewCell {
    @IBOutlet weak var userAvatar: UIImageView!
    @IBOutlet weak var fullName: UILabel!
    @IBOutlet weak var lastMessageText: UILabel!
    @IBOutlet weak var lastMessageDate: UILabel!
    @IBOutlet weak var messagesCountContainer: UIView!
    @IBOutlet weak var messagesCount: UILabel!
    @IBOutlet weak var messageTextTrailingConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        userAvatar.applyCircledStyle()
        messagesCountContainer.applyCircledStyle()
    }
    
    func fillData(_ chatTableViewCellModel: ChatTableViewCellModel) {
        userAvatar.sd_setImage(with: URL(string: chatTableViewCellModel.message.userAvatarUrl!), completed: nil)
        fullName.text = chatTableViewCellModel.message.ownerUserName
        lastMessageText.text = chatTableViewCellModel.message.text
        lastMessageDate.text = convertDateToString(chatTableViewCellModel.message.sentDate!)
        messagesCount.text = String(chatTableViewCellModel.unreadedMessagesCount)
        
        if chatTableViewCellModel.unreadedMessagesCount == 0 {
            messagesCountContainer.isHidden = true
            messageTextTrailingConstraint.constant = 0
            messagesCountContainer.widthAnchor.constraint(equalToConstant: 0).isActive = true
        }
    }
    
    private func convertDateToString(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        return dateFormatter.string(from: date)
    }
}
