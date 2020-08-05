//
//  Initializable.swift
//  FlatQuestion
//
//  Created by MacBook on 7/29/20.
//  Copyright © 2020 Андрей Олесов. All rights reserved.
//

import Foundation

protocol Initializable {
    func initialize<T>(withData data: T)
}
