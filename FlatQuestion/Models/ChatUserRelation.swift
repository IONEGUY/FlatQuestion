import Foundation

struct ChatMembersRelation: Decodable {
    var chatId: String
    var chatIds: [String]
}
