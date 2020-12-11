//
//  SignUpViewController.swift
//  Instamator
//
//  Created by Amit Chaudhary on 12/10/20.
//  Copyright © 2020 Amit Chaudhary. All rights reserved.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController {
    
    var imageSelected = false
    
    let profileTopButton: UIButton = {
        let aButton = UIButton(type: UIButton.ButtonType.system)
        aButton.setImage(#imageLiteral(resourceName: "plus_photo").withRenderingMode(UIImage.RenderingMode.alwaysOriginal), for: UIControl.State.normal)
        aButton.addTarget(self, action: #selector(bringImagePicker), for: UIControl.Event.touchUpInside)
        return aButton
    }()
    
    let emailTextField: UITextField = {
        let aTextField = UITextField()
        aTextField.placeholder = "Enter Email"
        aTextField.backgroundColor = UIColor(white: 0, alpha: 0.03)
        aTextField.borderStyle = .roundedRect
        aTextField.font = UIFont.systemFont(ofSize: 14)
        aTextField.addTarget(self, action: #selector(enableSignUpButton), for: UIControl.Event.editingChanged)
        return aTextField
    }()
    
    let passwordTextField: UITextField = {
        let aTextField = UITextField()
        aTextField.placeholder = "Enter Password"
        aTextField.backgroundColor = UIColor(white: 0, alpha: 0.03)
        aTextField.borderStyle = .roundedRect
        aTextField.font = UIFont.systemFont(ofSize: 14)
        aTextField.isSecureTextEntry = true
        aTextField.addTarget(self, action: #selector(enableSignUpButton), for: UIControl.Event.editingChanged)
        return aTextField
    }()
    
    let fullNameTextField: UITextField = {
        let aTextField = UITextField()
        aTextField.placeholder = "Enter Full Name"
        aTextField.backgroundColor = UIColor(white: 0, alpha: 0.03)
        aTextField.borderStyle = .roundedRect
        aTextField.font = UIFont.systemFont(ofSize: 14)
        aTextField.addTarget(self, action: #selector(enableSignUpButton), for: UIControl.Event.editingChanged)
        return aTextField
    }()
    
    let usernameTextField: UITextField = {
        let aTextField = UITextField()
        aTextField.placeholder = "Enter Username"
        aTextField.backgroundColor = UIColor(white: 0, alpha: 0.03)
        aTextField.borderStyle = .roundedRect
        aTextField.font = UIFont.systemFont(ofSize: 14)
        aTextField.isSecureTextEntry = false
        aTextField.addTarget(self, action: #selector(enableSignUpButton), for: UIControl.Event.editingChanged)
        return aTextField
    }()
    
    let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 149/255, green: 204/255, blue: 244/255, alpha: 1)
        button.layer.cornerRadius = 5
        button.isEnabled = false
        button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        return button
    }()
    
    let alreadyHaveAccountButton: UIButton = {
        let aButton = UIButton(type: UIButton.ButtonType.system)
        let attributedTitle = NSMutableAttributedString(string: "Already have an account?", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14.0), NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        attributedTitle.append(NSAttributedString(string: " Sign In", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14.0), NSAttributedString.Key.foregroundColor: UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)]))
        aButton.setAttributedTitle(attributedTitle, for: UIControl.State.normal)
        aButton.addTarget(self, action: #selector(bringLogIn), for: UIControl.Event.touchUpInside)
        return aButton
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.view.addSubview(profileTopButton)
        profileTopButton.anchorView(top: self.view.topAnchor, left: nil, bottom: nil, right: nil, topPadding: 40, leftPadding: 0, bottomPadding: 0, rightPadding: 0, width: 120, height: 120)
        profileTopButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        self.configureViewComponents()
        
        self.view.addSubview(alreadyHaveAccountButton)
        alreadyHaveAccountButton.anchorView(top: nil, left: self.view.leftAnchor, bottom: self.view.bottomAnchor, right: self.view.rightAnchor, topPadding: 0, leftPadding: 0, bottomPadding: 10, rightPadding: 0, width: 0, height: 40)
        
    }
    
    func configureViewComponents() {
        let aStackView = UIStackView(arrangedSubviews: [fullNameTextField, usernameTextField, emailTextField, passwordTextField, signUpButton])
        aStackView.axis = .vertical
        aStackView.distribution = .fillEqually
        aStackView.spacing = 10
        self.view.addSubview(aStackView)
        aStackView.anchorView(top: profileTopButton.bottomAnchor, left: self.view.leftAnchor, bottom: nil, right: self.view.rightAnchor, topPadding: 40, leftPadding: 40, bottomPadding: 0, rightPadding: 40, width: 0, height: 240)
    }
    
    
}


//MARK: - Extension
extension SignUpViewController {
    
    @objc func bringLogIn() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @objc func enableSignUpButton() {
        guard emailTextField.hasText, passwordTextField.hasText, usernameTextField.hasText, fullNameTextField.hasText else {
            return
        }
        signUpButton.isEnabled = true
        signUpButton.backgroundColor = UIColor(red: 17/255, green: 134/255, blue: 237/255, alpha: 1)
    }
    
    
    @objc func handleSignUp() {
        guard let safeEmail = emailTextField.text else {
            return
        }
        guard let safePassword = passwordTextField.text else {
            return
        }
        guard let safeUserName = usernameTextField.text else {
            return
        }
        guard let safeFullName = fullNameTextField.text else {
            return
        }
        guard let profileImage = self.profileTopButton.imageView?.image else {
            return
        }
        guard let safeImageData = profileImage.pngData() else {
            return
        }
        
        // 1. now create user with above data
        Auth.auth().createUser(withEmail: safeEmail, password: safePassword) { (user, error) in
            if let safeError = error {
                print(safeError)
            }
            
            if let safeUser = user {
                let fileName = NSUUID().uuidString
                
                //2. storage reference to get image downloadURL
                let fbStorageRef = Storage.storage().reference()
                fbStorageRef.child("Profile_Images").child(fileName).putData(safeImageData, metadata: nil) { (storageMetaData, error) in
                    if let safeError = error {
                        print(safeError)
                    }
                    fbStorageRef.child("Profile_Images").child(fileName).downloadURL { (downloadURL, error) in
                        if let safeError = error {
                            print(safeError)
                        }
                        if let safeDownloadURL = downloadURL?.absoluteString {
                            let userValue = ["name": safeFullName, "username": safeUserName, "profileImageURLString": safeDownloadURL]
                            let userDictValue = [safeUser.user.uid: userValue]
                            
                            //3. add an user to database
                            Database.database().reference().child("Users").updateChildValues(userDictValue) { (error, dataBaseReference) in
                                if let safeError = error {
                                    print(safeError)
                                }
                                
                            }  // (error, databasereference)
                        }
                        
                    } // (downloadURL, error)
                    
                }  // (storageMetaData, error)
            }
            
        } // (user, error)
        
        self.navigationController?.dismiss(animated: true, completion: nil)
        
    }
    
}

//MARK: - UIImagePickerDelegate
extension SignUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @objc func bringImagePicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.modalPresentationStyle = .fullScreen
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let safeProfileImage = info[.editedImage] as? UIImage else {
            imageSelected = false
            return
        }
        
        imageSelected = true
        profileTopButton.layer.cornerRadius = profileTopButton.frame.width / 2
        profileTopButton.layer.borderColor = UIColor.blue.cgColor
        profileTopButton.layer.masksToBounds = true
        profileTopButton.layer.borderWidth = 2
        profileTopButton.setImage(safeProfileImage.withRenderingMode(UIImage.RenderingMode.alwaysOriginal), for: UIControl.State.normal)
        self.dismiss(animated: true, completion: nil)
    }
    
}
