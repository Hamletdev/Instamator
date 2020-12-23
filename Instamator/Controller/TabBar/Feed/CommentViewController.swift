//
//  CommentViewController.swift
//  Instamator
//
//  Created by Amit Chaudhary on 12/16/20.
//  Copyright © 2020 Amit Chaudhary. All rights reserved.
//

import Foundation
import UIKit
import Firebase

fileprivate let reUseIdentifier = "CommentCell"

class CommentViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var post: Post?
    var totalComment = [Comment]()
    
    let commentTextField: UITextField = {
        let aTextField = UITextField()
        aTextField.font = UIFont.systemFont(ofSize: 14)
        aTextField.placeholder = "Enter Comment.."
        return aTextField
    }()
    
    let postButton: UIButton = {
        let aButton = UIButton(type: UIButton.ButtonType.system)
        aButton.setTitle("Post", for: UIControl.State.normal)
        aButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        aButton.addTarget(self, action: #selector(handleUploadCommentToDB), for: UIControl.Event.touchUpInside)
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
        self.commentTextField.anchorView(top: cv.topAnchor, left: cv.leftAnchor, bottom: cv.bottomAnchor, right: self.postButton.leftAnchor, topPadding: 0, leftPadding: 8, bottomPadding: 0, rightPadding: 2, width: 0, height: 0)
        
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
        self.collectionView.backgroundColor = .white
        self.navigationItem.title = "Comments"
        self.collectionView.register(CommentViewCell.self, forCellWithReuseIdentifier: reUseIdentifier)
        self.collectionView.alwaysBounceVertical = true
        self.collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: -50, right: 0)
        self.collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: -50, right: 0)
        self.collectionView.keyboardDismissMode = .interactive
        
        self.fetchComments()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardAppeared), name: UIResponder.keyboardDidShowNotification, object: nil)
    }
    
    
    //MARK: - UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
       return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return totalComment.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: reUseIdentifier, for: indexPath) as! CommentViewCell
        cell.comment = totalComment[indexPath.row]
        self.handleHashtagTapped(cell: cell)
        self.handleMentionTapped(cell: cell)
        return cell
    }
    
    
    //MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let frame = CGRect(x: 0, y: 0, width: collectionView.frame.width, height: 50)
        let dummyCell = CommentViewCell(frame: frame)
        dummyCell.comment = totalComment[indexPath.row]
        dummyCell.layoutIfNeeded()
        let targetSize = CGSize(width: collectionView.frame.width, height: 1000)
        let estimatedSize = dummyCell.systemLayoutSizeFitting(targetSize)
        let height = max(60, estimatedSize.height)
        
        return CGSize(width: self.collectionView.frame.width, height: height)
    }
    
    
}


//MARK: - Post Firebase
extension CommentViewController {
    @objc func handleUploadCommentToDB() {
        guard let currentID = Auth.auth().currentUser?.uid, let commentText = self.commentTextField.text, let postID = self.post?.postID else {return}
        let creationDate = Int(NSDate().timeIntervalSince1970)
        let dictionaryValue = ["commentText": commentText, "creationDate": creationDate, "uID": currentID] as [String: AnyObject]
        COMMENT_REF.child(postID).childByAutoId().updateChildValues(dictionaryValue) { (error, ref) in
            if let safeError = error {
                print(safeError)
            }
            
            if commentText.contains("@") {
                self.uploadMentionedCommentNotificationToDB()
            } else {
              self.uploadCommentNotificationsToDatabase()
            }
            self.commentTextField.text = nil
        }
    }
    
    func uploadMentionedCommentNotificationToDB() {
        guard let currentID = Auth.auth().currentUser?.uid, let commentText = self.commentTextField.text, let postID = self.post?.postID  else {return}
        let creationDate = Int(Date().timeIntervalSince1970)
        let words = commentText.components(separatedBy: .whitespacesAndNewlines)
        for var word in words {
            if word.hasPrefix("@") {
                word = word.trimmingCharacters(in: .punctuationCharacters)
                word = word.trimmingCharacters(in: .symbols)
                USERS_REF.observe(DataEventType.childAdded) { (snapshot) in
                    let userID = snapshot.key
                    USERS_REF.child(userID).observeSingleEvent(of: .value) { (snapshot) in
                        guard let userDictionary = snapshot.value as? [String: AnyObject] else {return}
                        if word == userDictionary["username"] as? String {
                            let notifValues = ["creationDate": creationDate, "currentID": currentID, "postID": postID, "type": COMMENTMENTION_INT_VALUE, "checked": false] as [String: AnyObject]
                            if userID != currentID {
                                NOTIFICATION_REF.child(userID).childByAutoId().updateChildValues(notifValues)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func fetchComments() {
        guard let postID = self.post?.postID else {
            return
        }
        COMMENT_REF.child(postID).observe(DataEventType.childAdded) { (snapshot) in
            guard let dictionaryValue = snapshot.value as? [String: AnyObject], let userID = dictionaryValue["uID"] as? String else {return}
            Database.fetchUser(userID) { (user) in
                let comment = Comment(user, dictionary: dictionaryValue)
                self.totalComment.append(comment)
                self.collectionView.reloadData()
            }
        }
    }
    
    func uploadCommentNotificationsToDatabase() {
        //postID, creationDate, type =0, checked = false, post.ownerID, currentID
        guard let currentID = Auth.auth().currentUser?.uid else {return}
        guard let safePost = self.post, let safePostID = safePost.postID else {return}
        let dictionaryValues = ["creationDate": Int(NSDate().timeIntervalSince1970), "currentID": currentID, "postID": safePostID, "type": COMMENT_VALUE, "checked": false] as [String: AnyObject]
        NOTIFICATION_REF.child(safePost.ownerID).childByAutoId().updateChildValues(dictionaryValues)
    }
    
}


//MARK: - Helper Methods
extension CommentViewController {
    func handleHashtagTapped(cell: CommentViewCell) {
        cell.commentLabel.handleHashtagTap { (hashTag) in
            let htvc = HashTagViewController(collectionViewLayout: UICollectionViewFlowLayout())
            htvc.hashTag = hashTag
            self.navigationController?.pushViewController(htvc, animated: true)
        }
    }
    
    func handleMentionTapped(cell: CommentViewCell) {
        cell.commentLabel.handleMentionTap { (mentionedUsername) in
            USERS_REF.observe(DataEventType.childAdded) { (snapshot) in
                let userID = snapshot.key
                USERS_REF.child(userID).observeSingleEvent(of: DataEventType.value) { (snapshot) in
//                    guard let userDictionary = snapshot.value as? [String: AnyObject] else {return}
//                    let username = userDictionary["username"] as? String
                    Database.fetchUser(userID) { (user) in
                        let userProfileController = UserProfileViewController(collectionViewLayout: UICollectionViewFlowLayout())
                        userProfileController.headerUser = user
                        userLoadedFromSearch = true
                        self.navigationController?.pushViewController(userProfileController, animated: true)
                    }
                }
            }
        }
    }
    
    @objc func keyboardAppeared() {
        print("UIKeyboard Appeared")
        self.collectionView.scrollToLast()
    }
}
