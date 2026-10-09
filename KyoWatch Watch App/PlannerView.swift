//
//  PlannerView.swift
//  KyoWatch Watch App
//
//  Created by Aether on 25/01/2023.
//

import SwiftUI

struct PlannerView: View {
    //core data
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "timestamp", ascending: true)]) var timeSlots: FetchedResults<TimeSlot>
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "number", ascending: true)]) var days: FetchedResults<Day>
    @FetchRequest(sortDescriptors: []) var weeks: FetchedResults<Week>
    
    var body: some View {
        List{
            Button {

            } label: {
                VStack(alignment: .leading){
                    Text("Viewing")
                        .font(.caption)
                        .opacity(0.6)
                    Text("Week 1, Mon")
                        .font(.caption)
                }
                .padding(1)
            }
            ForEach(timeSlots) { timeSlot in
                NavigationLink {
                    
                } label: {
                    Text(timeSlot.name ?? "Untitled")
                }



            }

        }.navigationTitle("Planner")


    }
}

struct PlannerView_Previews: PreviewProvider {
    static var previews: some View {
        PlannerView()
    }
}
