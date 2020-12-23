//
//  UIImage.swift
//  Instamator
//
//  Created by Amit Chaudhary on 12/11/20.
//  Copyright © 2020 Amit Chaudhary. All rights reserved.
//

import Foundation
import UIKit

var cachedImage = [String: UIImage]()

extension UIImageView {
    
    func loadImage(_ imageString: String) {
        self.image = nil
        let checkImageString = imageString
        if cachedImage[imageString] != nil {
            self.image = cachedImage[imageString]
            return
        }
        guard let url = URL(string: imageString) else {
            return
        }
        
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task = session.dataTask(with: url) { (data, response, error) in
            if let safeError = error {
                print(safeError)
            }
            
            if checkImageString != url.absoluteString {
                return
            }
            
            if let safeData = data {
                let profileImage = UIImage(data: safeData)
                DispatchQueue.main.async {
                    cachedImage[imageString] = profileImage
                    self.image = profileImage
                }
            }
        }
        task.resume()
    }
    
}
