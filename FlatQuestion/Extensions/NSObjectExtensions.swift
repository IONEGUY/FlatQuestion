//
//  NSObjectExtensions.swift
//  FlatQuestion
//
//  Created by MacBook on 7/17/20.
//  Copyright © 2020 Андрей Олесов. All rights reserved.
//

import Foundation

extension NSObject {
    static var typeName: String {
        return String(describing: self)
    }
}
