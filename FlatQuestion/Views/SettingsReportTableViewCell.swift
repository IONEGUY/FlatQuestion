//
//  SettingsReportTableViewCell.swift
//  FlatQuestion
//
//  Created by Андрей Олесов on 8/2/20.
//  Copyright © 2020 Андрей Олесов. All rights reserved.
//

import UIKit

class SettingsReportTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension SettingsReportTableViewCell: ReuseIdentifierProtocol {
    static var identifier: String {
        return "SettingsReportTableViewCell"
    }
}
