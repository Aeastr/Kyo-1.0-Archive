//
//  OccuranceModel.swift
//  KyoNeo
//
//  Created by Aether on 30/04/2023.
//

import SwiftUI

struct OccuranceModel: Hashable {
    var id = UUID()
    var week: Week?
    var day: Day?
    var start: Date?
    var end: Date?
}
