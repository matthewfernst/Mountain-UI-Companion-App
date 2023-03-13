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
    
    private var profileViewModel = ProfileViewModel.shared
    private var profile: Profile!
    
    private let dynamoDBClient = DynamoDBUtils.dynamoDBClient
    private let userTable = DynamoDBUtils.usersTable
    
    private var changedFirstName: String? = nil
    private var changedLastName: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Edit Profile"
        self.navigationController?.navigationBar.prefersLargeTitles = false
        
        bindViewModel()
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(goBackToSettings))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveNameAndEmailChanges))
        
        tableView.register(NameTableViewCell.self, forCellReuseIdentifier: NameTableViewCell.identifier)
        tableView.register(EmailTableViewCell.self, forCellReuseIdentifier: EmailTableViewCell.identifier)
    }
    
    func handleFirstNameChange(newFirstName: String) {
        changedFirstName = newFirstName
    }
    
    func handleLastNameChange(newLastName: String) {
        changedLastName = newLastName
    }
    
    func bindViewModel() {
        profile = profileViewModel.profile
    }
    
    @objc func goBackToSettings() {
        self.navigationController?.popViewController(animated: true)
    }
    
    // TODO: Implement -> How to get data from text fields?
    @objc func saveNameAndEmailChanges()  {
        let newProfilePicture = "https://lh3.googleusercontent.com/a/AGNmyxb5YYFbO5Yizb5Xk99j0FtSpvaWpTLPAQkIy-EdcJQ=s320"
        
        let firstName = changedFirstName ?? profile.firstName
        let lastName = changedLastName ?? profile.lastName
        let email = "matthew.f.ernst@gmail.com"
        
        let newName = firstName + " " + lastName
        // Update Dynamo
        Task {
            await DynamoDBUtils.updateDynamoDBItem(email: email,
                                                   newName: newName,
                                                   newProfilePictureURL: newProfilePicture)
        }
        
        // Update shared profile to update all other views
        profileViewModel.updateProfile(newProfile: Profile(name: newName,
                                                           email: email,
                                                           profilePictureURL: URL(string: newProfilePicture)))
        
        self.navigationController?.popViewController(animated: true)
        
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
                
                nameCell.configure(name: profile.name, delegate: self)
                
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


extension EditProfileTableViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        switch NameTextFieldTags(rawValue: textField.tag) {
        case .firstName:
            if let text = textField.text {
                let newFirstName = (text as NSString).replacingCharacters(in: range, with: string)
                self.handleFirstNameChange(newFirstName: newFirstName)
            }
        case .lastName:
            if let text = textField.text {
                let newLastName = (text as NSString).replacingCharacters(in: range, with: string)
                self.handleLastNameChange(newLastName: newLastName)
            }
        default:
            break
        }
        return true
    }
}
