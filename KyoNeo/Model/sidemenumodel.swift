//
//  sidemenumodel.swift
//  KyoNeo
//
//  Created by Aether on 08/01/2023.
//

import SwiftUI

//rather than creting individual lines of code for each sideMenuItem, I've used indentifiables, an array, and enums. This allows me to use forloops to run through code, as seen in lines 31-59 in sideMenu.swift
//i can easily add or remove items and make changes to their icon and text

struct sideMenuItem: Identifiable { // Creates a 'item' that can be referenced
    var id = UUID()
    var text: String = ""
    var icon: String = ""
    var state: sideMenuState
}

var sideMenuItems = [ //defines the different items to display in the sideMenu, allows me to easily add and remove items without changing major parts of code and keeps thing organised
    sideMenuItem(text: "Profile", icon: "person.crop.circle", state: .button),
    sideMenuItem(state: .div),
    sideMenuItem(text: "Events", icon: "person.crop.circle", state: .button),
    sideMenuItem(state: .div),
    sideMenuItem(text: "Reports", icon: "person.crop.circle", state: .button),
    sideMenuItem(state: .spacer),
    sideMenuItem(text: "Calendar", icon: "person.crop.circle", state: .button),
    sideMenuItem(state: .div),
    sideMenuItem(text: "Map", icon: "person.crop.circle", state: .button),
    sideMenuItem(state: .div),
    sideMenuItem(text: "Messages", icon: "person.crop.circle", state: .button),
    sideMenuItem(state: .spacer),
    sideMenuItem(state: .spacer),
    sideMenuItem(text: "Settings", icon: "person.crop.circle", state: .button),
]
enum sideMenuState: String { //used to define the type of a sideMenuItem, useful for when a variable can onky take one out of a small set of possible values
    case unset
    case button
    case div
    case spacer
} //using an enum makes code much cleaner, rather than using strings to identify these different states/types; which could get messy, an enum is called by uisng .[case]
