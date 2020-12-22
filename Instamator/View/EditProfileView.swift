//
//  EditProfileView.swift
//  Instamator
//
//  Created by Amit Chaudhary on 12/22/20.
//  Copyright © 2020 Amit Chaudhary. All rights reserved.
//

import Foundation
import UIKit

class EditProfileView: UIView {
    
    var delegate: EditProfileViewDelegate?
    
    var editFrame = CGRect()
    
    var updatedUsername: String?
    
    let profileImageView: UIImageView = {
        let aImageView = UIImageView()
        aImageView.contentMode = .scaleAspectFill
        aImageView.clipsToBounds = true
        aImageView.backgroundColor = .lightGray
        return aImageView
    }()
    
    let changePhotoButton: UIButton = {
        let aButton = UIButton()
        aButton.setTitle("Change Photo", for: UIControl.State.normal)
        aButton.setTitleColor(.systemBlue, for: UIControl.State.normal)
        aButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        aButton.addTarget(self, action: #selector(handleChangeProfilePhotoButtonTapped), for: .touchUpInside)
        return aButton
    }()
    
    let separatorView: UIView = {
        let aView = UIView()
        aView.backgroundColor = .lightGray
        return aView
    }()
    
    let usernameTF: UITextField = {
        let aTextField = UITextField()
        aTextField.textAlignment = .left
        aTextField.borderStyle = .none
        return aTextField
    }()
    
    let fullnameTF: UITextField = {
        let aTextField = UITextField()
        aTextField.textAlignment = .left
        aTextField.borderStyle = .none
        aTextField.isUserInteractionEnabled = false
        return aTextField
    }()
    
    let fullNameLabel: UILabel = {
        let aLabel = UILabel()
        aLabel.text = "Full Name"
        aLabel.font = UIFont.systemFont(ofSize: 16)
        return aLabel
    }()
    
    let userNameLabel: UILabel = {
           let aLabel = UILabel()
           aLabel.text = "Username"
           aLabel.font = UIFont.systemFont(ofSize: 16)
           return aLabel
       }()
    
    let nameSeparatorView: UIView = {
           let aView = UIView()
           aView.backgroundColor = .lightGray
           return aView
       }()
    
    let usernameSeparatorView: UIView = {
           let aView = UIView()
           aView.backgroundColor = .lightGray
           return aView
       }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
//        self.translatesAutoresizingMaskIntoConstraints = false
        self.constructViewComponents()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


//MARK: - Helpers
extension EditProfileView {
    @objc func handleChangeProfilePhotoButtonTapped() {
        self.delegate?.handleChangeProfilePhoto()
    }
    
    func constructViewComponents() {
//        guard let safeWindow = self.window else {return}
        let frame = CGRect(x: 0, y: 80, width: UIScreen.main.bounds.width, height: 160)
        let containerView = UIView(frame: frame)
        containerView.backgroundColor = .white
        self.addSubview(containerView)
        
        containerView.addSubview(profileImageView)
        profileImageView.anchorView(top: containerView.topAnchor, left: nil, bottom: nil, right: nil, topPadding: 15, leftPadding: 0, bottomPadding: 0, rightPadding: 0, width: 80, height: 80)
        profileImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        profileImageView.layer.cornerRadius = 40
        
        containerView.addSubview(changePhotoButton)
        changePhotoButton.anchorView(top: profileImageView.bottomAnchor, left: nil, bottom: nil, right: nil, topPadding: 15, leftPadding: 0, bottomPadding: 0, rightPadding: 0, width: 0, height: 0)
        changePhotoButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        
        containerView.addSubview(separatorView)
        separatorView.anchorView(top: nil, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: containerView.rightAnchor, topPadding: 0, leftPadding: 0, bottomPadding: 0, rightPadding: 0, width: 0, height: 0.6)
        
        self.addSubview(fullNameLabel)
        fullNameLabel.anchorView(top: containerView.bottomAnchor, left: self.leftAnchor, bottom: nil, right: nil, topPadding: 20, leftPadding: 14, bottomPadding: 0, rightPadding: 0, width: 0, height: 0)
        self.addSubview(userNameLabel)
        userNameLabel.anchorView(top: fullNameLabel.bottomAnchor, left: self.leftAnchor, bottom: nil, right: nil, topPadding: 20, leftPadding: 14, bottomPadding: 0, rightPadding: 0, width: 0, height: 0)
        
        self.addSubview(fullnameTF)
        fullnameTF.anchorView(top: containerView.bottomAnchor, left: self.fullNameLabel.rightAnchor, bottom: nil, right: self.rightAnchor, topPadding: 20, leftPadding: 12, bottomPadding: 0, rightPadding: 12, width: UIScreen.main.bounds.width / 1.5, height: 0)
        
        self.addSubview(usernameTF)
        usernameTF.anchorView(top: fullnameTF.bottomAnchor, left: self.userNameLabel.rightAnchor, bottom: nil, right: self.rightAnchor, topPadding: 20, leftPadding: 12, bottomPadding: 0, rightPadding: 12, width: UIScreen.main.bounds.width / 1.5, height: 0)
        
        self.addSubview(nameSeparatorView)
        nameSeparatorView.anchorView(top: nil, left: fullnameTF.leftAnchor, bottom: fullnameTF.bottomAnchor, right: self.rightAnchor, topPadding: 0, leftPadding: 0, bottomPadding: 0, rightPadding: 0, width: 0, height: 0.5)
        
        self.addSubview(usernameSeparatorView)
        usernameSeparatorView.anchorView(top: nil, left: usernameTF.leftAnchor, bottom: usernameTF.bottomAnchor, right: self.rightAnchor, topPadding: 0, leftPadding: 0, bottomPadding: 0, rightPadding: 0, width: 0, height: 0.5)
        
    }
}
