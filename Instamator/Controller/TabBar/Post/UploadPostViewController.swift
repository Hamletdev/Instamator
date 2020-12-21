//
//  UploadPostViewController.swift
//  Instamator
//
//  Created by Amit Chaudhary on 12/10/20.
//  Copyright © 2020 Amit Chaudhary. All rights reserved.
//

import UIKit
import Firebase

class UploadPostViewController: UIViewController, UITextViewDelegate {
    
    var postImage: UIImage?
    
    let photoImageView: UIImageView = {
        let aImageView = UIImageView()
        aImageView.contentMode = .scaleAspectFill
        aImageView.clipsToBounds = true
        aImageView.backgroundColor = .blue
        return aImageView
    }()
    
    let captionTextView: UITextView = {
        let aTextView = UITextView()
        aTextView.backgroundColor = .systemGroupedBackground
        aTextView.font = UIFont.systemFont(ofSize: 12)
        return aTextView
    }()
    
    let postButton: UIButton = {
        let aButton = UIButton(type: UIButton.ButtonType.system)
        aButton.backgroundColor = UIColor(red: 149/255, green: 204/255, blue: 244/255, alpha: 1)
        aButton.setTitle("POST", for: UIControl.State.normal)
        aButton.setTitleColor(.white, for: UIControl.State.normal)
        aButton.layer.cornerRadius = 5
        aButton.addTarget(self, action: #selector(handlePostButtonTapped), for: UIControl.Event.touchUpInside)
        aButton.isEnabled = false
        return aButton
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.captionTextView.delegate = self
        
        self.view.addSubview(photoImageView)
        photoImageView.anchorView(top: self.view.topAnchor, left: self.view.leftAnchor, bottom: nil, right: nil, topPadding: 92, leftPadding: 12, bottomPadding: 0, rightPadding: 0, width: 120, height: 120)
        self.view.addSubview(captionTextView)
        captionTextView.anchorView(top: self.view.topAnchor, left: photoImageView.rightAnchor, bottom: nil, right: self.view.rightAnchor, topPadding: 92, leftPadding: 12, bottomPadding: 0, rightPadding: 12, width: 0, height: 120)
        self.view.addSubview(postButton)
        postButton.anchorView(top: self.photoImageView.bottomAnchor, left: self.view.leftAnchor, bottom: nil, right: self.view.rightAnchor, topPadding: 20, leftPadding: 40, bottomPadding: 0, rightPadding: 40, width: 0, height: 40)

        self.loadPostImage()
    }
    
    func loadPostImage() {
        guard let safePostImage = self.postImage else {return}
        photoImageView.image = safePostImage
    }

}


//MARK: - Firebase Operation Post
extension UploadPostViewController {
    @objc func handlePostButtonTapped() {
        guard let caption = self.captionTextView.text, let postImage = photoImageView.image, let currentUID = Auth.auth().currentUser?.uid else {return}
        guard let uploadData = postImage.pngData() else {return}
        let fileName = NSUUID().uuidString
        let creationDate = Int(NSDate().timeIntervalSince1970)
        
        //2. storage reference to get image downloadURL
        let fbStorageRef = Storage.storage().reference()
        fbStorageRef.child("Post_Images").child(fileName).putData(uploadData, metadata: nil) { (storageMetaData, error) in
            if let safeError = error {
                print(safeError)
            }
            fbStorageRef.child("Post_Images").child(fileName).downloadURL { (downloadURL, error) in
                if let safeError = error {
                    print(safeError)
                }
                if let safeDownloadURL = downloadURL?.absoluteString {
                    
                    let postID = POSTS_REF.childByAutoId()
                    
                    let postValues = ["caption": caption, "creationDate": creationDate, "postImageURLString": safeDownloadURL, "likes": 0, "ownerID": currentUID] as [String: AnyObject]
                    
                    //attach each PostID to it's owner; helpful in fetch posts for user
                    let userPostValue = [postID.key!: 1]
                    DB_REF.child("User-Posts").child(currentUID).updateChildValues(userPostValue)
                    
                    //updated post to owner and to it's followers in USER_FEED_REF
                    self.addPostsFromFollowingUsers(with: postID.key!)
                    self.uploadHashTagToDatabase(postID: postID.key!)
                    
                    //4. add a post to database
                    postID.updateChildValues(postValues) { (error, databaseRef) in
                        if let safeError = error {
                            print(safeError)
                        }
                        
                        self.dismiss(animated: true) {
                            self.tabBarController?.selectedIndex = 0
                        }
                    }  // (error, databasereference)
                }
                
            } // (downloadURL, error)
            
        }  //(storagemetadata, ref)
        
    }
    
    func addPostsFromFollowingUsers(with postID: String) {
        guard let currentUID = Auth.auth().currentUser?.uid else {return}
        FOLLOWING_USERS_REF.child(currentUID).observe(DataEventType.childAdded) { (snapshot) in
            let followingID = snapshot.key
            USER_POSTS_REF.child(followingID).observe(DataEventType.childAdded) { (snapshot2) in
                let postID = snapshot2.key
                USER_FEED_REF.child(currentUID).updateChildValues([postID: "followingFeedAdded"])
            }
        }
        USER_POSTS_REF.child(currentUID).observe(DataEventType.childAdded) { (snapshot3) in
            let postID = snapshot3.key
            USER_FEED_REF.child(currentUID).updateChildValues([postID: "ownerFeedAdded"])
        }
        
    }
    
    func uploadHashTagToDatabase(postID: String) {
        guard let caption = self.captionTextView.text else {return}
        let words = caption.components(separatedBy: .whitespacesAndNewlines)
        for var word in words {
            if word.hasPrefix("#") {
                word = word.trimmingCharacters(in: .punctuationCharacters)
                word = word.trimmingCharacters(in: .symbols)
                let hashTagValues = [postID: "hashtagpostID"]
                HASHTAG_POSTS_REF.child(word.lowercased()).updateChildValues(hashTagValues)
            }
        }
    }
}


//MARK: - UITextViewDelegate
extension UploadPostViewController {
    func textViewDidChange(_ textView: UITextView) {
        guard !textView.text.isEmpty else {
            self.postButton.isEnabled = false
            self.postButton.backgroundColor = UIColor(red: 149/255, green: 204/255, blue: 244/255, alpha: 1)
            return
        }
        self.postButton.isEnabled = true
        self.postButton.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
    }
}


