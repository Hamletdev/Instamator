//
//  Post.swift
//  Instamator
//
//  Created by Amit Chaudhary on 12/13/20.
//  Copyright © 2020 Amit Chaudhary. All rights reserved.
//

import Foundation
import UIKit

class Post: Equatable {
    static func == (lhs: Post, rhs: Post) -> Bool {
        if lhs.postID == rhs.postID {
            return true
        } else {
            return false
        }
    }
    
    var caption: String!
    var creationDate: Int!
    var likes: Int!
    var postImageURLString: String!
    var ownerID: String!
    var postID: String!
    var user: User?
    
    init(_ postID: String, user: User, postDictionary: [String: AnyObject]) {
        self.postID = postID
        self.user = user
        
        if let safeCaption = postDictionary["caption"] as? String {
            self.caption = safeCaption
        }
        if let safeCreationDate = postDictionary["creationDate"] as? Int {
            self.creationDate = safeCreationDate
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
}
