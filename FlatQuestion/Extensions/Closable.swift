//
//  Closable.swift
//  FlatQuestion
//
//  Created by Андрей Олесов on 6/24/20.
//  Copyright © 2020 Андрей Олесов. All rights reserved.
//

import Foundation
import UIKit
protocol Closable {
    func close()
}

extension UIViewController: Closable {
    func close() {
        self.dismiss(animated: true, completion: nil)
    }
}
