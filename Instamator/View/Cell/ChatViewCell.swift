//
//  ChatViewCell.swift
//  Instamator
//
//  Created by Amit Chaudhary on 12/19/20.
//  Copyright © 2020 Amit Chaudhary. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class ChatViewCell: UICollectionViewCell {
    
    var bubbleViewWidthAnchor: NSLayoutConstraint?
    var bubbleViewLeftAnchor: NSLayoutConstraint?
    var bubbleViewRightAnchor: NSLayoutConstraint?
    
    var message: Message? {
        didSet {
            guard let messageText = message?.messageText else {return}
            textView.text = messageText
            guard let partnerID = self.message?.getPartnerID() else {
                return
            }
            Database.fetchUser(partnerID) { (user) in
                self.profileImageView.loadImage(user.profileImageURLString)
            }
        }
    }
    
    let bubbleView: UIView = {
        let aView = UIView()
        aView.backgroundColor = UIColor(red: 0/255, green: 137/255, blue: 249/255, alpha: 1)
        aView.translatesAutoresizingMaskIntoConstraints = false
        aView.layer.cornerRadius = 15
        aView.layer.masksToBounds = true
        return aView
    }()
    
    let textView: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.text = "Sample Text"
        tv.font = UIFont.systemFont(ofSize: 14)
        tv.textColor = .white
        tv.isEditable = false
        tv.backgroundColor = .clear
        return tv
    }()
    
    let profileImageView: UIImageView = {
        let aImageView = UIImageView()
        aImageView.contentMode = .scaleAspectFill
        aImageView.clipsToBounds = true
        aImageView.backgroundColor = .lightGray
        return aImageView
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(bubbleView)
        self.addSubview(textView)
        self.addSubview(profileImageView)
        
        profileImageView.anchorView(top: nil, left: self.leftAnchor, bottom: self.bottomAnchor, right: nil, topPadding: 0, leftPadding: 8, bottomPadding: -10, rightPadding: 0, width: 30, height: 30)
        profileImageView.layer.cornerRadius = 15
        
        bubbleViewRightAnchor = bubbleView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10)
        bubbleViewRightAnchor?.isActive = true
        bubbleViewLeftAnchor = bubbleView.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8)
        bubbleViewLeftAnchor?.isActive = false
        bubbleView.topAnchor.constraint(equalTo: self.topAnchor, constant: 8).isActive = true
        bubbleViewWidthAnchor = bubbleView.widthAnchor.constraint(equalToConstant: 200)
        bubbleViewWidthAnchor?.isActive = true
        bubbleView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
        textView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 8).isActive = true
        textView.topAnchor.constraint(equalTo: self.topAnchor, constant: 8).isActive = true
        textView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor).isActive = true
        textView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
