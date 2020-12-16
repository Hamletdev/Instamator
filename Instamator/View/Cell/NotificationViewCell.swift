//
//  NotificationViewCell.swift
//  Instamator
//
//  Created by Amit Chaudhary on 12/16/20.
//  Copyright © 2020 Amit Chaudhary. All rights reserved.
//

import Foundation
import UIKit

class NotificationViewCell: UITableViewCell {
    
    //MARK: - Properties
    let profileImageView: UIImageView = {
        let aImageView = UIImageView()
        aImageView.contentMode = .scaleAspectFill
        aImageView.clipsToBounds = true
        aImageView.backgroundColor = .lightGray
        return aImageView
    }()
    
    let postLabel: UILabel = {
        let aLabel = UILabel()
        let attributedString = NSMutableAttributedString(string: "Audrey", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 12)])
        attributedString.append(NSAttributedString(string: " Comment Text from Audrey On Post", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)]))
        attributedString.append(NSAttributedString(string: " 2d.", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
        aLabel.attributedText = attributedString
        aLabel.numberOfLines = 2
        return aLabel
    }()
    
    lazy var followButton: UIButton = {
        let aButton = UIButton(type: .system)
        aButton.setTitle("Loading", for: UIControl.State.normal)
        aButton.setTitleColor(.white, for: UIControl.State.normal)
        aButton.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
        aButton.addTarget(self, action: #selector(followSideButtonTapped), for: UIControl.Event.touchUpInside)
        return aButton
    }()
    
    let postImageView: UIImageView = {
           let aImageView = UIImageView()
           aImageView.contentMode = .scaleAspectFill
           aImageView.clipsToBounds = true
           aImageView.backgroundColor = .lightGray
           return aImageView
       }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        
        self.addSubview(profileImageView)
        profileImageView.anchorView(top: nil, left: self.leftAnchor, bottom: nil, right: nil, topPadding: 0, leftPadding: 8, bottomPadding: 8, rightPadding: 8, width: 40, height: 40)
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.layer.cornerRadius = 20
        
        if FOLLOW_VALUE == 0 {
            self.addSubview(followButton)
            followButton.anchorView(top: nil, left: nil, bottom: nil, right: self.rightAnchor, topPadding: 0, leftPadding: 0, bottomPadding: 0, rightPadding: 10, width: 80, height: 25)
            followButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
            followButton.layer.cornerRadius = 3
        }
        
        self.addSubview(postImageView)
        postImageView.anchorView(top: nil, left: nil, bottom: nil, right: self.rightAnchor, topPadding: 0, leftPadding: 0, bottomPadding: 0, rightPadding: 8, width: 35, height: 35)
        postImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        self.addSubview(postLabel)
        postLabel.anchorView(top: nil, left: profileImageView.rightAnchor, bottom: nil, right: postImageView.leftAnchor, topPadding: 0, leftPadding: 5, bottomPadding: 0, rightPadding: 5, width: 0, height: 0)
        postLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


//MARK: - Extra Methods
extension NotificationViewCell {
    @objc func followSideButtonTapped() {
        
    }
}
