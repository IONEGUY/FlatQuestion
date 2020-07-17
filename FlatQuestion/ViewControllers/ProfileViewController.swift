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
    
    @IBAction func appCommentButtonPressed() {
    }
    
    private let commentsTableViewRowSpacing: CGFloat = 15
    private var flats = [Flat]()
    private var comments = [Comment]()
    private var flatModalVC: FlatModalViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        writeMessageButton.applyShadow()
        userAvatar.layer.cornerRadius = 15
        userAvatar.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
        setupMockData()
        
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
        self.view.layoutIfNeeded()
    }
    
    private func addModalFlatView(flat: Flat) {
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
    
     private func setupMockData() {
         self.flats.append(Flat(title: "Party name here",
                                address: "st. Ulyanovskaya 8", numberOfPersons: 12, dateToCome: "Tomorrow",
                                arrayWithDescription:
             [FlatDescription(name: "Description", description: "Best party ever just click to button"),
              FlatDescription(name: "Информация", description: "Всем привет)) Если вам скучно и не знсебя заайте - потусим вместе)) мы компания из 4 человек ждем адекватных, веселых девчонок))")]))
         self.flats.append(Flat(title: "Party name here",
                            address: "st. Ulyanovskaya 8 sdsffsfsdfsf", numberOfPersons: 12, dateToCome: "Tomorrow",
                            arrayWithDescription:
         [FlatDescription(name: "Description", description: "Best party ever i seen. If u want to join us, just click to button"),
          FlatDescription(name: "Information", description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore e.")]))
         self.flats.append(Flat(title: "Party name here",
                                address: "st. Ulyanovskaya 8", numberOfPersons: 12, dateToCome: "Tomorrow",
                                arrayWithDescription:
             [FlatDescription(name: "Description", description: "Best party ever i seen. If u want to join us, just click to button"),
              FlatDescription(name: "Information", description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore e.Lorem ipsum dolor sit amet")]))
         self.flats.append(Flat(title: "Party name here",
                            address: "st. Ulyanovskaya 8", numberOfPersons: 12, dateToCome: "Tomorrow",
                            arrayWithDescription:
         [FlatDescription(name: "Description", description: "Best party ever i seen. If u want to join us, just click to button"),
          FlatDescription(name: "Information", description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore e.")]))
        
        userAvatar.sd_setImage(with: URL(string: "https://avatars.mds.yandex.net/get-zen_doc/30884/pub_5d5221ff1ee34f00ac7e6a14_5d524bb8ae56cc00ac1b5953/scale_1200"), completed: nil)
        fullName.text = "Константин Константинопольский"
        genderAndYearsLabel.text = "Парень, 24 года"
        locationLabel.text = "Минск"
        aboutMeLabel.text = "Всем привет) Меня зовут Костя. Я люблю вечеринки, активный отдых и электронную музыку. В свободное время пишу музыку и тусуюсь с друзьями."
        instagramNick.text = "crazy_bee"
        vkNick.text = "constantino"
        
        self.comments.append(Comment(text: "Адекватный парень, вечеринка прошла круто)",
                                     createdAt: Date(), rate: Rate.Five, creatorName: "Полина Иванченко"))
        self.comments.append(Comment(text: "Было много людей, мне ваще не зашло",
                                     createdAt: Date(), rate: Rate.Two, creatorName: "Игорь Ивановский"))
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
        addModalFlatView(flat: self.flats[indexPath.item])
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
