//
//  MainTabViewController.swift
//  Instamator
//
//  Created by Amit Chaudhary on 12/10/20.
//  Copyright © 2020 Amit Chaudhary. All rights reserved.
//

import UIKit
import Firebase

class MainTabViewController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.checkIfUserIsLoggedIn()
        self.configureViewControllers()
        // Do any additional setup after loading the view.
    }
    
    func configureViewControllers() {
        let feedVC = configureNavControllers(#imageLiteral(resourceName: "home_unselected"), #imageLiteral(resourceName: "home_selected"), FeedViewController(collectionViewLayout: UICollectionViewFlowLayout()))
        let searchVC = configureNavControllers(#imageLiteral(resourceName: "search_unselected"), #imageLiteral(resourceName: "search_selected"), SearchViewController())
        let selectPhotoVC = configureNavControllers(#imageLiteral(resourceName: "plus_unselected"), #imageLiteral(resourceName: "plus_unselected"))
        let notificationsVC = configureNavControllers(#imageLiteral(resourceName: "like_unselected"), #imageLiteral(resourceName: "like_selected"), NotificationViewController())
        let userProfileVC = configureNavControllers(#imageLiteral(resourceName: "profile_unselected"), #imageLiteral(resourceName: "profile_selected"), UserProfileViewController(collectionViewLayout: UICollectionViewFlowLayout()))
        
        self.viewControllers = [feedVC, searchVC, selectPhotoVC, notificationsVC,userProfileVC]
    }
    
    // embed each viewController in navigation Controller as rootViewController
    func configureNavControllers(_ unselectedImage: UIImage, _ selectedImage: UIImage,_ currentTabViewController: UIViewController = UIViewController()) -> UINavigationController {
        let navController = UINavigationController(rootViewController: currentTabViewController)
        navController.tabBarItem.image = unselectedImage
        navController.tabBarItem.selectedImage = selectedImage
        navController.navigationBar.tintColor = .blue
        return navController
    }
    
    
    func checkIfUserIsLoggedIn() {
        if Auth.auth().currentUser == nil {
            //user is not logged in
            DispatchQueue.main.async {
                let loginVC = LogInViewController()
                let navController = UINavigationController(rootViewController: loginVC)
                navController.modalPresentationStyle = .fullScreen
                self.present(navController, animated: true, completion: nil)
            }
        } else {
            print("MainTab View Loaded")
        }
    }
    
}


//MARK: - UITabBarControllerDelegate
extension MainTabViewController {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        let index = self.viewControllers?.firstIndex(of: viewController)
        if index == 2 {
            let selectPhotoVC = SelectPhotoViewController(collectionViewLayout: UICollectionViewFlowLayout())
            let navController = UINavigationController(rootViewController: selectPhotoVC)
            navController.modalPresentationStyle = .fullScreen
            self.present(navController, animated: true, completion: nil)
            return false
        }
        return true
    }
}
