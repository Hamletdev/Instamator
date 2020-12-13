//
//  UploadViewController.swift
//  Instamator
//
//  Created by Amit Chaudhary on 12/10/20.
//  Copyright © 2020 Amit Chaudhary. All rights reserved.
//

import UIKit

class UploadViewController: UIViewController {
    
    var postImage: UIImage?
    
    let photoImageView: UIImageView = {
        let aImageView = UIImageView()
        aImageView.contentMode = .scaleAspectFill
        aImageView.clipsToBounds = true
        aImageView.backgroundColor = .blue
        return aImageView
    }()
    
    let captionTextView: UITextView = {
        let aTextView = UITextView()
        aTextView.backgroundColor = .systemGroupedBackground
        aTextView.font = UIFont.systemFont(ofSize: 12)
        return aTextView
    }()
    
    let postButton: UIButton = {
        let aButton = UIButton(type: UIButton.ButtonType.system)
        aButton.backgroundColor = UIColor(red: 149/255, green: 204/255, blue: 244/255, alpha: 1)
        aButton.setTitle("POST", for: UIControl.State.normal)
        aButton.setTitleColor(.white, for: UIControl.State.normal)
        aButton.layer.cornerRadius = 5
        return aButton
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        self.view.addSubview(photoImageView)
        photoImageView.anchorView(top: self.view.topAnchor, left: self.view.leftAnchor, bottom: nil, right: nil, topPadding: 92, leftPadding: 12, bottomPadding: 0, rightPadding: 0, width: 120, height: 120)
        self.view.addSubview(captionTextView)
        captionTextView.anchorView(top: self.view.topAnchor, left: photoImageView.rightAnchor, bottom: nil, right: self.view.rightAnchor, topPadding: 92, leftPadding: 12, bottomPadding: 0, rightPadding: 12, width: 0, height: 120)
        self.view.addSubview(postButton)
        postButton.anchorView(top: self.photoImageView.bottomAnchor, left: self.view.leftAnchor, bottom: nil, right: self.view.rightAnchor, topPadding: 20, leftPadding: 40, bottomPadding: 0, rightPadding: 40, width: 0, height: 40)

        self.loadPostImage()
    }
    
    func loadPostImage() {
        guard let safePostImage = self.postImage else {return}
        photoImageView.image = safePostImage
    }

}
