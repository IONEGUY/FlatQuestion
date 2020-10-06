import UIKit
import Foundation
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage

public enum MyError: Error {
    case flatRequestAlreadySended
    case isYourFlat
    case unrecognizedError
    case userHasNoFlats
}

extension MyError: LocalizedError {
    public var errorDescription: String? {
        switch self {
            case .flatRequestAlreadySended:
                return "Запрос на тусовку уже был отправлен".localized
            case .isYourFlat: return "Нельзя отправить запрос самому себе".localized
            case .unrecognizedError: return "Неопознанная ошибка".localized
            case .userHasNoFlats: return "У вас нет активных тусовок".localized
        } 
    }
}

class FireBaseHelper {
//    let ReceiverFCMToken = "e2Gs7QsBnkv1n1xmoE5yj-:APA91bGZtkw2Ja1ANEUXLSS_z9d28swaGLugG6FXB2iBlaD-ujimVY9gS1dIDwVTxaFmKajU3_BXdqgURmw2_4ap4yjXGG7EjAjbwjyIgkxyiIipu0FSsacfFCKu4mWPQf-aeblwOYXO"

    // Please change it your Firebase Legacy server key
    // Firebase -> Project settings -> Cloud messaging -> Legacy server key
    
    static var shared = FireBaseHelper()
    
    let legacyServerKey = "AAAAGsccgZs:APA91bH2qdmqAG4jXRGeNgDmt-eeqR7aAuY4dUJ8ieyQSjaRFF0h4pBo4NC-MG06XTiMGDZw6WL2nIYTtmGxP_lVXNFTlI0JUQ4vIr5igpXWj3l44Je_uLgIdFUfqzAcH8FiWtYHi5NB"
   
    var fcmToken: String? {
        get {
            return Messaging.messaging().fcmToken
        }
    }
    
    func initChat(chat: Chat, completion: @escaping () -> ()) {
        let db = Firestore.firestore()
        do {
            try db.collection("chats").document().setData(from: chat)
            completion()
        } catch let error {
            print("Error writing Flat to Firestore: \(error)")
            completion()
        }
    }
    
    func setFCMToken(fcmTokenGroup: FCMTokenGroup , completion: @escaping (_ result: Result<Void,Error>) -> ()) {
        let db = Firestore.firestore()
        do {
            try db.collection("fcm_tokens").document().setData(from: fcmTokenGroup)
            completion(.success(()))
        } catch let error {
            print("Error writing Flat to Firestore: \(error)")
            completion(.failure(error))
        }
    }
    
    func updateFCMToken(fcmTokenGroup: FCMTokenGroup , completion: @escaping (_ result: Result<Void,Error>) -> ()) {
        let db = Firestore.firestore()
        do {
            
            db.collection("fcm_tokens").whereField("userId", isEqualTo: fcmTokenGroup.userId).getDocuments { (snapshot, error) in
                guard let document = snapshot?.documents.first else { return }
                let encoder = Firestore.Encoder()
                guard let updateData = try? encoder.encode(fcmTokenGroup) else {
                    completion(.failure(MyError.unrecognizedError))
                    return
                }
                db.collection("fcm_tokens").document(document.documentID).updateData(updateData) { (error) in
                    error == nil ? completion(.success(())) : completion(.failure(error!))
                }
                
            }
        } catch let error {
            print("Error writing Flat to Firestore: \(error)")
            completion(.failure(error))
        }
    }
    
    func sendNotification(to userId: String, title: String, body: String) {
        let db = Firestore.firestore()
        db.collection("fcm_tokens").whereField("userId", isEqualTo: userId as Any).getDocuments { (snapshot, error) in
            guard let document = snapshot?.documents.first else { return }
            guard var fbModel = try? document.data(as: FCMTokenGroup.self), fbModel.fcmToken != "" else {
                return
            }
            let token = fbModel.fcmToken
            print("sendMessageTouser()")
            let urlString = "https://fcm.googleapis.com/fcm/send"
            let url = NSURL(string: urlString)!
            let paramString: [String : Any] = ["to" : token,
                                               "notification" : ["title" : title, "body" : body],
                                               "data" : ["user" : "test_id"]
            ]
            let request = NSMutableURLRequest(url: url as URL)
            request.httpMethod = "POST"
            request.httpBody = try? JSONSerialization.data(withJSONObject:paramString, options: [.prettyPrinted])
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("key=\(self.legacyServerKey)", forHTTPHeaderField: "Authorization")
            let task =  URLSession.shared.dataTask(with: request as URLRequest)  { (data, response, error) in
                do {
                    if let jsonData = data {
                        if let jsonDataDict  = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] {
                            NSLog("Received data:\n\(jsonDataDict))")
                        }
                    }
                } catch let err as NSError {
                    print(err.debugDescription)
                }
            }
            task.resume()
            
        }
    }
    func getFlatRequests(completion: @escaping (_ result: Result<[FlatRequestModel],Error>) -> ()) {
        guard let flats = UserSettings.appUser?.flats else {
            completion(.failure(MyError.unrecognizedError))
            return }
//        guard flats.count > 0 else {
//            completion(.failure(MyError.userHasNoFlats))
//            return }
        let db = Firestore.firestore()
        db.collection("flat_requests").whereField("ownerId", isEqualTo: UserSettings.appUser!.id! as Any).getDocuments { (snapshot, error) in
                if error != nil {
                    completion(.failure(MyError.unrecognizedError))
                } else {
                    guard let documents = snapshot?.documents, documents.count != 0 else {
                        completion(.success([FlatRequestModel]()))
                        return
                    }
                    var models = [FlatRequestModel]()
                    documents.forEach({ (snapshot) in
                        guard var fbModel = try? snapshot.data(as: FlatRequestModel.self) else {
                            completion(.failure(MyError.unrecognizedError))
                            return
                        }
                        models.append(fbModel)
                    })
                    completion(.success(models))
                }
            }
    }
    
    func getFlatRequestsMy(completion: @escaping (_ result: Result<[FlatRequestModel],Error>) -> ()) {
        guard let flats = UserSettings.appUser?.flats else {
            completion(.failure(MyError.unrecognizedError))
            return }
        
        let db = Firestore.firestore()
        db.collection("flat_requests").getDocuments { (snapshot, error) in
                if error != nil {
                    completion(.failure(MyError.unrecognizedError))
                } else {
                    guard let documents = snapshot?.documents, documents.count != 0 else { return }
                    var models = [FlatRequestModel]()
                    documents.forEach({ (snapshot) in
                        guard var fbModel = try? snapshot.data(as: FlatRequestModel.self) else {
                            completion(.failure(MyError.unrecognizedError))
                            return
                        }
                        fbModel.requests.forEach({ (userInfo) in
                            if userInfo.id == UserSettings.appUser!.id! {
                                models.append(fbModel)
                            }
                        })
                        completion(.success(models))
                    })
                }
            }
    }
    
    private func getCommentsOfUser(userId: String, completion: @escaping (_ result: Result<[Comment],Error>) -> ()) {
        let db = Firestore.firestore()
        db.collection("comments").whereField("forUserId", isEqualTo: userId as Any).getDocuments { (snapshot, error) in
            if let error = error {
                print(error)
            } else if let snapshot = snapshot {
               let flats = snapshot.documents.compactMap {
                return try? $0.data(as: Comment.self)
                }
                completion(.success(flats))
            }
        }
    }
    
    func getComments(userId: String, completion: @escaping (_ result: [Comment]) -> ()) {
        getCommentsOfUser(userId: userId) { (result) in
            switch result {
            case .success(let comments): completion(comments)
            case .failure(let error): print(error)
            }
        }
    }
    
    func updateFlatRequestStatus(flatId: Int, userInformation: UserInfo,completion: @escaping (_ result: Result<Void,Error>) -> ()) {
        let db = Firestore.firestore()
        db.collection("flat_requests").whereField("id", isEqualTo: flatId as Any).getDocuments { (snapshot, error) in
            if error != nil {
                completion(.failure(MyError.unrecognizedError))
            } else {
                guard let document = snapshot?.documents.first else { return }
                guard var fbModel = try? document.data(as: FlatRequestModel.self) else {
                    completion(.failure(MyError.unrecognizedError))
                    return
                }
                
                guard var userInfoToChange = fbModel.requests.first(where: { (userInfo) -> Bool in
                    return userInfo.id == userInformation.id
                }) else {
                    completion(.failure(MyError.unrecognizedError))
                    return
                }
               
                let index = fbModel.requests.firstIndex { (userInfo) -> Bool in
                    return userInfo.id == userInformation.id
                }
                userInfoToChange.status = userInformation.status
                
                fbModel.requests[index!] = userInfoToChange
                
                let encoder = Firestore.Encoder()
                guard let updateData = try? encoder.encode(fbModel) else {
                    completion(.failure(MyError.unrecognizedError))
                    return
                }
                
                db.collection("flat_requests").document(document.documentID).updateData(updateData) { (error) in
                    error == nil ? completion(.success(())) : completion(.failure(error!))
                }
                
            }
        }
    }
    
    func removeFlatRequestUserInfo(flatId: Int, userInformation: UserInfo,completion: @escaping (_ result: Result<Void,Error>) -> ()) {
        let db = Firestore.firestore()
        db.collection("flat_requests").whereField("id", isEqualTo: flatId as Any).getDocuments { (snapshot, error) in
            if error != nil {
                completion(.failure(MyError.unrecognizedError))
            }
            guard let document = snapshot?.documents.first else { return }
            guard var fbModel = try? document.data(as: FlatRequestModel.self) else {
                completion(.failure(MyError.unrecognizedError))
                return
            }
            let index = fbModel.requests.firstIndex { (userInfo) -> Bool in
                return userInfo.id == userInformation.id
            }
            fbModel.requests.remove(at: index!)
            
            let encoder = Firestore.Encoder()
            guard let updateData = try? encoder.encode(fbModel) else {
                completion(.failure(MyError.unrecognizedError))
                return
            }
            
            db.collection("flat_requests").document(document.documentID).updateData(updateData) { (error) in
                error == nil ? completion(.success(())) : completion(.failure(error!))
            }
        }
    }
    
    func removeFlatRequest(flatId: Int) {
        let db = Firestore.firestore()
        db.collection("flat_requests").whereField("id", isEqualTo: flatId as Any).getDocuments { (snapshot, error) in
            guard let document = snapshot?.documents.first else { return }
            db.collection("flat_requests").document(document.documentID).delete()
            
        }
    }
    
    func updateUserInfoWithImage(user: AppUser, profileImage: UIImage, completion: @escaping (_ result: Result<Void,Error>) -> ()) {
        var urlString: String?
        uploadImageOfPerson(toPerson: String(user.id!), image: profileImage) { (result) in
            switch result {
            case .success(let url): urlString = url.absoluteString
                user.avatarUrl = urlString
            self.updateUserInfo(user: user) { (result) in
                completion(result)
                }
            case .failure(let error): completion(.failure(error))
            }
        }
    }
    
    func updateUserInfo(user: AppUser, completion: @escaping (_ result: Result<Void,Error>) -> ()) {
        let db = Firestore.firestore()
        do {
            db.collection("users").whereField("id", isEqualTo: user.id as Any).getDocuments { (snapshot, error) in
                guard error == nil else { return }
                let document = snapshot?.documents.first
                db.collection("users").document(document!.documentID).updateData(user.asDictionary) { (error) in
                    guard let error = error else {
                        completion(.success(()))
                        return
                    }
                    completion(.failure(error))
                }
            }
        }
    }
    
    func getUserById(id: String, completion: @escaping (_ result: Result<AppUser,Error>) -> ()) {
        let db = Firestore.firestore()
        do {
            db.collection("users").whereField("id", isEqualTo: id as Any).getDocuments { (snapshot, error) in
                guard error == nil else {
                    completion(.failure(MyError.unrecognizedError))
                    return
                }
                let document = snapshot?.documents.first
                guard var user = try? document!.data(as: AppUser.self) else {
                    completion(.failure(MyError.unrecognizedError))
                    return
                }
                completion(.success(user))
            }
        }
    }
    
    func updateRequestsForFlat(model: FlatRequestModel, completion: @escaping (_ result: Result<Void,Error>) -> ()) {
        var model = model
        let db = Firestore.firestore()
        do {
            db.collection("flat_requests").whereField("id", isEqualTo: model.id as Any).getDocuments { (snapshot, error) in
                if snapshot?.documents.count != 0 {
                    let document = snapshot?.documents.first
                    guard var fbModel = try? document!.data(as: FlatRequestModel.self) else {
                        completion(.failure(MyError.unrecognizedError))
                        return
                    }
                    var isNewRequest = true
                    fbModel.requests.forEach { (userInfo) in
                        if userInfo.id == model.requests.first?.id {
                            isNewRequest = false
                        }
                    }
                    guard isNewRequest else {
                        completion(.failure(MyError.flatRequestAlreadySended))
                        return
                    }
                    fbModel.requests.append(model.requests.first!)
                    
                    let encoder = Firestore.Encoder()
                    guard let updateData = try? encoder.encode(fbModel) else {
                        completion(.failure(MyError.unrecognizedError))
                        return
                    }
                    
                    db.collection("flat_requests").document(document!.documentID).updateData(updateData) { (error) in
                        error == nil ? completion(.success(())) : completion(.failure(error!))
                    }
                    
                } else {
                    self.sendNewRequestForFlat(model: model) { (result) in
                        completion(result)
                    }
                }
            }
        }
    }
    
    
    private func sendNewRequestForFlat(model: FlatRequestModel, completion: @escaping (_ result: Result<Void,Error>) -> ()) {
        let db = Firestore.firestore()
        do {
            try db.collection("flat_requests").document().setData(from: model)
            completion(.success(()))
        } catch let error {
            print("Error writing Flat to Firestore: \(error)")
            completion(.failure(error))
        }
    }

    func download(urlString: String) {
        let ref = Storage.storage().reference(forURL: urlString)
        let megaByte = Int64(1 * 1024 * 1024)
        ref.getData(maxSize: megaByte) { (data, error) in
            guard let imageData = data else { return }
            let image = UIImage(data: imageData)
            print("")
        }
    }
    
    func get(completion: @escaping ([FlatModel]) -> ()){
            let db = Firestore.firestore()

        db.collection("flats").getDocuments { (snapshot, error) in
            if let error = error {
                print(error)
            } else if let snapshot = snapshot {
               let flats = snapshot.documents.compactMap {
                return try? $0.data(as: FlatModel.self)
                }
                completion(flats)
            }
        }
    }
    
    func getFlatsById(userId: String, completion: @escaping ([FlatModel]) -> ()) {
        let db = Firestore.firestore()

        db.collection("flats").whereField("userId", isEqualTo: userId as Any).getDocuments { (snapshot, error) in
                   if let error = error {
                       print(error)
                   } else if let snapshot = snapshot {
                      let flats = snapshot.documents.compactMap {
                       return try? $0.data(as: FlatModel.self)
                       }
                       completion(flats)
                   }
               }
    }
    
    func getFlatById(flatId: Int, completion: @escaping ([FlatModel]) -> ()) {
        let db = Firestore.firestore()

        db.collection("flats").whereField("id", isEqualTo: flatId as Any).getDocuments { (snapshot, error) in
                   if let error = error {
                       print(error)
                   } else if let snapshot = snapshot {
                      let flats = snapshot.documents.compactMap {
                       return try? $0.data(as: FlatModel.self)
                       }
                       completion(flats)
                   }
               }
    }
    
    func removeFlat(flat: FlatModel, completion: @escaping (_ result: Result<Void,Error>) -> ()) {
        let urls = flat.images!
        DispatchQueue.global(qos: .background).async {
            urls.forEach { (string) in
                let storageRef = Storage.storage().reference(forURL: string)
                storageRef.delete { error in
                    if let error = error {
                        print(error.localizedDescription)
                    } else {
                        print("File deleted successfully")
                    }
                }
            }
        }
        
        let db = Firestore.firestore()
        
        db.collection("flats").whereField("id", isEqualTo: flat.id as Any).getDocuments { (snapshot, error) in
            guard error == nil else {
                completion(.failure(MyError.unrecognizedError))
                return
            }
            guard let document = snapshot?.documents.first else {
                completion(.failure(MyError.unrecognizedError))
                return
            }
            db.collection("flats").document(document.documentID).delete { (error) in
                guard error == nil else {
                    completion(.failure(MyError.unrecognizedError))
                    return
                }
                let userWithDeletedFlat = UserSettings.appUser
                userWithDeletedFlat?.flats?.removeAll(where: { (id) -> Bool in
                    return id == flat.id
                })
                self.updateUserInfo(user: userWithDeletedFlat!) { (result) in
                    UserSettings.appUser = userWithDeletedFlat
                    completion(result)
                }
            }
        }
        
        removeFlatRequest(flatId: flat.id)
        
    }
    
    func updateFlatWithImage(name: String, address: String, additionalInfo: String, allPlacesCount: Int, emptyPlacesCount: Int, date: Date, id: Int, x: Double, y: Double, images: [UIImage], flatId: Int, urls: [String], completion: @escaping (_ result: Result<Void,Error>) -> ()) {
        
        DispatchQueue.global(qos: .background).async {
            urls.forEach { (string) in
                let storageRef = Storage.storage().reference(forURL: string)
                storageRef.delete { error in
                    if let error = error {
                        print(error.localizedDescription)
                    } else {
                        print("File deleted successfully")
                    }
                }
            }
        }
        
        var urlStrings = [String]()
        
        for index in 0..<images.count {
            print(index)
        }
        
        
        for index in 0..<images.count {
            uploadImageOfFlat(toFlat: id, image: images[index]) { (result) in
                switch result {
                case .success(let url): urlStrings.append(url.absoluteString)
                if urlStrings.count ==  images.count {
                    let flat = FlatModel(name: name, additionalInfo: additionalInfo, allPlacesCount: allPlacesCount, emptyPlacesCount: emptyPlacesCount, date: date.timeIntervalSince1970, id: id, images: urlStrings, x: x, y: y, address: address, userId: UserSettings.appUser!.id!)
                    self.updateFlat(flat: flat) { (result) in
                        switch result {
                        case .success(()): let user = UserSettings.appUser
                        var userFlats = user?.flats
                        userFlats?.append(flat.id)
                        user?.flats = userFlats
                        UserSettings.appUser = user
                        self.updateUserInfo(user: user!) { (result) in
                            completion(result)
                            }
                        case .failure(let error): completion(.failure(error))
                        }
                    }
                    }
                case .failure(let error): completion(.failure(error))
                }
            }
        }
        
  
        
    }
    func createFlatWithImage(name: String, address: String, additionalInfo: String, allPlacesCount: Int, emptyPlacesCount: Int, date: Date, id: Int, x: Double, y: Double, images: [UIImage], completion: @escaping (_ result: Result<Void,Error>) -> ()) {
        var urlStrings = [String]()
        
        for index in 0..<images.count {
            print(index)
        }
        
        
        for index in 0..<images.count {
            uploadImageOfFlat(toFlat: id, image: images[index]) { (result) in
                switch result {
                case .success(let url): urlStrings.append(url.absoluteString)
                if urlStrings.count ==  images.count {
                    let flat = FlatModel(name: name, additionalInfo: additionalInfo, allPlacesCount: allPlacesCount, emptyPlacesCount: emptyPlacesCount, date: date.timeIntervalSince1970, id: id, images: urlStrings, x: x, y: y, address: address, userId: UserSettings.appUser!.id!)
                    self.createFlat(flat: flat) { (result) in
                        switch result {
                        case .success(()): let user = UserSettings.appUser
                        var userFlats = user?.flats
                        userFlats?.append(flat.id)
                        user?.flats = userFlats
                        self.updateUserInfo(user: user!) { (result) in
                            UserSettings.appUser = user
                            completion(result)
                            }
                        case .failure(let error): completion(.failure(error))
                        }
                    }
                    }
                case .failure(let error): completion(.failure(error))
                }
            }
        }
    }
    
    func createFlat(flat: FlatModel, completion: @escaping (_ result: Result<Void,Error>) -> ()) {
        let db = Firestore.firestore()
        do {
            try db.collection("flats").document().setData(from: flat)
            completion(.success(()))
        } catch let error {
            print("Error writing Flat to Firestore: \(error)")
            completion(.failure(error))
        }
    }
    
    func createComment(comment: Comment, completion: @escaping (_ result: Result<Void,Error>) -> ()) {
        let db = Firestore.firestore()
        do {
            try db.collection("comments").document().setData(from: comment)
            completion(.success(()))
        } catch let error {
            print("Error writing Flat to Firestore: \(error)")
            completion(.failure(error))
        }
    }
    func updateFlat(flat: FlatModel, completion: @escaping (_ result: Result<Void,Error>) -> ()) {
        
        let db = Firestore.firestore()
       
            try db.collection("flats").whereField("id", isEqualTo: flat.id as Any).getDocuments(completion: { (snapshot, error) in
                let document = snapshot?.documents.first
                let encoder = Firestore.Encoder()
                guard let updateData = try? encoder.encode(flat) else {
                    completion(.failure(MyError.unrecognizedError))
                    return
                }
                
                db.collection("flats").document(document!.documentID).updateData(updateData) { (error) in
                    error == nil ? completion(.success(())) : completion(.failure(error!))
                }
            })
        
    }

}

private extension FireBaseHelper {
    func getImageOfPersonByUrl() {
        
    }
    func uploadImageOfFlat(toFlat flatId: Int, image: UIImage, completion: @escaping (Result<URL,Error>) -> ()) {
        let ref = Storage.storage().reference().child("flats").child(String(flatId)).child(String(Date().timeIntervalSince1970))
        
        guard let data = image.jpegData(compressionQuality: 0.4) else { return }
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        ref.putData(data, metadata: metaData) { (metaData, error) in
            guard error == nil else {
                completion(.failure(error!))
                return
            }
            ref.downloadURL { (url, error) in
                guard let url = url else {
                    completion(.failure(error!))
                    return
                }
                completion(.success(url))
            }
        }
    }
    
    func uploadImageOfPerson(toPerson personId: String, image: UIImage, completion: @escaping (Result<URL,Error>) -> ()) {
        let ref = Storage.storage().reference().child("users").child(personId).child(String(Date().timeIntervalSince1970))
        
        guard let data = image.jpegData(compressionQuality: 0.4) else { return }
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        ref.putData(data, metadata: metaData) { (metaData, error) in
            guard error == nil else {
                completion(.failure(error!))
                return
            }
            ref.downloadURL { (url, error) in
                guard let url = url else {
                    completion(.failure(error!))
                    return
                }
                completion(.success(url))
            }
        }
    }
}
