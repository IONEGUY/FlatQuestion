//
//  UIViewExtensions.swift
//  FlatQuestion
//
//  Created by MacBook on 5/30/20.
//  Copyright © 2020 Андрей Олесов. All rights reserved.
//

import UIKit

extension UIView {
    func addShadow(shadowColor: CGColor, shadowOffset: CGSize, shadowOpacity: Float, shadowRadius: CGFloat) {
        layer.shadowColor = shadowColor
        layer.shadowOffset = shadowOffset
        layer.shadowOpacity = shadowOpacity
        layer.shadowRadius = shadowRadius
    }
    
    func applyGradient(colours: [UIColor]) {
        self.applyGradient(colours: colours, locations: nil)
    }

    func applyGradient(colours: [UIColor], locations: [NSNumber]?) {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = colours.map { $0.cgColor }
        gradient.locations = locations
        gradient.cornerRadius = 20
        layer.insertSublayer(gradient, at: 0)
    }
}
