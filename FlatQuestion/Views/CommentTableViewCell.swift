//
//  CommentTableViewCell.swift
//  FlatQuestion
//
//  Created by MacBook on 7/16/20.
//  Copyright © 2020 Андрей Олесов. All rights reserved.
//

import UIKit

class CommentTableViewCell: UITableViewCell {
    @IBOutlet weak var fullName: UILabel!
    @IBOutlet weak var createdAt: UILabel!
    @IBOutlet weak var commentText: UILabel!
    @IBOutlet weak var rateView: UIView!
    @IBOutlet weak var bottonSpacing: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    public func fillData(_ comment: Comment?) {
        fullName.text = comment?.creatorName ?? String.empty
        commentText.text = comment?.text
        setDate(comment?.createdAt ?? Date())
        setRate(comment?.rate ?? Rate.None)
    }
    
    private func setRate(_ rate: Rate) {
        let stars = rateView.subviews;
        for index in (Rate.One.rawValue...rate.rawValue) {
            (stars[Rate.Five.rawValue - index] as? UIImageView)?.tintColor = UIColor.init(hex: "#EAAB09")
        }
    }
    
    private func setDate(_ date: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        createdAt.text = dateFormatter.string(from: date)
    }
}