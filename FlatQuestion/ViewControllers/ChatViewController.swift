//
//  ChatViewController.swift
//  FlatQuestion
//
//  Created by MacBook on 7/21/20.
//  Copyright © 2020 Андрей Олесов. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController {
    @IBOutlet weak var chatsTableView: UITableView!
    
    @IBAction func searchPressed() {
    }
    
    var chats = [ChatTableViewCellModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initData()
        
        chatsTableView.register(UINib(nibName: ChatTableViewCell.typeName, bundle: nil), forCellReuseIdentifier: ChatTableViewCell.typeName)
        chatsTableView.separatorColor = .gray
        chatsTableView.tableFooterView = UIView()
        chatsTableView.separatorInset = UIEdgeInsets.zero
        chatsTableView.delegate = self
        chatsTableView.dataSource = self
        chatsTableView.reloadData()
    }
    
    private func initData() {
        chats.append(ChatTableViewCellModel(message: Message(userAvatarUrl: "https://sun9-54.userapi.com/c636225/v636225861/2964c/rNAmlOZGjz8.jpg", ownerUserName: "Ivan Zavadsky", sentDate: Date(), text: "simple text simple text simple text ext simp ext simp text simple text ext simp ext simp")))
        chats.append(ChatTableViewCellModel(message: Message(userAvatarUrl: "https://sun9-54.userapi.com/c636225/v636225861/2964c/rNAmlOZGjz8.jpg", ownerUserName: "Ivan Zavadsky", sentDate: Date(), text: "simple text simple text simple text"), unreadedMessagesCount: 123))
        chats.append(ChatTableViewCellModel(message: Message(userAvatarUrl: "https://sun9-54.userapi.com/c636225/v636225861/2964c/rNAmlOZGjz8.jpg", ownerUserName: "Ivan Zavadsky", sentDate: Date(), text: "simple text simple text simple text ext simp ext simp"), unreadedMessagesCount: 6))
        chats.append(ChatTableViewCellModel(message: Message(userAvatarUrl: "https://sun9-54.userapi.com/c636225/v636225861/2964c/rNAmlOZGjz8.jpg", ownerUserName: "Ivan Zavadsky", sentDate: Date(), text: "simple text simple text simple text"), unreadedMessagesCount: 12))
    }
}

extension ChatViewController: UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedChat = chats[indexPath.row]
        
        let vc = ChatDetailViewController(selectedChat)
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
