//
//  Setting.swift
//  Mountain-UI-Companion
//
//  Created by Matthew Ernst on 1/22/23.
//

import Foundation
import UIKit

struct Setting {
    var id = UUID()
    let name: String
    let iconName: String
    var isSystemIcon: Bool = true
    let backgroundColor: UIColor
}


let exampleSettings: [Setting] = [
    .init(name: "General", iconName: "slider.vertical.3", backgroundColor: .systemBlue),
    .init(name: "Notifications", iconName: "bell.badge.fill", backgroundColor: .red),
]
