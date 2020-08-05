//
//  DateTimeConverterHelper.swift
//  FlatQuestion
//
//  Created by MacBook on 7/28/20.
//  Copyright © 2020 Андрей Олесов. All rights reserved.
//

import Foundation

class DateTimeConverterHelper {
    class func convert(date: Date, toFormat format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: date)
    }
}
