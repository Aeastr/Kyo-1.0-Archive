//
//  TabBar.swift
//  KyoNeo
//
//  Created by Aether on 20/11/2022.
//

import SwiftUI
#if os(iOS) || os(visionOS)
#if canImport(RiveRuntime)
import RiveRuntime
#endif


struct PlannerEditBar: View {
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "timestamp", ascending: true)]) var timeSlots: FetchedResults<TimeSlot>

    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "number", ascending: true)],
                  predicate: NSPredicate(format: "singleDayWeek == nil OR singleDayWeek == %@", NSNumber(value: false))
    ) var weeks: FetchedResults<Week>


    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "number", ascending: true),
                                    // Add more sort descriptors if needed
                                   ],
                  predicate: NSPredicate(format: "singleDayWeek == %@", NSNumber(value: true))
    ) var singleDayweeks: FetchedResults<Week>

    @Environment(\.managedObjectContext) private var viewContext

    @State var color: Color = Color("2")

    @State var currentSelectedDay: Day = Day()
    @State var currentschedule_SelectedWeek: Week = Week()
    @State var weekHasBeenSelected: Bool = false

    @EnvironmentObject var sharedObject: plannerEditObject

    @Environment(\.accessibilityReduceMotion) var reduceMotion

    @AppStorage("Contrast") var contrast = false

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        GeometryReader { proxy in

            let hasHomeIndicator = proxy.safeAreaInsets.bottom > 0

            HStack {



                Menu {
                    Section("Are you sure?"){

                        Button {

                        } label: {
                            Text("Cancel")
                        }

                    Button(role: .destructive) {
                        print(sharedObject.selectedItemsArray)
                        for slot in timeSlots {
                            if sharedObject.selectedItemsArray.contains(where: { slotID in
                                slotID == slot.id
                            }){
                                withAnimation(.smoothCard){
                                    viewContext.delete(slot)
                                }
                            }
                        }

                        sharedObject.selectedItemsArray = []

                    } label: {
                        if sharedObject.selectedItemsArray.count == 1 {
                            Label("Delete", systemImage: "trash").minimumScaleFactor(0.5)
                        }
                        if sharedObject.selectedItemsArray.count > 1{
                                Label("Delete \(sharedObject.selectedItemsArray.count) items", systemImage: "trash").minimumScaleFactor(0.5)
                        }
                    }



                }
                } label: {
                    Label("Delete", systemImage: "trash").minimumScaleFactor(0.5)
                        .ignoresSafeArea()

                }
                .menuStyle(neoMenu(role: .destructive))

                .disabled(sharedObject.selectedItemsArray.count == 0 ? true: false)
                .opacity(sharedObject.selectedItemsArray.count == 0 ? 0.5 : 1)
                .animation(.smoothCard, value: sharedObject.selectedItemsArray.count)


                Menu {

                    ForEach(weeks, id: \.self){ week in

                        Menu {
                            PlannerEditBar_MoveMenu(filter: week.number)

                        } label: {
                            Text("Week \(week.number)")

                        }



                    }
                    Divider()
                    Button {
                       // showWeekCreate.toggle()
                    } label: {
                        Text("New Week")
                        Image(systemName: "plus")
                    }
                } label: {

                    Label("Move", systemImage: "arrow.forward.square").minimumScaleFactor(0.5)
                        .ignoresSafeArea()
                }
                .menuStyle(neoMenu())
                .disabled(sharedObject.selectedItemsArray.count == 0 ? true: false)
                .opacity(sharedObject.selectedItemsArray.count == 0 ? 0.5 : 1)
                .animation(.smoothCard, value: sharedObject.selectedItemsArray.count)
                    
                    Button() {
                        
                        for slot in timeSlots {
                            if sharedObject.selectedItemsArray.contains(where: { slotID in
                                slotID == slot.id
                            }){
                                if let index = sharedObject.selectedItemsArray.firstIndex(where: { $0 == slot.id }) {
                                    sharedObject.selectedItemsArray.remove(at: index)
                                }

                                withAnimation(.smoothCard){
                                    duplicateTimesSlot(data: slot)
                                }
                            }
                        }

                    } label: {
                        Label("Duplicate", systemImage: "square.on.square")
                            .minimumScaleFactor(0.5)
                    }
                    .buttonStyle(neoButton(role: .regularAction))

                .disabled(sharedObject.selectedItemsArray.count == 0 ? true: false)
                .opacity(sharedObject.selectedItemsArray.count == 0 ? 0.5 : 1)
                .animation(.smoothCard, value: sharedObject.selectedItemsArray.count)


         }
            .animation(.linear, value: contrast)
            .padding(.bottom, hasHomeIndicator ? 25 : 13)
                        .padding(.horizontal, 2)
                        .padding(.top, hasHomeIndicator ? 6 : 10)
                        .frame(maxWidth: .infinity, maxHeight: hasHomeIndicator ? 88 : 69)
                        .background(.thinMaterial)
                        .cornerRadius(34, corners: [.topLeft, .topRight])


                                    .overlay(
                                        RoundedCorner(radius: 34, corners: [.topLeft, .topRight])
                                            .stroke(
                                                colorScheme == .dark ? .white.opacity(0.5)
                            : .black.opacity(0.1)
                                            )
                                            .blendMode(colorScheme == .dark ? .overlay : .normal)

                                    )
                                    .frame(maxHeight: .infinity, alignment: .bottom)
                                    .ignoresSafeArea()
                                 //   .accessibilityElement(children: .combine)
    //    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedTab )
        }

    }



    func duplicateTimesSlot(data: TimeSlot){
        withAnimation {
            let item = TimeSlot(context: viewContext)
            item.id = UUID()

            item.day = data.day
            item.classEntity = data.classEntity
            item.room = data.room
            item.startTime = data.endTime
            item.endTime = TimeFormatter.getTimeString(TimeFormatter.toDate(data.endTime ?? "00:00")?.addingTimeInterval(3600) ?? Date())
            item.color1 = data.color1
            item.color2 = data.color2
            item.timestamp = TimeFormatter.toDate(data.endTime ?? "00:00", mode: .time)
            print("timestamped \(item.timestamp)")

            data.classEntity?.addToTimeSlot(item)
            data.day?.addToTimeSlots(item)

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }

            sharedObject.selectedItemsArray.append(item.id!)

        }
    }
}
#endif


