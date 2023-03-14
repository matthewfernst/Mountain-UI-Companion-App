//
//  ProfileTableViewController.swift
//  Mountain-UI-Companion
//
//  Created by Matthew Ernst on 1/25/23.
//

import UIKit

class EditProfileTableViewController: UITableViewController {
    
    static var identifier = "EditProfileTableViewController"
    
    private var profileViewModel = ProfileViewModel.shared
    private var profile: Profile!
    
    private let dynamoDBClient = DynamoDBUtils.dynamoDBClient
    private let userTable = DynamoDBUtils.usersTable
    
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
    
    func bindViewModel() {
        profile = profileViewModel.profile
    }
    
    @objc func goBackToSettings() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func saveNameAndEmailChanges()  {
        #warning("TODO: Add Profile Picture Change -> Image Picker needed.")
        let newProfilePictureURL = URL(string: "https://i.imgur.com/w5rkSIj.jpg")!
        // Update Dynamo
        Task {
            await DynamoDBUtils.updateDynamoDBItem(uuid: self.profileViewModel.uuid,
                                                   newName: self.profileViewModel.name,
                                                   newEmail: self.profileViewModel.email,
                                                   newProfilePictureURL: newProfilePictureURL.absoluteString)
        }
        
        // Update shared profile to update all other views
        Profile.createProfile(uuid: self.profileViewModel.uuid,
                              name: self.profileViewModel.name,
                              email: self.profileViewModel.email,
                              profilePictureURL: newProfilePictureURL) { [unowned self] newProfile in
            self.profileViewModel.updateProfile(newProfile: newProfile)
            DispatchQueue.main.async {
                // Refresh the previous view controller
                self.navigationController?.popViewController(animated: true)
            }
        }
        
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
                emailCell.configure(email: profile.email, delegate: self)
                
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
        switch EditProfileTextFieldTags(rawValue: textField.tag) {
        case .firstName:
            if let text = textField.text {
                self.profileViewModel.profile?.firstName = (text as NSString).replacingCharacters(in: range, with: string)
            }
        case .lastName:
            if let text = textField.text {
                self.profileViewModel.profile?.lastName = (text as NSString).replacingCharacters(in: range, with: string)
            }
        case .email:
            if let text = textField.text {
                self.profileViewModel.profile?.email = (text as NSString).replacingCharacters(in: range, with: string)
            }
        default:
            break
        }
        self.profile = self.profileViewModel.profile
        return true
    }
}
