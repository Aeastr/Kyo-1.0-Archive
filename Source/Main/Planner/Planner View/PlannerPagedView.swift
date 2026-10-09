//
//  PlannerPagedView.swift
//  KyoNeo
//
//  Created by Aether on 22/12/2023.
//

import SwiftUI
import AmethystUI

struct PlannerPagedView: View {
    var color: Color

    // Amethyst
    @Binding var scrolled: Bool

    // Scheduling
    @AppStorage("schedule_SelectedWeekID") var schedule_SelectedWeekID: String?
    @AppStorage("schedule_SelectedDayID") var schedule_SelectedDayID: String?

    // Status/Style
    @AppStorage("planner_Suggestions") var planner_Suggestions: Bool = true
    @AppStorage("planner_TimelineBubbles") var planner_TimelineBubbles:  Bool = true
    @AppStorage("planner_Style") var planner_Style:  typeEntryViewMode = .blocks
    @AppStorage("global_Compact") var global_Compact  = false
    @State private var edit: Bool = false

    // Data
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "number", ascending: false)]) var weeks: FetchedResults<Week>
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "number", ascending: false)]) var days: FetchedResults<Week>
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @State var showPlannerSetup: Bool = false

    var body: some View {
        #if !os(macOS)
        TabView(selection: $schedule_SelectedDayID) {

            if let sWID = schedule_SelectedWeekID{
                if weeks.contains(where: { $0.id?.uuidString == sWID }) {
                    let schedule_SelectedWeeks = weeks.filter{ week in
                        return week.id?.uuidString == sWID
                    }.prefix(1)
                    if schedule_SelectedWeeks.count != 0{
                        let week = schedule_SelectedWeeks[0]

                        if let daysArray = (Array(week.days ?? []) as? [Day])?.sorted(by: { $0.number < $1.number }) {
                            ForEach(daysArray, id: \.self) { day in
                                // Your content for each day here
                                //                                                ScrollablePlannerDay(day: day, editMode: $edit, scrolled: $scrolled, color: color)
                                ScrollView{
                                    ScrollDetector(scrolled: $scrolled)
                                    StaticPlannerDay(day: day, editMode: $edit, color: color)

                                }
                                .coordinateSpace(name: "scroll")

                                .tag(day.id?.uuidString)
                                .tabItem({
                                    if let name = day.name{
                                        Text(name)
                                    }
                                })
                                .animation(.bouncy, value: global_Compact)
                                .background{
                                    cherryEmptyDayView(day: day)
                                }
#if os(iOS)
                                .safeAreaInset(edge: .top) {
                                    Color.clear.frame(height: horizontalSizeClass == .compact ? 95 : 50)
                                }
                                .safeAreaInset(edge: .bottom) {
                                    Color.clear
                                        .frame(height: 40)
                                }
#endif
                            }
                        }

                    }

                }
                else{
                    if !weeks.isEmpty{
                        Text("Select a Day to view")
                            .onAppear{

                                schedule_SelectedWeekID = weeks.first?.id?.uuidString

                            }
                    }
                    else{
                        VStack(alignment: .leading){
                                                                    Text("Planner hasn't been set up, no weeks/days found")
                                                                    Button {
                                                                        showPlannerSetup.toggle()
                                                                    } label: {
                                                                        Text("Set Up")
                                                                    }
                                                                    .buttonStyle(PolishedButton(color: color, background: true))
                                                                }
                                                                .frame(maxWidth: 300, alignment: .center)

                    }
                }
            }
            else{
                // Show an error message if schedule_SelectedWeekID is nil
                if !weeks.isEmpty{
                                        Text("Select a Day to view")
                                            .onAppear{

                                                schedule_SelectedWeekID = weeks.first?.id?.uuidString

                                            }
                                    }
                                    else{
                                        VStack(alignment: .leading){
                                            Text("Planner hasn't been set up, no weeks/days found")
                                            Button {
                                                showPlannerSetup.toggle()
                                            } label: {
                                                Text("Set Up")
                                            }
                                            .buttonStyle(PolishedButton(color: color, background: true))
                                        }
                                        .frame(maxWidth: 300, alignment: .center)

                                    }
            }

        }
        .tabViewStyle(.page)
        .sheet(isPresented: $showPlannerSetup) {
            NavigationStack{
                WeekSlider()
                                .interactiveDismissDisabled()

            }
            .presentationCornerRadius(25)
        }
        #else
        Group{
            if let sWID = schedule_SelectedWeekID{
                if weeks.contains(where: { $0.id?.uuidString == sWID }) {

                    if let schedule_SelectedWeek = weeks.first(where: { week in
                        return week.id?.uuidString == sWID
                    }), let daysArray = (Array(schedule_SelectedWeek.days ?? []) as? [Day])?.sorted(by: { $0.number < $1.number }), let showDay = daysArray.first(where: { day in
                        return day.id?.uuidString == schedule_SelectedDayID
                    }) {
                        ScrollView{
                            ScrollDetector(scrolled: $scrolled)

                            StaticPlannerDay(day: showDay, editMode: $edit, color: color)
                                .padding(.top, 10)
                        }
                        .coordinateSpace(name: "scroll")
                    }
                }
            }
        }

        #endif
    }
}

#Preview {
    PlannerPagedView(color: Color.accentColor, scrolled: .constant(false))
}
