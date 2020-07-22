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
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var aboutMeLabel: UILabel!
    @IBOutlet weak var instagramButton: UIView!
    @IBOutlet weak var vkButton: UIView!
    @IBOutlet weak var instagramNick: UILabel!
    @IBOutlet weak var vkNick: UILabel!
    @IBOutlet weak var commentsTableView: UITableView!
    @IBOutlet weak var partiesCollectionView: UICollectionView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    
    var imageView: UIImageView?
    var profileView: ProfileView?
    
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let y = -scrollView.contentOffset.y
        let height = max (y, 180)
        profileView?.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: height)
        if height == 180 {
            let gradientView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 300))
            gradientView.applyGradientV2(colours: [UIColor(hexString: "0x615CBF")!, UIColor(hexString: "0x1C2F4B")!])
                self.profileView?.profileView.image = UIImage(view: gradientView)
                self.profileView?.showSmallView()
            
        } else {
            guard let user = isYourAccount ? UserSettings.appUser : self.appUser else { return }
                self.profileView?.profileView.sd_setImage(with: URL(string: user.avatarUrl!), completed: nil)
                self.profileView?.hideSmallView()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        scrollView.contentInset = UIEdgeInsets(top: 300, left: 0, bottom: 0, right: 0)
        
        addTopProfileView()
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
    
    func addTopProfileView() {
        let profileView = ProfileView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 300))
        profileView.profileView.contentMode = .scaleAspectFill
        //profileView.profileView.clipsToBounds = true
        profileView.writeMessageButton.addCorner(with: 20, with: .black)
        view.addSubview(profileView)
        self.profileView = profileView
        profileView.delegate = self
        
        profileView.profileView.layer.cornerRadius = 15
        profileView.profileView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
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
        self.profileView?.writeMessageButton.setTitle(title, for: .normal)
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
        
        profileView!.profileView.sd_setImage(with: URL(string: user.avatarUrl!), completed: nil)
        profileView?.fullName.text = "\(user.firstName!) \(user.lastName!)"
        
        profileView?.genderAndYearsLabel.text = "\(user.sex! ? "Парень" : "Девушка"), \(getYearsFromDate(date: user.date?.date()))"
        profileView?.locationLabel.text = user.location
        aboutMeLabel.text = user.aboutMe
        instagramNick.text = user.instLink
        vkNick.text = user.vkLink
        
        profileView?.smallFullNameLabel.text = "\(user.firstName!) \(user.lastName!)"
        profileView?.smallGenderAndYearsLabel.text = "\(user.sex! ? "Парень" : "Девушка"), \(getYearsFromDate(date: user.date?.date()))"
        profileView?.smallLocationLabel.text = user.location
        profileView?.smallProfileView.sd_setImage(with: URL(string: user.avatarUrl!), completed: nil)
        
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
    
    func showEditFlatVC(flat: FlatModel) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "CreateFlatViewController") as! CreateFlatViewController
        vc.modalPresentationStyle = .overFullScreen
        vc.delegate = self
        vc.isEditingFlat = true
        vc.existedFlatModel = flat
        self.present(vc, animated: true, completion: nil)
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
        !isYourAccount ? addModalFlatView(flat: self.flats[indexPath.item]) : showEditFlatVC(flat: self.flats[indexPath.row])
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

extension ProfileViewController: ProfileViewProtocol {
    func didButtonPressed() {
        isYourAccount ? showEditProfileScreen() : writeMessage()
    }
    
    private func showEditProfileScreen() {
        let vc = EditProfileViewController(nibName: "EditProfileViewController", bundle: nil)
        vc.isEditingProfile = true
        vc.delegate = self
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    private func writeMessage() {
        // TODO: go to CHAT
    }
}

extension ProfileViewController: EditProfileViewControllerProtocol {
    func successEditingProfile() {
        setupData()
        
        partiesCollectionView.delegate = self
        partiesCollectionView.dataSource = self
        commentsTableView.reloadData()
        
        self.collectionViewHeightConstraint.constant = 0
        self.view.layoutIfNeeded()
    }
}

extension ProfileViewController: CreateFlatProtocol {
    func flatWasCreated() {
        setupData()
        
        partiesCollectionView.delegate = self
        partiesCollectionView.dataSource = self
        commentsTableView.reloadData()
        
        self.collectionViewHeightConstraint.constant = 0
        self.view.layoutIfNeeded()
    }
}
