//
//  CommentViewCell.swift
//  Instamator
//
//  Created by Amit Chaudhary on 12/16/20.
//  Copyright © 2020 Amit Chaudhary. All rights reserved.
//

import Foundation
import UIKit

class CommentViewCell: UICollectionViewCell {
    
    var comment: Comment? {
        didSet {
            guard let commentUser = self.comment?.user, let profileImageStringOfUser = commentUser.profileImageURLString, let commentText = self.comment?.commentText, let username = commentUser.userName, let timeStamp = comment?.creationDate else {return}
            self.profileImageView.loadImage(profileImageStringOfUser)
            let attributedString = NSMutableAttributedString(string: username, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 12)])
            attributedString.append(NSAttributedString(string: " \(commentText)", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)]))
            attributedString.append(NSAttributedString(string: " \(timeStamp)", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
            self.commentTextView.attributedText = attributedString
        }
    }
    
    let profileImageView: UIImageView = {
        let aImageView = UIImageView()
        aImageView.contentMode = .scaleAspectFill
        aImageView.clipsToBounds = true
        aImageView.backgroundColor = .lightGray
        return aImageView
    }()
    
    let commentTextView: UITextView = {
        let aTextView = UITextView()
        aTextView.font = UIFont.systemFont(ofSize: 12)
        let attributedString = NSMutableAttributedString(string: "Audrey", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 12)])
        attributedString.append(NSAttributedString(string: " Comment Text from Audrey On Post", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)]))
        attributedString.append(NSAttributedString(string: " 2d.", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
        aTextView.attributedText = attributedString
        aTextView.isScrollEnabled = false
        return aTextView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.addSubview(profileImageView)
        profileImageView.anchorView(top: nil, left: self.leftAnchor, bottom: nil, right: nil, topPadding: 16, leftPadding: 12, bottomPadding: 0, rightPadding: 0, width: 36, height: 36)
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.layer.cornerRadius = 18
        
        self.addSubview(commentTextView)
        commentTextView.anchorView(top: self.topAnchor, left: profileImageView.rightAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, topPadding: 4, leftPadding: 8, bottomPadding: 4, rightPadding: 4, width: 0, height: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
