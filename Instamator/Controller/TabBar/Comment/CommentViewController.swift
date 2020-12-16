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
    
    var postID: String?
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
        self.collectionView.backgroundColor = .white
        self.navigationItem.title = "Comments"
        self.collectionView.register(CommentViewCell.self, forCellWithReuseIdentifier: reUseIdentifier)
        self.collectionView.alwaysBounceVertical = true
        self.collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: -50, right: 0)
        self.collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: -50, right: 0)
        self.collectionView.keyboardDismissMode = .interactive
        
        self.fetchComments()
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
        guard let currentID = Auth.auth().currentUser?.uid, let commentText = self.commentTextField.text, let postID = self.postID else {return}
        let creationDate = Int(NSDate().timeIntervalSince1970)
        let dictionaryValue = ["commentText": commentText, "creationDate": creationDate, "uID": currentID] as [String: AnyObject]
        COMMENT_REF.child(postID).childByAutoId().updateChildValues(dictionaryValue) { (error, ref) in
            if let safeError = error {
                print(safeError)
            }
            self.commentTextField.text = nil
        }
    }
    
    func fetchComments() {
        guard let postID = self.postID else {
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
}
