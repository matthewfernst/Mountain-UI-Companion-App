//
//  ProfileTableViewController.swift
//  Mountain-UI-Companion
//
//  Created by Matthew Ernst on 1/25/23.
//

import UIKit

enum ProfileSections: Int, CaseIterable {
    case changeNameAndEmail = 0
    case signOut = 1
}

enum NameAndEmailSections: Int, CaseIterable {
    case name = 0
    case email = 1
}

class EditProfileTableViewController: UITableViewController {
    
    static var identifier = "EditProfileTableViewController"
    
    private var profile = LoginViewController.userProfile!
    private let dynamoDBClient = DynamoDBUtils.dynamoDBClient
    private let userTable = DynamoDBUtils.usersTable
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Edit Profile"
        self.navigationController?.navigationBar.prefersLargeTitles = false
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(goBackToSettings))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveNameAndEmailChanges))
        
        tableView.register(NameTableViewCell.self, forCellReuseIdentifier: NameTableViewCell.identifier)
        tableView.register(EmailTableViewCell.self, forCellReuseIdentifier: EmailTableViewCell.identifier)
    }
    
    @objc func goBackToSettings() {
        for controller in self.navigationController!.viewControllers as Array {
            if controller.isKind(of: AccountViewController.self) {
                self.navigationController!.popToViewController(controller, animated: true)
                break
            }
        }
    }
    // TODO: Implement
    @objc func saveNameAndEmailChanges() {
        // check which changed
        
        // Save in DynamoDB
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return ProfileSections.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch ProfileSections(rawValue: section) {
        case .changeNameAndEmail:
            return 2
        case .signOut:
            return 1
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch ProfileSections(rawValue: indexPath.section) {
        case .changeNameAndEmail:
            switch NameAndEmailSections(rawValue: indexPath.row) {
            case .name:
                guard let nameCell = tableView.dequeueReusableCell(withIdentifier: NameTableViewCell.identifier, for: indexPath) as? NameTableViewCell else {
                    return UITableViewCell()
                }
                
                nameCell.configure(name: profile.name)
                
                return nameCell
                
            case .email:
                guard let emailCell = tableView.dequeueReusableCell(withIdentifier: EmailTableViewCell.identifier, for: indexPath) as? EmailTableViewCell else { return UITableViewCell()
                }
                
                emailCell.configure(email: profile.email)
                
                return emailCell
            default:
                return UITableViewCell()
            }
            
        case .signOut:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath)
            var configuation = cell.defaultContentConfiguration()
            
            configuation.text = "Sign Out"
            configuation.textProperties.alignment = .center
            configuation.textProperties.color = .red
            
            cell.backgroundColor = .secondarySystemBackground
            cell.contentConfiguration = configuation
            
            return cell
        default:
            return UITableViewCell()
        }
        
    }
    
}
