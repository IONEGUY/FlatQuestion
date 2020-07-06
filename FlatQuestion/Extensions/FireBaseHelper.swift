//
//  FireBaseHelper.swift
//  FlatQuestion
//
//  Created by Андрей Олесов on 6/21/20.
//  Copyright © 2020 Андрей Олесов. All rights reserved.
//

import UIKit
import Foundation
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage

class FireBaseHelper {
    
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
                    let flat = FlatModel(name: name, additionalInfo: additionalInfo, allPlacesCount: allPlacesCount, emptyPlacesCount: emptyPlacesCount, date: date, id: id, images: urlStrings, x: x, y: y, address: address)
                    self.createFlat(flat: flat) { (result) in
                        completion(result)
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
}

private extension FireBaseHelper {
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
