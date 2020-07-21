//
//  ProfileView.swift
//  FlatQuestion
//
//  Created by Андрей Олесов on 7/21/20.
//  Copyright © 2020 Андрей Олесов. All rights reserved.
//

import Foundation
import UIKit

protocol ProfileViewProtocol: AnyObject {
    func didButtonPressed()
}

class ProfileView: UIView {
    @IBOutlet weak var profileView: UIImageView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var genderAndYearsLabel: UILabel!
    @IBOutlet weak var fullName: UILabel!
    @IBOutlet weak var writeMessageButton: UIButton!
    
    @IBOutlet weak var smallView: UIView!
    @IBOutlet weak var smallFullNameLabel: UILabel!
    @IBOutlet weak var smallGenderAndYearsLabel: UILabel!
    @IBOutlet weak var smallLocationLabel: UILabel!
    @IBOutlet weak var smallProfileView: UIImageView!
    @IBOutlet weak var locationView: UIView!
    
    weak var delegate: ProfileViewProtocol?
    
    var isSmallView = false
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    private func loadFromNib() {
        let bundle = Bundle.init(for: type(of: self))
        let nib = UINib(nibName: "ProfileView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as? UIView
        view!.frame = bounds
        view!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view!)
    }
    
    private func setupView() {
        loadFromNib()
    }
    
    @IBAction func buttonDidPressed(_ sender: Any) {
        delegate?.didButtonPressed()
    }
    
    func showSmallView() {
        guard !isSmallView else { return }
        self.smallView.isHidden = false
        self.locationView.isHidden = true
        self.genderAndYearsLabel.isHidden = true
        self.fullName.isHidden = true
        self.isSmallView = true
        self.layoutSubviews()
        
    }
    
    func hideSmallView() {
        guard isSmallView else { return }
        
        self.smallView.isHidden = true
        self.locationView.isHidden = false
        self.genderAndYearsLabel.isHidden = false
        self.fullName.isHidden = false
        self.isSmallView = false
        self.layoutSubviews()
        
    }
}
