//
//  AppUser.swift
//  FlatQuestion
//
//  Created by MacBook on 5/26/20.
//  Copyright © 2020 Андрей Олесов. All rights reserved.
//

import UIKit

class AppUser: NSObject, NSCoding, Codable {
    func encode(with coder: NSCoder) {
        coder.encode(id, forKey: "id")
        coder.encode(firstName, forKey: "firstName")
        coder.encode(lastName, forKey: "lastName")
        coder.encode(email, forKey: "email")
        coder.encode(avatarUrl, forKey: "avatarUrl")
    }
    
    required init?(coder: NSCoder) {
        id = coder.decodeObject(forKey: "id") as? String ?? ""
        firstName = coder.decodeObject(forKey: "firstName") as? String ?? ""
        lastName = coder.decodeObject(forKey: "lastName") as? String ?? ""
        email = coder.decodeObject(forKey: "email") as? String ?? ""
        avatarUrl = coder.decodeObject(forKey: "avatarUrl") as? String ?? ""
    }
    
    init(id: String?, firstName: String?, lastName: String?, email: String?, avatarUrl: String?) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.avatarUrl = avatarUrl
    }
    
    var id: String?
    var firstName: String?
    var lastName: String?
    var email: String?
    var avatarUrl: String?
}
