//
//  MessagesUIViewController.swift
//  Instamator
//
//  Created by Amit Chaudhary on 12/18/20.
//  Copyright © 2020 Amit Chaudhary. All rights reserved.
//

import Foundation
import UIKit

fileprivate let reUseIdentifier = "MessagesCell"

class MessagesUIViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        constructNavigationBar()
        self.tableView.register(MessagesUIViewCell.self, forCellReuseIdentifier: reUseIdentifier)
    }
    
    
    //MARK: - UITableViewDataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: reUseIdentifier, for: indexPath) as! MessagesUIViewCell
        cell.detailTextLabel?.text = "Username"
        cell.textLabel?.text = "User"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}


//MARK: - Helper Methods
extension MessagesUIViewController {
    func constructNavigationBar() {
        navigationItem.title = "Messages"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(handleNewMessage))
    }
    
    @objc func handleNewMessage() {
        
    }
}
