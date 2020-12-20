//
//  NewMessageViewController.swift
//  Instamator
//
//  Created by Amit Chaudhary on 12/19/20.
//  Copyright © 2020 Amit Chaudhary. All rights reserved.
//

import Foundation
import UIKit
import Firebase

fileprivate let reUseIdentifier = "NewMessageCell"

class NewMessageViewController: UITableViewController {
    
    var totalUsers = [User]()
    var messagesUIVC = MessagesUIViewController()
    
    override func viewDidLoad() {
           super.viewDidLoad()
           constructNavigationBar()
           self.tableView.register(NewMessageViewCell.self, forCellReuseIdentifier: reUseIdentifier)
        
        self.tableView.tableFooterView = UIView(frame: .zero)
        self.fetchUsers()
        
       }
       
       
       //MARK: - UITableViewDataSource
       override func numberOfSections(in tableView: UITableView) -> Int {
           return 1
       }
       
       override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return totalUsers.count
       }
       
       override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           let cell = self.tableView.dequeueReusableCell(withIdentifier: reUseIdentifier, for: indexPath) as! NewMessageViewCell
        cell.user = totalUsers[indexPath.row]
        return cell
       }
       
       override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
           return 60
       }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.dismiss(animated: true) {
            let user = self.totalUsers[indexPath.row]
            self.messagesUIVC.showChatController(forUser: user)
        }
    }
}


//MARK: - Helper Methods
extension NewMessageViewController {
    func constructNavigationBar() {
        navigationItem.title = "Users"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.cancel, target: self, action: #selector(dismissViewController))
    }
    
    @objc func dismissViewController() {
        self.dismiss(animated: true, completion: nil)
    }
}


//MARK: - Firebase Operations
extension NewMessageViewController {
    func fetchUsers() {
        USERS_REF.observe(DataEventType.childAdded) { (snapshot) in
            guard let currentID = Auth.auth().currentUser?.uid else {return}
            if snapshot.key != currentID {
                Database.fetchUser(snapshot.key) { (user) in
                    self.totalUsers.append(user)
                    self.tableView.reloadData()
                }
            }
        }
    }
}
