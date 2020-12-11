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

public var userLoadedFromSearch = false

class SearchViewController: UITableViewController {
    
    var totalUser = [User]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(SearchViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        self.tableView.separatorInset = UIEdgeInsets(top: 0, left: 50, bottom: 0, right: 0)
        
        self.fetchUsers()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return totalUser.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! SearchViewCell

        // Configure the cell...
        cell.searchUser = totalUser[indexPath.row]
        return cell
    }
    
    
    //MARK: - Table view Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let userProfileVC = UserProfileViewController(collectionViewLayout: UICollectionViewFlowLayout())
        userProfileVC.user = totalUser[indexPath.row]
        self.navigationController?.pushViewController(userProfileVC, animated: true)
        userLoadedFromSearch = true
    }

}


//MARK: - Firebase Operation
extension SearchViewController {
    func fetchUsers() {
        Database.database().reference().child("Users").observe(DataEventType.childAdded) { (snapshot) in
            guard let searchUserDictionary = snapshot.value as? [String: AnyObject] else { return }
                                             
            let userID = snapshot.key
            let user = User(userID, userDictionary: searchUserDictionary)
        
            self.totalUser.append(user)
            self.tableView.reloadData()
        }
    }
}
