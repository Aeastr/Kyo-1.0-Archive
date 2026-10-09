//
//  PlannerWeekView.swift
//  KyoNeo
//
//  Created by Aether on 22/12/2023.
//

import SwiftUI
import AmethystUI

struct PlannerWeekView: View {
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
        ZStack{


            if let sWID = schedule_SelectedWeekID{
                if weeks.contains(where: { $0.id?.uuidString == sWID }) {
                    let schedule_SelectedWeeks = weeks.filter{ week in
                        return week.id?.uuidString == sWID
                    }.prefix(1)
                    if schedule_SelectedWeeks.count != 0{
                        let week = schedule_SelectedWeeks[0]
                        if let daysArray = (Array(week.days ?? []) as? [Day])?.sorted(by: { $0.number < $1.number }) {
                            let currentDayIndex = Calendar.current.component(.weekday, from: Date()) - 1
                            var factor = (155.7142857143)
#if os(iOS)
                            GeometryReader{ proxy in
                                ScrollView{
#if os(iOS)
                                    ScrollDetector(scrolled: $scrolled)
#endif

                                    var columns: [GridItem] {

                                        if Double(proxy.size.width) < (Double(factor) * Double(daysArray.count)){
                                            var columnWidths: [GridItem] = Array(repeating: .init(.fixed(150)), count: daysArray.count)
                                            //                                                if !(currentDayIndex > daysArray.count - 1){
                                            //                                                    columnWidths[currentDayIndex] = .init(.fixed(70))
                                            //                                                }// Adjust the width as needed
                                            return columnWidths
                                        }
                                        else{
                                            var columnWidths: [GridItem] = Array(repeating: .init(.flexible()), count: daysArray.count)
                                            //                                                if !(currentDayIndex > daysArray.count - 1){
                                            //                                                    columnWidths[currentDayIndex] = .init(.fixed(70))
                                            //                                                }// Adjust the width as needed
                                            return columnWidths
                                        }

                                    }
                                    ZStack{
                                        ScrollView(.horizontal, showsIndicators: false) {
                                            LazyVGrid(columns: columns, spacing: 10) {
                                                ForEach(daysArray, id: \.self) { day in
                                                    weekDayColumns(day: day)
                                                }
                                            }

                                            .padding(.horizontal, 20)
                                            .padding(.top, 3)
                                            .frame(minWidth: Double(proxy.size.width) < (Double(factor) * Double(daysArray.count)) ? 0 : proxy.size.width)

                                        }


                                    }
                                }
                            }
#else
                            GeometryReader{ proxy in
                                ScrollView(.vertical, showsIndicators: true){
                                    var columns: [GridItem] {
                                        if Double(proxy.size.width) < (Double(factor) * Double(daysArray.count)){
                                            var columnWidths: [GridItem] = Array(repeating: .init(.fixed(150)), count: daysArray.count)
                                            //                                                if !(currentDayIndex > daysArray.count - 1){
                                            //                                                    columnWidths[currentDayIndex] = .init(.fixed(70))
                                            //                                                }// Adjust the width as needed
                                            return columnWidths
                                        }
                                        else{
                                            var columnWidths: [GridItem] = Array(repeating: .init(.flexible()), count: daysArray.count)
                                            //                                                if !(currentDayIndex > daysArray.count - 1){
                                            //                                                    columnWidths[currentDayIndex] = .init(.fixed(70))
                                            //                                                }// Adjust the width as needed
                                            return columnWidths
                                        }

                                    }
                                    if Double(proxy.size.width) < (Double(factor) * Double(daysArray.count)){
                                        ScrollView(.horizontal, showsIndicators: true) {
                                            LazyVGrid(columns: columns, spacing: 10) {
                                                ForEach(daysArray, id: \.self) { day in
                                                    weekDayColumns(day: day)
                                                }
                                            }

                                            .padding(.horizontal)
                                            .padding(.top, 3)
                                        }
                                        .animation(.smooth, value: columns.description.hash)
                                    }
                                    else{

                                        LazyVGrid(columns: columns, spacing: 10) {
                                            ForEach(daysArray, id: \.self) { day in
                                                weekDayColumns(day: day)
                                            }
                                        }
                                        .animation(.smooth, value: columns.description.hash)

                                        .padding(.horizontal)
                                        .padding(.top, 3)
                                        .animation(.smooth, value: columns.description.hash)
                                    }





                                }
                            }
#endif

                        }

                    }

                }
            }


        }
        //                        .offset(x: 10)

        .frame(maxWidth: .infinity)
#if os(iOS)
        .safeAreaInset(edge: .top) {
            Color.clear.frame(height: horizontalSizeClass == .compact ? 80 : 40)
        }
        .coordinateSpace(name: "scroll")
#endif
    }
}

#Preview {
    PlannerWeekView(color: Color.accentColor, scrolled: .constant(false))
}
