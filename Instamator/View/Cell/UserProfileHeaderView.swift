//
//  UserProfileHeaderView.swift
//  Instamator
//
//  Created by Amit Chaudhary on 12/10/20.
//  Copyright © 2020 Amit Chaudhary. All rights reserved.
//

import UIKit
import Firebase

class UserProfileHeaderView: UICollectionReusableView, UICollectionViewDelegateFlowLayout {
    
    var delegate: UserProfileHeaderViewDelegate?
    
    var user: User? {
        didSet {
            self.updateUserStats()
            let fullName = user?.fullName
            self.fullnameLabel.text = fullName
            guard let safeString = user?.profileImageURLString else {
                return
            }
             self.profileImageView.loadImage(safeString)
            self.titleEditFollowButton()
        }
    }
    
    let profileImageView: UIImageView = {
        let aImageView = UIImageView()
        aImageView.contentMode = .scaleAspectFill
        aImageView.clipsToBounds = true
        aImageView.backgroundColor = .lightGray
        return aImageView
    }()
    
    let fullnameLabel: UILabel = {
        let aLabel = UILabel()
        aLabel.text = "Audrey Hepburn"
        aLabel.font = UIFont.boldSystemFont(ofSize: 14)
        return aLabel
    }()
    
    let postLabel: UILabel = {
        let aLabel = UILabel()
        aLabel.numberOfLines = 0
        aLabel.textAlignment = .center
        let attributedString = NSMutableAttributedString(string: "0\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.black])
        attributedString.append(NSAttributedString(string: "Post", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.systemBlue]))
        aLabel.attributedText = attributedString
        return aLabel
    }()
    
    lazy var followingLabel: UILabel = {
           let aLabel = UILabel()
           aLabel.numberOfLines = 0
           aLabel.textAlignment = .center
           let attributedString = NSMutableAttributedString(string: "", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.black])
           attributedString.append(NSAttributedString(string: "Following", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.systemBlue]))
           aLabel.attributedText = attributedString
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(followingLabelTapped))
        tapGesture.numberOfTapsRequired = 1
        aLabel.isUserInteractionEnabled = true
        aLabel.addGestureRecognizer(tapGesture)
           return aLabel
       }()
    
    lazy var followersLabel: UILabel = {
           let aLabel = UILabel()
           aLabel.numberOfLines = 0
           aLabel.textAlignment = .center
        let attributedString = NSMutableAttributedString(string: "", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.black])
        attributedString.append(NSAttributedString(string: "Followers", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.systemBlue]))
           aLabel.attributedText = attributedString
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(followerLabelTapped))
        tapGesture.numberOfTapsRequired = 1
        aLabel.isUserInteractionEnabled = true
        aLabel.addGestureRecognizer(tapGesture)
           return aLabel
       }()
    
    lazy var editProfileButton: UIButton = {
        let aButton = UIButton(type: UIButton.ButtonType.system)
        aButton.setTitle("Loading..", for: UIControl.State.normal)
        aButton.layer.cornerRadius = 3
        aButton.layer.borderColor = UIColor.lightGray.cgColor
        aButton.layer.borderWidth = 0.5
        aButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        aButton.addTarget(self, action: #selector(editFollowButtonIsTapped), for: UIControl.Event.touchUpInside)
        return aButton
    }()
    
    let gridButton: UIButton = {
        let aButton = UIButton(type: UIButton.ButtonType.system)
        aButton.setImage(#imageLiteral(resourceName: "grid"), for: UIControl.State.normal)
        aButton.tintColor = UIColor(white: 0, alpha: 0.25)
        return aButton
    }()
    
    let listButton: UIButton = {
        let aButton = UIButton(type: UIButton.ButtonType.system)
        aButton.setImage(#imageLiteral(resourceName: "list"), for: UIControl.State.normal)
        aButton.tintColor = UIColor(white: 0, alpha: 0.25)
        return aButton
    }()
    
    let bookmarkButton: UIButton = {
        let aButton = UIButton(type: UIButton.ButtonType.system)
        aButton.setImage(#imageLiteral(resourceName: "ribbon"), for: UIControl.State.normal)
        aButton.tintColor = UIColor(white: 0, alpha: 0.25)
        return aButton
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .systemGroupedBackground
        
        self.addSubview(profileImageView)
        profileImageView.anchorView(top: self.topAnchor, left: self.leftAnchor, bottom: nil, right: nil, topPadding: 16, leftPadding: 12, bottomPadding: 0, rightPadding: 0, width: 70, height: 70)
        profileImageView.layer.cornerRadius = 35
        
        self.addSubview(fullnameLabel)
        fullnameLabel.anchorView(top: profileImageView.bottomAnchor, left: self.leftAnchor, bottom: nil, right: nil, topPadding: 12, leftPadding: 12, bottomPadding: 0, rightPadding: 0, width: 0, height: 0)
        
        self.constructUserStats()
        
        self.addSubview(editProfileButton)
        editProfileButton.anchorView(top: postLabel.bottomAnchor, left: fullnameLabel.rightAnchor, bottom: nil, right: self.rightAnchor, topPadding: 12, leftPadding: 30, bottomPadding: 0, rightPadding: 16, width: 0, height: 30)
        
        self.constructBottomToolbar()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func constructUserStats() {
        let aStackView = UIStackView(arrangedSubviews: [postLabel, followingLabel, followersLabel])
        aStackView.axis = .horizontal
        aStackView.distribution = .fillEqually
        aStackView.spacing = 5
        self.addSubview(aStackView)
        aStackView.anchorView(top: self.topAnchor, left: profileImageView.rightAnchor, bottom: nil, right: self.rightAnchor, topPadding: 16, leftPadding: 12, bottomPadding: 0, rightPadding: 12, width: 0, height: 50)
    }
    
    
    func constructBottomToolbar() {
        let topDividerView = UIView()
        let bottomDividerView = UIView()
        topDividerView.backgroundColor = .lightGray
        bottomDividerView.backgroundColor = .lightGray
        
        let aStackView = UIStackView(arrangedSubviews: [gridButton, listButton, bookmarkButton])
        aStackView.axis = .horizontal
        aStackView.distribution = .fillEqually
        self.addSubview(aStackView)
        self.addSubview(topDividerView)
        self.addSubview(bottomDividerView)
        
        aStackView.anchorView(top: nil, left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, topPadding: 0, leftPadding: 0, bottomPadding: 0, rightPadding: 0, width: 0, height: 40)
        topDividerView.anchorView(top: aStackView.topAnchor, left: self.leftAnchor, bottom: nil, right: self.rightAnchor, topPadding: 0, leftPadding: 0, bottomPadding: 0, rightPadding: 0, width: 0, height: 0.5)
        bottomDividerView.anchorView(top: aStackView.bottomAnchor, left: self.leftAnchor, bottom: nil, right: self.rightAnchor, topPadding: 0, leftPadding: 0, bottomPadding: 0, rightPadding: 0, width: 0, height: 0.5)
    }
    
}


//MARK: - Extra Methods
extension UserProfileHeaderView {
    func titleEditFollowButton() {
        guard let currentuserID = Auth.auth().currentUser?.uid else {
            return
        }
        if self.user?.uID == currentuserID {
            self.editProfileButton.setTitle("Edit Profile", for: .normal)
        } else {
            self.user?.checkIfAnUserIsFollowed(completion: { (followed) in
                if followed == true {
                    self.editProfileButton.setTitle("Following", for: .normal)
                    self.editProfileButton.setTitleColor(.white, for: .normal)
                    self.editProfileButton.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
                } else {
                    self.editProfileButton.setTitle("Follow", for: .normal)
                    self.editProfileButton.setTitleColor(.white, for: .normal)
                    self.editProfileButton.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
                }
            })
            
        }
    }
    
    @objc func editFollowButtonIsTapped() {
        self.delegate?.handleEditFollowButtonTapped(self)
    }
    
    func updateUserStats() {
        self.delegate?.setHeaderUserStats(self)
    }
    
    @objc func followingLabelTapped() {
        self.delegate?.handleFollowingLabelTapped(self)
    }
    
    @objc func followerLabelTapped() {
        self.delegate?.handleFollowerLabelTapped(self)
    }
}
