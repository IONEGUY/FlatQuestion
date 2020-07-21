//
//  NotificationsViewController.swift
//  FlatQuestion
//
//  Created by Андрей Олесов on 7/17/20.
//  Copyright © 2020 Андрей Олесов. All rights reserved.
//

import UIKit

class NotificationsViewController: UIViewController {


    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var flatRequests = [FlatRequestModel]() {
        didSet{
            self.userRequests.removeAll()
            flatRequests.forEach { (flatRequest) in
                flatRequest.requests.forEach { (userInfo) in
                    userRequests.append((flatRequest.id, userInfo))
                }
            }
        }
    }
    var userRequests:[(flatId: Int, userInfo: UserInfo)] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        localize()
        self.tableView.separatorColor = .clear
        self.tableView.contentInset = UIEdgeInsets(top: 32, left: 0, bottom: 0, right: 0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        initTableView()
        getRequests()
    }
    
    func localize() {
        titleLabel.text = "Уведомления".localized
    }
    
    func initTableView() {
        
        tableView.register(UINib(nibName: NotificationsTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: NotificationsTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
    }
 
    func getRequests() {
        FireBaseHelper().getFlatRequests { (result) in
            self.flatRequests.removeAll()
            switch result {
            case .success(let flatModel): self.flatRequests.append(flatModel)
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

extension NotificationsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userRequests.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let userRequest = userRequests[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NotificationsTableViewCell.identifier, for: indexPath) as? NotificationsTableViewCell else {
            return UITableViewCell()
        }
        cell.delegate = self
        cell.setupCell(flatId: userRequest.flatId, userInfo: userRequest.userInfo)
        return cell
    }
    
    
    
}

extension NotificationsViewController: NotificationsTableViewCellProtocol {
    func statusOfRequestWasChanged(result: Result<Void, Error>) {
        getRequests()
    }
}
