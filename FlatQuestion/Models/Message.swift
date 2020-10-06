import UIKit

struct Message: Codable {
    var id: String?
    var senderId: String
    var senderAvatarUrl: String
    var sentDate: Date
    var text: String
    var isRead: Bool
    var uploaded: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id
        case senderId
        case sentDate
        case text
        case senderAvatarUrl
        case isRead
    }
}
