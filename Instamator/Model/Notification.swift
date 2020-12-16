//
//  Notification.swift
//  Instamator
//
//  Created by Amit Chaudhary on 12/16/20.
//  Copyright © 2020 Amit Chaudhary. All rights reserved.
//

import Foundation
import UIKit

class Notification {
    var user: User!
    var posT: Post?
    var creationDate: Int!
    var didCheck = false
    var type: Int!
    var currentID: String!
    var postID: String!
    var notificationType: NotificationType!
    
    init(_ user: User, post: Post? = nil, dictionary: [String: AnyObject]) {
        self.user = user
        if let safePost = post {
            self.posT = safePost
        }
        if let safeCreationDate = dictionary["creationDate"] as? Int {
            self.creationDate = safeCreationDate
        }
        if let safeType = dictionary["type"] as? Int {
            self.type = safeType
        }
        if let safepostID = dictionary["postID"] as? String {
            self.postID = safepostID
        }
        if let safeChecked = dictionary["checked"] as? Int {
            if safeChecked == 0 {
                self.didCheck = false
            } else {
                self.didCheck = true
            }
        }
        if let safeUID = dictionary["currentID"] as? String {
            self.currentID = safeUID
        }
        
        if let safeType = dictionary["type"] as? Int {
            self.notificationType = NotificationType.init(rawValue: safeType)
        }
        
        
    }
    
}
