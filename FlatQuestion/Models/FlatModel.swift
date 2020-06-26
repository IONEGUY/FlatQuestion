//
//  FlatModel.swift
//  FlatQuestion
//
//  Created by Андрей Олесов on 6/22/20.
//  Copyright © 2020 Андрей Олесов. All rights reserved.
//

import Foundation
import Firebase

public struct FlatModel: Codable {

    let name: String
    let additionalInfo: String?
    let allPlacesCount: Int?
    let emptyPlacesCount: Int?
    let date: Date?
    let id: Int
    var images: [String]?
    let x: Double
    let y: Double
    let address: String
    
    enum CodingKeys: CodingKey {
        case name
        case additionalInfo
        case allPlacesCount
        case emptyPlacesCount
        case date
        case id
        case images
        case x
        case y
        case address
    }
}
