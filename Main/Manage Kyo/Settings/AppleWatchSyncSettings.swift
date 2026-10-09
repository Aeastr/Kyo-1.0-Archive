//
//  AppleWatchSyncSettings.swift
//  KyoNeo
//
//  Created by Aether on 03/11/2023.
//

import SwiftUI

struct AppleWatchSyncSettings: View {
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)]) var classes: FetchedResults<ClassEntity>
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)]) var spliters: FetchedResults<SplitterEntity>
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)]) var weeks: FetchedResults<Week>
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)]) var days: FetchedResults<Day>
    @FetchRequest(sortDescriptors: []) var timeSlots: FetchedResults<TimeSlot>
    var body: some View {
        VStack{
#if os(iOS)
                Button {
                    for item in classes{
//                        SharedDataManager.shared.sendClassDataToWatch(entity: item)
                    }
                } label: {
                    Text("send classes")
                }

                Button {
                    for item in spliters{
//                        SharedDataManager.shared.sendSplitDataToWatch(entity: item)
                    }
                } label: {
                    Text("send splitters")
                }

            Button {
                for item in weeks{
//                    SharedDataManager.shared.sendWeekDataToWatch(entity: item)
                }
            } label: {
                Text("send weeks")
            }

            Button {
                for item in days{
//                    SharedDataManager.shared.sendDayDataToWatch(entity: item)
                }
            } label: {
                Text("send days")
            }

            Button {
                for item in timeSlots{
//                    SharedDataManager.shared.sendTimeSlotDataToWatch(entity: item)
                }
            } label: {
                Text("send timeslots")
            }
            #endif
        }
    }
}

#Preview {
    AppleWatchSyncSettings()
}
