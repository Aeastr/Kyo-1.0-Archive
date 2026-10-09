//
//  startErrors.swift
//  KyoWatch Watch App
//
//  Created by Aether on 04/11/2023.
//

import SwiftUI

enum startErrors: LocalizedError{
//    case none
    case parentlessTimeSlots

    var errorDescription: String? {
            switch self {
            case .parentlessTimeSlots:
                return "Failed to get current day"
            }
        }

        var failureReason: String? {
            switch self {
            case .parentlessTimeSlots:
                return "There was a small hiccup with some entries."
            }
        }

        var recoverySuggestion: String? {
            switch self {
            case .parentlessTimeSlots:
                return "Tap Fix"
            }
        }

    var fixAction: () -> Void {
        switch self {
        case .parentlessTimeSlots:
            {
                let timeSlotFix = timeSlotChecks()
                timeSlotFix.deleteParentlessTimeSlots()
            }
        }
    }
}
