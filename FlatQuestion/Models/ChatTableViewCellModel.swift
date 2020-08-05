//
//  ChatTableViewCellModel.swift
//  FlatQuestion
//
//  Created by MacBook on 7/22/20.
//  Copyright © 2020 Андрей Олесов. All rights reserved.
//

import UIKit

struct ChatTableViewCellModel {
    var chatId: String
    var recipientName: String
    var recipientAvatarUrl: String
    var messageText: String
    var messageSentTime: String
    var unreadedMessagesCount: Int = 0
}
