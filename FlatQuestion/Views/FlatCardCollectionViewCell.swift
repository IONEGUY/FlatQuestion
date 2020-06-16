//
//  FlatCardCollectionViewCell.swift
//  FlatQuestion
//
//  Created by Андрей Олесов on 5/14/20.
//  Copyright © 2020 Андрей Олесов. All rights reserved.
//

import UIKit

class FlatCardCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func fillCellData(with flat: Flat) {
        self.titleLabel.text = flat.title
        setupViewOfAddressLabel(address: flat.address)
    }
}

//MARK: Private methods
extension FlatCardCollectionViewCell {
    private func setupViewOfAddressLabel(address: String) {
        let attributedString = NSMutableAttributedString(string: address)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 0
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
        addressLabel.attributedText = attributedString
    }
}

extension FlatCardCollectionViewCell: ReuseIdentifierProtocol {
    static var identifier: String {
        return String(describing: self)
    }
}
