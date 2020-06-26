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
        let shadowLayer = CAShapeLayer()
        shadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: radius).cgPath
        shadowLayer.fillColor = UIColor.white.cgColor

        shadowLayer.shadowColor = shadowColor.cgColor
        shadowLayer.shadowPath = shadowLayer.path
        shadowLayer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        shadowLayer.shadowOpacity = 0.2

        shadowLayer.shadowRadius = 15

        
        layer.insertSublayer(shadowLayer, at: 0)
        

    }

}
