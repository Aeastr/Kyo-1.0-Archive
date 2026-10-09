//
//  ScrollablePlannerDay.swift
//  KyoNeo
//
//  Created by Aether on 08/08/2023.
//

import SwiftUI
import CoreData
import AmethystUI


struct ScrollablePlannerDay: View {
    @ObservedObject var day: Day

    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "timestamp", ascending: true)]) var timeSlots: FetchedResults<TimeSlot>
    
    @AppStorage("countdownOnlyCurrent") var countdownOnlyCurrent = true
    @State var shownTimeSlot: TimeSlot?
    @State var viewTimeSlot: TimeSlot?
    @State var shareTimeSlot: TimeSlot?
    @State var classForTask: ClassEntity?
    @Binding var editMode: Bool
    @Binding var scrolled: Bool
    var color: Color = .red
    @AppStorage("global_Compact") var global_Compact  = false


    @AppStorage("planner_TimelineBubbles") var planner_TimelineBubbles:  Bool = true
   @AppStorage("planner_Style") var planner_Style:  typeEntryViewMode = .blocks
    var body: some View {
        ScrollView{

                ScrollDetector(scrolled: $scrolled)
            VStack(spacing: planner_Style == .threads ? planner_TimelineBubbles ? 0 : 25 :global_Compact ? 0 : 10){

            if let timeSlotsArray = (Array(day.timeSlots ?? []) as? [TimeSlot])?.sorted(by: { $0.timestamp ?? Date() < $1.timestamp ?? Date() }) {
                ForEach(Array(timeSlotsArray.enumerated()), id:\.element) { index, timeSlot in
                    if planner_Style == .threads{
                        let prevSlot = (index != 0) ? timeSlotsArray[index - 1] : timeSlot
                        let nextSlot = (index != (timeSlotsArray.endIndex - 1)) ? timeSlotsArray[index + 1] : timeSlot
                        EntryThread(timeSlot: timeSlot,timeSlotPrev: prevSlot, timeSlotNext: nextSlot, index: index, widthBubble: editMode ? 60 : 70, shownTimeSlot: $shownTimeSlot, viewTimeSlot: $viewTimeSlot, classForTask: $classForTask, editMode: $editMode)
                            .transition(.blurWithoutScale.animation(.smooth))
                    }
                    else if planner_Style == .blocks{
                        EntryBlock(timeSlot: timeSlot, context: viewContext, shownTimeSlot: $shownTimeSlot, viewTimeSlot: $viewTimeSlot, classForTask: $classForTask, shareTimeSlot: $shareTimeSlot, editMode: $editMode)
                            .transition(.blurWithoutScale.animation(.smooth))
                    }
                }
                .sheet(item: $shownTimeSlot) { item in
                    TimeSlotWorkshop(entity: item)
                        .interactiveDismissDisabled()
                        .presentationCornerRadius(25)
                }
                
                if timeSlotsArray.isEmpty{
                    VStack{
                        if timeSlots.isEmpty{
                            Text("No entries, add an entry with ")
                                .font(.caption)
                            +
                            Text(Image(systemName: "plus"))
                                .foregroundColor(color)
                                .font(.footnote)
                                .bold()
                            
                            +
                            Text(" to get started")
                                .font(.caption)
                        }
                        else{
                            Text("No entries")
                                .font(.caption)
                            
                        }
                    }
                    
                    .frame(height: 18)
                    .frame(maxWidth: .infinity)
                    .neoSettingsCard()
                    .padding(.horizontal, 28)
                    .padding(.vertical, 2)
                }
            }
            
        }
        .padding(.top, 1)

            Color.clear
                .frame(height: 80)

    }
        .coordinateSpace(name: "scroll")

#if os(iOS) || os(visionOS)
        .safeAreaInset(edge: .top) {
        Color.clear
            .frame(height: 100)
    }
    .safeAreaInset(edge: .bottom) {
        Color.clear
            .frame(height: 40)
    }
        #endif
//        .sheet(item: $viewTimeSlot) { item in
//            EntryDetail(timeSlot: item, currentState: countdownOnlyCurrent ? item.day?.name == TimeFormatter.getDayCode(date: Date()) ? TimeHelper.getTimeState(startTime: item.startTime ?? "00:00", endTime: item.endTime ?? "00:01") : .upcoming : TimeHelper.getTimeState(startTime: item.startTime ?? "00:00", endTime: item.endTime ?? "00:01"))
//                .presentationDetents([.fraction(0.64), .large])
//                .presentationDragIndicator(.hidden)
//        }
//    .navigationDestination(item: $viewTimeSlot) { item in
//        EntryDetailSuper(timeSlot: item, currentState: countdownOnlyCurrent ? item.day?.name == TimeFormatter.getDayCode(date: Date()) ? TimeHelper.getTimeState(startTime: item.startTime ?? "00:00", endTime: item.endTime ?? "00:01") : .upcoming : TimeHelper.getTimeState(startTime: item.startTime ?? "00:00", endTime: item.endTime ?? "00:01"))
//            .presentationDetents([.fraction(0.64), .large])
//            .presentationDragIndicator(.hidden)
//    }

        .sheet(item: $classForTask) { item in
            TaskWorkshop(selectedClass: classForTask)
                .interactiveDismissDisabled()
                .presentationCornerRadius(25)
        }

        .sheet(item: $shareTimeSlot) { item in
            PlannerShareView(timeSlot: item)
                .presentationCornerRadius(25)

        }
    }
}


