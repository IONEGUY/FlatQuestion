import UIKit

class ChatDetailViewController: UIViewController, UITextViewDelegate {
    @IBOutlet weak var recipientName: UILabel!
    @IBOutlet weak var messagesTableView: UITableView!
    @IBOutlet weak var newMessageTextView: UITextView!
    @IBOutlet weak var attachFileButton: UIImageView!
    @IBOutlet weak var navigationBarItem: UIImageView!
    
    private var placeholderLabel : UILabel!
    private var messagesGrouped = [(key: String, value: [Message])]()
    private var messages = [Message]()
    private var chatModel: Chat!
    private var chatsServise = ChatsService()
    
    private let footerHeight: CGFloat = 70
    private var refreshControl = UIRefreshControl()
    private var loadingCell: LoadingCell!
    private var loadMoreEnabled = true
    private var messagesRead = false
    private var isNewChat = false
    
    private var chatDisappearing: (() -> ())?
    
    @IBAction func goBackButtonPressed() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sendButtonPressed() {
        if newMessageTextView.text.isEmptyOrWhitespace() {
            return
        }
        
        var message = Message(id: UUID().uuidString,
                              senderId: UserSettings.appUser!.id!,
                              senderAvatarUrl: UserSettings.appUser!.avatarUrl ?? Constants.defaultAvatarUrl,
                              sentDate: Date(),
                              text: newMessageTextView.text,
                              isRead: false,
                              uploaded: false)
        
        let interlocutorId = chatModel.memberIds!.filter
            { $0! != UserSettings.appUser!.id! }.first!
        
        DispatchQueue.global().async { [weak self] in
            guard let strongSelf = self else { return }
            
            let messageUploaded =
                strongSelf.chatsServise.addMessage(message: message, chatId: strongSelf.chatModel.chatId!)
            
            if !messageUploaded { return }
            
            if (strongSelf.isNewChat) {
                _ = strongSelf.chatsServise.createChat(strongSelf.chatModel)
                strongSelf.isNewChat = false
            }
            
            FireBaseHelper.shared.sendNotification(
                to: interlocutorId!,
                title: "New Message from \(UserSettings.appUser?.fullName ?? String.empty)",
                body: message.text)
            
            DispatchQueue.main.async {
                strongSelf.newMessageTextView.text = String.empty
                strongSelf.updatePlaceholderLabelVisibility()
                message.uploaded = messageUploaded
                strongSelf.insertNewMessage(message)
            }
        }
    }
    
    init(_ chatModel: Chat, _ isNewChat: Bool = false, _ chatDisappearing: (() -> ())? = nil) {
        super.init(nibName: String(describing: ChatDetailViewController.self), bundle: nil)
        self.chatDisappearing = chatDisappearing
        self.isNewChat = isNewChat
        self.modalPresentationStyle = .custom
        self.chatModel = chatModel
        chatsServise.createListener(forChatId: chatModel.chatId!, onNewMessageAdded:
            { [weak self] newMessage in
                guard let strongSelf = self else { return }
                var message = newMessage
                message.isRead = true
                strongSelf.chatsServise.markMessagesAsRead(forChatId: strongSelf.chatModel.chatId!)
                strongSelf.insertNewMessage(message)
        })
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        chatDisappearing?()
    }
    
    override func viewWillLayoutSubviews() {
        let colorView = UIView(frame: navigationBarItem.frame)
        colorView.backgroundColor = UIColor(hex: 0x191D29)
        navigationBarItem.image = UIImage(view: colorView)
        navigationBarItem.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        navigationBarItem.clipsToBounds = true
        super.viewWillLayoutSubviews()
    }
    
    private func updateGroupedMessages() {
        let groups = Dictionary(grouping: messages) { message -> String in
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE, d MMMM"
            return formatter.string(from: message.sentDate)
        }
        messagesGrouped = []
        let sortedKeys = groups.keys.sorted(by: >)
        sortedKeys.forEach { key in
            if let value = groups[key] {
                messagesGrouped.append((key: key, value: value))
            }
        }
    }
    
    private func setupMessagesTableViewFooter() {
        loadingCell = Bundle.main.loadNibNamed(LoadingCell.typeName,
                                               owner: self.messagesTableView, options: nil)!.first as? LoadingCell
        loadingCell.setMessage(String.empty)
        self.messagesTableView.tableFooterView = loadingCell
        self.messagesTableView.sectionFooterHeight = footerHeight
        setStatusToActivityIndicator(isRunning: false)
    }
    
    private func setStatusToActivityIndicator(isRunning: Bool) {
        loadingCell.changeSpinnerStatus(isRunning: isRunning)
        messagesTableView.tableFooterView!.isHidden = !isRunning;
    }
    
    private func setBackdroundMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.messagesTableView.bounds.width, height: self.messagesTableView.bounds.height))
        messageLabel.text = message
        messageLabel.textColor = .label
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.sizeToFit()
        self.messagesTableView.backgroundView = messageLabel
    }
    
    private func loadMore() {
        setStatusToActivityIndicator(isRunning: true)
        DispatchQueue.global().async {
            let newMessages = self.loadPagedMessagesResult()
            
            DispatchQueue.main.async {
                guard self.loadMoreEnabled else {
                    self.setStatusToActivityIndicator(isRunning: false)
                    return
                }
                
                self.messages.append(contentsOf: newMessages)
                self.updateGroupedMessages()
                self.messagesTableView.reloadData()
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(closeNewMessageTextView))
        messagesTableView.addGestureRecognizer(tapGesture)
        
        ActivityIndicatorHelper.show(in: self.view)
        DispatchQueue.global().async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.messages = strongSelf.loadPagedMessagesResult()
            strongSelf.updateGroupedMessages()
            strongSelf.chatsServise.markMessagesAsRead(forChatId: strongSelf.chatModel.chatId!)
            
            DispatchQueue.main.async {
                ActivityIndicatorHelper.dismiss()
                strongSelf.initUI()
            }
        }
    }
    
    @objc private func closeNewMessageTextView() {
        self.view.endEditing(true)
    }
    
    private func loadPagedMessagesResult() -> [Message] {
        let pagingResult = chatsServise.getMessagesWithPaging(forChatId: chatModel.chatId!)
        loadMoreEnabled = pagingResult.loadMoreAvailable
        return pagingResult.messages
    }
    
    private func insertNewMessage(_ message: Message) {
        self.messages.insert(message, at: 0)
        self.updateGroupedMessages()
        self.messagesTableView.reloadData()
    }
    
    private func initUI() {
        createPlaceholderLabel()
        newMessageTextView.delegate = self
        messagesTableView.register(UINib(nibName: IncomingMessageTableViewCell.typeName, bundle: nil), forCellReuseIdentifier: IncomingMessageTableViewCell.typeName)
        messagesTableView.register(UINib(nibName: OutgoingMessageTableViewCell.typeName, bundle: nil), forCellReuseIdentifier: OutgoingMessageTableViewCell.typeName)
        messagesTableView.separatorStyle = .none
        messagesTableView.separatorColor = .none
        messagesTableView.showsVerticalScrollIndicator = false
        messagesTableView.transform = CGAffineTransform(scaleX: 1, y: -1)
        messagesTableView.delegate = self
        messagesTableView.dataSource = self
        messagesTableView.reloadData()
        recipientName.text = chatModel.interlocutorFullName
        setupMessagesTableViewFooter()
    }

    private func createPlaceholderLabel() {
        placeholderLabel = UILabel()
        placeholderLabel.text = "Написать сообщение".localized
        placeholderLabel.sizeToFit()
        newMessageTextView.addSubview(placeholderLabel)
        placeholderLabel.frame.origin = CGPoint(x: 5, y: (newMessageTextView.font?.pointSize)! / 2)
        placeholderLabel.textColor = UIColor.lightGray
        placeholderLabel.isHidden = !newMessageTextView.text.isEmpty
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        for index in 0..<self.messages.count {
            self.messages[index].isRead = true
        }
        
        self.messagesTableView.reloadData()

        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        updatePlaceholderLabelVisibility()
    }
    
    private func updatePlaceholderLabelVisibility() {
        placeholderLabel.isHidden = !newMessageTextView.text.isEmpty
    }
    
    private func createDayNameFooter(forSection section: Int) -> UIView {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 30))
        label.font = UIFont.systemFont(ofSize: 11)
        label.textColor = UIColor(hex: 0x8F8F8F)
        label.textAlignment = .center
        label.text = createDayNameLabelText(section: section)
        label.transform = CGAffineTransform(scaleX: 1, y: -1)
        return label
    }
    
    private func createDayNameLabelText(section: Int) -> String {
        var text = String.empty
        guard let date = self.messagesGrouped[section].value.first?.sentDate
            else { return String.empty }
        
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            text = "Сегодня".localized
        } else if calendar.isDateInYesterday(date) {
            text = "Вчера".localized
        } else {
            text = self.messagesGrouped[section].key
        }
        
        return text
    }
}

extension ChatDetailViewController: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        let deltaOffset = maximumOffset - currentOffset
        if deltaOffset <= 0 && loadMoreEnabled {
            loadMoreEnabled = false
            loadMore()
        }
    }
}

extension ChatDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messagesGrouped[section].value.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return messagesGrouped.count
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return createDayNameFooter(forSection: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = self.messagesGrouped[indexPath.section].value[indexPath.item]
        let sentTime = DateTimeConverterHelper
            .convert(date: message.sentDate, toFormat: "HH:mm")
        
        let cell: UITableViewCell
        if message.senderId == UserSettings.appUser?.id {
            cell = tableView.dequeueReusableCell(with: OutgoingMessageTableViewCell.self, for: indexPath)
            (cell as! OutgoingMessageTableViewCell).initialize(withData:
                MessageCellModel(messageText: message.text,
                                 sentTime: sentTime,
                                 sentSuccessfully: message.uploaded))
        } else {
            cell = tableView.dequeueReusableCell(with: IncomingMessageTableViewCell.self, for: indexPath)
            (cell as! IncomingMessageTableViewCell).initialize(withData:
                MessageCellModel(avatarUrl: message.senderAvatarUrl,
                                 messageText: message.text,
                                 sentTime: sentTime,
                                 isRead: message.isRead))
        }

        cell.contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
        return cell
    }
}
