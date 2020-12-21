//
//  FeedViewCell.swift
//  Instamator
//
//  Created by Amit Chaudhary on 12/14/20.
//  Copyright © 2020 Amit Chaudhary. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import ActiveLabel

class FeedViewCell: UICollectionViewCell {
    
    var delegate: FeedViewCellDelegate?
    
    var post: Post? {
        didSet {
            guard let userID = post?.ownerID, let postImageString = post?.postImageURLString, let likes = post?.likes else {return}
            Database.fetchUser(userID) { (user) in
                self.usernameButton.setTitle(user.userName, for: UIControl.State.normal)
                self.constructPostCaption(user)
                
                self.profileImageView.loadImage(user.profileImageURLString)
                
                //set profileImageView
                //                if let profileImageString = user.profileImageURLString {
                //                UIImage.loadImageUsingCacheWithUrlString(profileImageString) { image in
                //                    if profileImageString == user.profileImageURLString {
                //                        self.profileImageView.image = image
                //                    }
                //                }
                //            } else {
                //                self.profileImageView.image = nil
                //            }
            }
            
            self.likesLabel.text = "\(likes) likes"
            self.updateCurrentUserLikedImage()
            
            UIImage.loadImageUsingCacheWithUrlString(postImageString) { image in
                // set the image only when we are still displaying the content for the image we finished downloading
                if postImageString == self.post?.postImageURLString {
                    self.postImageView.image = image
                }
            }
            
        }
    }
    
    let profileImageView: UIImageView = {
        let aImageView = UIImageView()
        aImageView.contentMode = .scaleAspectFill
        aImageView.clipsToBounds = true
        aImageView.backgroundColor = .lightGray
        return aImageView
    }()
    
    lazy var usernameButton: UIButton = {
        let aButton = UIButton(type: .system)
        aButton.setTitle("Username", for: UIControl.State.normal)
        aButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        aButton.addTarget(self, action: #selector(usernameButtonTapped), for: UIControl.Event.touchUpInside)
        return aButton
    }()
    
    lazy var optionsButton: UIButton = {
        let aButton = UIButton(type: .system)
        aButton.setTitle("•••", for: UIControl.State.normal)
        aButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        aButton.addTarget(self, action: #selector(optionsButtonTapped), for: UIControl.Event.touchUpInside)
        return aButton
    }()
    
    lazy var postImageView: UIImageView = {
        let aImageView = UIImageView()
        aImageView.contentMode = .scaleAspectFill
        aImageView.clipsToBounds = true
        aImageView.backgroundColor = .lightGray
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(likeButtonTapped))
        doubleTap.numberOfTouchesRequired = 1
        aImageView.isUserInteractionEnabled = true
        aImageView.addGestureRecognizer(doubleTap)
        return aImageView
    }()
    
    lazy var likeButton: UIButton = {
        let aButton = UIButton(type: .system)
        aButton.setImage(#imageLiteral(resourceName: "like_unselected"), for: UIControl.State.normal)
        aButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        aButton.addTarget(self, action: #selector(likeButtonTapped), for: UIControl.Event.touchUpInside)
        return aButton
    }()
    
    lazy var commentButton: UIButton = {
        let aButton = UIButton(type: .system)
        aButton.setImage(#imageLiteral(resourceName: "comment"), for: UIControl.State.normal)
        aButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        aButton.addTarget(self, action: #selector(commentButtonTapped), for: UIControl.Event.touchUpInside)
        return aButton
    }()
    
    lazy var messageButton: UIButton = {
        let aButton = UIButton(type: .system)
        aButton.setImage(#imageLiteral(resourceName: "send2"), for: UIControl.State.normal)
        aButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        return aButton
    }()
    
    let bookmarkButton: UIButton = {
        let aButton = UIButton(type: .system)
        aButton.setImage(#imageLiteral(resourceName: "ribbon"), for: UIControl.State.normal)
        aButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        return aButton
    }()
    
    lazy var likesLabel: UILabel = {
        let aLabel = UILabel()
        aLabel.text = "3 likes"
        aLabel.font = UIFont.boldSystemFont(ofSize: 12)
        let likesTap = UITapGestureRecognizer(target: self, action: #selector(likesLabelTapped))
        likesTap.numberOfTouchesRequired = 1
        aLabel.isUserInteractionEnabled = true
        aLabel.addGestureRecognizer(likesTap)
        return aLabel
    }()
    
    let captionLabel: ActiveLabel = {
        let aLabel = ActiveLabel()
        aLabel.numberOfLines = 0
        return aLabel
    }()
    
    let historyTimeLabel: UILabel = {
        let aLabel = UILabel()
        aLabel.text = "2 days ago"
        aLabel.textColor = .lightGray
        aLabel.font = UIFont.boldSystemFont(ofSize: 10)
        return aLabel
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .systemGroupedBackground
        self.addSubview(profileImageView)
        profileImageView.anchorView(top: self.topAnchor, left: self.leftAnchor, bottom: nil, right: nil, topPadding: 10, leftPadding: 10, bottomPadding: 0, rightPadding: 0, width: 40, height: 40)
        profileImageView.layer.cornerRadius = 20
        
        self.addSubview(usernameButton)
        usernameButton.anchorView(top: nil, left: self.profileImageView.rightAnchor, bottom: nil, right: nil, topPadding: 0, leftPadding: 10, bottomPadding: 0, rightPadding: 0, width: 0, height: 0)
        usernameButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        
        self.addSubview(optionsButton)
        optionsButton.anchorView(top: nil, left: nil, bottom: nil, right: self.rightAnchor, topPadding: 0, leftPadding: 0, bottomPadding: 0, rightPadding: 10, width: 0, height: 0)
        optionsButton.centerYAnchor.constraint(equalTo: self.profileImageView.centerYAnchor).isActive = true
        
        self.addSubview(postImageView)
        postImageView.anchorView(top: profileImageView.bottomAnchor, left: self.leftAnchor, bottom: nil, right: self.rightAnchor, topPadding: 2, leftPadding: 0, bottomPadding: 0, rightPadding: 0, width: 0, height: 0)
        postImageView.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 1).isActive = true
        self.constructActionButtons()
        
        self.addSubview(likesLabel)
        likesLabel.anchorView(top: self.commentButton.bottomAnchor, left: self.leftAnchor, bottom: nil, right: nil, topPadding: 2, leftPadding: 10, bottomPadding: 0, rightPadding: 0, width: 0, height: 0)
        
        self.addSubview(captionLabel)
        captionLabel.anchorView(top: self.likesLabel.bottomAnchor, left: self.leftAnchor, bottom: nil, right: self.rightAnchor, topPadding: 6, leftPadding: 10, bottomPadding: 0, rightPadding: 8, width: 0, height: 0)
        
        self.addSubview(historyTimeLabel)
        historyTimeLabel.anchorView(top: self.captionLabel.bottomAnchor, left: self.leftAnchor, bottom: nil, right: nil, topPadding: -1, leftPadding: 10, bottomPadding: 0, rightPadding: 0, width: 0, height: 0)
    }
    
    func constructActionButtons() {
        let aStackView = UIStackView(arrangedSubviews: [likeButton, commentButton,messageButton])
        aStackView.axis = .horizontal
        aStackView.distribution = .fillEqually
        self.addSubview(aStackView)
        aStackView.anchorView(top: postImageView.bottomAnchor, left: nil, bottom: nil, right: nil, topPadding: 5, leftPadding: 0, bottomPadding: 0, rightPadding: 0, width: 120, height: 40)
        
        self.addSubview(bookmarkButton)
        bookmarkButton.anchorView(top: self.postImageView.bottomAnchor, left: nil, bottom: nil, right: self.rightAnchor, topPadding: 8, leftPadding: 0, bottomPadding: 0, rightPadding: 12, width: 30, height: 30)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


//MARK: - Extra Methods
extension FeedViewCell {
    func constructPostCaption(_ user: User) {
        guard let post = self.post else { return }
        guard let caption = post.caption else { return }
        guard let username = post.user?.userName else { return }
        
        // look for username as pattern
        let customType = ActiveType.custom(pattern: "^\(username)\\b")
        
        // enable username as custom type
        captionLabel.enabledTypes = [.mention, .hashtag, .url, customType]
        
        // configure usnerame link attributes
        captionLabel.configureLinkAttribute = { (type, attributes, isSelected) in
            var atts = attributes
            
            switch type {
            case .custom:
                atts[NSAttributedString.Key.font] = UIFont.boldSystemFont(ofSize: 12)
            default: ()
            }
            return atts
        }
        
        captionLabel.customize { (label) in
            label.text = "\(username) \(caption)"
            label.customColor[customType] = .blue
            label.font = UIFont.systemFont(ofSize: 12)
            label.textColor = .black
            captionLabel.numberOfLines = 2
        }
        self.historyTimeLabel.text = "2 Days Ago"
    }
    
    @objc func usernameButtonTapped() {
        self.delegate?.handleUsernameButtonTapped(self)
    }
    
    @objc func optionsButtonTapped() {
        self.delegate?.handleOptionsButtonTapped(self)
    }
    
    @objc func likeButtonTapped() {
        self.delegate?.handleLikeButtonTapped(self)
    }
    
    @objc func commentButtonTapped() {
        self.delegate?.handleCommentButtonTapped(self)
    }
    
    @objc func likesLabelTapped() {
        self.delegate?.bringLikesScreenOfUsers(self)
    }
    
    @objc func messagesButtonTapped() {
        self.delegate?.handleShowMessages(self)
    }
    
    func updateCurrentUserLikedImage() {
        self.delegate?.handleCurrentUserLikedPostOnRefresh(self)
    }
    
}
