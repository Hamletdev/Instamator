//
//  Database.swift
//  Instamator
//
//  Created by Amit Chaudhary on 12/13/20.
//  Copyright © 2020 Amit Chaudhary. All rights reserved.
//

import Foundation
import Firebase
import UIKit

extension Database {
    static func fetchUser(_ userID: String, completion: @escaping(User) ->()) {
        USERS_REF.child(userID).observeSingleEvent(of: .value) { (snapshot) in
            guard let safeUserDictionary = snapshot.value as? [String: AnyObject] else {return}
            let safeUser = User(userID, userDictionary: safeUserDictionary)
            completion(safeUser)
        }
    }
    
    static func fetchPost(with postID: String, completion: @escaping(Post) -> ()) {
        POSTS_REF.child(postID).observeSingleEvent(of: DataEventType.value) { (snapshot) in
            guard let postDict = snapshot.value as? [String: AnyObject], let ownerID = postDict["ownerID"] as? String else { return }
            Database.fetchUser(ownerID) { (user) in
                let aPost = Post(postID, user: user, postDictionary: postDict)
                completion(aPost)
            }
        }
    }
    
}
