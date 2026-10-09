//
//  DefaultSplitterModel.swift
//  KyoNeo
//
//  Created by Aether on 30/08/2023.
//

import SwiftUI

struct DefaultSplitter: Identifiable, Hashable {
    var id = UUID()
    var text: String
    var type: SplitterType
}

let defaultSplitters: [DefaultSplitter] = [
    DefaultSplitter(text: "Break", type: .divider),
    DefaultSplitter(text: "Lunch", type: .divider),
    DefaultSplitter(text: "Free Slot", type: .free)
]
