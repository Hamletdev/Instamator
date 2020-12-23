//
//  EditProfileViewController.swift
//  Instamator
//
//  Created by Amit Chaudhary on 12/22/20.
//  Copyright © 2020 Amit Chaudhary. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class EditProfileViewController: UIViewController {
    
    let editProfileView = EditProfileView()
    
    var editUser: User?
    var userProfileVC: UserProfileViewController?
    
    var imageChanged = false
    var usernameChanged = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.constructNavBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view = self.editProfileView
        self.editProfileView.delegate = self
        self.editProfileView.usernameTF.delegate = self
        self.loadUserData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.editProfileView.constructViewComponents()
    }
}


//MARK: - EditProfileViewDelegate
extension EditProfileViewController: EditProfileViewDelegate {
    func handleChangeProfilePhoto() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true, completion: nil)
    }
    
}


//MARK: - Helper Methods
extension EditProfileViewController {
    func constructNavBar() {
        self.navigationItem.title = "Edit Profile"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: UIBarButtonItem.Style.plain, target: self, action: #selector(handleCancelButton))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.plain, target: self, action: #selector(handleDoneButton))
    }
    
    @objc func handleCancelButton() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func handleDoneButton() {
        self.editProfileView.endEditing(true)
        if imageChanged {
            self.uploadEditedProfileImage()
        }
        if usernameChanged {
            self.uploadEditedUsername()
        }
    }
    
    func loadUserData() {
        guard let safeUser = self.editUser else {return}
        self.editProfileView.profileImageView.loadImage(safeUser.profileImageURLString)
        self.editProfileView.fullnameTF.text = safeUser.fullName
        self.editProfileView.usernameTF.text = safeUser.userName
    }
}


//MARK: - ImagePickerDelegate
extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.editedImage] as? UIImage {
            self.editProfileView.profileImageView.image = selectedImage
            self.imageChanged = true
        }
        self.dismiss(animated: true, completion: nil)
    }
}


//MARK: - UITextFieldDelegate
extension EditProfileViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let safeUser = self.editUser else {return}
        let trimmedString = self.editProfileView.usernameTF.text?.replacingOccurrences(of: "\\s+$", with: "", options: .regularExpression)
        
        guard safeUser.userName != trimmedString, trimmedString != "" else {
            self.usernameChanged = false
            return
        }
        
        self.editProfileView.updatedUsername = trimmedString
        self.usernameChanged = true
    }
}


//MARK: - Firebase Operations
extension EditProfileViewController {
    func uploadEditedProfileImage() {
        guard imageChanged == true, let currentID = Auth.auth().currentUser?.uid, let safeUser = self.editUser, let updatedProfileImage = self.editProfileView.profileImageView.image else {return}
        Storage.storage().reference(forURL: safeUser.profileImageURLString).delete(completion: nil)
        let fileName = NSUUID().uuidString
        guard let safeImageData = updatedProfileImage.pngData() else {return}
        STORAGE_REF.child("Profile_Images").child(fileName).putData(safeImageData, metadata: nil) { (storageMetaData, error) in
            if let safeError = error {
                print(safeError)
            }
            STORAGE_REF.child("Profile_Images").child(fileName).downloadURL { (downloadURL, error) in
                if let safeError = error {
                    print(safeError)
                }
                
                if let safeDownloadURLString = downloadURL?.absoluteString {
                    USERS_REF.child(currentID).child("profileImageURLString").setValue(safeDownloadURLString) { (error, ref) in
                        self.userProfileVC?.fetchcurrentUserData()
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
            
        }
    }
    
    func uploadEditedUsername() {
        guard let safeEditedUsername = self.editProfileView.updatedUsername, let currentID = Auth.auth().currentUser?.uid, usernameChanged == true else {return}
        USERS_REF.child(currentID).child("username").setValue(safeEditedUsername) { (error, ref) in
            if let safeError = error {
                print(safeError)
            }
            self.userProfileVC?.fetchcurrentUserData()
            self.dismiss(animated: true, completion: nil)
        }
    }
}
