//
//  TaskSortingOptions.swift
//  KyoNeo
//
//  Created by Aether on 05/04/2024.
//

import SwiftUI

enum TaskSortingOption: String, CaseIterable {
    case due = "Due Date"
    case `class` = "Classes"

    var symbol: String {
        switch self {
        case .due:
            return "calendar.badge.clock"
        case .class:
            return "book.closed"
        }
    }

    var number: Int {
        switch self {
        case .due:
            return 0
        case .class:
            return 1
//        case .all:
//            return 4
        }
    }
}


enum SortingOptionPolarity: String, CaseIterable {
    case ascending
    case descending

    var symbol: String {
        switch self {
        case .ascending:
            return "arrow.up.to.line.alt"
        case .descending:
            return "arrow.down.to.line.alt"
        }
    }

    var number: Int {
        switch self {
        case .ascending:
            return 0
        case .descending:
            return 1
//        case .all:
//            return 4
        }
    }
}
