//
//  FlatRequestModel.swift
//  FlatQuestion
//
//  Created by Андрей Олесов on 7/16/20.
//  Copyright © 2020 Андрей Олесов. All rights reserved.
//

import Foundation

struct FlatRequestModel: Codable {
    let id: Int
    var requests: [UserInfo]
    var ownerId: String
    
    var asDictionary : [String:Any] {
      let mirror = Mirror(reflecting: self)
      let dict = Dictionary(uniqueKeysWithValues: mirror.children.lazy.map({ (label:String?, value:Any) -> (String, Any)? in
        guard let label = label else { return nil }
        return (label, value)
      }).compactMap { $0 })
      return dict
    }
}

struct UserInfo: Codable {
    let id: String
    var status: RequestStatus
    let message: String
    let fullName: String
    let photoLink: String
}
