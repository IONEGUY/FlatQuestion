//
//  FlatPhotoCollectionViewCell.swift
//  FlatQuestion
//
//  Created by Андрей Олесов on 5/19/20.
//  Copyright © 2020 Андрей Олесов. All rights reserved.
//

import UIKit

class FlatPhotoCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var image: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}

extension FlatPhotoCollectionViewCell: ReuseIdentifierProtocol {
    static var identifier: String {
        return String(describing: self)
    }
}
