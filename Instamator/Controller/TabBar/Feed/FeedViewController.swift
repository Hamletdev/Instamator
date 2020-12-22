//
//  FeedViewController.swift
//  Instamator
//
//  Created by Amit Chaudhary on 12/10/20.
//  Copyright © 2020 Amit Chaudhary. All rights reserved.
//

import UIKit
import Firebase
import ActiveLabel

private let reuseIdentifier = "FeedViewCell"

class FeedViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var totalPost = [Post]()
    
    var viewSinglePost = false
    var feedPost: Post?
    
    var currentKey: String? // pagination
    var userProfileVC: UserProfileViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.backgroundColor = .white
        
        self.collectionView!.register(FeedViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: UIControl.Event.valueChanged)
        collectionView.refreshControl = refreshControl
        
        //self.fetchPosts()
        self.fetchPostsWithPagination()
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
        
        self.usernameActiveLabelTapped(cell: cell)
        self.hashTagActiveLabelTapped(cell: cell)
        
        return cell
    }
    
    //pagination
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if totalPost.count > 3 {
            if indexPath.item == totalPost.count - 1 {
                self.fetchPostsWithPagination()
            }
        }
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
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "send2"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(handleShowMessagesFromNavBar))
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
    
    @objc func handleShowMessagesFromNavBar() {
        let messagesUI = MessagesUIViewController()
        navigationController?.pushViewController(messagesUI, animated: true)
    }
}


//MARK: - FeedViewCellDelegate
extension FeedViewController: FeedViewCellDelegate {
    @objc func handleShowMessages(_ cell: FeedViewCell) {
        let messagesUI = MessagesUIViewController()
        navigationController?.pushViewController(messagesUI, animated: true)
    }
    
    
    func handleUsernameButtonTapped(_ cell: FeedViewCell) {
        let userProfileVC = UserProfileViewController(collectionViewLayout: UICollectionViewFlowLayout())
        guard let post = cell.post else {return}
        userProfileVC.headerUser = post.user
        userLoadedFromSearch = true
        navigationController?.pushViewController(userProfileVC, animated: true)
    }
    
    func handleOptionsButtonTapped(_ cell: FeedViewCell) {
        guard let safePost = self.feedPost else {return}
        let alertController = UIAlertController(title: "Options", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Edit Post", style: UIAlertAction.Style.default, handler: { (_) in
            //edit post
            let uploadPostVC = UploadPostViewController()
            let navigationController = UINavigationController(rootViewController: uploadPostVC)
            uploadPostVC.postToEdit = safePost
            uploadPostVC.buttonAction = ButtonAction(rawValue: 1)
            navigationController.modalPresentationStyle = .fullScreen
            self.present(navigationController, animated: true, completion: nil)
        }))
        
        alertController.addAction(UIAlertAction(title: "Delete Post", style: UIAlertAction.Style.destructive, handler: { (_) in
            //delete post
            safePost.deletePost()
            if !self.viewSinglePost {
                self.handleRefresh()
            } else {
                if let userProfileVC = self.userProfileVC {
                self.navigationController?.popViewController(animated: true)
                    userProfileVC.handleRefresh()
                }
            }
            
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func handleLikeButtonTapped(_ cell: FeedViewCell) {
        guard let post = cell.post else {return}
        guard let currentUser = post.user else {return}
        guard let postID = post.postID else {return}
        
        USER_LIKES_REF.child(currentUser.uID).observe(.value) { (snapshot) in
            if postID == snapshot.key {
                post.didLike = true
            }
        }
        print(post.didLike)
        if post.didLike {
            post.updateLikesToDatabase(false) { (likes) in
                cell.likesLabel.text = "\(likes) likes"
                cell.likeButton.setImage(#imageLiteral(resourceName: "like_unselected"), for: UIControl.State.normal)
            }
        } else {
            post.updateLikesToDatabase(true) { (likes) in
                cell.likeButton.setImage(#imageLiteral(resourceName: "like_selected"), for: UIControl.State.normal)
                cell.likesLabel.text = "\(likes) likes"
            }
        }
    }
    
    func handleCommentButtonTapped(_ cell: FeedViewCell) {
        let commentVC = CommentViewController(collectionViewLayout: UICollectionViewFlowLayout())
        guard let safePost = cell.post else {return}
        commentVC.post = safePost
        navigationController?.pushViewController(commentVC, animated: true)
    }
    
    func bringLikesScreenOfUsers(_ cell: FeedViewCell) {
        let followLikeVC = FollowLikeViewController()
        followLikeVC.followLikeScreenMode = FollowLikeScreenMode.init(rawValue: 2)
        followLikeVC.userID = cell.post?.user?.uID
        followLikeVC.postID = cell.post?.postID
        self.navigationController?.pushViewController(followLikeVC, animated: true)
    }
    
    func handleCurrentUserLikedPostOnRefresh(_ cell: FeedViewCell) {
        guard let post = cell.post else { return }
        guard let postId = post.postID else { return }
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        USER_LIKES_REF.child(currentUid).observeSingleEvent(of: .value) { (snapshot) in
            
            // check if post id exists in user-like structure
            if snapshot.hasChild(postId) {
                post.didLike = true
                cell.likeButton.setImage(#imageLiteral(resourceName: "like_selected"), for: .normal)
            } else {
                post.didLike = false
                cell.likeButton.setImage(#imageLiteral(resourceName: "like_unselected"), for: .normal)
            }
            
        }
    }
    
    func hashTagActiveLabelTapped(cell: FeedViewCell) {
        cell.captionLabel.handleHashtagTap { (hashTag) in
            let htVC = HashTagViewController(collectionViewLayout: UICollectionViewFlowLayout())
            htVC.hashTag = hashTag
            self.navigationController?.pushViewController(htVC, animated: true)
        }
    }
    
    func usernameActiveLabelTapped(cell: FeedViewCell) {
        guard let user = cell.post?.user, let username = user.userName else {return}
        let customType = ActiveType.custom(pattern: "\(username)\\b")
        cell.captionLabel.handleCustomTap(for: customType) { (_) in
            
            let userProfileController = UserProfileViewController(collectionViewLayout: UICollectionViewFlowLayout())
            userProfileController.headerUser = user
            userLoadedFromSearch = true
            self.navigationController?.pushViewController(userProfileController, animated: true)
        }
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
                
                self.collectionView.reloadData()
                self.collectionView.refreshControl?.endRefreshing()
            }
        }
    }
    
    func fetchPostsWithPagination() {
        guard let currentUID = Auth.auth().currentUser?.uid else {return}
        if self.currentKey == nil {
            USER_FEED_REF.child(currentUID).queryLimited(toLast: 4).observeSingleEvent(of: DataEventType.value) { (snapshot) in
                self.collectionView.refreshControl?.endRefreshing()
                guard let allObjects = snapshot.children.allObjects as? [DataSnapshot], let first = snapshot.children.allObjects.first as? DataSnapshot else {return}
                allObjects.forEach { (snapshot) in
                    let postID = snapshot.key
                    Database.fetchPost(with: postID) { (post) in
                        self.totalPost.append(post)
                        self.totalPost.sort { (p1, p2) -> Bool in
                            return p1.creationDate > p2.creationDate
                        }
                        
                        self.collectionView.reloadData()
                    }
                }
                self.currentKey = first.key
            }
        } else {
            USER_FEED_REF.child(currentUID).queryOrderedByKey().queryEnding(atValue: self.currentKey).queryLimited(toLast: 6).observeSingleEvent(of: .value) { (snapshot) in
                guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] , let first = snapshot.children.allObjects.first as? DataSnapshot else {return}
                allObjects.forEach { (snapshot) in
                    let postID = snapshot.key
                    if postID != self.currentKey {
                        Database.fetchPost(with: postID) { (post) in
                            self.totalPost.append(post)
                            self.totalPost.sort { (p1, p2) -> Bool in
                                return p1.creationDate > p2.creationDate
                            }
                            
                            self.collectionView.reloadData()
                        }
                    }
                }
                self.currentKey = first.key
            }
        }
    }
    
}


//MARK: - Extra Methods
extension FeedViewController {
    @objc func handleRefresh() {
        self.totalPost.removeAll(keepingCapacity: false)
        self.currentKey = nil
        //self.fetchPosts()
        self.fetchPostsWithPagination()
        self.collectionView.reloadData()
    }
}

