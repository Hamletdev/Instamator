//
//  UserProfileViewController.swift
//  Instamator
//
//  Created by Amit Chaudhary on 12/10/20.
//  Copyright © 2020 Amit Chaudhary. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "Cell"
private let headerIdentifier = "HeaderProfileCell"

class UserProfileViewController: UICollectionViewController, UserProfileHeaderViewDelegate {
    
    var user: User?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.backgroundColor = .white

        // Register cell classes and header
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView!.register(UserProfileHeaderView.self, forSupplementaryViewOfKind:UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if userLoadedFromSearch == false {
            self.fetchcurrentUserData()
        } else {
            userLoadedFromSearch = false
        }
    }
    

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    
        // Configure the cell
    
        return cell
    }

  

}


//MARK: - Supplementary Header Data Source
extension UserProfileViewController: UICollectionViewDelegateFlowLayout {
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as! UserProfileHeaderView
        header.delegate = self
        header.user = self.user
        self.navigationItem.title = self.user?.userName
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: self.collectionView.frame.width, height: 180)
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
            self.user = currentUser
            self.collectionView.reloadData()
        }
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
                print(safeSnapshot)
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
                print(safeSnapshot)
            } else {
                numberOfFollowers = 0
            }
            let attributedString = NSMutableAttributedString(string: "\(numberOfFollowers)\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.black])
            attributedString.append(NSAttributedString(string: " Follower", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.systemBlue]))
            header.followersLabel.attributedText = attributedString
        }
    }
    
    func handleFollowingLabelTapped(_ header: UserProfileHeaderView) {
        let followVC = FollowViewController()
        followVC.viewOfFollower = false
        userLoadedFromSearch = true
        followVC.userID = self.user?.uID
        self.navigationController?.pushViewController(followVC, animated: true)
    }
    
    func handleFollowerLabelTapped(_ header: UserProfileHeaderView) {
         let followVC = FollowViewController()
        followVC.viewOfFollower = true
        userLoadedFromSearch = true
        followVC.userID = self.user?.uID
         self.navigationController?.pushViewController(followVC, animated: true)
    }
    
}
