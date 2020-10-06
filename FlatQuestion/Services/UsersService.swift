import Foundation
import Firebase

class UsersService {
    private let firestore = Firestore.firestore()
    private let errorsHandler: ErrorHandler = AlertErrorMessageHandler()
    
    func getUser(byId id: String?) -> AppUser? {
        var user: AppUser? = nil
        let semaphore = DispatchSemaphore(value: 0)
        
        firestore.collection("users")
            .whereField("id", isEqualTo: id)
            .getDocuments { [weak self] (snapshot, error) in
                if error != nil {
                    self?.errorsHandler.handle(error!.localizedDescription)
                } else {
                    if let documents = snapshot?.documents {
                        user = try? documents.first?.data(as: AppUser.self)
                    }
                }
                semaphore.signal()
        }
        _ = semaphore.wait(timeout: .distantFuture)
        return user
    }
}
