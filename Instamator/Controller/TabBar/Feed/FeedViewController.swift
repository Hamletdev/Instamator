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

    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.backgroundColor = .white

        self.collectionView!.register(FeedViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.fetchPosts()
        
        self.addLogOutButton()
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! FeedViewCell
        cell.delegate = self
        cell.post = totalPost[indexPath.row]
        
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
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Log Out", style: UIBarButtonItem.Style.plain, target: self, action: #selector(handleLogOut))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "send2"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(handleShowMessages))
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
        print("A")
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
        POSTS_REF.observe(.childAdded) { (snapshot) in
            let postID = snapshot.key
            guard let postDictValue = snapshot.value as? [String: AnyObject] else { return}
            let fetchedPost = Post(postID, postDictionary: postDictValue)
            self.totalPost.append(fetchedPost)
            self.totalPost.sort { (p1, p2) -> Bool in
                return p1.creationDate > p2.creationDate
            }
            self.collectionView.reloadData()
        }
    }
}
