//
//  ProfileTableViewController.swift
//  Mountain-UI-Companion
//
//  Created by Matthew Ernst on 1/25/23.
//

import UIKit

enum ProfileSections: Int, CaseIterable {
    case editProfile = 0
    case signOut = 1
}

class ProfileTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return ProfileSections.allCases.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch ProfileSections(rawValue: section) {
        case .editProfile:
            return 1
        case .signOut:
            return 1
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath)
        
        switch ProfileSections(rawValue: indexPath.section) {
        case .editProfile:
            cell.textLabel?.text = "Edit Profile"
            cell.textLabel?.textAlignment = .left
            cell.accessoryType = .disclosureIndicator
        case .signOut:
            cell.textLabel?.text = "Sign Out"
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.textColor = .red
        default:
            return cell
        }
        cell.backgroundColor = .secondarySystemBackground
        return cell
        
    }

}
