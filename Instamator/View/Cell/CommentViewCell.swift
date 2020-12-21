//
//  CommentViewCell.swift
//  Instamator
//
//  Created by Amit Chaudhary on 12/16/20.
//  Copyright © 2020 Amit Chaudhary. All rights reserved.
//

import Foundation
import UIKit
import ActiveLabel

class CommentViewCell: UICollectionViewCell {
    
    var comment: Comment? {
        didSet {
            guard let commentUser = self.comment?.user, let profileImageStringOfUser = commentUser.profileImageURLString else {return}
            self.profileImageView.loadImage(profileImageStringOfUser)
            self.constructCommentLabel()
        }
    }
    
    let profileImageView: UIImageView = {
        let aImageView = UIImageView()
        aImageView.contentMode = .scaleAspectFill
        aImageView.clipsToBounds = true
        aImageView.backgroundColor = .lightGray
        return aImageView
    }()
    
    let commentLabel: ActiveLabel = {
        let commLabel = ActiveLabel()
        commLabel.enabledTypes = [.mention, .hashtag]
        commLabel.font = UIFont.systemFont(ofSize: 13)
        commLabel.numberOfLines = 0
        return commLabel
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.addSubview(profileImageView)
        profileImageView.anchorView(top: nil, left: self.leftAnchor, bottom: nil, right: nil, topPadding: 16, leftPadding: 12, bottomPadding: 0, rightPadding: 0, width: 36, height: 36)
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.layer.cornerRadius = 18
        
        self.addSubview(commentLabel)
        commentLabel.anchorView(top: self.topAnchor, left: profileImageView.rightAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, topPadding: 4, leftPadding: 8, bottomPadding: 4, rightPadding: 4, width: 0, height: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


//MARK: - Helper Methods
extension CommentViewCell {
    func constructCommentLabel() {
        guard let comment = self.comment, let user = comment.user, let username = user.userName, let commentText = comment.commentText else {return}
        let customType = ActiveType.custom(pattern: "^\(username)\\b")
        
        commentLabel.enabledTypes = [.hashtag, .mention, .url, customType]
        
        commentLabel.configureLinkAttribute = { (type, attributes, isSelected) in
            var atts = attributes
            
            switch type {
            case .custom:
                atts[NSAttributedString.Key.font] = UIFont.boldSystemFont(ofSize: 12)
            default: ()
            }
            return atts
        }
        
        commentLabel.customize { (label) in
            label.text = "\(username) \(commentText)"
            label.customColor[customType] = .black
            label.font = UIFont.systemFont(ofSize: 12)
            label.textColor = .black
            label.numberOfLines = 0
        }
    }
}
