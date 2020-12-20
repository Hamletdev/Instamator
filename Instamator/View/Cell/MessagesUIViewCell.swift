//
//  MessagesUIViewCell.swift
//  Instamator
//
//  Created by Amit Chaudhary on 12/18/20.
//  Copyright © 2020 Amit Chaudhary. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class MessagesUIViewCell: UITableViewCell {
    
    var message: Message? {
        didSet {
            guard let messageText = self.message?.messageText else {return}
            self.detailTextLabel?.text = messageText
            if let seconds = message?.creationDate {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "hh:mm:ss"
                self.timeStampLabel.text = dateFormatter.string(from: seconds)
            }
            
            guard let partnerID = self.message?.getPartnerID() else {
                return
            }
            Database.fetchUser(partnerID) { (user) in
                self.profileImageView.loadImage(user.profileImageURLString)
                self.textLabel?.text = user.fullName
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
    
    let timeStampLabel: UILabel = {
        let aLabel = UILabel()
        aLabel.font = UIFont.systemFont(ofSize: 12)
        aLabel.textColor = .darkGray
        return aLabel
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: reuseIdentifier)
        
        self.addSubview(profileImageView)
        profileImageView.anchorView(top: nil, left: self.leftAnchor, bottom: nil, right: nil, topPadding: 0, leftPadding: 12, bottomPadding: 0, rightPadding: 0, width: 40, height: 40)
        profileImageView.layer.cornerRadius = 20
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        self.addSubview(timeStampLabel)
        timeStampLabel.anchorView(top: self.topAnchor, left: nil, bottom: nil, right: self.rightAnchor, topPadding: 20, leftPadding: 0, bottomPadding: 0, rightPadding: 14, width: 0, height: 0)
        self.selectionStyle = .none
        
        self.layoutSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let safeTextLabel = self.textLabel, let safeDetailTextLabel = self.detailTextLabel else {
            return
        }
        safeTextLabel.frame = CGRect(x: 68, y: safeTextLabel.frame.origin.y - 2, width: safeTextLabel.frame.width, height: safeTextLabel.frame.height)
        safeDetailTextLabel.frame = CGRect(x: 68, y: safeDetailTextLabel.frame.origin.y + 2, width: safeDetailTextLabel.frame.width, height: safeDetailTextLabel.frame.height)
        safeTextLabel.font = UIFont.boldSystemFont(ofSize: 12)
        safeDetailTextLabel.font = UIFont.systemFont(ofSize: 12)
        safeDetailTextLabel.textColor = .lightGray
        safeTextLabel.textColor = .darkText
        
    }
}
