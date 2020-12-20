//
//  Message.swift
//  Instamator
//
//  Created by Amit Chaudhary on 12/19/20.
//  Copyright © 2020 Amit Chaudhary. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class Message {
    var messageText: String!
    var toID: String!
    var fromID: String!
    var creationDate: Date!
    
    init(dictionary: [String: AnyObject]) {
        if let safeMessageText = dictionary["messageText"] as? String {
            self.messageText = safeMessageText
        }
        if let safetoID = dictionary["toID"] as? String {
            self.toID = safetoID
        }
        if let safefromID = dictionary["fromID"] as? String {
            self.fromID = safefromID
        }
        if let safeCreationDate = dictionary["creationDate"] as? Double {
            self.creationDate = Date(timeIntervalSince1970: safeCreationDate)
        }
    }
    
    func getPartnerID() -> String? {
        guard let currentuserID = Auth.auth().currentUser?.uid else {return nil}
        if self.fromID == currentuserID {
            return self.toID
        } else {
            return fromID
        }
    }
}
