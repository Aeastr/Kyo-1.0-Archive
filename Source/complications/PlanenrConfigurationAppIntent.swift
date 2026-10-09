//
//  PlanenrConfigurationAppIntent.swift
//  KyoWatch Watch App
//
//  Created by Aether on 04/11/2023.
//

#if canImport(WidgetKit)
import WidgetKit
import AppIntents

struct PlannerWidgetIntents: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Planner Widgit"
    static var description = IntentDescription("This is an example widget.")

    // An example configurable parameter.
    @Parameter(title: "Show countdowns", default: true)
    var showCountdowns: Bool
    @Parameter(title: "Show Details", default: true)
    var showDetails: Bool
}


extension PlannerWidgetIntents {
    fileprivate static var def: PlannerWidgetIntents {
        let intent = PlannerWidgetIntents()
        intent.showCountdowns = true
        intent.showDetails = true
        return intent
    }
    fileprivate static var noCountDown: PlannerWidgetIntents {
        let intent = PlannerWidgetIntents()
        intent.showCountdowns = false
        intent.showDetails = true
        return intent
    }
}
#endif
