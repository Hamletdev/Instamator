//
//  FollowViewCell.swift
//  Instamator
//
//  Created by Amit Chaudhary on 12/12/20.
//  Copyright © 2020 Amit Chaudhary. All rights reserved.
//

import UIKit
import Firebase

class FollowLikeViewCell: UITableViewCell {
    
    var delegate: FollowLikeViewCellDelegate?
    
    var followUser: User? {
        didSet {
            guard let username = followUser?.userName, let fullName = followUser?.fullName, let profileImageString = followUser?.profileImageURLString else { return }
            self.detailTextLabel?.text = username
            self.textLabel?.text = fullName
            self.profileImageView.loadImage(profileImageString)
            
            if followUser?.uID == Auth.auth().currentUser?.uid {
                self.followSideButton.isHidden = true
            }
            
            self.followUser?.checkIfAnUserIsFollowed(completion: { (followed) in
                if followed {
                    self.followSideButton.setTitle("Following", for: UIControl.State.normal)
                    self.followSideButton.setTitleColor(.black, for: UIControl.State.normal)
                    self.followSideButton.layer.borderWidth = 0.5
                    self.followSideButton.layer.borderColor = UIColor.lightGray.cgColor
                    self.followSideButton.backgroundColor = .white
                } else {
                    self.followSideButton.setTitle("Follow", for: UIControl.State.normal)
                    self.followSideButton.setTitleColor(.white, for: UIControl.State.normal)
                    self.followSideButton.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
                }
            })
            
        }
    }
    
    let profileImageView: UIImageView = {
           let aImageView = UIImageView()
           aImageView.contentMode = .scaleAspectFill
           aImageView.clipsToBounds = true
           aImageView.backgroundColor = .lightGray
           return aImageView
       }()
    
    lazy var followSideButton: UIButton = {
        let aButton = UIButton(type: .system)
        aButton.setTitle("Loading", for: UIControl.State.normal)
        aButton.setTitleColor(.white, for: UIControl.State.normal)
        aButton.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
        aButton.addTarget(self, action: #selector(followSideButtonTapped), for: UIControl.Event.touchUpInside)
        return aButton
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        self.addSubview(profileImageView)
        profileImageView.anchorView(top: nil, left: self.leftAnchor, bottom: nil, right: nil, topPadding: 0, leftPadding: 12, bottomPadding: 0, rightPadding: 0, width: 42, height: 42)
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.layer.cornerRadius = 21
        
        self.textLabel?.text = "Full Name"
        self.detailTextLabel?.text = "Username"
        self.selectionStyle = .none
        
        self.addSubview(followSideButton)
        followSideButton.anchorView(top: nil, left: nil, bottom: nil, right: self.rightAnchor, topPadding: 0, leftPadding: 0, bottomPadding: 0, rightPadding: 12, width: 85, height: 30)
        followSideButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        followSideButton.layer.cornerRadius = 3
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
           super.layoutSubviews()
           
           textLabel?.frame = CGRect(x: 68, y: textLabel!.frame.origin.y + 2, width: (textLabel?.frame.width)!, height: (textLabel?.frame.height)!)
           textLabel?.font = UIFont.boldSystemFont(ofSize: 14)
           
           detailTextLabel?.frame = CGRect(x: 68, y: detailTextLabel!.frame.origin.y + 2, width: (detailTextLabel!.frame.width), height: detailTextLabel!.frame.height)
           detailTextLabel?.textColor = .lightGray
           detailTextLabel?.font = UIFont.systemFont(ofSize: 12)
       }
    
}


//MARK: - Extra Methods
extension FollowLikeViewCell {
   @objc func followSideButtonTapped() {
    delegate?.handleFollowSideButton(self)
    }
}
