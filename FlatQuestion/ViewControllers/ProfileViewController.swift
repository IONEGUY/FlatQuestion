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
    @IBOutlet weak var imInSocialLabel: UILabel!
    @IBOutlet weak var myFlatsLabel: UILabel!
    @IBOutlet weak var commentsLabel: UILabel!
    @IBOutlet weak var addCommentButton: UIButton!
    @IBOutlet weak var aboutMeLabelDescription: UILabel!
    
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    
   
    
    var imageView: UIImageView?
    var profileView: ProfileView?
    var isYourAccount = true
    var appUser: AppUser?
    
    private let commentsTableViewRowSpacing: CGFloat = 15
    private var flats = [FlatModel]()
    private var comments = [Comment]()
    private var flatModalVC: FlatModalViewController!
    
    func localize() {
        aboutMeLabel.text = "Обо мне:".localized
        imInSocialLabel.text = "Я в социальных сетях:".localized
        myFlatsLabel.text = "Мои вечеринки:".localized
        commentsLabel.text = "Отзывы обо мне:".localized
        addCommentButton.setTitle("+ Добавить отзыв", for: .normal)
        
    }
    
    @IBAction func appCommentButtonPressed() {
        let vc = RatingViewController(delegate: self, user: appUser!)
        vc.transitioningDelegate = self
        present(vc, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.navigationBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.navigationController?.navigationBar.isHidden = false
    }

    @IBAction func logOutPressed() {
        let userId = UserSettings.appUser?.id
        DispatchQueue.global(qos: .userInitiated).async {
            FireBaseHelper().updateFCMToken(fcmTokenGroup: FCMTokenGroup(userId: (userId)!, fcmToken: "")) { (result) in
                print("Fcm Token Updated")
            }
        }
        UserSettings.clearAppUser()
        navigateToLoginVC()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        tableViewHeightConstraint.constant = commentsTableView.contentSize.height
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let y = -scrollView.contentOffset.y
        let height = max (y, 180)
        profileView?.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: height)
        profileView?.settingsButton.isHidden = !isYourAccount
        if height == 180 {
            let colorView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 300))
            colorView.backgroundColor = UIColor(hex: 0x191D29)
                self.profileView?.profileView.image = UIImage(view: colorView)
                self.profileView?.showSmallView()
            
        } else {
            guard let user = isYourAccount ? UserSettings.appUser : self.appUser else { return }
            self.profileView?.profileView.sd_imageIndicator = SDWebImageActivityIndicator.gray
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
        localize()
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
        //profileView.writeMessageButton.addCorner(with: 20, with: .black)
        view.addSubview(profileView)
        self.profileView = profileView
        profileView.delegate = self
        
        profileView.profileView.layer.cornerRadius = 15
        profileView.profileView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    }
    
    private func addModalFlatView(flat: FlatModel) {
        flatModalVC = FlatModalViewController(nibName: "FlatModalViewController", bundle: nil)
        flatModalVC.isProfileHidden = true
        flatModalVC.flat = flat
        flatModalVC.delegate = self
        self.addChild(flatModalVC)
        self.view.addSubview(flatModalVC.view)
        flatModalVC.didMove(toParent: self)
        let height = view.frame.height
        let width  = view.frame.width
        flatModalVC.view.frame = CGRect(x: 0, y: view.frame.maxY, width: width, height: height)
    }
    
    func getComments() {
        DispatchQueue.global(qos: .userInteractive).async {
            FireBaseHelper().getComments(userId: (self.appUser?.id ?? UserSettings.appUser?.id)!) { (comments) in
                self.comments = comments
                self.comments.sort { (comment1, comment2) -> Bool in
                    return comment1.createdAt > comment2.createdAt
                }
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.1) {
                        self.commentsTableView.reloadData()
                        self.updateViewConstraints()
                        self.view.layoutIfNeeded()
                        self.tableViewHeightConstraint.constant = self.commentsTableView.contentSize.height
                        self.view.layoutIfNeeded()
                    }
                }
            }
        }
    }
     func setupData() {
        
        if UserSettings.appUser == nil {
            navigateToLoginVC()
        }
        guard let user = isYourAccount ? UserSettings.appUser : self.appUser else { return }
        let title = !isYourAccount ? "Написать сообщение".localized : "Редактировать профиль".localized
        if isYourAccount { addCommentButton.isHidden = true}
        self.profileView?.writeMessageButton.setTitle(title, for: .normal)
        DispatchQueue.global(qos: .userInteractive).async {
            FireBaseHelper().getFlatsById(userId: (user.id!)) { (flats) in
                
                self.flats = flats
                
                DispatchQueue.main.async {
                     self.partiesCollectionView.alpha = 0
                    UIView.animate(withDuration: 0.5) {
                        self.collectionViewHeightConstraint.constant = self.flats.count > 0 ? 115 : 0
                        self.partiesCollectionView.reloadData()
                        self.view.layoutIfNeeded()
                    }
                    UIView.animate(withDuration: 0, delay: 0.6, options: .allowAnimatedContent, animations: {
                        self.partiesCollectionView.alpha = 1
                    }, completion: nil)
                }
            }
        }
        getComments()
        profileView!.profileView.sd_setImage(with: URL(string: user.avatarUrl!), completed: nil)
        profileView?.fullName.text = user.fullName!
        
        profileView?.genderAndYearsLabel.text = "\(user.sex ?? true ? "Парень".localized : "Девушка".localized), \(getYearsFromDate(date: user.date?.date()))"
        profileView?.locationLabel.text = user.location
        instagramNick.text = user.instLink
        vkNick.text = user.vkLink
        aboutMeLabelDescription.text = user.aboutMe
        profileView?.smallFullNameLabel.text = user.fullName!
        profileView?.smallGenderAndYearsLabel.text = "\(user.sex! ? "Парень".localized : "Девушка".localized), \(getYearsFromDate(date: user.date?.date()))"
        profileView?.smallLocationLabel.text = user.location
        profileView?.smallProfileView.sd_setImage(with: URL(string: user.avatarUrl!), completed: nil)
        
//        self.comments.append(Comment(text: "Адекватный парень, вечеринка прошла круто)",
//                                     createdAt: Date(), rate: Rate.Five, creatorName: "Полина Иванченко"))
//        self.comments.append(Comment(text: "Было много людей, мне ваще не зашло",
//                                     createdAt: Date(), rate: Rate.Two, creatorName: "Игорь Ивановский"))
        
        instagramButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.openInstagram)))
        vkButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.openVK)))

     }
    
    @objc func openVK() {
        guard let user = isYourAccount ? UserSettings.appUser : self.appUser else { return }
        ThirdPartyApplicationOpenner().openVKWithId(id: user.vkLink)
    }
    
    @objc func openInstagram() {
        guard let user = isYourAccount ? UserSettings.appUser : self.appUser else { return }
        ThirdPartyApplicationOpenner().openInstagramWithId(id: user.instLink)
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
    
    @IBAction func openSettings(_ sender: Any) {
        let vc = SettingsViewController(nibName: "SettingsViewController", bundle: nil)
        vc.modalPresentationStyle = .fullScreen
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

extension ProfileViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {

        let totalCellWidth = 283

        let leftInset = (collectionView.frame.width - CGFloat(totalCellWidth)) / 2
        let rightInset = leftInset

        return UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: rightInset)
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
        cell.selectionStyle = .none
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
    
    func shouldOpenProfileVC(vc: UIViewController) {
        
    }
    
    func shouldOpenFlatVC(vc: UIViewController) {
        
    }
}

extension ProfileViewController: ProfileViewProtocol {
    func settingsButtonPressed() {
        let vc = SettingsViewController(nibName: "SettingsViewController", bundle: nil)
        //vc.modalPresentationStyle = .fullScreen
        //self.present(vc, animated: true, completion: nil)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func didButtonPressed() {
        isYourAccount ? showEditProfileScreen() : writeMessage()
    }
    
    private func showEditProfileScreen() {
        let vc = EditProfileViewController(nibName: "EditProfileViewController", bundle: nil)
        vc.isEditingProfile = true
        vc.delegate = self
        //vc.modalPresentationStyle = .fullScreen
        //self.present(vc, animated: true, completion: nil)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func writeMessage() {
        let interlocutorId = appUser?.id
        var chat = Chat(chatId: UUID().uuidString,
                        memberIds: [interlocutorId, UserSettings.appUser?.id])
        
        DispatchQueue.global().async {
            let existingChat = ChatsService.shared.getChat(byMemberIds: chat.memberIds)
            if existingChat != nil {
                chat = existingChat!
            }
            
            DispatchQueue.main.async {
                chat.interlocutorFullName = self.appUser?.fullName
                let isNewChat = existingChat == nil
                self.present(ChatDetailViewController(chat, isNewChat, nil), animated: true, completion: nil)
            }
        }
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

extension ProfileViewController: RatingViewControllerProtocol {
    func addButtonPressed() {
        getComments()
    }
    
    func declineButtonPressed() {
        print()
    }
}

extension ProfileViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if presented is AcceptModalViewController || presented is ModalPopUpViewController || presented is QuestionModalViewController || presented is RatingViewController{
            return TransparentBackgroundModalPresenter(isPush: true, originFrame: UIScreen.main.bounds)
        } else {
        return SuccessModalPresenter(isPush: true, originFrame: UIScreen.main.bounds)
        }
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if dismissed is AcceptModalViewController || dismissed is ModalPopUpViewController || dismissed is QuestionModalViewController || dismissed is RatingViewController{
        return TransparentBackgroundModalPresenter(isPush: false)
        } else {
            return SuccessModalPresenter(isPush: false)
        }
    }
}
