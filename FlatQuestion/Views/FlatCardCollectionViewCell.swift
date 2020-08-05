//
//  FlatCardCollectionViewCell.swift
//  FlatQuestion
//
//  Created by Андрей Олесов on 5/14/20.
//  Copyright © 2020 Андрей Олесов. All rights reserved.
//

import UIKit
import SDWebImage
class FlatCardCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var placesLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func fillCellData(with flat: FlatModel) {
        self.titleLabel.text = flat.name
        setupViewOfAddressLabel(address: flat.address)
        dateLabel.text = DateFormatterHelper().getStringFromDate_MMM_yyyy_HH_mm(date: flat.date?.date() ?? Date())
        placesLabel.text = "Свободно".localized + " \(String(describing: flat.emptyPlacesCount!)) " + "из".localized + " \(String(describing: flat.allPlacesCount!))"
        guard let url = URL(string: (flat.images?[0])!) else {return}
        imageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
        imageView.sd_setImage(with: url, completed: nil)
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
