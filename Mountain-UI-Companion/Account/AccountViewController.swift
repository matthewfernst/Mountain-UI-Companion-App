//
//  ProfileViewController.swift
//  Mountain-UI-Companion
//
//  Created by Matthew Ernst on 1/22/23.
//

import UIKit

enum AllSettingsSections: Int, CaseIterable {
    case profile = 0
    case general = 1
    case support = 2
}

enum GeneralSettinsSections: Int, CaseIterable {
    case app = 0
    case notifications = 1
}

class AccountViewController: UITableViewController {
    
    private var generalSettings = settingOptions
    private var supportSettings = supportOptions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Account"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        // Register the custom header view.
        tableView.register(MadeWithLoveFooterView.self,
                           forHeaderFooterViewReuseIdentifier: "MadeWithLove")
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return AllSettingsSections.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch AllSettingsSections(rawValue: section) {
        case .profile:
            return 1
        case .general:
            return generalSettings.count
        case .support:
            return supportSettings.count
        default:
            return 0
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        let name: String
        let backgroundColor: UIColor
        var settingImage: UIImage!
        
        switch AllSettingsSections(rawValue: indexPath.section) {
        case .profile:
            cell = tableView.dequeueReusableCell(withIdentifier: "Profile", for: indexPath)
            let profileName = "Matthew Ernst"
            cell.textLabel?.text = profileName
            cell.detailTextLabel?.text = "Edit Account & Profile"
            cell.textLabel?.numberOfLines = 2
            // TODO: Add profile pic if there is one!
            let profileImage = profileName.initials.image(withAttributes: [
                .font: UIFont.systemFont(ofSize: 24, weight: .medium),
            ], size: CGSize(width: 60, height: 60), move: CGPoint(x: 13, y: 15))?.withTintColor(.label)
            cell.imageView?.image = profileImage
            cell.imageView?.layer.masksToBounds = true
            cell.imageView?.clipsToBounds = true
            cell.imageView?.layer.cornerRadius = 30
            cell.imageView?.backgroundColor = .systemBackground
            cell.imageView?.contentMode = .scaleToFill
            cell.backgroundColor = .secondarySystemBackground
            return cell
            
        case .general:
            cell = tableView.dequeueReusableCell(withIdentifier: "Setting", for: indexPath)
            let setting = generalSettings[indexPath.row]
            name = setting.name
            backgroundColor = setting.backgroundColor
            settingImage = UIImage(systemName: setting.iconName)
            let settingImageConfiguration = UIImage.SymbolConfiguration(weight: .bold)
            cell.imageView?.image = settingImage.withConfiguration(settingImageConfiguration)
            cell.textLabel?.text = name
            cell.tintColor = .white
            cell.imageView?.layer.cornerRadius = 5
            cell.imageView?.backgroundColor = backgroundColor
            cell.backgroundColor = .secondarySystemBackground
            return cell
            
        case .support:
            cell = tableView.dequeueReusableCell(withIdentifier: "Setting", for: indexPath)
            let setting = supportSettings[indexPath.row]
            name = setting.setting.name
            backgroundColor = setting.setting.backgroundColor
            settingImage = UIImage(named: setting.setting.iconName)
            settingImage = settingImage.scalePreservingAspectRatio(targetSize: CGSize(width: 28, height: 28))
            cell.imageView?.image = settingImage
            cell.textLabel?.text = name
            cell.tintColor = .white
            cell.imageView?.layer.masksToBounds = true
            cell.imageView?.layer.cornerRadius = 5
            cell.imageView?.backgroundColor = backgroundColor
            cell.backgroundColor = .secondarySystemBackground
            return cell
            
        default:
            return UITableViewCell()
        }
        
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch AllSettingsSections(rawValue: section) {
        case .general:
            return "Settings"
        case .support:
            return "Show your support"
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        switch AllSettingsSections(rawValue: section) {
        case .support:
            let footer = tableView.dequeueReusableHeaderFooterView(withIdentifier: "MadeWithLove") as! MadeWithLoveFooterView
            footer.appVersionLabel.text = "Version 1.0.0"
            footer.madeWithLoveLabel.text = "Made with ❤️+☕️ in San Diego, CA"
            return footer
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch AllSettingsSections(rawValue: section) {
        case .support:
            return 100
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch AllSettingsSections(rawValue: indexPath.section) {
        case .profile:
            if let profileVC = self.storyboard?.instantiateViewController(withIdentifier: "ProfileTableView") as? ProfileTableViewController {
                self.navigationController?.pushViewController(profileVC, animated: true)
            }
            
        case .general:
            switch GeneralSettinsSections(rawValue: indexPath.row) {
            case .app:
                if let appVC = self.storyboard?.instantiateViewController(withIdentifier: "AppSettingTableView") as? AppSettingTableViewController {
                    self.navigationController?.pushViewController(appVC, animated: true)
                }
                
            case .notifications:
                if let notificationVC = self.storyboard?.instantiateViewController(withIdentifier: "NotificationSettingsTableView") as? NotificationSettingsTableViewController {
                    self.navigationController?.pushViewController(notificationVC, animated: true)
                }
                
            default:
                return
            }
            

        case .support:
            if let url = URL(string: self.supportSettings[indexPath.row].link) {
                UIApplication.shared.open(url)
            }
            
        default:
            break
        }
        
    }
}

