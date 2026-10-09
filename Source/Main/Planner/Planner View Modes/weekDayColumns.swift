//
//  weekDayColumns.swift
//  KyoNeo
//
//  Created by Aether on 18/08/2023.
//

import SwiftUI

struct weekDayColumns: View {
    @ObservedObject var day: Day
    var body: some View {
        var factor = (175.7142857143)
        VStack(){
            HStack{
                Text(day.name ?? "no name") // Assuming Day has a "name" property
                    .font(.caption)
                    .textCase(/*@START_MENU_TOKEN@*/.uppercase/*@END_MENU_TOKEN@*/)
                Spacer()
                Divider()
            }
            .frame(maxWidth: .infinity)
            .frame(height: 9)
            .padding(.bottom, 3)
            HStack{
            VStack{
                if let timeSlotsArray = (Array(day.timeSlots ?? []) as? [TimeSlot])?.sorted(by: { $0.timestamp ?? Date() < $1.timestamp ?? Date() }) {
                    ForEach(timeSlotsArray, id: \.self) { timeSlot in
                        PlannerStamp(timeSlot: timeSlot)
                            .transition(.identity)
                    }

                    if timeSlotsArray.isEmpty{
                        Text("No Entries")
                            .padding()
                            .regularOutline()
                            .padding()
                            .frame(maxWidth: .infinity)
                    }

                }
                Spacer()
            }

                Divider()}
        }
    }
}
