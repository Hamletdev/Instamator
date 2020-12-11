//
//  SearchViewCell.swift
//  Instamator
//
//  Created by Amit Chaudhary on 12/11/20.
//  Copyright © 2020 Amit Chaudhary. All rights reserved.
//

import UIKit

class SearchViewCell: UITableViewCell {
    
    var searchUser: User? {
        didSet {
            guard let username = searchUser?.userName, let fullName = searchUser?.fullName, let profileImageString = searchUser?.profileImageURLString else { return }
            self.detailTextLabel?.text = username
            self.textLabel?.text = fullName
            self.profileImageView.loadImage(profileImageString)
            
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
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        self.addSubview(profileImageView)
        profileImageView.anchorView(top: nil, left: self.leftAnchor, bottom: nil, right: nil, topPadding: 0, leftPadding: 12, bottomPadding: 0, rightPadding: 0, width: 42, height: 42)
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.layer.cornerRadius = 21
        
        self.textLabel?.text = "Full Name"
        self.detailTextLabel?.text = "Username"
        self.selectionStyle = .none
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
