//
//  DecodeHelper.swift
//  FlatQuestion
//
//  Created by MacBook on 6/18/20.
//  Copyright © 2020 Андрей Олесов. All rights reserved.
//

import UIKit

class DecodeHelper {
    static func decodeFromDictionary<T: Codable>(dictionary: [String: Any], type: T.Type) -> T {
        return try! JSONDecoder().decode(type, from: JSONSerialization.data(withJSONObject: dictionary))
    }
}
