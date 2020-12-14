//
//  FeedViewController.swift
//  Instamator
//
//  Created by Amit Chaudhary on 12/10/20.
//  Copyright © 2020 Amit Chaudhary. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "FeedViewCell"

class FeedViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var totalPost = [Post]()
    
    var viewSinglePost = false
    var feedPost: Post?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.backgroundColor = .white
        
        self.collectionView!.register(FeedViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: UIControl.Event.valueChanged)
        collectionView.refreshControl = refreshControl
        
        self.fetchPosts()
        if !viewSinglePost {
            self.addLogOutButton()
        }
    }
    
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if viewSinglePost {
            return 1
        } else {
            return totalPost.count
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! FeedViewCell
        cell.delegate = self
        if viewSinglePost {
            if let singlePost = self.feedPost {
                cell.post = singlePost
            } else {
                cell.post = totalPost[indexPath.row]
            }
        } else {
            cell.post = totalPost[indexPath.row]
        }
        
        return cell
    }
    
    
    //MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.collectionView.frame.width
        return CGSize(width: width, height: width + (width / 2) - 25)
    }
    
}


//MARK: - NavigationItems
extension FeedViewController {
    func addLogOutButton() {
        self.navigationItem.title = "Feed"
        if !viewSinglePost {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Log Out", style: UIBarButtonItem.Style.plain, target: self, action: #selector(handleLogOut))
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "send2"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(handleShowMessages))
        }
    }
    
    @objc func handleLogOut() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Log Out", style: UIAlertAction.Style.destructive, handler: { (action) in
            do {
                try Auth.auth().signOut()
                let loginVC = LogInViewController()
                let navController = UINavigationController(rootViewController: loginVC)
                navController.modalPresentationStyle = .fullScreen
                self.present(navController, animated: true, completion: nil)
            } catch {
                print(error)
            }
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc func handleShowMessages() {
        
    }
}


//MARK: - FeedViewCellDelegate
extension FeedViewController: FeedViewCellDelegate {
    func handleUsernameButtonTapped(_ cell: FeedViewCell) {
        let userProfileVC = UserProfileViewController(collectionViewLayout: UICollectionViewFlowLayout())
        guard let post = cell.post else {return}
        userProfileVC.headerUser = post.user
        userLoadedFromSearch = true
        navigationController?.pushViewController(userProfileVC, animated: true)
    }
    
    func handleOptionsButtonTapped(_ cell: FeedViewCell) {
        print("B")
    }
    
    func handleLikeButtonTapped(_ cell: FeedViewCell) {
        print("C")
    }
    
    func handleCommentButtonTapped(_ cell: FeedViewCell) {
        print("D")
    }
    
    
}


//MARK: - Firebase Operations
extension FeedViewController {
    func fetchPosts() {
        guard let currentUID = Auth.auth().currentUser?.uid else {return}
        USER_FEED_REF.child(currentUID).observe(DataEventType.childAdded) { (snapshot) in
            let postID = snapshot.key
            Database.fetchPost(with: postID) { (post) in
                self.totalPost.append(post)
                self.totalPost.sort { (p1, p2) -> Bool in
                    return p1.creationDate > p2.creationDate
                }
                self.collectionView.refreshControl?.endRefreshing()
                self.collectionView.reloadData()
            }
        }
    }
    
}


//MARK: - Extra Methods
extension FeedViewController {
    @objc func handleRefresh() {
        self.totalPost.removeAll(keepingCapacity: false)
        self.fetchPosts()
        self.collectionView.reloadData()
    }
}

