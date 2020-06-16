//
//  FlatDescriptionTableViewCell.swift
//  FlatQuestion
//
//  Created by Андрей Олесов on 5/21/20.
//  Copyright © 2020 Андрей Олесов. All rights reserved.
//

import UIKit

class FlatDescriptionTableViewCell: UITableViewCell {

    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setupTitle(title: String, description: String) {
        self.titleLabel.text = title
        self.descriptionLabel.text = description
    }
}

extension FlatDescriptionTableViewCell: ReuseIdentifierProtocol {
    static var identifier: String {
        return String(describing: self)
    }
}
