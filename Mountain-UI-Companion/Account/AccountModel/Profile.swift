//
//  Profile.swift
//  Mountain-UI-Companion
//
//  Created by Matthew Ernst on 1/25/23.
//

import Foundation
import UIKit

struct Profile {
    var userName: String
    var email: String
    var profilePicture: UIImage?
 
    init(userName: String, email: String, profilePicture: UIImage? = nil) {
        self.userName = userName
        self.email = email
        if let profilePicture = profilePicture {
            self.profilePicture = profilePicture
        } else {
            self.profilePicture = userName.initials.image(move: .zero)?.withTintColor(.label)
        }
    }
}


let exampleProfile = Profile(userName: "Matthew Ernst", email: "matthew.f.ernst@gmail.com")
