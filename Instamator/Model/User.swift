//
//  User.swift
//  Instamator
//
//  Created by Amit Chaudhary on 12/11/20.
//  Copyright © 2020 Amit Chaudhary. All rights reserved.
//

import Foundation
import UIKit

class User {
    var fullName: String!
    var userName: String!
    var profileImageURLString: String!
    var uID: String!
    
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
    
}
