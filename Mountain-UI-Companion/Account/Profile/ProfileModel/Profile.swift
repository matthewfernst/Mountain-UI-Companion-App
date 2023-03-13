//
//  Profile.swift
//  Mountain-UI-Companion
//
//  Created by Matthew Ernst on 1/25/23.
//

import Foundation
import UIKit

enum DefaultProfilePictureIndex: Int, CaseIterable {
    case accountSettings = 0
    case logBook = 1
}

class Profile {
    var name: String
    var firstName: String {
        name.components(separatedBy: " ")[0]
    }
    var lastName: String {
        name.components(separatedBy: " ")[1]
    }
    var email: String
    var profilePicture: UIImage?
    var defaultLogbookProfilePicture: UIImage!
    var defaultAccountSettingsProfilePicture: UIImage!
    // TODO: Season Stats in different place?
    // var seasonSummary = [SessionSummary?]()
    // var mostRecentSessionSummary = [SessionSummary?]()
    
    init(name: String, email: String, profilePictureURL: URL? = nil) {
        self.name = name
        self.email = email
        self.defaultLogbookProfilePicture = name.initials.image(move: .zero)?.withTintColor(.label)
        self.defaultAccountSettingsProfilePicture = name.initials.image(withAttributes: [
            .font: UIFont.systemFont(ofSize: 45, weight: .medium),
        ], size: CGSize(width: 110, height: 110), move: CGPoint(x: 22, y: 28))?.withTintColor(.label)
        if let profilePictureURL = profilePictureURL {
            DispatchQueue.global().async { [weak self] in
                if let data = try? Data(contentsOf: profilePictureURL) {
                    DispatchQueue.main.async { [weak self] in
                        self?.profilePicture = UIImage(data: data)
                    }
                }
            }
        }

    }
}


#if DEBUG
extension Profile {
    static var sampleProfile = Profile(name: "John Appleseed", email: "johnappleseed@icloud.com")
}
#endif
