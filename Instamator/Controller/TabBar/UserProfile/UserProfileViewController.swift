//
//  UserProfileViewController.swift
//  Instamator
//
//  Created by Amit Chaudhary on 12/10/20.
//  Copyright © 2020 Amit Chaudhary. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "UserProfileCell"
private let headerIdentifier = "HeaderProfileCell"

class UserProfileViewController: UICollectionViewController, UserProfileHeaderViewDelegate {
    
    var headerUser: User?
    
    var totalPost = [Post]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.backgroundColor = .white
        
        // Register cell classes and header
        self.collectionView!.register(UserProfileCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView!.register(UserProfileHeaderView.self, forSupplementaryViewOfKind:UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if userLoadedFromSearch == false {
            self.fetchcurrentUserData()
            self.fetchPosts(Auth.auth().currentUser?.uid)
        } else {
            userLoadedFromSearch = false
            self.fetchPosts(self.headerUser?.uID)
        }
    }
    
    
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return totalPost.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! UserProfileCell
        
        cell.post = totalPost[indexPath.row]
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as! UserProfileHeaderView
        header.delegate = self
        header.user = self.headerUser
        
        self.navigationItem.title = self.headerUser?.userName
        return header
    }
    
    
    //MARK: - UICollectionViewDelegate
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let feedVC = FeedViewController(collectionViewLayout: UICollectionViewFlowLayout())
        feedVC.viewSinglePost = true
        feedVC.feedPost = totalPost[indexPath.row]
        navigationController?.pushViewController(feedVC, animated: true)
    }
    
    
    
}


//MARK: - UICollectionViewDelegateFlowLayout
extension UserProfileViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: self.collectionView.frame.width, height: 180)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (self.collectionView.frame.width - 2) / 3
        return CGSize(width: width, height: width)
    }
    
}


//MARK: - UserProfileHeaderViewDelegate
extension UserProfileViewController {
    func handleEditFollowButtonTapped(_ header: UserProfileHeaderView) {
        guard let safeUser = header.user else {return}
        if header.editProfileButton.titleLabel?.text == "Follow" {
            header.editProfileButton.setTitle("Following", for: UIControl.State.normal)
            safeUser.follow()
        } else if header.editProfileButton.titleLabel?.text == "Following" {
            header.editProfileButton.setTitle("Follow", for: UIControl.State.normal)
            safeUser.unfollow()
        }
    }
    
    func setHeaderUserStats(_ header: UserProfileHeaderView) {
        var numberOfFollowers = 0
        var numberOfFollowing = 0
        guard let userID = header.user?.uID else {return}
        FOLLOWING_USERS_REF.child(userID).observe(.value) { (snapshot) in
            if let safeSnapshot = snapshot.value as? [String: AnyObject] {
                numberOfFollowing = safeSnapshot.count
                
            } else {
                numberOfFollowing = 0
            }
            let attributedString = NSMutableAttributedString(string: "\(numberOfFollowing)\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.black])
            attributedString.append(NSAttributedString(string: " Following", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.systemBlue]))
            header.followingLabel.attributedText = attributedString
        }
        
        FOLLOWER_USERS_REF.child(userID).observe(.value) { (snapshot) in
            if let safeSnapshot = snapshot.value as? [String: AnyObject] {
                numberOfFollowers = safeSnapshot.count
                
            } else {
                numberOfFollowers = 0
            }
            let attributedString = NSMutableAttributedString(string: "\(numberOfFollowers)\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.black])
            attributedString.append(NSAttributedString(string: " Follower", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.systemBlue]))
            header.followersLabel.attributedText = attributedString
        }
    }
    
    func handleFollowingLabelTapped(_ header: UserProfileHeaderView) {
        let followVC = FollowLikeViewController()
//        followVC.viewOfFollower = false
        followVC.followLikeScreenMode = FollowLikeScreenMode.init(rawValue: 0)
        userLoadedFromSearch = true
        followVC.userID = self.headerUser?.uID
        self.navigationController?.pushViewController(followVC, animated: true)
    }
    
    func handleFollowerLabelTapped(_ header: UserProfileHeaderView) {
        let followVC = FollowLikeViewController()
//        followVC.viewOfFollower = true
        followVC.followLikeScreenMode = FollowLikeScreenMode.init(rawValue: 1)
        userLoadedFromSearch = true
        followVC.userID = self.headerUser?.uID
        self.navigationController?.pushViewController(followVC, animated: true)
    }
    
}


//MARK: - Firebase Operations
extension UserProfileViewController {
    
    func fetchcurrentUserData() {
        
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            return
        }
        
        Database.database().reference().child("Users").child(currentUserID).observe(DataEventType.value) { (snapshot) in
            guard let currentUserDictionary = snapshot.value as? [String: AnyObject] else { return }
            
            let currentUser: User = User(currentUserID, userDictionary: currentUserDictionary)
            self.headerUser = currentUser
            self.collectionView.reloadData()
        }
    }
    
    func fetchPosts(_ userID: String?) {
        guard let headerUID = userID else {return}
        USER_POSTS_REF.child(headerUID).observe(DataEventType.childAdded) { (snapshot) in
            let postID = snapshot.key
            Database.fetchPost(with: postID) { (post) in
                if self.totalPost.contains(post) {
                    return
                } else if (self.totalPost.count > 0) {
                    if self.totalPost[0].ownerID != post.ownerID {
                        self.totalPost = [Post]()
                        self.totalPost.append(post)
                        self.totalPost.sort { (p1, p2) -> Bool in
                            return p1.creationDate > p2.creationDate
                        }
                        self.collectionView.reloadData()
                    } else {
                        self.totalPost.append(post)
                        self.totalPost.sort { (p1, p2) -> Bool in
                            return p1.creationDate > p2.creationDate
                        }
                        self.collectionView.reloadData()
                    }
                } else {
                    self.totalPost.append(post)
                    self.totalPost.sort { (p1, p2) -> Bool in
                        return p1.creationDate > p2.creationDate
                    }
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
}

