//
//  WidgetsBundle.swift
//  Widgets
//
//  Created by Aether on 05/08/2023.
//

import WidgetKit
import SwiftUI

@main
struct WidgetsBundle: WidgetBundle {
    var body: some Widget {
        PlannerWidget()
        #if !os(watchOS)
        TaskWidget()
        DayOverViewWidget()
        #else
        complications()
#endif
#if !os(macOS) && !os(watchOS)
        TaskCountWidget()
#endif
    }
}
