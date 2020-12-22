//
//  SearchViewController.swift
//  Instamator
//
//  Created by Amit Chaudhary on 12/10/20.
//  Copyright © 2020 Amit Chaudhary. All rights reserved.
//

import UIKit
import Firebase

fileprivate let reuseIdentifier = "SearchCell"
fileprivate let reUsePostIdentifier = "SearchPostCell"

public var userLoadedFromSearch = false

class SearchViewController: UITableViewController {
    
    var totalUser = [User]()
    var filteredUsers = [User]()
    var searchBar = UISearchBar()
    var inSearchMode = false
    var totalPosts = [Post]()
    
    var collectionView: UICollectionView!
    
    var currentKey: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(SearchViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        self.tableView.separatorInset = UIEdgeInsets(top: 0, left: 50, bottom: 0, right: 0)
        
        self.constructCollectionView()
        self.navigationItem.title = "Search"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "search_unselected"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(constructSearchBar))
//         self.fetchPosts()
        self.constructRefreshControl()
        self.fetchPostsWithPagination()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if inSearchMode {
            return filteredUsers.count
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! SearchViewCell

        // Configure the cell...
        if inSearchMode {
            cell.searchUser = filteredUsers[indexPath.row]
        } else {
          cell.searchUser = totalUser[indexPath.row]
        }
        return cell
    }
    
    
    //MARK: - Table view Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let userProfileVC = UserProfileViewController(collectionViewLayout: UICollectionViewFlowLayout())
        userProfileVC.headerUser = filteredUsers[indexPath.row]
        self.navigationController?.pushViewController(userProfileVC, animated: true)
        userLoadedFromSearch = true
    }

}


//MARK: - Firebase Operation
extension SearchViewController {
    func fetchTotalUsers() {
        Database.database().reference().child("Users").observe(DataEventType.childAdded) { (snapshot) in
            guard let searchUserDictionary = snapshot.value as? [String: AnyObject] else { return }
                                             
            let userID = snapshot.key
            let user = User(userID, userDictionary: searchUserDictionary)
        
            self.totalUser.append(user)
            self.tableView.reloadData()
        }
    }
    
    func fetchPosts() {
           POSTS_REF.observe(DataEventType.childAdded) { (snapshot) in
               let postID = snapshot.key
               Database.fetchPost(with: postID) { (post) in
                   self.totalPosts.append(post)
                   self.collectionView.reloadData()
               }
           }
       }
       
       //pagination
       func fetchPostsWithPagination() {
           if self.currentKey == nil {
               POSTS_REF.queryLimited(toLast: 15).observeSingleEvent(of: DataEventType.value) { (snapshot) in
                    self.tableView.refreshControl?.endRefreshing()
                   guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] , let first = snapshot.children.allObjects.first as? DataSnapshot else {return}
                   allObjects.forEach { (snapshot) in
                       let postID = snapshot.key
                       Database.fetchPost(with: postID) { (post) in
                           self.totalPosts.append(post)
                           self.collectionView.reloadData()
                       }
                   }
                   self.currentKey = first.key
               }
           } else {
               POSTS_REF.queryOrderedByKey().queryEnding(atValue: self.currentKey).queryLimited(toLast: 6).observeSingleEvent(of: DataEventType.value) { (snapshot) in
                   guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] , let first = snapshot.children.allObjects.first as? DataSnapshot else {return}
                   allObjects.forEach { (snapshot) in
                       let postID = snapshot.key
                       if postID != self.currentKey {
                       Database.fetchPost(with: postID) { (post) in
                           self.totalPosts.append(post)
                           self.collectionView.reloadData()
                        }
                      }
                   }
                   self.currentKey = first.key
               }
           }
       }
}


//MARK: - UISearchBar
extension SearchViewController: UISearchBarDelegate {
    @objc func constructSearchBar() {
        navigationItem.titleView = searchBar
        searchBar.isHidden = false
        self.collectionView.removeFromSuperview()
        self.inSearchMode = true
        searchBar.sizeToFit()
        searchBar.delegate = self
        searchBar.barTintColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
        self.tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        searchBar.text = nil
        self.inSearchMode = false
        searchBar.isHidden = true
        searchBar.showsCancelButton = false
        self.tableView.reloadData()
        self.tableView.addSubview(collectionView)
        self.collectionView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
        self.inSearchMode = true
        self.fetchTotalUsers()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let searchText = searchBar.text
        if searchText?.count == 0 {
            filteredUsers = totalUser
            self.tableView.reloadData()
        } else {
        filteredUsers = totalUser.filter({ (user) -> Bool in
            return user.userName.contains(searchText!)
        })
            self.tableView.reloadData()
        }
    }
}


//MARK: - UICollectionView
extension SearchViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func constructCollectionView() {
        let layOut = UICollectionViewFlowLayout()
        layOut.scrollDirection = .vertical
        collectionView = UICollectionView(frame: self.tableView.frame, collectionViewLayout: layOut)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = .clear
        self.tableView.addSubview(collectionView)
        self.tableView.separatorColor = .clear
        self.collectionView.register(SearchPostCell.self, forCellWithReuseIdentifier: reUsePostIdentifier)
    }
    
    
    //MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        totalPosts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reUsePostIdentifier, for: indexPath) as! SearchPostCell
        cell.post = totalPosts[indexPath.row]
        return cell
    }
    
    
    //MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let feedVC = FeedViewController(collectionViewLayout: UICollectionViewFlowLayout())
        feedVC.viewSinglePost = true
        feedVC.feedPost = totalPosts[indexPath.row]
        navigationController?.pushViewController(feedVC, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if totalPosts.count > 14 {
            if indexPath.item == totalPosts.count - 1 {
                self.fetchPostsWithPagination()
            }
        }
    }
    
    
    //MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (self.tableView.frame.width - 2) / 3
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
}


//MARK: - Helper Methods
extension SearchViewController {
    func constructRefreshControl() {
        let refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(refreshTableView), for: UIControl.Event.valueChanged)
        self.tableView.refreshControl = refresher
    }
    
    @objc func refreshTableView() {
        self.totalPosts.removeAll(keepingCapacity: false)
        self.currentKey = nil
        self.fetchPostsWithPagination()
        self.collectionView.reloadData()
    }
}