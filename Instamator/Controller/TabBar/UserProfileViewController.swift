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

class UserProfileViewController: UICollectionViewController {
    
    var user: User?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.backgroundColor = .white

        // Register cell classes and header
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView.register(UserProfileHeaderView.self, forSupplementaryViewOfKind:UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier)

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
