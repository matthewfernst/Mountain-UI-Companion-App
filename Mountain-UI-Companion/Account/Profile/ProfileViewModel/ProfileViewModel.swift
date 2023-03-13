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
    
    var name: String {
        return profile?.name ?? ""
    }
    
    var email: String {
        return profile?.email ?? ""
    }
    
    var profilePicture: UIImage? {
        return profile?.profilePicture
    }
    
    var defaultProfilePictureLarge: UIImage {
        return (profile?.defaultLogbookProfilePicture)!
    }
    
    var defaultProfilePictureSmall: UIImage {
        return (profile?.defaultAccountSettingsProfilePicture)!
    }
    
    func updateProfile(newProfile: Profile) {
        self.profile = newProfile
    }
    
    private init() {}
    
}
