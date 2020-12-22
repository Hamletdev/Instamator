//
//  Protocols.swift
//  Instamator
//
//  Created by Amit Chaudhary on 12/12/20.
//  Copyright © 2020 Amit Chaudhary. All rights reserved.
//

import Foundation

protocol UserProfileHeaderViewDelegate {
    func handleEditFollowButtonTapped(_ header: UserProfileHeaderView)
    func setHeaderUserStats(_ header: UserProfileHeaderView)
    func handleFollowingLabelTapped(_ header: UserProfileHeaderView)
    func handleFollowerLabelTapped(_ header: UserProfileHeaderView)
}

protocol FollowLikeViewCellDelegate {
    func handleFollowSideButton(_ cell: FollowLikeViewCell)
}

protocol FeedViewCellDelegate {
    func handleUsernameButtonTapped(_ cell: FeedViewCell)
    func handleOptionsButtonTapped(_ cell: FeedViewCell)
    func handleLikeButtonTapped(_ cell: FeedViewCell)
    func handleCommentButtonTapped(_ cell: FeedViewCell)
    func handleShowMessages(_ cell: FeedViewCell)
    
    func bringLikesScreenOfUsers(_ cell: FeedViewCell)
    func handleCurrentUserLikedPostOnRefresh(_ cell: FeedViewCell)
}

protocol NotificationViewCellDelegate {
    func postNotificationImageTapped(_ cell: NotificationViewCell)
    func followNotificationButtonTapped(_ cell: NotificationViewCell)
}

protocol EditProfileViewDelegate {
    func handleChangeProfilePhoto()
}
