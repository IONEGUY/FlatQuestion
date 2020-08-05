//
//  OutgoingMessageTableViewCell.swift
//  FlatQuestion
//
//  Created by MacBook on 7/28/20.
//  Copyright © 2020 Андрей Олесов. All rights reserved.
//

import UIKit

class OutgoingMessageTableViewCell: UITableViewCell {
    @IBOutlet weak var messageSentTime: UILabel!
    @IBOutlet weak var messageText: UILabel!
    @IBOutlet weak var messageTextContainer: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        messageTextContainer.layer.cornerRadius = 10;
        messageTextContainer.layer.borderWidth = 1.5;
        messageTextContainer.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1).cgColor
    }
    
    public func initialize(withData messageCellModel: MessageCellModel) {
        self.messageText.text = messageCellModel.messageText
        self.messageSentTime.text = messageCellModel.sentTime
    }
}
