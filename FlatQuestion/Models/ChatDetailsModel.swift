import Foundation

class Chat: Codable {
    var chatId: String?
    var lastSenderId: String?
    var interlocutor: AppUser?
    var interlocutorFullName: String?
    var interlocuterAvatarUrl: String?
    var lastMessage: String?
    var lastMessageSentTime: Date?
    var unreadMessagesCount: Int?
    var memberIds: [String?]?
    
    init(chatId: String?,
         memberIds: [String?]) {
        self.chatId = chatId
        self.memberIds = memberIds
    }
    
    init(chatId: String?,
         lastSenderId: String?,
         lastMessage: String?,
         lastMessageSentTime: Date?,
         unreadMessagesCount: Int?) {
        self.chatId = chatId
        self.lastSenderId = lastSenderId
        self.lastMessage = lastMessage
        self.lastMessageSentTime = lastMessageSentTime
        self.unreadMessagesCount = unreadMessagesCount
    }
    
    func updateMainInfo(_ chat: Chat) {
        lastSenderId = chat.lastSenderId
        lastMessage = chat.lastMessage
        lastMessageSentTime = chat.lastMessageSentTime
        unreadMessagesCount = chat.unreadMessagesCount
    }
    
    enum CodingKeys: String, CodingKey {
        case chatId
        case memberIds
    }    
}
