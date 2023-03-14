//
//  Profile.swift
//  Mountain-UI-Companion
//
//  Created by Matthew Ernst on 1/25/23.
//

import Foundation
import UIKit

class Profile {
    var uuid: String
    var name: String {
        firstName + " " + lastName
    }
    var firstName: String
    var lastName: String
    var email: String
    var profilePicture: UIImage?
    var defaultLogbookProfilePicture: UIImage!
    var defaultAccountSettingsProfilePicture: UIImage!
    // TODO: Season Stats in different place?
    // var seasonSummary = [SessionSummary?]()
    // var mostRecentSessionSummary = [SessionSummary?]()
    
    init(uuid: String, name: String, email: String, profilePicture: UIImage? = nil) {
        self.uuid = uuid
        
        self.firstName = name.components(separatedBy: " ")[0]
        self.lastName = name.components(separatedBy: " ")[1]
        
        self.email = email
        
        self.profilePicture = profilePicture
        self.defaultLogbookProfilePicture = name.initials.image(move: .zero)?.withTintColor(.label)
        self.defaultAccountSettingsProfilePicture = name.initials.image(withAttributes: [
            .font: UIFont.systemFont(ofSize: 45, weight: .medium),
        ], size: CGSize(width: 110, height: 110), move: CGPoint(x: 22, y: 28))?.withTintColor(.label)
    }
    
    static func createProfile(uuid: String, name: String, email: String, profilePictureURL: URL? = nil, completion: @escaping (Profile) -> Void) {
        guard let profilePictureURL = profilePictureURL else {
            completion(Profile(uuid: uuid, name: name, email: email))
            return
        }
        
        URLSession.shared.dataTask(with: profilePictureURL) { (data, response, error) in
            if let error = error {
                print("Error downloading profile picture: \(error.localizedDescription)")
                completion(Profile(uuid: uuid, name: name, email: email))
                return
            }
            
            guard let data = data, let profilePicture = UIImage(data: data) else {
                completion(Profile(uuid: uuid, name: name, email: email))
                return
            }
            
            let profile = Profile(uuid: uuid, name: name, email: email, profilePicture: profilePicture)
            completion(profile)
        }.resume()
    }

}

struct UserProfileInfo {
    var uuid: String
    var name: String
    var email: String
    var profilePictureURL: URL?
}

#if DEBUG
extension Profile {
    static var sampleProfile = Profile(uuid: UUID().uuidString, name: "John Appleseed", email: "johnappleseed@icloud.com")
}
#endif
