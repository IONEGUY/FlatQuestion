//
//  UIView+CornerShadow.swift
//  FlatQuestion
//
//  Created by Андрей Олесов on 6/12/20.
//  Copyright © 2020 Андрей Олесов. All rights reserved.
//

import Foundation

import UIKit

extension UIView {
    
    func removeCorner() {
        guard let sublayers = layer.sublayers else {return}
        if sublayers.count > 2 {
            let sublayer = layer.sublayers![0]
            sublayer.removeFromSuperlayer()
        }
    }
    
    func addCorner(with radius: CGFloat, with shadowColor: UIColor){

        //removeCorner()
//                    let shadowLayer = CAShapeLayer()
//        shadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: 12).cgPath
//        shadowLayer.fillColor = UIColor.white.cgColor
//
//        shadowLayer.shadowColor = UIColor.darkGray.cgColor
//        shadowLayer.shadowPath = shadowLayer.path
//        shadowLayer.shadowOffset = CGSize(width: 2.0, height: 2.0)
//        shadowLayer.shadowOpacity = 0.3
//        shadowLayer.shadowRadius = 30
//
//        layer.insertSublayer(shadowLayer, at: 0)
        
        setupShadow(shadowColor, cornerRadius: radius)
    }
    
    func setupShadow(_ color: UIColor = UIColor.gray, cornerRadius: CGFloat) {
        self.layer.cornerRadius = cornerRadius
        self.addShadow(shadowColor: color.cgColor,
                         shadowOffset: CGSize(width: 0, height: 10),
                         shadowOpacity: 0.2,
                         shadowRadius: 10.0)
    }

}
