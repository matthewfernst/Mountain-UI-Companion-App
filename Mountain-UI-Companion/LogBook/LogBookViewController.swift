//
//  LogBookViewController.swift
//  Mountain-UI-Companion
//
//  Created by Matthew Ernst on 1/23/23.
//

import UIKit

enum SessionSection: Int, CaseIterable {
    case seasonSummary = 0
    case sessionSummary = 1
}

class LogBookViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var lifetimeTotalVerticalFeet: UILabel!
    @IBOutlet var lifetimeDaysOnMountainLabel: UILabel!
    @IBOutlet var lifetimeRunsTimeLabel: UILabel!
    @IBOutlet var lifetimeRunsLabel: UILabel!
    @IBOutlet var allLifetimeStateButton: UIButton!
    @IBOutlet var sessionSummaryTableView: UITableView!
    
    var profileViewModel = ProfileViewModel.shared
    var profile: Profile!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "LogBook"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        profile = profileViewModel.profile
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "info.circle"), style: .plain, target: self, action: #selector(explainMoreWithSlopes))
        
        sessionSummaryTableView.delegate = self
        sessionSummaryTableView.dataSource = self
        sessionSummaryTableView.register(SessionTableViewCell.self, forCellReuseIdentifier: SessionTableViewCell.identifier)
        sessionSummaryTableView.rowHeight = 66.0
        
        let profileImage = profile.profilePicture ?? profile.defaultLargeProfilePicture
        profileImageView.image = profileImage
        profileImageView.backgroundColor = .secondarySystemBackground
        profileImageView.makeRounded()
    }
    
    @objc func explainMoreWithSlopes() {
        
        let message = """
                      This data comes from the Slopes app and is a way to quickly see your data being used.
                      For more detailed information, vist your Slopes app.
                      """
        
        let ac = UIAlertController(title: "Information Taken From Slopes", message: message, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        
        present(ac, animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return SessionSection.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch SessionSection(rawValue: section) {
        case .seasonSummary:
            return 1
        case .sessionSummary:
            return 2
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch SessionSection(rawValue: indexPath.section) {
        case .seasonSummary:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SeasonSummaryCell", for: indexPath)
            var configuration = cell.defaultContentConfiguration()
            
            configuration.text = "Season Summary"
            configuration.secondaryText = "5 runs | 2 days | 4.3k FT"
            configuration.secondaryTextProperties.color = .secondaryLabel
        
            cell.backgroundColor = .secondarySystemBackground
            
            return cell
            
        case .sessionSummary:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SessionTableViewCell.identifier, for: indexPath) as? SessionTableViewCell else {
                return UITableViewCell()
            }
            
            cell.configure()
            return cell
            
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch SessionSection(rawValue: section) {
        case.seasonSummary:
            return 50
        default:
            return 18
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch SessionSection(rawValue: section) {
        case .seasonSummary:
            let header = UILabel()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy"
            
            let currentYear = dateFormatter.string(from: .now)
            let pastYear = String((Int(currentYear) ?? 0) - 1)
            
            header.text = "\(pastYear)/\(currentYear)"
            header.font = UIFont.systemFont(ofSize: 22, weight: .bold)
            
            return header
            
        default:
            return nil
        }
    }
}


