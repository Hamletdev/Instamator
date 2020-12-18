//
//  NotificationViewController.swift
//  Instamator
//
//  Created by Amit Chaudhary on 12/10/20.
//  Copyright © 2020 Amit Chaudhary. All rights reserved.
//

import UIKit
import Firebase

fileprivate let reUseIdentifier = "NotificationCell"

class NotificationViewController: UITableViewController {
    
    var timer: Timer?
    
    var totalNotifications = [Notification]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Notifications"
        self.tableView.register(NotificationViewCell.self, forCellReuseIdentifier: reUseIdentifier)
        self.tableView.separatorColor = .clear
        
        self.fetchNotifications()

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return totalNotifications.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reUseIdentifier, for: indexPath) as! NotificationViewCell
        cell.delegate = self
        cell.notification = totalNotifications[indexPath.row]

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    
    //MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //present to notification user profile
        guard let notificationUser = totalNotifications[indexPath.row].user else {return}
        let userProfileVC = UserProfileViewController(collectionViewLayout: UICollectionViewFlowLayout())
        userProfileVC.headerUser = notificationUser
        self.navigationController?.pushViewController(userProfileVC, animated: true)
        userLoadedFromSearch = true
    }
  

}


//MARK: - Firebase Data Operations
extension NotificationViewController {
    func fetchNotifications() {
        guard let currentID = Auth.auth().currentUser?.uid else {return}
        NOTIFICATION_REF.child(currentID).observe(DataEventType.childAdded) { (snapshot) in
            
            guard let dictionary = snapshot.value as? [String: AnyObject] else { return }
             
            if let userID = dictionary["currentID"] as? String  {
                Database.fetchUser(userID) { (user) in
                    if let postID = dictionary["postID"] as? String {
                        Database.fetchPost(with: postID) { (post) in
                            let newNotification = Notification(user, post: post, dictionary: dictionary)
                            self.totalNotifications.append(newNotification)
                            self.sortNotificationsByDate()
                        }
                    } else {
                        let newNotification = Notification(user, dictionary: dictionary)
                        self.totalNotifications.append(newNotification)
                        self.sortNotificationsByDate()
                    }
                }
            }
        }
    }
    
}


//MARK: - NotificationViewCellDelegate
extension NotificationViewController: NotificationViewCellDelegate {
    func postNotificationImageTapped(_ cell: NotificationViewCell) {
        guard let notificationPost = cell.notification?.posT else {return}
        let feedVC = FeedViewController(collectionViewLayout: UICollectionViewFlowLayout())
        feedVC.viewSinglePost = true
        feedVC.feedPost = notificationPost
        navigationController?.pushViewController(feedVC, animated: true)
    }
    
    func followNotificationButtonTapped(_ cell: NotificationViewCell) {
        guard let cellUser = cell.notification?.user else {return}

         if cellUser.isFollowed {
             cellUser.unfollow()
             cell.followButton.setTitle("Follow", for: UIControl.State.normal)
             cell.followButton.setTitleColor(.white, for: UIControl.State.normal)
             cell.followButton.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
         } else {
             cellUser.follow()
             cell.followButton.setTitle("Following", for: UIControl.State.normal)
             cell.followButton.setTitleColor(.black, for: UIControl.State.normal)
             cell.followButton.layer.borderWidth = 0.5
             cell.followButton.layer.borderColor = UIColor.lightGray.cgColor
             cell.followButton.backgroundColor = .white
         }
    }
    
}


//MARK: - Helper
extension NotificationViewController {
    @objc func sortNotificationsByDate() {
           self.totalNotifications.sort { (notif1, notif2) -> Bool in
               return notif1.creationDate > notif2.creationDate
           }
       self.tableView.reloadData()
       }


//       @objc func handleRefresh() {
//              self.totalNotifications.removeAll()
//              self.tableView.reloadData()
//              fetchNotifications()
//              refresher.endRefreshing()
//          }
//
//       func configureRefreshControl() {
//              refresher.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
//              self.tableView.refreshControl = refresher
//          }
}


