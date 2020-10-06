import UIKit

class NotificationsViewController: UIViewController {


    @IBOutlet weak var navigationBarView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var refreshControl = UIRefreshControl()
    var flatRequests = [FlatRequestModel]() {
        didSet{
            self.userRequests.removeAll()
            flatRequests.forEach { (flatRequest) in
                flatRequest.requests.forEach { (userInfo) in
                    if userInfo.status != .Declined {userRequests.append((flatRequest.id, userInfo))}
                }
            }
        }
    }
    var flatRequestsMy = [FlatRequestModel]()
    var userRequests:[(flatId: Int, userInfo: UserInfo)] = []
    var flatModalVC: FlatModalViewController!
    override func viewDidLoad() {
        super.viewDidLoad()
        localize()
        setupView()
        
        
        let timer = Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
    }
    
    override func viewWillLayoutSubviews() {
        let colorView = UIView(frame: navigationBarView.frame)
        colorView.backgroundColor = UIColor(hex: 0x191D29)
        navigationBarView.image = UIImage(view: colorView)
        navigationBarView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        navigationBarView.clipsToBounds = true
        super.viewWillLayoutSubviews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        initTableView()
        getRequests(completion: nil)
    }
    
    @objc func fireTimer() {
        getRequests(completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.navigationBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.navigationController?.navigationBar.isHidden = false
    }
    
    func setupView() {
        self.tableView.separatorColor = .clear
        self.tableView.contentInset = UIEdgeInsets(top: 32, left: 0, bottom: 0, right: 0)
        self.view.layoutSubviews()
    }
    
    func localize() {
        titleLabel.text = "Уведомления".localized
    }
    
    func initTableView() {
        refreshControl.attributedTitle = NSAttributedString(string: "Loading requests")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
        tableView.register(UINib(nibName: NotificationsTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: NotificationsTableViewCell.identifier)
        tableView.register(UINib(nibName: NotificationTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: NotificationTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
    }
 
    @objc func refresh(_ sender: AnyObject) {
        getRequests {
            if self.refreshControl.isRefreshing { self.refreshControl.endRefreshing() }
        }
    }
    
    func getRequests(completion: (() -> ())?) {
        DispatchQueue.global(qos: .userInteractive).async {
            FireBaseHelper().getFlatRequests { (result) in
                completion?()
                self.flatRequests.removeAll()
                switch result {
                case .success(let models): self.flatRequests = models
                            DispatchQueue.main.async {
                        self.tableView.reloadData()
                        self.view.layoutIfNeeded()
                    }
                    self.view.layoutIfNeeded()
                case .failure(let error): self.showErrorAlert(message: error.localizedDescription)
                }
            }
        }
        
        DispatchQueue.global(qos: .userInteractive).async {
            FireBaseHelper().getFlatRequestsMy { (result) in
                completion?()
                self.flatRequestsMy.removeAll()
                switch result {
                case .success(let models): self.flatRequestsMy = models
                            DispatchQueue.main.async {
                        self.tableView.reloadData()
                        self.view.layoutIfNeeded()
                    }
                    self.view.layoutIfNeeded()
                case .failure(let error): self.showErrorAlert(message: error.localizedDescription)
                }
            }
        }
    
    }
}

extension NotificationsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? userRequests.count : flatRequestsMy.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
        let userRequest = userRequests[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NotificationsTableViewCell.identifier, for: indexPath) as? NotificationsTableViewCell else {
            return UITableViewCell()
        }
        cell.selectionStyle = .none
        cell.delegate = self
        cell.setupCell(flatId: userRequest.flatId, userInfo: userRequest.userInfo)
        return cell
        } else {
            let request = flatRequestsMy[indexPath.row]
            guard let cell = tableView.dequeueReusableCell(withIdentifier: NotificationTableViewCell.identifier, for: indexPath) as? NotificationTableViewCell else {
                return UITableViewCell()
            }
            let userInfo = request.requests.first { (userInfo) -> Bool in
                return userInfo.id == UserSettings.appUser?.id
            }
            let date = userInfo?.date
            cell.setup(photo: URL(string: request.flatPhotoLink)!, name: request.flatName, time: DateTimeConverterHelper.convert(date: date!.date(), toFormat: "HH:mm"), status: userInfo!.status)
            cell.selectionStyle = .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == 1 else {
            return
        }
        let request = flatRequestsMy[indexPath.row]
        FireBaseHelper().getFlatById(flatId: request.id) { (flatModel) in
            guard let flat = flatModel.first else { return }
            DispatchQueue.main.async {
                self.flatModalVC = FlatModalViewController(nibName: "FlatModalViewController", bundle: nil)
                self.flatModalVC.flat = flat
                self.flatModalVC.delegate = self
                self.addChild(self.flatModalVC)
                self.view.addSubview(self.flatModalVC.view)
                self.flatModalVC.didMove(toParent: self)
                let height = self.view.frame.height
                let width  = self.view.frame.width
                self.flatModalVC.view.frame = CGRect(x: 0, y: self.view.frame.maxY, width: width, height: height)
            }
        }
        
    }
    
    
    
}

extension NotificationsViewController: NotificationsTableViewCellProtocol {
    func statusOfRequestWasChanged(result: Result<Void, Error>, userId: String) {
        DispatchQueue.global(qos: .background).async {
            FireBaseHelper().sendNotification(to: userId, title: "Туса-Джуса", body: "Статус вашей заявки был изменен".localized)
        }
        getRequests(completion: nil)
    }
}

extension NotificationsViewController: RemovableDelegate {
    func shouldOpenProfileVC(vc: UIViewController) {
        UIView.animate(withDuration: 0.1, animations: {
            self.flatModalVC.willMove(toParent: nil)
            self.flatModalVC.view.removeFromSuperview()
            self.flatModalVC.removeFromParent()
        }) { (finished) in
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        //self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func shouldOpenFlatVC(vc: UIViewController) {
        UIView.animate(withDuration: 0.1, animations: {
            self.flatModalVC.willMove(toParent: nil)
            self.flatModalVC.view.removeFromSuperview()
            self.flatModalVC.removeFromParent()
        }) { (finished) in
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        //self.navigationController?.pushViewController(vc, animated: true)
    }
    

    func shouldRemoveFromSuperView() {
        flatModalVC.willMove(toParent: nil)
        flatModalVC.view.removeFromSuperview()
        flatModalVC.removeFromParent()
    }
    
}
