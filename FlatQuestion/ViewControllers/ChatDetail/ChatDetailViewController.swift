//
//  ChatDetailViewController.swift
//  FlatQuestion
//
//  Created by MacBook on 7/22/20.
//  Copyright © 2020 Андрей Олесов. All rights reserved.
//

import UIKit

class ChatDetailViewController: UIViewController, UITextViewDelegate {
    @IBOutlet weak var recipientName: UILabel!
    @IBOutlet weak var messagesTableView: UITableView!
    @IBOutlet weak var newMessageTextView: UITextView!
    @IBOutlet weak var attachFileButton: UIImageView!
    
    private var placeholderLabel : UILabel!
    private var messages = [Message]()
    private var chatCellModel: ChatTableViewCellModel!
    
    @IBAction func searchMessagesPressed() {
    }
    
    @IBAction func sendButtonPressed() {
        messages.insert(Message(
            senderId: UserSettings.appUser?.id,
            userAvatarUrl: "https://sun9-40.userapi.com/c623818/v623818963/7bf2/9_K7DupHOIQ.jpg",
            ownerUserName: String.empty,
            sentDate: Date(),
            text: newMessageTextView.text), at: 0)
        newMessageTextView.text = String.empty
        updatePlaceholderLabelVisibility()
        newMessageTextView.resignFirstResponder()
        messagesTableView.reloadData()
    }
    
    init(_ chatCellModel: ChatTableViewCellModel) {
        super.init(nibName: String(describing: ChatDetailViewController.self), bundle: nil)
        self.modalPresentationStyle = .custom
        self.chatCellModel = chatCellModel
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        newMessageTextView.delegate = self
        
        createPlaceholderLabel()
        
        initMessages()
        
        messagesTableView.register(UINib(nibName: IncomingMessageTableViewCell.typeName, bundle: nil), forCellReuseIdentifier: IncomingMessageTableViewCell.typeName)
        messagesTableView.register(UINib(nibName: OutgoingMessageTableViewCell.typeName, bundle: nil), forCellReuseIdentifier: OutgoingMessageTableViewCell.typeName)
        messagesTableView.separatorStyle = .none
        messagesTableView.separatorColor = .none
        messagesTableView.transform = CGAffineTransform(scaleX: 1, y: -1)
        messagesTableView.delegate = self
        messagesTableView.dataSource = self
        messagesTableView.reloadData()
        
        recipientName.text = chatCellModel.recipientName
    }
    
    @objc private func textFieldEditingDidChange(_ sender: Any) {

    }
    
    private func initMessages() {
        messages.append(Message(senderId: "",
                                userAvatarUrl: "https://sun9-40.userapi.com/c623818/v623818963/7bf2/9_K7DupHOIQ.jpg",
                                ownerUserName: String.empty,
                                sentDate: Date(),
                                text: "Привет) не против, если мы к вам присоединимся в 21-00?"))
        messages.append(Message(senderId: UserSettings.appUser?.id,
                                userAvatarUrl: "https://sun9-40.userapi.com/c623818/v623818963/7bf2/9_K7DupHOIQ.jpg",
                                ownerUserName: String.empty,
                                sentDate: Date(),
                                text: "Привет) не против, как раз к этому времени все и будут приезжать"))
        messages.append(Message(senderId: "",
                                userAvatarUrl: "https://sun9-40.userapi.com/c623818/v623818963/7bf2/9_K7DupHOIQ.jpg",
                                ownerUserName: String.empty,
                                sentDate: Date(),
                                text: "Предварительно наберем"))
        messages.append(Message(senderId: UserSettings.appUser?.id,
                                userAvatarUrl: "https://sun9-40.userapi.com/c623818/v623818963/7bf2/9_K7DupHOIQ.jpg",
                                ownerUserName: String.empty,
                                sentDate: Date(),
                                text: "Хорошо. Только вы не уточнили номер телефона)))"))
    }
    
    private func createPlaceholderLabel() {
        placeholderLabel = UILabel()
        placeholderLabel.text = "Написать сообщение"
        placeholderLabel.sizeToFit()
        newMessageTextView.addSubview(placeholderLabel)
        placeholderLabel.frame.origin = CGPoint(x: 5, y: (newMessageTextView.font?.pointSize)! / 2)
        placeholderLabel.textColor = UIColor.lightGray
        placeholderLabel.isHidden = !newMessageTextView.text.isEmpty
    }
    
    func textViewDidChange(_ textView: UITextView) {
        updatePlaceholderLabelVisibility()
    }
    
    private func updatePlaceholderLabelVisibility() {
        placeholderLabel.isHidden = !newMessageTextView.text.isEmpty
    }
}

extension ChatDetailViewController: UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}

extension ChatDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = self.messages[indexPath.item]
        let sentTime = DateTimeConverterHelper
            .convert(date: message.sentDate!, toFormat: "HH:mm")
        
        let cell: UITableViewCell
        if message.senderId == UserSettings.appUser?.id {
            cell = tableView.dequeueReusableCell(with: OutgoingMessageTableViewCell.self, for: indexPath)
            (cell as! OutgoingMessageTableViewCell).initialize(withData:
                MessageCellModel(avatarUrl: message.userAvatarUrl!, messageText: message.text!, sentTime: sentTime))
        } else {
            cell = tableView.dequeueReusableCell(with: IncomingMessageTableViewCell.self, for: indexPath)
            (cell as! IncomingMessageTableViewCell).initialize(withData:
                MessageCellModel(avatarUrl: message.userAvatarUrl!, messageText: message.text!, sentTime: sentTime))
        }

        cell.contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
        return cell
    }
}
