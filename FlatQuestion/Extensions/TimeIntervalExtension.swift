import Foundation

extension TimeInterval {
    func date() -> Date {
        return Date(timeIntervalSince1970: self)
    }
}
