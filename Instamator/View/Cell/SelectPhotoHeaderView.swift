//
//  SelectPhotoHeaderView.swift
//  Instamator
//
//  Created by Amit Chaudhary on 12/13/20.
//  Copyright © 2020 Amit Chaudhary. All rights reserved.
//

import Foundation
import UIKit

class SelectPhotoHeaderView: UICollectionReusableView {
    
    let photoImageView: UIImageView = {
           let aImageView = UIImageView()
           aImageView.contentMode = .scaleAspectFill
           aImageView.clipsToBounds = true
           aImageView.backgroundColor = .lightGray
           return aImageView
       }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(photoImageView)
        photoImageView.anchorView(top: self.topAnchor, left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, topPadding: 0, leftPadding: 0, bottomPadding: 0, rightPadding: 0, width: 0, height: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
