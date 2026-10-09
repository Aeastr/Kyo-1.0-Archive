//
//  StaticPlannerDay.swift
//  KyoNeo
//
//  Created by Aether on 02/08/2023.
//

import SwiftUI
import CoreData
struct cherryEmptyDayView: View{
    @ObservedObject var day: Day

    var body: some View{
        if let x = (Array(day.timeSlots ?? []) as? [TimeSlot]){
            if x.isEmpty{
                CherryCatView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity,  alignment: .bottomTrailing)
                    .padding([.bottom], 20)
                    .opacity(0.25)
            }
        }
    }
}
struct StaticPlannerDay: View {
    @ObservedObject var day: Day

    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.colorScheme) private var colorScheme

    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "timestamp", ascending: true)]) var timeSlots: FetchedResults<TimeSlot>
    
    @AppStorage("countdownOnlyCurrent") var countdownOnlyCurrent = true
    @State var shownTimeSlot: TimeSlot?
    @State var viewTimeSlot: TimeSlot?
    @State var shareTimeSlot: TimeSlot?
    @State var classForTask: ClassEntity?
    @State var showCreateEntry: Bool = false
    @Binding var editMode: Bool
    var color: Color = .red
    var endMessage: Bool = true
    @AppStorage("global_Compact") var global_Compact  = false
    @AppStorage("planner_TimelineBubbles") var planner_TimelineBubbles:  Bool = true
    @AppStorage("planner_Style") var planner_Style:  typeEntryViewMode = .blocks

    @AppStorage("planner_Suggestions") var planner_Suggestions: Bool = true
    var previewMode: Bool = false


    var body: some View {
        #if os(visionOS)
        let spacing: CGFloat = 16
        #else
        let spacing: CGFloat = 10
        #endif
        VStack(spacing: planner_Style == .threads ? planner_TimelineBubbles ? 0 : 25 : (global_Compact || previewMode) ? 0 : spacing){

            if let timeSlotsArray = (Array(day.timeSlots ?? []) as? [TimeSlot])?.sorted(by: { $0.timestamp ?? Date() < $1.timestamp ?? Date() }) {
                ForEach(Array(timeSlotsArray.enumerated()), id:\.element) { index, timeSlot in
                    if planner_Style == .threads && !previewMode{
                        let prevSlot = (index != 0) ? timeSlotsArray[index - 1] : timeSlot
                        let nextSlot = (index != (timeSlotsArray.endIndex - 1)) ? timeSlotsArray[index + 1] : timeSlot

                            EntryThread(timeSlot: timeSlot,timeSlotPrev: prevSlot, timeSlotNext: nextSlot, index: index, widthBubble: editMode ? 60 : 70, shownTimeSlot: $shownTimeSlot, viewTimeSlot: $viewTimeSlot, classForTask: $classForTask, editMode: $editMode)

                        if let currentTimeSlotEnd = timeSlot.endTime, let nextTimeSlotStart = nextSlot.startTime, planner_Suggestions{
                            if (ensureCorrectFormat(input: currentTimeSlotEnd) != ensureCorrectFormat(input: nextTimeSlotStart)) && (timeSlot != nextSlot){
                                HStack{
                                    let color1 = Color(hex: timeSlot.classEntity?.color1 ?? timeSlot.splitterEntity?.color1 ?? "a5bbc9")
                                    let color1Next = Color(hex: nextSlot.classEntity?.color1 ??  nextSlot.splitterEntity?.color1 ?? "a5bbc9")

                                    DottedLine()
                                        .stroke(style: StrokeStyle(lineWidth: 3.65, lineCap: .round, dash: [1]))
                                                    .frame(width: 1)
                                                    .foregroundStyle(LinearGradient(gradient: Gradient(colors: [color1, color1Next]), startPoint: .top, endPoint: .bottom))

                                    let number = differenceBetween((timeSlot.endTime ?? ""), (nextSlot.startTime ?? ""))
                                    let roundedNumber = decimalToFraction(number)

                                    Spacer()
                                    Group{
                                        Text(roundedNumber + "\(differenceBetween((timeSlot.endTime ?? ""), (nextSlot.startTime ?? "")) > 1 ? " hrs" : " hr") Free")
                                            .fontWeight(.semibold)
                                        +
                                        Text(" - Add entry")
                                            .foregroundStyle(Color.getAdjustedColor(color: color1, colorScheme: colorScheme))
                                            .fontWeight(.bold)

                                    }
                                    .textCase(.uppercase)
                                    .font(Font.footnote)
                                    .fixedSize(horizontal: true, vertical: false)
                                    .opacity(0.7)
                                    .transition(.blur)
                                    .onTapGesture {
                                        showCreateEntry.toggle()

                                    }


                                    Spacer()
                                }
                                .frame(height: TimeHelper.getTotalMinutes(for: currentTimeSlotEnd, for: nextTimeSlotStart))
                                
                                .padding(.horizontal, 60.1667)
                                .padding(.vertical, -5)
                            }
                        }


                    }
                    else if planner_Style == .blocks{
                        let nextSlot = (index != (timeSlotsArray.endIndex - 1)) ? timeSlotsArray[index + 1] : timeSlot

                        VStack(spacing: 0){

                            EntryBlock(timeSlot: timeSlot, context: viewContext, shownTimeSlot: $shownTimeSlot, viewTimeSlot: $viewTimeSlot, classForTask: $classForTask, shareTimeSlot: $shareTimeSlot, editMode: $editMode, previewMode: previewMode)
                                .scrollTransition() { content, phase in
                                    content
                                        .opacity(phase.isIdentity ? 1 : 0.7)
//                                        .scaleEffect( phase.isIdentity ? 1 : 0.97)
                                }
                                .allowsHitTesting(!editMode)

                            if editMode{
                                Image(systemName: "circle")
                                    .font(.system(size: 20))
                                    .padding(.leading, editMode ? 20 : 0 )
                            }
                        }
                        .padding(.horizontal, editMode ? 20 : 0 )
                        .padding(.trailing, editMode ? 10 : 0 )
                        .contentShape(Rectangle())
                        .onTapGesture{
                            if editMode{
                                print("Add")
                            }
                        }

                        .transition(.blur.animation(.smooth))
                        .animation(.smooth, value: timeSlots.count)

                        if let currentTimeSlotEnd = timeSlot.endTime, let nextTimeSlotStart = nextSlot.startTime, planner_Suggestions{
                            if (ensureCorrectFormat(input: currentTimeSlotEnd) != ensureCorrectFormat(input: nextTimeSlotStart)) && (timeSlot != nextSlot){
                                HStack{
                                    let color1 = Color(hex: timeSlot.classEntity?.color1 ?? timeSlot.splitterEntity?.color1 ?? "a5bbc9")
                                    let color1Next = Color(hex: nextSlot.classEntity?.color1 ??  nextSlot.splitterEntity?.color1 ?? "a5bbc9")

                                    DottedLine()
                                        .stroke(style: StrokeStyle(lineWidth: 3.65, lineCap: .round, dash: [1]))
                                                    .frame(width: 1)
                                                    .foregroundStyle(LinearGradient(gradient: Gradient(colors: [color1, color1Next]), startPoint: .top, endPoint: .bottom))

                                    let number = differenceBetween((timeSlot.endTime ?? ""), (nextSlot.startTime ?? ""))
                                    let roundedNumber = decimalToFraction(number)

                                    Spacer()
                                    Group{
                                        Text(roundedNumber + "\(differenceBetween((timeSlot.endTime ?? ""), (nextSlot.startTime ?? "")) > 1 ? " hrs" : " hr") Free")
                                            .fontWeight(.semibold)
                                        +
                                        Text(" - Add entry")
                                            .foregroundStyle(Color.getAdjustedColor(color: color1, colorScheme: colorScheme))
                                            .fontWeight(.bold)

                                    }
                                    .textCase(.uppercase)
                                    .font(Font.footnote)
                                    .fixedSize(horizontal: true, vertical: false)
                                    .opacity(0.7)
                                    .transition(.blur)
                                    .onTapGesture {
                                        showCreateEntry.toggle()

                                    }


                                    Spacer()
                                }
                                .frame(height: TimeHelper.getTotalMinutes(for: currentTimeSlotEnd, for: nextTimeSlotStart))

                                .padding(.horizontal, 60.1667)
                                .padding(.vertical, -5)

                                .animation(.smooth, value: timeSlots.count)
                            }
                        }

                    }
                }

                .animation(.smooth, value: timeSlots.count)
                .sheet(item: $shownTimeSlot) { item in
                    #if !os(macOS)
                    NavigationStack{
                        TimeSlotWorkshop(entity: item)
                            .interactiveDismissDisabled()
                            .presentationCornerRadius(25)
                    }
                    #else
                    NavigationStack{
                        TimeSlotWorkshop(entity: item)
                            .frame(idealWidth: 570, idealHeight:  640)
                    }
                        .id(UUID())
                        .presentationCornerRadius(25)
                    #endif
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


                if !timeSlotsArray.isEmpty && endMessage{
                    Text("That's all")
                        .italic()
                        .opacity(0.6)
                        .font(.caption)
                        .padding(.vertical, 14)
                        .padding(.bottom, 10)


                }
                else{
                }
            }
        }

        .animation(.smooth, value: timeSlots.count)
        .sheet(isPresented: $showCreateEntry, content: {
            TimeSlotWorkshop(color1: color)
        })
        .animation(.smooth, value: planner_Suggestions)
//        .navigationDestination(item: $viewTimeSlot) { unwrappedItem in
//            // Check if the necessary components can be safely unwrapped
//
//             if let startTime = unwrappedItem.startTime,
//               let endTime = unwrappedItem.endTime,
//               let dayName = unwrappedItem.day?.name {
//
//                // Calculate the TimeState
//                let isCurrentDay = dayName == TimeFormatter.getDayCode(date: Date())
//                let timeState = countdownOnlyCurrent && isCurrentDay ? TimeHelper.getTimeState(startTime: startTime, endTime: endTime) : .upcoming
//
//                // Present the EntryDetail view
//                EntryDetailSuper(timeSlot: unwrappedItem, currentState: timeState)
//                    .presentationDetents([.fraction(0.64), .large])
//                    .presentationDragIndicator(.hidden)
//                    .toolbar(.hidden)
//            } else {
//                // Alternative view for when unwrapping fails
//                Text("Time slot details are incomplete or not available")
//            }
//        }



        .sheet(item: $classForTask) { item in
            TaskWorkshop(selectedClass: item)
                .interactiveDismissDisabled()
                .presentationCornerRadius(25)
        }

        .sheet(item: $shareTimeSlot) { item in
            PlannerShareView(timeSlot: item)
                .presentationCornerRadius(25)

        }
    }
}


struct DottedLine: Shape {

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        return path
    }
}


