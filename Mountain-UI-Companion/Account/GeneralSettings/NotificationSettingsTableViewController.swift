//
//  NotificationTableViewController.swift
//  Mountain-UI-Companion
//
//  Created by Matthew Ernst on 1/25/23.
//

import UIKit

class NotificationSettingsTableViewController: UITableViewController {
    
    static var identifier = "NotificationSettingsTableView"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Notifications"
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath)
        
        cell.textLabel?.text = "Allow Notifications"
        
        let notificationSwitch = UISwitch()
        notificationSwitch.sizeToFit()
        
        cell.accessoryView = notificationSwitch
        cell.backgroundColor = .secondarySystemBackground
        return cell
    }

}
