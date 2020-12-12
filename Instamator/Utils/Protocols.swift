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

protocol FollowViewCellDelegate {
    func handleFollowSideButton(_ cell: FollowViewCell)
}
