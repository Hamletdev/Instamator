//
//  Comment.swift
//  Instamator
//
//  Created by Amit Chaudhary on 12/16/20.
//  Copyright © 2020 Amit Chaudhary. All rights reserved.
//

import Foundation
import UIKit

class Comment {
    var commentText: String!
    var userID: String!
    var creationDate: Date!
    var user: User!
    
    init(_ user: User, dictionary: [String: AnyObject]) {
        self.user = user
        if let safeCommentText = dictionary["commentText"] as? String {
            self.commentText = safeCommentText
        }
        if let safeUserID = dictionary["uID"] as? String {
            self.userID = safeUserID
        }
        if let safeCreationDate = dictionary["creationDate"] as? Double {
            self.creationDate = Date(timeIntervalSince1970: safeCreationDate)
        }
    }
}
