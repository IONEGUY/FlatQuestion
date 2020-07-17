//
//  TimeIntervalExtension.swift
//  FlatQuestion
//
//  Created by Андрей Олесов on 7/7/20.
//  Copyright © 2020 Андрей Олесов. All rights reserved.
//

import Foundation

extension TimeInterval {
    func date() -> Date {
        return Date(timeIntervalSince1970: self)
    }
}
