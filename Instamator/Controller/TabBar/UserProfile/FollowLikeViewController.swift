//
//  FollowLikeViewController.swift
//  Instamator
//
//  Created by Amit Chaudhary on 12/12/20.
//  Copyright © 2020 Amit Chaudhary. All rights reserved.
//

import UIKit
import Firebase

fileprivate let reuseIdentifier = "FollowCell"

class FollowLikeViewController: UITableViewController {
    
    var totalUsers = [User]()
    var viewOfFollower = false
    var userID: String?
    var postID: String?
    
    var followLikeScreenMode = FollowLikeScreenMode(rawValue: 0)

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(FollowLikeViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        
        if followLikeScreenMode?.rawValue == 1 {
            self.navigationItem.title = "Followers"
        } else if followLikeScreenMode?.rawValue == 0 {
            self.navigationItem.title = "Following"
        } else if followLikeScreenMode?.rawValue == 2 {
            self.navigationItem.title = "Likes"
        }
        
        self.tableView.separatorColor = .clear
        self.fetchTotalUsers()

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return totalUsers.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! FollowLikeViewCell

        // Configure the cell...
        cell.delegate = self
        cell.followUser = totalUsers[indexPath.row]

        return cell
    }

}


//MARK: - Firebase Operation
extension FollowLikeViewController {
    func fetchTotalUsers() {
        
        guard let uID = self.userID else {return}
        if self.followLikeScreenMode?.rawValue == 1 {
            FOLLOWER_USERS_REF.child(uID).observeSingleEvent(of: .value) { (snapshot) in
            
                guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
                allObjects.forEach { (snapshot) in
                    
                    let followerID = snapshot.key
                    USERS_REF.child(followerID).observeSingleEvent(of: .value) { (snapshot) in
                        guard let safeUserDictionary = snapshot.value as? [String: AnyObject] else {return}
                        let user = User(followerID, userDictionary: safeUserDictionary)
                        self.totalUsers.append(user)
                        self.tableView.reloadData()
                    }
                }  //foreac
            }
        } else if self.followLikeScreenMode?.rawValue == 0 {
            FOLLOWING_USERS_REF.child(uID).observeSingleEvent(of: .value) { (snapshot) in
                guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else {return}
                allObjects.forEach { (snapshot) in
                    let followingID = snapshot.key
                    USERS_REF.child(followingID).observeSingleEvent(of: .value) { (snapshot) in
                        guard let safeUserDictionary = snapshot.value as? [String: AnyObject] else {return}
                        let user = User(followingID, userDictionary: safeUserDictionary)
                        self.totalUsers.append(user)
                        self.tableView.reloadData()
                    }
                }
            }
        } else if self.followLikeScreenMode?.rawValue == 2 {
            guard let safePostID = self.postID else {return}
            POST_LIKES_REF.child(safePostID).observe(DataEventType.childAdded) { (snapshot) in
                Database.fetchUser(snapshot.key) { (user) in
                    self.totalUsers.append(user)
                    self.tableView.reloadData()
                }
            }
        }
    }
}


//MARK: - FollowViewCellDelegate
extension FollowLikeViewController: FollowLikeViewCellDelegate {
    func handleFollowSideButton(_ cell: FollowLikeViewCell) {
        guard let cellUser = cell.followUser else {return}
       
        if cellUser.isFollowed {
            cellUser.unfollow()
            cell.followSideButton.setTitle("Follow", for: UIControl.State.normal)
            cell.followSideButton.setTitleColor(.white, for: UIControl.State.normal)
            cell.followSideButton.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
        } else {
            cellUser.follow()
            cell.followSideButton.setTitle("Following", for: UIControl.State.normal)
            cell.followSideButton.setTitleColor(.black, for: UIControl.State.normal)
            cell.followSideButton.layer.borderWidth = 0.5
            cell.followSideButton.layer.borderColor = UIColor.lightGray.cgColor
            cell.followSideButton.backgroundColor = .white
        }
    }
    
    
}
