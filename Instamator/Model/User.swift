//
//  User.swift
//  Instamator
//
//  Created by Amit Chaudhary on 12/11/20.
//  Copyright © 2020 Amit Chaudhary. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class User {
    var fullName: String!
    var userName: String!
    var profileImageURLString: String!
    var uID: String!
    var isFollowed = false
    
    init(_ userID: String, userDictionary: [String: AnyObject]) {
        self.uID = userID
        
        if let safeFullName = userDictionary["name"] as? String {
            self.fullName = safeFullName
        }
        if let safeUserName = userDictionary["username"] as? String {
            self.userName = safeUserName
        }
        if let safeImageURLString = userDictionary["profileImageURLString"] as? String {
            self.profileImageURLString = safeImageURLString
        }
    }
    
    //follow an user
    func follow() {
        guard let currentuID = Auth.auth().currentUser?.uid else { return }
        guard let uID = self.uID else {
            return
        }
        self.isFollowed = true
        FOLLOWING_USERS_REF.child(currentuID).updateChildValues([uID: "Added"])
        FOLLOWER_USERS_REF.child(uID).updateChildValues([currentuID: "Added"])
        
        //Add post of another user to current user
        USER_POSTS_REF.child(uID).observe(DataEventType.childAdded) { (snapshot) in
            let postID = snapshot.key
            USER_FEED_REF.child(currentuID).updateChildValues([postID: "FollowButtonTapped"])
        }
    }
    
    func unfollow() {
        guard let currentUID = Auth.auth().currentUser?.uid else {
            return
        }
        guard let uID = self.uID else {return}
        self.isFollowed = false
        FOLLOWING_USERS_REF.child(currentUID).child(uID).removeValue()
        FOLLOWER_USERS_REF.child(uID).child(currentUID).removeValue()
        
        //remove post of another user from current user
        USER_POSTS_REF.child(uID).observe(DataEventType.childAdded) { (snapshot) in
            let postID = snapshot.key
            USER_FEED_REF.child(currentUID).child(postID).removeValue()
        }
    }
    
    func checkIfAnUserIsFollowed(completion: @escaping(Bool) ->()) {
        guard let currentUID = Auth.auth().currentUser?.uid else {return}
        FOLLOWING_USERS_REF.child(currentUID).observeSingleEvent(of: DataEventType.value) { (snapshot) in
            if snapshot.hasChild(self.uID) {
                self.isFollowed = true
                completion(self.isFollowed)
            } else {
                self.isFollowed = false
                completion(self.isFollowed)
            }
        }
    }
    
    
}
