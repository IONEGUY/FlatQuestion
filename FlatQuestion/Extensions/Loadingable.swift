//
//  Loadingable.swift
//  FlatQuestion
//
//  Created by Андрей Олесов on 6/24/20.
//  Copyright © 2020 Андрей Олесов. All rights reserved.
//

import Foundation
import UIKit

protocol Loadingable {
    func showLoadingIndicator()
    func hideLoadingableIndicator()
}

extension UIViewController: Loadingable {
    
    func showLoadingIndicator() {
        LoadingUtils.showActivityIndicator(view: view, targetVC: self)
    }
    
    func hideLoadingableIndicator() {
        LoadingUtils.hideActivityIndicator(view: view)
    }
    
}
