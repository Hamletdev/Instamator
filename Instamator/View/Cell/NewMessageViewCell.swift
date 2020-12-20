//
//  NewMessageViewCell.swift
//  Instamator
//
//  Created by Amit Chaudhary on 12/19/20.
//  Copyright © 2020 Amit Chaudhary. All rights reserved.
//

import Foundation
import UIKit

class NewMessageViewCell: UITableViewCell {
    
    var user: User? {
        didSet {
            guard let profileImageString = user?.profileImageURLString, let username = user?.userName, let fullName = user?.fullName else {return}
            self.profileImageView.loadImage(profileImageString)
            self.textLabel?.text = fullName
            self.detailTextLabel?.text = username
        
        }
    }
    
    let profileImageView: UIImageView = {
          let aImageView = UIImageView()
          aImageView.contentMode = .scaleAspectFill
          aImageView.clipsToBounds = true
          aImageView.backgroundColor = .lightGray
          return aImageView
      }()
      
      override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
          super.init(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: reuseIdentifier)
          
          self.addSubview(profileImageView)
          profileImageView.anchorView(top: nil, left: self.leftAnchor, bottom: nil, right: nil, topPadding: 0, leftPadding: 12, bottomPadding: 0, rightPadding: 0, width: 40, height: 40)
          profileImageView.layer.cornerRadius = 20
          profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
          
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
