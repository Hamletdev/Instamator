//
//  LogInViewController.swift
//  Instamator
//
//  Created by Amit Chaudhary on 12/10/20.
//  Copyright © 2020 Amit Chaudhary. All rights reserved.
//

import UIKit
import Firebase

class LogInViewController: UIViewController {
    
    //closure stored properties
    
    let logoContainerView: UIView = {
        let aView = UIView()
        let logoImageView = UIImageView(image: #imageLiteral(resourceName: "logo2"))
        logoImageView.contentMode = .scaleAspectFill
        aView.addSubview(logoImageView)
        logoImageView.anchorView(top: nil, left: nil, bottom: nil, right: nil, topPadding: 0, leftPadding: 0, bottomPadding: 0, rightPadding: 0, width: 180, height: 50)
        logoImageView.centerYAnchor.constraint(equalTo: aView.centerYAnchor).isActive = true
        logoImageView.centerXAnchor.constraint(equalTo: aView.centerXAnchor).isActive = true
        aView.backgroundColor = UIColor(red: 0/255, green: 120/255, blue: 175/255, alpha: 1)
        return aView
    }()
    
    let emailTextField: UITextField = {
        let aTextField = UITextField()
        aTextField.placeholder = "Enter Email"
        aTextField.backgroundColor = UIColor(white: 0, alpha: 0.03)
        aTextField.borderStyle = .roundedRect
        aTextField.font = UIFont.systemFont(ofSize: 14)
        aTextField.addTarget(self, action: #selector(enableLoginButton), for: .editingChanged)
        return aTextField
    }()
    
    let passwordTextField: UITextField = {
        let aTextField = UITextField()
        aTextField.placeholder = "Enter Password"
        aTextField.backgroundColor = UIColor(white: 0, alpha: 0.03)
        aTextField.borderStyle = .roundedRect
        aTextField.font = UIFont.systemFont(ofSize: 14)
        aTextField.isSecureTextEntry = true
        aTextField.addTarget(self, action: #selector(enableLoginButton), for: UIControl.Event.editingChanged)
        return aTextField
    }()
    
    let loginButton: UIButton = {
        let aButton = UIButton(type: UIButton.ButtonType.system)
        aButton.setTitle("Login", for: UIControl.State.normal)
        aButton.setTitleColor(.white, for: UIControl.State.normal)
        aButton.backgroundColor = UIColor(red: 149/255, green: 204/255, blue: 244/255, alpha: 1)
        aButton.layer.cornerRadius = 5
        aButton.isEnabled = false
        aButton.addTarget(self, action: #selector(handleLogIn), for: UIControl.Event.touchUpInside)
        return aButton
    }()
    
    let doNotHaveAccountButton: UIButton = {
        let aButton = UIButton(type: UIButton.ButtonType.system)
        let attributedTitle = NSMutableAttributedString(string: "Don't have an account?", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14.0), NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        attributedTitle.append(NSAttributedString(string: " Sign Up", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14.0), NSAttributedString.Key.foregroundColor: UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)]))
        aButton.setAttributedTitle(attributedTitle, for: UIControl.State.normal)
        aButton.addTarget(self, action: #selector(bringSignUpView), for: UIControl.Event.touchUpInside)
        return aButton
    }()
    
    
    //methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.navigationController?.navigationBar.isHidden = true
        
        self.view.addSubview(logoContainerView)
        logoContainerView.anchorView(top: self.view.topAnchor, left: self.view.leftAnchor, bottom: nil, right: self.view.rightAnchor, topPadding: 0, leftPadding: 0, bottomPadding: 0, rightPadding: 0, width: 0, height: 150)
        
        self.configureViewComponents()
        self.view.addSubview(doNotHaveAccountButton)
        doNotHaveAccountButton.anchorView(top: nil, left: self.view.leftAnchor, bottom: self.view.bottomAnchor, right: self.view.rightAnchor, topPadding: 0, leftPadding: 0, bottomPadding: 10, rightPadding: 0, width: 0, height: 40)
        
    }
    
    func configureViewComponents() {
        let aStackView = UIStackView(arrangedSubviews: [emailTextField, passwordTextField, loginButton])
        aStackView.axis = .vertical
        aStackView.distribution = .fillEqually
        aStackView.spacing = 10
        self.view.addSubview(aStackView)
        aStackView.anchorView(top: self.logoContainerView.bottomAnchor, left: self.view.leftAnchor, bottom: nil, right: self.view.rightAnchor, topPadding: 40, leftPadding: 40, bottomPadding: 0, rightPadding: 40, width: 0, height: 140)
    }
    
    
}


extension LogInViewController {
    @objc func bringSignUpView() {
        let signUpVC = SignUpViewController()
        signUpVC.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(signUpVC, animated: true)
    }
    
    @objc func enableLoginButton() {
        guard emailTextField.hasText, passwordTextField.hasText else {
            return
        }
        loginButton.isEnabled = true
        loginButton.backgroundColor = UIColor(red: 17/255, green: 134/255, blue: 237/255, alpha: 1)
    }
}

//MARK: - Firebase LogIn
extension LogInViewController {
    @objc func handleLogIn() {
        guard let safeEmailText = emailTextField.text , let safePasswordText = passwordTextField.text else {
            return
        }
        //logIn
        Auth.auth().signIn(withEmail: safeEmailText, password: safePasswordText) { (authData, error) in
            if let safeError = error {
                print(safeError)
                return
            }
            
            self.navigationController?.dismiss(animated: true, completion: nil)
        } // (authData,error)
    }
}
