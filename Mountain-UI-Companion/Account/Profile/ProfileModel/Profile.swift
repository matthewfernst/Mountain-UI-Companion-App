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
    
    init(name: String, email: String, profilePicture: UIImage? = nil) {
        self.name = name
        self.email = email
        self.profilePicture = profilePicture
        self.defaultLogbookProfilePicture = name.initials.image(move: .zero)?.withTintColor(.label)
        self.defaultAccountSettingsProfilePicture = name.initials.image(withAttributes: [
            .font: UIFont.systemFont(ofSize: 45, weight: .medium),
        ], size: CGSize(width: 110, height: 110), move: CGPoint(x: 22, y: 28))?.withTintColor(.label)
    }
    
    static func createProfile(name: String, email: String, profilePictureURL: URL? = nil, completion: @escaping (Profile) -> Void) {
        guard let profilePictureURL = profilePictureURL else {
            completion(Profile(name: name, email: email))
            return
        }
        
        URLSession.shared.dataTask(with: profilePictureURL) { (data, response, error) in
            if let error = error {
                print("Error downloading profile picture: \(error.localizedDescription)")
                completion(Profile(name: name, email: email))
                return
            }
            
            guard let data = data, let profilePicture = UIImage(data: data) else {
                completion(Profile(name: name, email: email))
                return
            }
            
            let profile = Profile(name: name, email: email, profilePicture: profilePicture)
            completion(profile)
        }.resume()
    }

}

struct UserProfileInfo {
    var name: String
    var email: String
    var profilePictureURL: URL?
}

#if DEBUG
extension Profile {
    static var sampleProfile = Profile(name: "John Appleseed", email: "johnappleseed@icloud.com")
}
#endif
