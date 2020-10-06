import UIKit

class ChatTableViewCell: UITableViewCell {
    @IBOutlet weak var userAvatar: UIImageView!
    @IBOutlet weak var messageOwnerAvatar: UIImageView!
    @IBOutlet weak var fullName: UILabel!
    @IBOutlet weak var lastMessageText: UILabel!
    @IBOutlet weak var lastMessageDate: UILabel!
    @IBOutlet weak var messagesCountContainer: UIView!
    @IBOutlet weak var messagesCount: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.clear
        selectedBackgroundView = backgroundView
        
        userAvatar.applyCircledStyle()
        messageOwnerAvatar.applyCircledStyle()
        messagesCountContainer.applyCircledStyle()
    }
    
    func fillData(_ chat: Chat) {
        messagesCountContainer.isHidden = false
        messageOwnerAvatar.isHidden = false
        
        userAvatar.sd_setImage(with: URL(string: chat.interlocuterAvatarUrl
            ?? Constants.defaultAvatarUrl), completed: nil)
        messageOwnerAvatar.sd_setImage(with:URL(string: UserSettings.appUser?.avatarUrl
            ?? Constants.defaultAvatarUrl), completed: nil)
        fullName.text = chat.interlocutorFullName
        lastMessageText.text = chat.lastMessage ?? "There are no messages in this chat"
        lastMessageDate.text = convertDateToString(chat.lastMessageSentTime)
        messagesCount.text = chat.unreadMessagesCount != nil
            ? String(chat.unreadMessagesCount!) : String.empty
        
        if chat.unreadMessagesCount ?? 0 == 0 || chat.lastSenderId == UserSettings.appUser?.id! {
            messagesCountContainer.isHidden = true
        }
        
        if chat.lastSenderId != UserSettings.appUser?.id! {
            messageOwnerAvatar.isHidden = true
        }
    }
    
    private func convertDateToString(_ date: Date?) -> String {
        guard let date = date else { return String.empty }
        var text = String.empty
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            text = "Сегодня".localized
        } else if calendar.isDateInYesterday(date) {
            text = "Вчера".localized
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM.yyyy"
            text = formatter.string(from: date)
        }
        
        return text
    }
}
