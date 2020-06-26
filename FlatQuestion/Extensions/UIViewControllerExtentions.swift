//
//  UIViewControllerExtentions.swift
//  FlatQuestion
//
//  Created by Андрей Олесов on 6/25/20.
//  Copyright © 2020 Андрей Олесов. All rights reserved.
//

import Foundation
import UIKit
extension UIViewController {
    func topMostViewController() -> UIViewController {
        
//        if let presented = self.presentedViewController {
//            return presented.topMostViewController()
//        }
//        
//        if let navigation = self as? UINavigationController {
//            return navigation.visibleViewController?.topMostViewController() ?? navigation
//        }
        
        if let tab = self as? UITabBarController {
            return tab.selectedViewController?.topMostViewController() ?? tab
        }
        
        return self
    }
}
