//
//  PlannerTimelineView.swift
//  KyoNeo
//
//  Created by Aether on 22/12/2023.
//

import SwiftUI
import AmethystUI

struct PlannerTimelineView: View {
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
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        ScrollViewReader{ proxy in
            ScrollView {
                ScrollDetector(scrolled: $scrolled)
                VStack(spacing:global_Compact ? 0 : 10){

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
                                        VStack(spacing:global_Compact ? 0 : 10){
                                            Text(day.name ?? "nan")
                                                .font(.caption)
                                                .opacity(0.6)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .padding(.horizontal, 20)
                                                .id(day.id?.uuidString ?? "nan")
                                                .tag(day.id?.uuidString ?? "nan")
                                                .padding(.bottom, 7)
                                                .zIndex(2)
                                            VStack(spacing:global_Compact ? 0 : 10){
                                                StaticPlannerDay(day: day, editMode: $edit, color: color, endMessage: false)
                                                    .zIndex(1)
                                                    .padding(.bottom, 25)

                                            }
                                            .animation(.smooth(duration: 0.45), value: edit)
                                            .animation(.smooth(duration: 0.45), value: planner_TimelineBubbles)

                                        }
                                        .padding(.top, 10)

#if !os(macOS)
                                        .animation(.smooth, value: planner_Style)
#endif


                                    }


                                }

                            }

                        }
                    }
                    else{
                        // Show an error message if schedule_SelectedWeekID is nil
                        Text("Select or Create a Week/Day")
                            .onAppear{

                                schedule_SelectedWeekID = weeks.first?.id?.uuidString

                            }
                    }
                }


                Color.clear
                    .frame(height: 55)
            }
            .coordinateSpace(name: "scroll")
#if os(iOS)
            .safeAreaInset(edge: .top) {
                Color.clear.frame(height: horizontalSizeClass == .compact ? 80 : 40)
            }
            .safeAreaInset(edge: .bottom) {
                Color.clear
                    .frame(height: 70)
            }
#endif

            .onAppear{
                proxy.scrollTo(schedule_SelectedDayID, anchor: UnitPoint(x: 0.1, y: 0.0))

            }
            .onChange(of: schedule_SelectedDayID){
                withAnimation(){
                    proxy.scrollTo(schedule_SelectedDayID, anchor: UnitPoint(x: 0.1, y: 0.0))
                }
            }



        }
    }
}

#Preview {
    PlannerTimelineView(color: Color.red, scrolled: .constant(false))
}
