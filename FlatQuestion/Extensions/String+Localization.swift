//
//  String+Localization.swift
//  FlatQuestion
//
//  Created by Андрей Олесов on 7/8/20.
//  Copyright © 2020 Андрей Олесов. All rights reserved.
//

import Foundation

extension String {
    var localized: String {
        get{
            return NSLocalizedString(self, comment: "")
        }
    }
}
