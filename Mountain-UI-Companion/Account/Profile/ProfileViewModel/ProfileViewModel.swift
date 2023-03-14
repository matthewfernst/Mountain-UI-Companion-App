//
//  ProfileViewModel.swift
//  Mountain-UI-Companion
//
//  Created by Matthew Ernst on 3/12/23.
//
import UIKit
import Foundation

class ProfileViewModel {
    static let shared = ProfileViewModel()
    
    var profile: Profile?
    
    var uuid: String {
        return profile?.uuid ?? ""
    }
    
    var name: String {
        return profile?.name ?? ""
    }
    
    var email: String {
        return profile?.email ?? ""
    }
    
    var profilePicture: UIImage? {
        return profile?.profilePicture
    }
    
    var profilePictureURL: URL? {
        return profile?.profilePictureURL
    }
    
    var defaultProfilePictureLarge: UIImage {
        return (profile?.defaultLargeProfilePicture)!
    }
    
    var defaultProfilePictureSmall: UIImage {
        return (profile?.defaultSmallProfilePicture)!
    }
    
    func updateProfile(newProfile: Profile) {
        self.profile = newProfile
    }
    
    private init() {}
    
}
