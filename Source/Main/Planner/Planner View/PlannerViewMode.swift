//
//  PlannerViewMode.swift
//  KyoNeo
//
//  Created by Aether on 22/12/2023.
//

import SwiftUI

enum plannerViewMode: String, CaseIterable{
    case pages =  "Paged"
    case timeline =  "Timeline"
    case week =  "Week"

    public var icon: String {
        switch self{
        case .week:
            return "rectangle.split.3x1"
        case .pages:
            return "rectangle.portrait.on.rectangle.portrait.angled"
        case .timeline:
            return "text.line.first.and.arrowtriangle.forward"
        }
    }

}
