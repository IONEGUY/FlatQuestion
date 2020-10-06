import UIKit

struct Comment: Codable {
    var forUserId: String
    var text: String
    var createdAt: TimeInterval
    var rate: Int
    var creatorName: String
    
    enum CodingKeys: CodingKey {
        case forUserId
        case text
        case createdAt
        case rate
        case creatorName
    }
}
