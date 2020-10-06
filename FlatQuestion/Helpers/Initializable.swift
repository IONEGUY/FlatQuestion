import Foundation

protocol Initializable {
    func initialize<T>(withData data: T)
}
