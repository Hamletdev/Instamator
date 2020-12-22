//
//  Enums.swift
//  Instamator
//
//  Created by Amit Chaudhary on 12/15/20.
//  Copyright © 2020 Amit Chaudhary. All rights reserved.
//

import Foundation
import UIKit

enum FollowLikeScreenMode: Int {
    case followingMode
    case followerMode
    case likeMode
}

enum NotificationType: Int {
    case likeType
    case commentType
    case followType
    case commentMention
    case postMention
    
    var notificationDescription: String {
        switch self {
        case .likeType:
            return " has liked your post"
        case .commentType:
            return " has commented on your post"
        case .followType:
            return " has followed you"
        case .commentMention:
            return " has mentioned you in a comment"
        case .postMention:
            return " has mentioned you in a post"
        }
    }
}

enum ButtonAction: Int {
    case uploadPost
    case editPost
}
