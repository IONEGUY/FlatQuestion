//
//  TopMapFilterCollectionViewCell.swift
//  FlatQuestion
//
//  Created by Андрей Олесов on 5/28/20.
//  Copyright © 2020 Андрей Олесов. All rights reserved.
//

import UIKit

class TopMapFilterCollectionViewCell: UICollectionViewCell {

    @IBOutlet private weak var titleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setupCell(with title:String) {
        self.titleLabel.text = title
    }
}

extension TopMapFilterCollectionViewCell: ReuseIdentifierProtocol {
    static var identifier: String {
        return String(describing: self)
    }
}
