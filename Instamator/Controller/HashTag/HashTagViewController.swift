//
//  HashTagViewController.swift
//  Instamator
//
//  Created by Amit Chaudhary on 12/21/20.
//  Copyright © 2020 Amit Chaudhary. All rights reserved.
//

import Foundation
import UIKit
import Firebase

fileprivate let reUseIdentifier = "HashTagCell"

class HashTagViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var hashTagPosts = [Post]()
    var hashTag: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.register(HashTagViewCell.self, forCellWithReuseIdentifier: reUseIdentifier)
        self.collectionView.backgroundColor = .white
        self.constructNavBar()
        
        self.fetchHashTaggedPosts()
    }
    
    //MARK: - UICollectionViewDataSource
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        hashTagPosts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reUseIdentifier, for: indexPath) as! HashTagViewCell
        cell.post = hashTagPosts[indexPath.item]
        return cell
    }
    
    
    //MARK: - UICollectionViewDelegate
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let feedVC = FeedViewController(collectionViewLayout: UICollectionViewFlowLayout())
        feedVC.viewSinglePost = true
        feedVC.feedPost = hashTagPosts[indexPath.item]
        navigationController?.pushViewController(feedVC, animated: true)
    }
    
    
    //MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (self.collectionView.frame.width - 2) / 3
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
}


//MARK: - Helper Methods
extension HashTagViewController {
    func constructNavBar() {
        guard let safeHashTag = self.hashTag else {return}
        self.navigationItem.title = safeHashTag
    }
}


//MARK: - Firebase Operations
extension HashTagViewController {
    func fetchHashTaggedPosts() {
        guard let safeHashTag = self.hashTag else {return}
        HASHTAG_POSTS_REF.child(safeHashTag).observe(DataEventType.childAdded) { (snapshot) in
            let postID = snapshot.key
            Database.fetchPost(with: postID) { (hashtagPost) in
                self.hashTagPosts.append(hashtagPost)
                self.collectionView.reloadData()
            }
        }
    }
}
