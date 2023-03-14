//
//  ProfileSectionEnums.swift
//  Mountain-UI-Companion
//
//  Created by Matthew Ernst on 3/13/23.
//

import Foundation

enum DefaultProfilePictureIndex: Int, CaseIterable {
    case accountSettings = 0
    case logBook = 1
}

enum ProfileSections: Int, CaseIterable {
    case changeNameAndEmail = 0
    case signOut = 1
}

enum NameAndEmailSections: Int, CaseIterable {
    case name = 0
    case email = 1
}

enum EditProfileTextFieldTags: Int, CaseIterable {
    case firstName = 0
    case lastName = 1
    case email = 2
}
