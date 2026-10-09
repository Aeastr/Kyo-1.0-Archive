//
//  Move TimeSlots.swift
//  KyoNeo
//
//  Created by Aether on 21/03/2023.
//

import SwiftUI

struct PlannerEditBar_MoveMenu: View {
    @EnvironmentObject var sharedObject: plannerEditObject

    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "timestamp", ascending: true)]) var timeSlots: FetchedResults<TimeSlot>
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "number", ascending: true)]) var days: FetchedResults<Day>

    @AppStorage("schedule_SelectedDayID") var schedule_SelectedDayID: String?
    @AppStorage("schedule_SelectedWeekID") var schedule_SelectedWeekID: String?


    var body: some View {
        ForEach(days, id: \.self) { day in


            Button {

                withAnimation(.smoothCard){
                    schedule_SelectedDayID = day.id?.uuidString
                    schedule_SelectedWeekID = day.week?.id?.uuidString
                }

                withAnimation(.smoothCard){
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {



                        for slot in timeSlots {
                            if sharedObject.selectedItemsArray.contains(where: { slotID in
                                slotID == slot.id
                            }){

                                let oldDay = slot.day
                                slot.day = day
                                oldDay?.removeFromTimeSlots(slot)
                                day.addToTimeSlots(slot)

                            }
                        }

                        if let timeSlot = timeSlots.last(where: { slot in slot.id.map { sharedObject.selectedItemsArray.contains($0) } ?? false }) {
                                print("Setting scrollTo to", timeSlot.id ?? "nil")
                                DispatchQueue.main.async {
                                    sharedObject.scrollTo = timeSlot.id
                                }
                            }

                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                withAnimation(.smoothCard){
                                sharedObject.selectedItemsArray = []
                            }
                        }


                        do {
                            try viewContext.save()
                        } catch {
                            let nsError = error as NSError
                            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                        }
                        // Set the scrollTo state to the desired TimeSlot's ID

                    }
                }




            } label: {
                Text(day.name ?? "error")
            }


        }


    }

    init(filter: Int64){
        _days = FetchRequest<Day>(sortDescriptors: [NSSortDescriptor(key: "number", ascending: true)], predicate: NSPredicate(format: "week.number == %i", filter))
    }

}


