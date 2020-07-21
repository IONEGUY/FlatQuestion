//
//  ProfileViewController.swift
//  FlatQuestion
//
//  Created by MacBook on 6/28/20.
//  Copyright © 2020 Андрей Олесов. All rights reserved.
//

import UIKit
import SDWebImage

class ProfileViewController: UIViewController {
    @IBOutlet weak var userAvatar: UIImageView!
    @IBOutlet weak var writeMessageButton: UIButton!
    @IBOutlet weak var aboutMeLabel: UILabel!
    @IBOutlet weak var instagramButton: UIView!
    @IBOutlet weak var vkButton: UIView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var genderAndYearsLabel: UILabel!
    @IBOutlet weak var fullName: UILabel!
    @IBOutlet weak var instagramNick: UILabel!
    @IBOutlet weak var vkNick: UILabel!
    @IBOutlet weak var commentsTableView: UITableView!
    @IBOutlet weak var partiesCollectionView: UICollectionView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    
    var isYourAccount = true
    var appUser: AppUser?
    
    @IBAction func appCommentButtonPressed() {
        
    }
    
    @IBAction func logOutPressed() {
        UserSettings.clearAppUser()
        navigateToLoginVC()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        tableViewHeightConstraint.constant = commentsTableView.contentSize.height
    }
    
    private let commentsTableViewRowSpacing: CGFloat = 15
    private var flats = [FlatModel]()
    private var comments = [Comment]()
    private var flatModalVC: FlatModalViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        writeMessageButton.applyShadow()
        userAvatar.layer.cornerRadius = 15
        userAvatar.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]

        setupData()

        partiesCollectionView.register(UINib(nibName: FlatCardCollectionViewCell.typeName, bundle: nil),
            forCellWithReuseIdentifier: FlatCardCollectionViewCell.typeName)
        partiesCollectionView.delegate = self
        partiesCollectionView.dataSource = self

        commentsTableView.register(UINib(nibName: CommentTableViewCell.typeName, bundle: nil), forCellReuseIdentifier: CommentTableViewCell.typeName)
        commentsTableView.autoresizesSubviews = true
        commentsTableView.separatorStyle = .none
        commentsTableView.delegate = self
        commentsTableView.dataSource = self
        commentsTableView.reloadData()
        
        self.collectionViewHeightConstraint.constant = 0
        self.view.layoutIfNeeded()
    }
    
    private func addModalFlatView(flat: FlatModel) {
        flatModalVC = FlatModalViewController(nibName: "FlatModalViewController", bundle: nil)
        flatModalVC.flat = flat
        flatModalVC.delegate = self
        self.addChild(flatModalVC)
        self.view.addSubview(flatModalVC.view)
        flatModalVC.didMove(toParent: self)
        let height = view.frame.height
        let width  = view.frame.width
        flatModalVC.view.frame = CGRect(x: 0, y: view.frame.maxY, width: width, height: height)
    }
    
    private func setupData() {
        
        guard let user = isYourAccount ? UserSettings.appUser : self.appUser else { return }
        let title = !isYourAccount ? "Написать сообщение" : "Редактировать профиль"
        writeMessageButton.setTitle(title, for: .normal)
        FireBaseHelper().getFlatsById(userId: (user.id!)) { (flats) in
            self.flats = flats
            UIView.animate(withDuration: 1) {
                self.collectionViewHeightConstraint.constant = self.flats.count > 0 ? 115 : 0
            }
            DispatchQueue.main.async {
                self.partiesCollectionView.reloadData()
                self.view.layoutIfNeeded()
            }
        }
        
        
        userAvatar.sd_setImage(with: URL(string: user.avatarUrl!), completed: nil)
        fullName.text = "\(user.firstName!) \(user.lastName!)"
        
        
        
        genderAndYearsLabel.text = "\(user.sex! ? "Парень" : "Девушка"), \(getYearsFromDate(date: user.date?.date()))"
        
        locationLabel.text = user.location
        aboutMeLabel.text = user.aboutMe
        instagramNick.text = user.instLink
        vkNick.text = user.vkLink
        
        self.comments.append(Comment(text: "Адекватный парень, вечеринка прошла круто)",
                                     createdAt: Date(), rate: Rate.Five, creatorName: "Полина Иванченко"))
        self.comments.append(Comment(text: "Было много людей, мне ваще не зашло",
                                     createdAt: Date(), rate: Rate.Two, creatorName: "Игорь Ивановский"))

     }
    
    func getYearsFromDate(date: Date?) -> String{
        guard let date = date else { return ""}
        let calanderDate = Calendar.current.dateComponents([.day, .year, .month], from: date)
        let currentCalanderDate = Calendar.current.dateComponents([.day, .year, .month], from: Date())
        let years: Int = currentCalanderDate.year! - calanderDate.year!
        return String(years)
    }
    
    func showEditFlatVC() {
        
    }

}


extension ProfileViewController: UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.flats.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        !isYourAccount ? addModalFlatView(flat: self.flats[indexPath.item]) : showEditFlatVC()
    }
}

extension ProfileViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let flatCell = self.partiesCollectionView?
            .dequeueReusableCell(withReuseIdentifier: FlatCardCollectionViewCell.self.identifier,
                                                                for: indexPath) as? FlatCardCollectionViewCell
        guard let cell = flatCell else {return UICollectionViewCell()}
        cell.heightAnchor.constraint(equalToConstant: 115).isActive = true
        cell.widthAnchor.constraint(equalToConstant: 283).isActive = true
        cell.clipsToBounds = false
        cell.applyShadow(shadowOffsetHeight: 0)
        cell.fillCellData(with: self.flats[indexPath.item])
        return cell
    }
}

extension ProfileViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.commentsTableView
            .dequeueReusableCell(withIdentifier: CommentTableViewCell.typeName,
                                 for: indexPath) as! CommentTableViewCell
        cell.bottonSpacing.constant = commentsTableViewRowSpacing
        cell.fillData(self.comments[indexPath.item])
        return cell
    }
}

extension ProfileViewController: UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}

extension ProfileViewController: RemovableDelegate {
    func shouldRemoveFromSuperView() {
        flatModalVC.willMove(toParent: nil)
        flatModalVC.view.removeFromSuperview()
        flatModalVC.removeFromParent()
    }
}
