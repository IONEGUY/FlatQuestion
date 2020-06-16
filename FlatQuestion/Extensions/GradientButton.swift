//
//  GradientButton.swift
//  FlatQuestion
//
//  Created by Андрей Олесов on 6/12/20.
//  Copyright © 2020 Андрей Олесов. All rights reserved.
//

import Foundation
import UIKit

class GradientButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButtonView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButtonView()
    }
}

private extension GradientButton {

    private func setupButtonView() {
        applyGradientV2(colours: [UIColor(hexString: "0x615CBF")!, UIColor(hexString: "0x1C2F4B")!])
        titleLabel?.font = UIFont(name: "SFProDisplay-Regular", size: 16)
        layer.cornerRadius = 20
        clipsToBounds = true
    }
}
