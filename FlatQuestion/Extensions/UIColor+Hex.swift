//
//  UIColor+Hex.swift
//  FlatQuestion
//
//  Created by Андрей Олесов on 6/12/20.
//  Copyright © 2020 Андрей Олесов. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    convenience init(hex: UInt) {
        let red   = CGFloat((hex >> 16) & 0xff) / 255
        let green = CGFloat((hex >> 08) & 0xff) / 255
        let blue  = CGFloat((hex >> 00) & 0xff) / 255
        
        self.init(red: red, green: green, blue: blue, alpha: 1)
    }
    
    convenience init(hexWithAlpha: UInt) {
        let red   = CGFloat((hexWithAlpha & 0xff000000) >> 24) / 255
        let green = CGFloat((hexWithAlpha & 0x00ff0000) >> 16) / 255
        let blue  = CGFloat((hexWithAlpha & 0x0000ff00) >> 8) / 255
        let alpha = CGFloat(hexWithAlpha & 0x000000ff) / 255
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    convenience init?(hexString: String?) {
        guard let hexString = hexString else {
            return nil
        }
        
        let hex: UInt
        if hexString.count == 8 { // Normal - "0xRRGGBB"
            hex = UInt(String(hexString.suffix(6)), radix: 16) ?? 0
            self.init(hex: hex)
        }
        else if hexString.count == 10 { // With Alpha - "0xRRGGBBAA"
            hex = UInt(String(hexString.suffix(8)), radix: 16) ?? 0
            self.init(hexWithAlpha: hex)
        } else {
            return nil
        }
    }
}
