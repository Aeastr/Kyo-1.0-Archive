//
//  PlannerSingleDay.swift
//  KyoNeo
//
//  Created by Aether on 22/12/2023.
//

import SwiftUI

struct PlannerSingleDay: View {
    var body: some View {
        TabView(selection: $selectedDay) {

            if let sWID = schedule_SelectedWeekID{
                if weeks.contains(where: { $0.id?.uuidString == sWID }) {
                    let schedule_SelectedWeeks = weeks.filter{ week in
                        return week.singleDayWeek == true
                    }.prefix(1)
                    if schedule_SelectedWeeks.count != 0{
                        let week = schedule_SelectedWeeks[0]

                        if let daysArray = (Array(week.days ?? []) as? [Day])?.sorted(by: { $0.number < $1.number }) {
                            ForEach(daysArray, id: \.self) { day in
                                // Your content for each day here
                                ScrollablePlannerDay(day: day, editMode: $edit, scrolled: $scrolled)

                                    .tag(day.name ?? "Mon")
                                    .animation(.bouncy, value: global_Compact)

                            }
                        }

                    }

                }
            }
            else{
                Text("Select or Create a Week/Day")
                    .onAppear{

                        schedule_SelectedWeekID = weeks.first?.id?.uuidString

                    }
            }

        }
        .ignoresSafeArea(edges: [.top, .bottom])
#if os(iOS) || os(visionOS)
        .tabViewStyle(.page(indexDisplayMode: .never))
#endif
    }
}

#Preview {
    PlannerSingleDay()
}
