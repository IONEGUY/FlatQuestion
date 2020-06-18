//
//  ActivityIndicatorHelper.swift
//  FlatQuestion
//
//  Created by MacBook on 6/10/20.
//  Copyright © 2020 Андрей Олесов. All rights reserved.
//

import UIKit
import JGProgressHUD

class ActivityIndicatorHelper {
    private static var hud: JGProgressHUD = JGProgressHUD(style: .dark)
    
    public static func show(in view: UIView, textLabel: String? = nil) {
        hud.textLabel.text = textLabel
        hud.show(in: view)
    }
    
    public static func dismiss() {
        hud.dismiss()
    }
}
