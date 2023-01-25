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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "LogBook"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        sessionSummaryTableView.delegate = self
        sessionSummaryTableView.dataSource = self
        
        let profileName = "Matthew Ernst"
        let profileImage = profileName.initials.image(withAttributes: [
            .font: UIFont.systemFont(ofSize: 45, weight: .medium),
        ], size: CGSize(width: 110, height: 110), move: CGPoint(x: 22, y: 28))?.withTintColor(.label)
        profileImageView.image = profileImage
        profileImageView.backgroundColor = .secondarySystemBackground
        profileImageView.layer.masksToBounds = true
        profileImageView.layer.cornerRadius = 55
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
            cell.textLabel?.text = "Season Summary"
            cell.detailTextLabel?.text = "5 runs | 2 days | 4.3k FT"
            cell.backgroundColor = .secondarySystemBackground
            return cell
            
        case .sessionSummary:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SeasonSummaryCell", for: indexPath)
            cell.textLabel?.text = "Steamboat Ski Resort"
            cell.detailTextLabel?.text = "3 runs | 1H 25M"
            
            let paragraph = NSMutableParagraphStyle()
            paragraph.alignment = .center
            
            let dateOfSessionAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 16),
                .paragraphStyle: paragraph
            ]
            
            let dateOfSession = "Jan\n2".image(withAttributes: dateOfSessionAttributes, size: CGSize(width: 50, height: 50), move: CGPoint(x: 0, y: 5))?.withTintColor(.label)
            cell.imageView?.image = dateOfSession
            cell.backgroundColor = .secondarySystemBackground
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
            header.text = "2022/2023"
            header.font = UIFont.systemFont(ofSize: 22, weight: .bold)
            return header
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}


