//
//  Support.swift
//  Mountain-UI-Companion
//
//  Created by Matthew Ernst on 1/22/23.
//

import Foundation
import UIKit

struct Support{
    var setting: Setting
    var link: String
}

let supportOptions: [Support] = [
    .init(setting: .init(name: "Follow me on GitHub", iconName: "githubIcon", isSystemIcon: false, backgroundColor: .black), link: Constants.github),
    .init(setting: .init(name: "Follow me on Twitter", iconName: "twitterIcon", isSystemIcon: false, backgroundColor: .systemBlue), link: Constants.twitter),
    .init(setting: .init(name: "Buy me coffee", iconName: "buyMeCoffeeIcon", isSystemIcon: false, backgroundColor: UIColor(red: 274 / 255, green: 222 / 255, blue: 74 / 255, alpha: 1)), link: Constants.buyMeCoffee)
]
