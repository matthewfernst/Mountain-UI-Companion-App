//
//  SettingsTableViewController.swift
//  Mountain-UI-Companion
//
//  Created by Matthew Ernst on 1/25/23.
//

import UIKit

enum AppSettingSections: Int, CaseIterable {
    case units = 0
    case theme = 1
}

class AppSettingTableViewController: UITableViewController {
    
    static var identitifer = "AppSettingTableView"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "App Settings"
        self.navigationItem.largeTitleDisplayMode = .never
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return AppSettingSections.allCases.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch AppSettingSections(rawValue: section) {
        case .units:
            return 1
        case .theme:
            return 1
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AppSettingCell", for: indexPath)
        switch AppSettingSections(rawValue: indexPath.section) {
        case .units:
            cell.textLabel?.text = "Units"
            cell.accessoryView = getPopoverButtonForCell(actionTitles: ["Imperial", "Metric"])
            cell.accessoryView?.tintColor = .label
        case .theme:
            cell.textLabel?.text = "Theme"
            cell.accessoryView = getPopoverButtonForCell(actionTitles: ["System", "Dark", "Light"])
            cell.accessoryView?.tintColor = .label
        default:
            return UITableViewCell()
        }
        cell.backgroundColor = .systemGroupedBackground
        return cell
    }
    
    
    func getPopoverButtonForCell(actionTitles: [String]) -> UIButton {
        let pullDownButton = UIButton()
        
        pullDownButton.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        
        let chevronDown = UIImage(systemName: "chevron.down")?.scalePreservingAspectRatio(targetSize: CGSize(width: 14, height: 14)).withTintColor(.lightGray)
        pullDownButton.setImage(chevronDown, for: .normal)
        
        let chevronUp = UIImage(systemName: "chevron.up")?.scalePreservingAspectRatio(targetSize: CGSize(width: 14, height: 14)).withTintColor(.lightGray)
        pullDownButton.setImage(chevronUp, for: .highlighted)
        
        pullDownButton.semanticContentAttribute = .forceRightToLeft
        
        var menuOptions = [UIAction]()
        actionTitles.forEach {  menuOptions.append(UIAction(title: "\($0) ", handler: {_ in })) }
        pullDownButton.menu = UIMenu(title: "", children:
            menuOptions
        )
        
        pullDownButton.setTitleColor(.label, for: .normal)
        pullDownButton.showsMenuAsPrimaryAction = true
        pullDownButton.changesSelectionAsPrimaryAction = true
        pullDownButton.sizeToFit()
        
        return pullDownButton
    }

}
