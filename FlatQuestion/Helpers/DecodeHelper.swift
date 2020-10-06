import UIKit

class DecodeHelper {
    static func decodeFromDictionary<T: Codable>(dictionary: [String: Any], type: T.Type) -> T {
        return try! JSONDecoder().decode(type, from: JSONSerialization.data(withJSONObject: dictionary))
    }
}
