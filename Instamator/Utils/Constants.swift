//
//  Constants.swift
//  Instamator
//
//  Created by Amit Chaudhary on 12/12/20.
//  Copyright © 2020 Amit Chaudhary. All rights reserved.
//

import Foundation
import Firebase

let DB_REF = Database.database().reference()
let STORAGE_REF = Storage.storage().reference()

let USERS_REF = Database.database().reference().child("Users")
let FOLLOWER_USERS_REF = Database.database().reference().child("Follower-Users")
let FOLLOWING_USERS_REF = Database.database().reference().child("Following-Users")

let POSTS_REF = DB_REF.child("Posts")
let USER_POSTS_REF = DB_REF.child("User-Posts")

let USER_FEED_REF = DB_REF.child("User-Feed")
