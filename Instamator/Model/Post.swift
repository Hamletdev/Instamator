//
//  Post.swift
//  Instamator
//
//  Created by Amit Chaudhary on 12/13/20.
//  Copyright © 2020 Amit Chaudhary. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class Post: Equatable {
    static func == (lhs: Post, rhs: Post) -> Bool {
        if lhs.postID == rhs.postID {
            return true
        } else {
            return false
        }
    }
    
    var caption: String!
    var creationDate: Date!
    var likes: Int!
    var postImageURLString: String!
    var ownerID: String!
    var postID: String!
    var user: User?
    var didLike = false
    
    init(_ postID: String, user: User, postDictionary: [String: AnyObject]) {
        self.postID = postID
        self.user = user
        
        if let safeCaption = postDictionary["caption"] as? String {
            self.caption = safeCaption
        }
        if let safeCreationDate = postDictionary["creationDate"] as? Double {
             self.creationDate = Date(timeIntervalSince1970: safeCreationDate)
        }
        if let safeLikes = postDictionary["likes"] as? Int {
            self.likes = safeLikes
        }
        
        if let safeOwnerID = postDictionary["ownerID"] as? String {
            self.ownerID = safeOwnerID
        }
        
        if let safePostImageString = postDictionary["postImageURLString"] as? String {
            self.postImageURLString = safePostImageString
        }
    }
    
    func updateLikesToDatabase(_ enableLike: Bool, completion:@escaping (Int) ->()) {
        guard let currentID = Auth.auth().currentUser?.uid else {return}
        guard let postID = self.postID else {return}
        if enableLike {
            USER_LIKES_REF.child(currentID).updateChildValues([postID: 1]) { (error, ref) in
                if let safeError = error {
                    print(safeError)
                }
                self.postLikeNotificationToDatabase()
                POST_LIKES_REF.child(postID).updateChildValues([currentID: 1]) { (error, ref) in
                    self.likes += 1
                    self.didLike = true
                    POSTS_REF.child(postID).child("likes").setValue(self.likes)
                    completion(self.likes)
                }
            }
            
        } else {
            USER_LIKES_REF.child(currentID).child(self.postID).observeSingleEvent(of: DataEventType.value) { (snapshot) in  // 1
                if let notificationID = snapshot.value as? String {
                
                NOTIFICATION_REF.child(self.ownerID).child(notificationID).removeValue()   //2
                
                USER_LIKES_REF.child(currentID).child(postID).removeValue { (error, ref) in   //3
            
                    POST_LIKES_REF.child(postID).child(currentID).removeValue { (error, ref) in
                        if self.likes > 0 {
                            self.likes -= 1
                            self.didLike = false
                            POSTS_REF.child(postID).child("likes").setValue(self.likes)
                            completion(self.likes)
                        }
                    }
                }   //3
                } else {
                    USER_LIKES_REF.child(currentID).child(postID).removeValue { (error, ref) in   //3
                
                        POST_LIKES_REF.child(postID).child(currentID).removeValue { (error, ref) in
                            if self.likes > 0 {
                                self.likes -= 1
                                self.didLike = false
                                POSTS_REF.child(postID).child("likes").setValue(self.likes)
                                completion(self.likes)
                            }
                        }
                    }
                
                }  // else
                
            }  //1
            
        }  //else
    }
    
    func postLikeNotificationToDatabase() {
        //creationDate, checked, currentID, post.ownerID, postID, type
        guard let currentID = Auth.auth().currentUser?.uid, let postID = self.postID else {return}
        let creationDate = Int(NSDate().timeIntervalSince1970)
        if currentID != self.ownerID {
            let dictionaryValues = ["creationDate": creationDate, "currentID": currentID,"postID": postID, "type": LIKE_VALUE, "checked": 0] as [String: AnyObject]
            let notificationRef = NOTIFICATION_REF.child(self.ownerID).childByAutoId()
            notificationRef.updateChildValues(dictionaryValues) { (error, ref) in
                USER_LIKES_REF.child(currentID).child(self.postID).setValue(notificationRef.key)
            }
        }
    }
    
    func deletePost() {
        guard let currentID = Auth.auth().currentUser?.uid else {return}
        Storage.storage().reference(forURL: self.postImageURLString).delete(completion: nil)
        //1
        FOLLOWER_USERS_REF.child(currentID).observe(DataEventType.childAdded) { (snapshot) in
            let followerID = snapshot.key
            //2
            USER_FEED_REF.child(followerID).child(self.postID).removeValue()
            //3
            USER_FEED_REF.child(currentID).child(self.postID).removeValue()
            //4
            USER_POSTS_REF.child(currentID).child(self.postID).removeValue()
            //5
            POST_LIKES_REF.child(self.postID).observe(DataEventType.childAdded) { (snapshot) in
                let likeUserID = snapshot.key
                //6
                USER_LIKES_REF.child(likeUserID).child(self.postID).observeSingleEvent(of: .value) { (snapshot) in
                    guard let notificationID = snapshot.value as? String else {return}
                    //7
                    NOTIFICATION_REF.child(self.ownerID).child(notificationID).removeValue { (error, ref) in
                        POST_LIKES_REF.child(self.postID).removeValue()
                        USER_LIKES_REF.child(likeUserID).child(self.postID).removeValue()
                    }
                }
            }
            
            let words = self.caption.components(separatedBy: .whitespacesAndNewlines)
            for var word in words {
                if word.hasPrefix("#") {
                    word = word.trimmingCharacters(in: .punctuationCharacters)
                    word = word.trimmingCharacters(in: .symbols)
                    HASHTAG_POSTS_REF.child(word).child(self.postID).removeValue()
                }
            }
        }
        
        COMMENT_REF.child(self.postID).removeValue()
        POSTS_REF.child(self.postID).removeValue()
    }
    
}
