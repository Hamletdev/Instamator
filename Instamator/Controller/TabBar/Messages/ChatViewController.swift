//
//  ChatViewController.swift
//  Instamator
//
//  Created by Amit Chaudhary on 12/19/20.
//  Copyright © 2020 Amit Chaudhary. All rights reserved.
//

import Foundation
import UIKit
import Firebase

fileprivate let reUseIdentifier = "ChatCell"

class ChatViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var user: User?
    var totalMessages = [Message]()
    
    let commentTextField: UITextField = {
        let aTextField = UITextField()
        aTextField.font = UIFont.systemFont(ofSize: 14)
        aTextField.placeholder = "Enter Message.."
        return aTextField
    }()
    
    let postButton: UIButton = {
        let aButton = UIButton(type: UIButton.ButtonType.system)
        aButton.setTitle("Send", for: UIControl.State.normal)
        aButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        aButton.addTarget(self, action: #selector(uploadMessageToDatabase), for: UIControl.Event.touchUpInside)
        return aButton
    }()
    
    let separatorView: UIView = {
        let aView = UIView()
        aView.backgroundColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
        return aView
    }()
    
    
    lazy var containerView: UIView = {
        let cv = UIView()
        cv.backgroundColor = .systemBackground
        cv.frame = CGRect(x: 0, y: 0, width: self.collectionView.frame.width, height: 50)
        
        cv.addSubview(self.postButton)
        self.postButton.anchorView(top: nil, left: nil, bottom: nil, right: cv.rightAnchor, topPadding: 0, leftPadding: 0, bottomPadding: 0, rightPadding: 8, width: 50, height: 0)
        self.postButton.centerYAnchor.constraint(equalTo: cv.centerYAnchor).isActive = true
        
        cv.addSubview(self.commentTextField)
        self.commentTextField.anchorView(top: cv.topAnchor, left: cv.leftAnchor, bottom: cv.bottomAnchor, right: self.postButton.leftAnchor, topPadding: 0, leftPadding: 8, bottomPadding: 0, rightPadding: 0, width: 0, height: 0)
        
        cv.addSubview(self.separatorView)
        self.separatorView.anchorView(top: cv.topAnchor, left: cv.leftAnchor, bottom: nil, right: cv.rightAnchor, topPadding: 0, leftPadding: 0, bottomPadding: 0, rightPadding: 0, width: 0, height: 0.6)
        
        return cv
    }()
    
    override var inputAccessoryView: UIView? {
        get {
            return containerView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.register(ChatViewCell.self, forCellWithReuseIdentifier: reUseIdentifier)
        self.collectionView.backgroundColor = .white
        self.constructNavigationBar()
        
        self.fetchMessages()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    func constructNavigationBar() {
        guard let safeUser = self.user else {return}
        self.navigationItem.title = safeUser.userName
        
        let infoButton = UIButton(type: .infoLight)
        infoButton.addTarget(self, action: #selector(infoButtonTapped), for: UIControl.Event.touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: infoButton)
    }
    
    
    //MARK: - UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return totalMessages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: reUseIdentifier, for: indexPath) as! ChatViewCell
        cell.message = totalMessages[indexPath.item]
        self.constructMessage(cell: cell, message: totalMessages[indexPath.item])
        return cell
    }
    
    
    //MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 80
        let message = totalMessages[indexPath.row]
        height = estimeateFrameForText(messageText: message.messageText).height + 20.0
        return CGSize(width: self.collectionView.frame.width, height: height)
    }
    
}


//MARK: - Firebase Operations
extension ChatViewController {
    
   @objc func uploadMessageToDatabase() {
    guard let currentFromID = Auth.auth().currentUser?.uid , let messageText = self.commentTextField.text , let toUserID = self.user?.uID  else {return}
    
    let creationDate = Int(Date().timeIntervalSince1970)
    let messageDictValues = ["messageText": messageText, "fromID": currentFromID, "toID": toUserID, "creationDate": creationDate] as [String: AnyObject]
    let messages_ref = MESSAGES_REF.childByAutoId()
    guard let messageID = messages_ref.key else { return }
    
    messages_ref.updateChildValues(messageDictValues) { (error, ref) in
        USER_MESSAGES_REF.child(currentFromID).child(toUserID).updateChildValues([messageID: 1])
        USER_MESSAGES_REF.child(toUserID).child(currentFromID).updateChildValues([messageID: 1])
    }
    
    self.commentTextField.text = nil
    
    }
    
    func fetchMessages() {
        guard let currentFromID = Auth.auth().currentUser?.uid, let toUserID = self.user?.uID else {return}
        USER_MESSAGES_REF.child(currentFromID).child(toUserID).observe(DataEventType.childAdded) { (snapshot) in
 
            let messageID = snapshot.key
            MESSAGES_REF.child(messageID).observe(.value) { (snapshot) in
                guard let messageDictValues = snapshot.value as? [String: AnyObject] else {return}
                let message = Message(dictionary: messageDictValues)
                self.totalMessages.append(message)
                self.collectionView.reloadData()
            }
        }
    }
}


//MARK: - Helper Methods
extension ChatViewController {
    
    @objc func infoButtonTapped() {
        let userProfileVC = UserProfileViewController(collectionViewLayout: UICollectionViewFlowLayout())
        userProfileVC.headerUser = self.user
        userLoadedFromSearch = true
        self.navigationController?.pushViewController(userProfileVC, animated: true)
    }
    
    func estimeateFrameForText(messageText: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
         let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: messageText).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)], context: nil)
    }
    
    func constructMessage(cell: ChatViewCell, message: Message) {
        guard let currentFromID = Auth.auth().currentUser?.uid else {return}
        
        cell.bubbleViewWidthAnchor?.constant = estimeateFrameForText(messageText: message.messageText).width + 20
        //cell.frame.size.height = estimeateFrameForText(messageText: message.messageText).height
        
        if message.fromID == currentFromID {
            cell.bubbleViewRightAnchor?.isActive = true
            cell.bubbleViewLeftAnchor?.isActive = false
            print(cell.bubbleView.frame.height)
            cell.bubbleView.backgroundColor = UIColor(red: 0/255, green: 137/255, blue: 249/255, alpha: 1)
            cell.textView.textColor = .white
            cell.profileImageView.isHidden = true
        } else {
            cell.bubbleViewRightAnchor?.isActive = false
            cell.bubbleViewLeftAnchor?.isActive = true
            cell.bubbleView.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
            cell.profileImageView.isHidden = false
            cell.textView.textColor = .black
        }
        
    }
    
}
