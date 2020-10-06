import UIKit

class ChatViewController: UIViewController {
    @IBOutlet weak var chatsTableView: UITableView!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var navigationBarView: UIImageView!
    private var refreshControl = UIRefreshControl()

    @IBAction func searchPressed() {
    }

    private var chats = [Chat]()
    private let chatsService = ChatsService()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.fetchChatsAndSetListeners()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        chatsTableView.register(UINib(nibName: ChatTableViewCell.typeName, bundle: nil), forCellReuseIdentifier: ChatTableViewCell.typeName)
        chatsTableView.separatorColor = .gray
        chatsTableView.tableFooterView = UIView()
        chatsTableView.separatorInset = UIEdgeInsets.zero
        chatsTableView.delegate = self
        chatsTableView.dataSource = self
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        chatsTableView.addSubview(refreshControl)

        getChatsWithLoading()
        
        createListenerForChatList()
        localize()
    }
    
    override func viewWillLayoutSubviews() {
        let colorView = UIView(frame: navigationBarView.frame)
        colorView.backgroundColor = UIColor(hex: 0x191D29)
        navigationBarView.image = UIImage(view: colorView)
        navigationBarView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        navigationBarView.clipsToBounds = true
        super.viewWillLayoutSubviews()
    }

    func localize() {
        titleLabel.text = "Сообщения".localized
    }
    private func createListenerForChatList() {
        NotificationCenter.default.addObserver(self, selector: #selector(reloadChats),
                                               name: Notification.Name("ChatListUpdated"),
                                               object: nil)
    }

    private func getChatsWithLoading() {
        ActivityIndicatorHelper.show(in: self.view)
        initChatList {
            ActivityIndicatorHelper.dismiss()
        }
    }

    private func updateChatUI(chat: Chat) {
        chats.first(where: { $0.chatId == chat.chatId })?.updateMainInfo(chat)
        chatsTableView?.reloadData()
        updateUnreadMessagesIndicator()
    }

    @objc private func refresh(_ sender: AnyObject) {
        initChatList {
            self.refreshControl.endRefreshing()
        }
    }
    
    private func fetchChatsAndSetListeners() {
        DispatchQueue.global().async {
            guard let id = UserSettings.appUser?.id else { return }
            self.chats = self.chatsService.getChats(forUserId: id)
            self.chats.forEach {
                self.chatsService.createListener(forChatId: $0.chatId!, onChatInfoUpdated: self.updateChatUI)
            }
            
            DispatchQueue.main.async {
                self.updateUnreadMessagesIndicator()
                self.chatsTableView?.reloadData()
            }
        }
    }
    
    private func initChatList(completion: (() -> ())? = nil) {
        DispatchQueue.global().async {
            self.fetchChatsAndSetListeners()

            DispatchQueue.main.async {
                completion?()
                self.chatsTableView.reloadData()
            }
        }
    }

    private func updateUnreadMessagesIndicator() {
        DispatchQueue.main.async {
            let allUnreadMessagesCount = self.chats
                .filter { $0.lastSenderId != UserSettings.appUser?.id }
                .map { $0.unreadMessagesCount ?? 0 }
                .reduce(0, +)
            self.tabBarItem?.badgeValue = allUnreadMessagesCount != 0
                ? String(allUnreadMessagesCount)
                : nil
        }
    }

    @objc private func reloadChats() {
        self.fetchChatsAndSetListeners()
    }
}

extension ChatViewController: UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedChat = chats[indexPath.row]

        let vc = ChatDetailViewController(selectedChat, false, getChatsWithLoading)
        present(vc, animated: true, completion: nil)
    }
}

extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.chats.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.chatsTableView
            .dequeueReusableCell(withIdentifier: ChatTableViewCell.typeName,
                                 for: indexPath) as! ChatTableViewCell
        cell.fillData(self.chats[indexPath.item])
        return cell
    }
}
