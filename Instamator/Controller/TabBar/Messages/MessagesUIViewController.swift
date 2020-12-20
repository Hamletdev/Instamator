//
//  MessagesUIViewController.swift
//  Instamator
//
//  Created by Amit Chaudhary on 12/18/20.
//  Copyright © 2020 Amit Chaudhary. All rights reserved.
//

import Foundation
import UIKit
import Firebase

fileprivate let reUseIdentifier = "MessagesCell"

class MessagesUIViewController: UITableViewController {
    
    var messageDict = [String: Message]()
    
    var messagestoID = [Message]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        constructNavigationBar()
        self.tableView.register(MessagesUIViewCell.self, forCellReuseIdentifier: reUseIdentifier)
        
        self.tableView.tableFooterView = UIView(frame: .zero)
        self.fetchMessages()
    }
    
    
    //MARK: - UITableViewDataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messagestoID.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: reUseIdentifier, for: indexPath) as! MessagesUIViewCell
        cell.message = messagestoID[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    
    //MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messagestoID[indexPath.row]
        guard let partnerID = message.getPartnerID() else {return}
        Database.fetchUser(partnerID) { (user) in
            self.showChatController(forUser: user)
        }
    }
}


//MARK: - Firebase Operations
extension MessagesUIViewController {
    
    func fetchMessages() {
           guard let currentFromUID = Auth.auth().currentUser?.uid else {return}
           self.messagestoID.removeAll()
           self.messageDict.removeAll()
           self.tableView.reloadData()
           
           USER_MESSAGES_REF.child(currentFromUID).observe(DataEventType.childAdded) { (snapshot) in
               let userID = snapshot.key
               USER_MESSAGES_REF.child(currentFromUID).child(userID).observe(DataEventType.childAdded) { (snapshot) in
                   let messageID = snapshot.key
                   self.fetchMessages(messageID: messageID)
               }
           }
       }
    
    func fetchMessages(messageID: String) {
        MESSAGES_REF.child(messageID).observe(.value) { (snapshot) in
            guard let messageDictValues = snapshot.value as? [String: AnyObject] else {return}
            let message = Message(dictionary: messageDictValues)
            let partnerID = message.getPartnerID()
            
            self.messageDict[partnerID!] = message
            self.messagestoID = Array(self.messageDict.values)
            
            self.tableView.reloadData()
        }
    }
}


//MARK: - Helper Methods
extension MessagesUIViewController {
    func constructNavigationBar() {
        navigationItem.title = "Messages"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(handlePlusButton))
    }
    
    @objc func handlePlusButton() {
        let newMessageVC = NewMessageViewController()
        newMessageVC.messagesUIVC = self
        let navigationController = UINavigationController(rootViewController: newMessageVC)
        navigationController.modalPresentationStyle = .fullScreen
        self.present(navigationController, animated: true, completion: nil)
    }
    
    func showChatController(forUser: User) {
        let chatVC = ChatViewController(collectionViewLayout: UICollectionViewFlowLayout())
        chatVC.user = forUser
        self.navigationController?.pushViewController(chatVC, animated: true)
    }
}


