//
//  DetaultTaskModel.swift
//  KyoNeo
//
//  Created by Aether on 30/08/2023.
//

import SwiftUI

struct defaultTaskType: Identifiable, Hashable {
    var id = UUID()
    var text: String
    var icon: String
}


let defaultTaskTypes: [defaultTaskType] = [
    defaultTaskType(text: "Assignment", icon: "doc.richtext"),
    defaultTaskType(text: "Exam", icon: "globe.desk"),
    defaultTaskType(text: "Reminder", icon: "app.badge.fill"),
    defaultTaskType(text: "Other", icon: "square.dotted"),
]
