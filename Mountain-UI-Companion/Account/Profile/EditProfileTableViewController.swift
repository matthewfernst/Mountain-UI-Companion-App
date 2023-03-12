//
//  ProfileTableViewController.swift
//  Mountain-UI-Companion
//
//  Created by Matthew Ernst on 1/25/23.
//

import UIKit

enum ProfileSections: Int, CaseIterable {
    case changeProfilePicture = 0
    case changeName = 1
    case signOut = 2
}

class EditProfileTableViewController: UITableViewController {
    
    static var identifier = "EditProfileTableViewController"

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return ProfileSections.allCases.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch ProfileSections(rawValue: section) {
        case .changeProfilePicture:
            return 1
        case .changeName:
            return 1
        case .signOut:
            return 1
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath)
        var configuation = cell.defaultContentConfiguration()
        
        switch ProfileSections(rawValue: indexPath.section) {
        case .changeProfilePicture:
            configuation.text = "Change Profile Picture"
            cell.accessoryType = .disclosureIndicator
        case .changeName:
            configuation.text = "Change Name"
            cell.accessoryType = .disclosureIndicator
        case .signOut:
            configuation.text = "Sign Out"
            configuation.textProperties.alignment = .center
            configuation.textProperties.color = .red
        default:
            return cell
        }
        cell.backgroundColor = .secondarySystemBackground
        cell.contentConfiguration = configuation
        return cell
        
    }

}
