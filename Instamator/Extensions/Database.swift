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
        print("AAAAAAAAAA")
        USERS_REF.child(userID).observeSingleEvent(of: .value) { (snapshot) in
            guard let safeUserDictionary = snapshot.value as? [String: AnyObject] else {return}
            let safeUser = User(userID, userDictionary: safeUserDictionary)
            completion(safeUser)
        }
    }
}
