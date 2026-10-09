//
//  DayItemModel.swift
//  KyoNeo
//
//  Created by Aether on 30/08/2023.
//

import SwiftUI

// Define a dayItemModel struct that conforms to the Identifiable protocol.
struct dayItemModel: Identifiable {
    // A unique identifier for each day item.
    var id = UUID()
    // The name of the day.
    var name: String
    // Indicates whether the day is active or not.
    var active: Bool = true
    // The number associated with the day.
    var number: Int = 0
}
