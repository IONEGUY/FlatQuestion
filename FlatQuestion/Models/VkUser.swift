//
//  VkUser.swift
//  FlatQuestion
//
//  Created by MacBook on 5/26/20.
//  Copyright © 2020 Андрей Олесов. All rights reserved.
//

import UIKit

struct VkUser: Decodable {
    var firstName: String
    var lastName: String
    
    private enum RootKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: RootKeys.self)
        self.firstName = try container.decode(String.self, forKey: .firstName)
        self.lastName = try container.decode(String.self, forKey: .lastName)
    }
}
