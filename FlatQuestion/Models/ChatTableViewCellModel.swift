import UIKit

struct ChatTableViewCellModel {
    var chatId: String
    var recipientName: String
    var recipientAvatarUrl: String
    var messageText: String
    var messageSentTime: String
    var unreadedMessagesCount: Int = 0
}
