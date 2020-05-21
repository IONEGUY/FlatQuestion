//
//  FlatCardCollectionViewCell.swift
//  FlatQuestion
//
//  Created by Андрей Олесов on 5/14/20.
//  Copyright © 2020 Андрей Олесов. All rights reserved.
//

import UIKit

class FlatCardCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var numberOfPersonsLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func fillCellData(with flat: Flat) {
        self.addressLabel.text = flat.address
        self.numberOfPersonsLabel.text = String(flat.numberOfPersons)
        self.titleLabel.text = flat.title
        self.dateLabel.text = flat.dateToCome
    }
}

extension FlatCardCollectionViewCell: ReuseIdentifierProtocol {
    static var identifier: String {
        return String(describing: self)
    }
}
