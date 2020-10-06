import UIKit
import SDWebImage
extension FlatModalViewController {
    private enum State {
        case partial
        case full
        case none
    }

    private enum Constant {
        static let fullViewYPosition: CGFloat = 50
        static let noneYPosition: CGFloat = UIScreen.main.bounds.height
        static func getPartialViewPosition(tabBarHeight: CGFloat) -> CGFloat {
            return UIScreen.main.bounds.height - 335 - tabBarHeight
        }
    }
}

protocol RemovableDelegate: class {
    func shouldRemoveFromSuperView()
    func shouldOpenProfileVC(vc: UIViewController)
    func shouldOpenFlatVC(vc: UIViewController)
}


class FlatModalViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    weak var delegate: RemovableDelegate?
    private var currentState: State?
    var flat: FlatModel?
    var isProfileHidden = false
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var viewForSendButton: UIView!
    
    @IBOutlet weak var sendInviteButton: UIButton!
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var mapView: UIView!
    @IBOutlet weak var favoriteView: UIView!
    @IBOutlet weak var shareView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var placesLabel: UILabel!
    
    @IBOutlet weak var profileLabel: UILabel!
    @IBOutlet weak var mapLabel: UILabel!
    @IBOutlet weak var favoriteLabel: UILabel!
    @IBOutlet weak var shareLabel: UILabel!
    
    var isYourFlat: Bool {
        return flat?.userId == UserSettings.appUser?.id
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        localize()
        setupGesture()
        setupCollectionView()
        setupTableView()
        roundViews()
    
    }
    
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
       if gesture.direction == .up {
        if currentState! == .partial {
            moveView(state: .full)
        }
       }
       else if gesture.direction == .down {
        if currentState! == .full {
            moveView(state: .partial)
        } else if currentState! == .partial {
            moveView(state: .none)
        }
       }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        currentState = .partial
        UIView.animate(withDuration: 0.6, animations: {
            self.moveView(state: .partial)
        })
    }

    private func setupGesture() {
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeUp.direction = .up
        self.view.addGestureRecognizer(swipeUp)

        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeDown.direction = .down
        self.view.addGestureRecognizer(swipeDown)

        view.isUserInteractionEnabled = true
        
        shareView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(shareFlat)))
    }
    
    @objc private func shareFlat() {
        let items: [Any] = ["Вот отличный флет, посмотри".localized, URL(string: "flat://\(String(flat!.id))")!]
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(ac, animated: true)
    }
    
    private func setupView() {
        if isProfileHidden { profileView.isHidden = true }
        if flat?.userId == UserSettings.appUser!.id {
            sendInviteButton.backgroundColor = .gray
        }
        nameLabel.text = flat?.name.capitalizingFirstLetter()
        if flat!.userId == UserSettings.appUser!.id {
            nameLabel.textColor = UIColor(hex: 0xBC70F6)
        } else {
            nameLabel.textColor = UIColor(hex: 0x03CCE0)
        }
        addressLabel.text = flat?.address
        dateLabel.text = DateFormatterHelper().getStringFromDate_MMM_yyyy_HH_mm(date: flat?.date?.date() ?? Date())
        placesLabel.text = "Свободно".localized + " \(String(describing: flat!.emptyPlacesCount!))" + "из".localized + " \(String(describing: flat!.allPlacesCount!))"
        if isYourFlat {
            self.profileView.isHidden = true
        }
    }

    private func setupTableView() {
        tableView.register(UINib(nibName: FlatDescriptionTableViewCell.identifier, bundle: nil),
                           forCellReuseIdentifier: FlatDescriptionTableViewCell.identifier)
        tableView.separatorColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
        self.view.layoutIfNeeded()
    }

    private func moveView(state: State) {
        UIView.animate(withDuration: 0.2) {
            if state == .full {
                self.viewForSendButton.alpha = 0
            } else {
                self.viewForSendButton.alpha = 1
            }
        }
        let yPosition = state == .partial ? Constant.getPartialViewPosition(
            tabBarHeight: self.tabBarController?.tabBar.frame.size.height ?? 0) : Constant.fullViewYPosition
        UIView.animate(withDuration: 0.3, delay: 0.0, options: [], animations: {
            if state == .none && self.currentState != .full {
                self.view.frame = CGRect(x: 0, y: Constant.noneYPosition, width: self.view.frame.width, height: self.view.frame.height)
                self.delegate?.shouldRemoveFromSuperView()
            } else {
                self.view.frame = CGRect(x: 0, y: yPosition, width: self.view.frame.width, height: self.view.frame.height)
            }
            self.currentState = state
        }, completion: nil)
    }
    
    @IBAction func openProfileButtonPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "ProfileViewController") as? ProfileViewController else { return }
        vc.isYourAccount = false
        FireBaseHelper().getUserById(id: flat!.userId) { (result) in
            switch result {
            case .success(let appUser): vc.appUser = appUser
            self.delegate?.shouldOpenProfileVC(vc: vc)
            self.present(vc, animated: true, completion: nil)
            case .failure(let error): self.showErrorAlert(message: error.localizedDescription)
            }
        }
        
    }
    
    
    @IBAction func sendInviteButtonPressed(_ sender: Any) {
        if isYourFlat {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "CreateFlatViewController") as! CreateFlatViewController
            vc.modalPresentationStyle = .overFullScreen
            vc.delegate = self
            vc.isEditingFlat = true
            vc.existedFlatModel = flat
            
            self.delegate?.shouldOpenFlatVC(vc: vc)
        } else {
            let vc = AcceptModalViewController(delegate: self, flat: flat!)
            vc.transitioningDelegate = self
            present(vc, animated: true, completion: nil)
        }
    }
    
    func localize() {
        sendInviteButton.setTitle(!isYourFlat ? "Присоедениться".localized : "Редактировать".localized, for: .normal)
        profileLabel.text = "Профиль".localized
        mapLabel.text = "Карта".localized
        favoriteLabel.text = "Избранные".localized
        shareLabel.text = "Поделиться".localized
    }

    func roundViews() {
        profileView.addCorner(with: 10, with: .black)
        mapView.addCorner(with: 10, with: .black)
        favoriteView.addCorner(with: 10, with: .black)
        shareView.addCorner(with: 10, with: .black)
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
    }

    @IBAction func close(_ sender: Any) {

        UIView.animate(withDuration: 0.6, animations: {
            self.view.frame = CGRect(x: 0, y: 900, width: self.view.frame.width, height: self.view.frame.height)
        }) { (Bool) in
            self.delegate?.shouldRemoveFromSuperView()
        }
    }
    
    private func setupCollectionView() {
        switch flat?.images?.count {
        case 1: self.collectionView.collectionViewLayout = generateLayoutOnePhoto()
        case 2: self.collectionView.collectionViewLayout = generateLayoutTwoPhotos()
        case 3: self.collectionView.collectionViewLayout = generateLayout()
        default:
            self.collectionView.collectionViewLayout = generateLayoutOnePhoto()
        }
        collectionView.register(UINib(nibName: FlatPhotoCollectionViewCell.identifier, bundle: nil),
        forCellWithReuseIdentifier: FlatPhotoCollectionViewCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        self.collectionView.reloadData()
        self.view.layoutIfNeeded()
    }

    func generateLayout() -> UICollectionViewLayout {
        let fullPhotoItem = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalWidth(2/3)))
        fullPhotoItem.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: 2,
            bottom: 0,
            trailing: 2)
        let mainItem = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(2/3),
                heightDimension: .fractionalHeight(1.0)))
        mainItem.contentInsets = NSDirectionalEdgeInsets(
            top: 2,
            leading: 2,
            bottom: 2,
            trailing: 2)
        let pairItem = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(0.5)))
        pairItem.contentInsets = NSDirectionalEdgeInsets(
            top: 2,
            leading: 2,
            bottom: 2,
            trailing: 2)
        let trailingGroup = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1/3),
                heightDimension: .fractionalHeight(1.0)),
            subitem: pairItem,
            count: 2)
        // 1
        let mainWithPairGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalWidth(5/10)),
            subitems: [mainItem, trailingGroup])
        let nestedGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)),
            subitems: [
                mainWithPairGroup,
                fullPhotoItem
            ]
        )
        let section = NSCollectionLayoutSection(group: nestedGroup)
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
}

    func generateLayoutOnePhoto() -> UICollectionViewLayout {
        let fullPhotoItem = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalWidth(2/3)))
        fullPhotoItem.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: 2,
            bottom: 0,
            trailing: 2)
        
        let trailingGroup = NSCollectionLayoutGroup.horizontal(
        layoutSize: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)),
        subitem: fullPhotoItem,
        count: 1)
        
        let section = NSCollectionLayoutSection(group: trailingGroup)
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }


    func generateLayoutTwoPhotos() -> UICollectionViewLayout {
        let fullPhotoItem = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalWidth(2/3)))
        fullPhotoItem.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: 2,
            bottom: 0,
            trailing: 2)
        
        let mainItem = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(2/3),
                heightDimension: .fractionalHeight(1.0)))
        mainItem.contentInsets = NSDirectionalEdgeInsets(
            top: 2,
            leading: 2,
            bottom: 2,
            trailing: 2)
        let pairItem = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(0.5)))
        pairItem.contentInsets = NSDirectionalEdgeInsets(
            top: 2,
            leading: 2,
            bottom: 2,
            trailing: 2)
        let trailingGroup = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1/3),
                heightDimension: .fractionalHeight(1.0)),
            subitem: pairItem,
            count: 1)
        // 1
        let mainWithPairGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalWidth(5/10)),
            subitems: [mainItem, trailingGroup])
        let nestedGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)),
            subitems: [
                mainWithPairGroup,
                fullPhotoItem
            ]
        )
        let section = NSCollectionLayoutSection(group: nestedGroup)
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }

extension FlatModalViewController: AcceptModalViewControllerProtocol {
    func inviteSuccessfullySended() {
        print("success")
    }
}

extension FlatModalViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return flat?.images?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FlatPhotoCollectionViewCell.identifier,
                                                      for: indexPath) as? FlatPhotoCollectionViewCell
        guard let photoCell = cell else {
            return UICollectionViewCell()
        }
        guard let url = URL(string: (flat?.images?[indexPath.row])!) else {
            return photoCell
        }
        photoCell.image.sd_imageIndicator = SDWebImageActivityIndicator.gray
        photoCell.image.sd_setImage(with: url, completed: nil)
        return photoCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var urlStrings = [String]()
        let selectedUrl = self.flat?.images![indexPath.item]
        urlStrings.append(selectedUrl!)
        let otherUrlStrings = self.flat?.images?.filter({ (string) -> Bool in
            return string != selectedUrl
        })
        urlStrings.append(contentsOf: otherUrlStrings!)
        WRGImageGallery().show(urls: urlStrings, viewController: self, initialPosition:0, tabBarToClose: self.tabBarController as? MainTabBarController)
    }
}

extension FlatModalViewController: UICollectionViewDataSource {}

extension FlatModalViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FlatDescriptionTableViewCell.identifier,
                                                 for: indexPath) as? FlatDescriptionTableViewCell
        guard let flatDescriptionCell = cell else {
            return UITableViewCell()
        }

        flatDescriptionCell.setupTitle(title: "Информация".localized,
                                       description: flat?.additionalInfo ?? "")
        return flatDescriptionCell
    }
}

extension FlatModalViewController: UITableViewDataSource {}

extension FlatModalViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if presented is AcceptModalViewController {
            return TransparentBackgroundModalPresenter(isPush: true, originFrame: UIScreen.main.bounds)
        } else {
        return SuccessModalPresenter(isPush: true, originFrame: UIScreen.main.bounds)
        }
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if dismissed is AcceptModalViewController {
        return TransparentBackgroundModalPresenter(isPush: false)
        } else {
            return SuccessModalPresenter(isPush: false)
        }
    }
}

extension FlatModalViewController: CreateFlatProtocol {
    func flatWasCreated() {
        print()
    }
}
