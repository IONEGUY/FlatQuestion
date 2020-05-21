//
//  Flat.swift
//  FlatQuestion
//
//  Created by Андрей Олесов on 5/14/20.
//  Copyright © 2020 Андрей Олесов. All rights reserved.
//

import Foundation

struct Flat {
    var title: String
    var address: String
    var numberOfPersons: Int
    var dateToCome: String
    var arrayWithDescription: [FlatDescription]
}

struct FlatDescription {
    var name: String
    var description: String
}
