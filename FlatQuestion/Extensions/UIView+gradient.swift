//
//  UIView+gradient.swift
//  FlatQuestion
//
//  Created by Андрей Олесов on 6/12/20.
//  Copyright © 2020 Андрей Олесов. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    @discardableResult
    func applyGradientV2(colours: [UIColor]) -> CAGradientLayer {
        return self.applyGradientV2(colours: colours, locations: nil)
    }

    @discardableResult
    func applyGradientV2(colours: [UIColor], locations: [NSNumber]?) -> CAGradientLayer {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = colours.map { $0.cgColor }
        gradient.locations = locations
        self.layer.insertSublayer(gradient, at: 0)
        return gradient
    }
}