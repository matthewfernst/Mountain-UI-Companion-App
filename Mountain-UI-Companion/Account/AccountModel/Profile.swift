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

struct Profile {
    var userName: String
    var email: String
    var profilePicture: UIImage?
    var defaultProfilePictures = [UIImage?]()
    // TODO: Season Stats in different place?
    // var seasonSummary = [SessionSummary?]()
    // var mostRecentSessionSummary = [SessionSummary?]()
    
    init(userName: String, email: String, profilePicture: UIImage? = nil) {
        self.userName = userName
        self.email = email
        if let profilePicture = profilePicture {
            self.profilePicture = profilePicture
        }
        
        self.defaultProfilePictures.append(userName.initials.image(move: .zero)?.withTintColor(.label))
        self.defaultProfilePictures.append(userName.initials.image(withAttributes: [
            .font: UIFont.systemFont(ofSize: 45, weight: .medium),
        ], size: CGSize(width: 110, height: 110), move: CGPoint(x: 22, y: 28))?.withTintColor(.label))
    }
}


let exampleProfile = Profile(userName: "Matthew Ernst", email: "matthew.f.ernst@gmail.com")
