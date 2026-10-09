// FIX: Use archive identifiers to keep this build and its data separate from the original app.
//
//  PlannerView.swift
//  KyoNeo
//
//  Created by Aether on 20/11/2022.
//

import SwiftUI
import CoreData
import Swift
import AmethystUI

struct PlannerView: View {
    // Core Data variables
    @Environment(\.managedObjectContext) private var viewContext

    // Scroll variables
    @State var scrolled: Bool = false

    // Color variable
    var color: Color = Color.accentColor

    // Schedule
    @AppStorage("schedule_SelectedWeekID") var schedule_SelectedWeekID: String?
    @AppStorage("schedule_SelectedDayID") var schedule_SelectedDayID: String?
    @AppStorage("schedule_SingleDayMode", store: UserDefaults(suiteName: "group.com.example.kyoarchive")) var schedule_SingleDayMode: Bool = false

    // View & Style
#if os(iOS)
    @AppStorage("planner_View") var planner_View: plannerViewMode = .pages
#else
    @AppStorage("planner_View") var planner_View: plannerViewMode = .week
#endif
    @AppStorage("planner_Style") var planner_Style: typeEntryViewMode = .blocks
    @AppStorage("planner_Suggestions") var planner_Suggestions: Bool = true
    @AppStorage("planner_TimelineBubbles") var planner_TimelineBubbles:  Bool = true
    @AppStorage("global_Compact") var global_Compact: Bool  = false
    @AppStorage("global_breakMode", store: UserDefaults(suiteName: "group.com.example.kyoarchive")) var global_breakMode: Bool = false
    @State var overrideBreakMode: Bool = false

    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "timestamp", ascending: true)]) var timeSlots: FetchedResults<TimeSlot>

    // Edit
    @State var edit: Bool = false
    @State var selectedTimeSlot: TimeSlot? = nil

    // Sheets
    @State private var showTimeSlotCreation: Bool = false
    @State var showSelectedTimeSlot: Bool = false
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass

    @AppStorage("planner_selectedTimeSlotDetailID") var planner_selectedTimeSlotDetailID: String?

#if !os(iOS)
    @AppStorage("planner_viewSettings_twoColumn") var planner_viewSettings_twoColumn : Bool = false
#else
    var planner_viewSettings_twoColumn : Bool = false
#endif

    // FIX: Archive access is unconditional; do not read or update a persisted purchase flag.

    private var kyoPlus_hasPlus: Bool { true }

    var body: some View {

        Group{
#if os(iOS)

            ZStack{
                if !global_breakMode || overrideBreakMode{
                    if !schedule_SingleDayMode{
                        if planner_View == .pages{
                            PlannerPagedView(color: color, scrolled: $scrolled)
                                .frame(minWidth: 350, maxWidth: .infinity)
                        }
                        else if planner_View == .week{

                            PlannerWeekView(color: color, scrolled: $scrolled)
                                .onAppear {

                                                                   // FIX: No purchase check or access-state write is needed; Kyo+ is permanently unlocked.

                                                               }
                        }
                        else if planner_View == .timeline {
                            PlannerTimelineView(color: color, scrolled: $scrolled)
                                .onAppear {

                                    // FIX: No purchase check or access-state write is needed; Kyo+ is permanently unlocked.

                                }
                        }
                    }
                    else{
                        PlannerPagedView(color: color, scrolled: $scrolled)
                            .frame(minWidth: 350, maxWidth: .infinity)
                        
                    }
                }
                else{
                    HolidayModeActive(overrideBreakMode: $overrideBreakMode, color: color)
                }
            }
            .amethystNavigationBar(title: /*orientationInfo.orientation == .portrait ?*/ "Planner" /*: ""*/, titleColor: .primary, tintColor: color, overrideType: .regular, scrolled: $scrolled, content: {
                navigationBarButtons
            }, toolbar: {
#if !os(visionOS)
                weekDaySelector(color: color , scrolled: $scrolled)
#endif
            })
            .toolbar(content: {

#if os(visionOS)
                ToolbarItem(placement: .bottomOrnament) {
                    weekDaySelector(color: color, scrolled: $scrolled)
                }
#elseif !os(iOS)
                ToolbarItem(placement: .navigation) {
                    weekDaySelector(color: color , scrolled: $scrolled)
                }
#endif


                #if !os(iOS)
                ToolbarItem(placement: .automatic) {

                    if planner_View != .week{
                        Picker(selection: $planner_Style, label: Label("Style", systemImage: kyoPlus_hasPlus ? "paintbrush" : "lock")) {
                            ForEach(typeEntryViewMode.allCases, id:\.self){ mode in
                                VStack{
                                    Label("\(mode.rawValue.capitalized)", systemImage: mode.icon)
                                }

                            }
                        }
                        .disabled(!kyoPlus_hasPlus)
                        .pickerStyle(.segmented)
                    }

                }

                ToolbarItem(placement: .automatic) {
                    HStack{
                        if planner_View != .week{
                            Divider()
                                .padding(.vertical, 3)
                        }
                        Picker(selection: $planner_View, label: Label("View", systemImage: "eyes")) {
                            ForEach(plannerViewMode.allCases, id:\.self){ mode in
                                VStack{

                                    Label("\(mode.rawValue.capitalized)", systemImage: mode.icon)

                                }
                                .tag(mode)
                            }
                        }
                        .pickerStyle(.segmented)
                        .disabled(!kyoPlus_hasPlus)
                    }

                }
                #endif
            })


#elseif os(visionOS) || os(macOS)
            HStack(spacing: 0){
                NavigationStack{
                    ZStack{
                        if !global_breakMode || overrideBreakMode{
                            if !schedule_SingleDayMode{
                                if planner_View == .pages{


                                    PlannerPagedView(color: color, scrolled: $scrolled)
                                        .frame(minWidth: 400, maxWidth: .infinity)




                                }
                                else if planner_View == .week{
                                    PlannerWeekView(color: color, scrolled: $scrolled)
                                        .onAppear {

                                                                           // FIX: No purchase check or access-state write is needed; Kyo+ is permanently unlocked.

                                                                       }
                                }
                                else if planner_View == .timeline {
                                    PlannerTimelineView(color: color, scrolled: $scrolled)
                                        .onAppear {

                                                                           // FIX: No purchase check or access-state write is needed; Kyo+ is permanently unlocked.

                                                                       }
                                }
                            }
                            else{
                                ScrollView{

                                }
                            }
                        }
                        else{
                            HolidayModeActive(overrideBreakMode: $overrideBreakMode, color: color)
                        }
                    }
                    .amethystNavigationBar(title: /*orientationInfo.orientation == .portrait ?*/ "Planner" /*: ""*/, titleColor: .primary, tintColor: color, overrideType: .regular, scrolled: $scrolled, content: {
                        navigationBarButtons
                    }, toolbar: {

                    })

                    .toolbar(content: {
#if os(visionOS)
                        ToolbarItem(placement: .bottomOrnament) {
                            weekDaySelector(color: color, scrolled: $scrolled)
                        }
                        #else

                        ToolbarItem(placement: .navigation) {
                            weekDaySelector(color: color, scrolled: $scrolled)
                        }
                        #endif




                        ToolbarItem(placement: .automatic) {

                            if planner_View != .week{
                                Picker(selection: $planner_Style, label: Label("Style", systemImage: kyoPlus_hasPlus ? "paintbrush" : "lock")) {
                                    ForEach(typeEntryViewMode.allCases, id:\.self){ mode in
                                        VStack{
                                            Label("\(mode.rawValue.capitalized)", systemImage: mode.icon)
                                        }

                                    }
                                }
                                .disabled(!kyoPlus_hasPlus)
                                .pickerStyle(.segmented)
                            }

                        }

                        ToolbarItem(placement: .automatic) {
                            HStack{
                                if planner_View != .week{
                                    Divider()
                                        .padding(.vertical, 3)
                                }
                                Picker(selection: $planner_View, label: Label("View", systemImage: "eyes")) {
                                    ForEach(plannerViewMode.allCases, id:\.self){ mode in
                                        VStack{

                                            Label("\(mode.rawValue.capitalized)", systemImage: mode.icon)

                                        }
                                        .tag(mode)
                                    }
                                }
                                .disabled(!kyoPlus_hasPlus)
                                .pickerStyle(.segmented)
                            }

                        }
                    })
                }
                //                .animation(.smooth(duration: 0.37), value: planner_selectedTimeSlotDetailID)
                if planner_viewSettings_twoColumn{
                    NavigationStack{
                        if let ID = planner_selectedTimeSlotDetailID{
                            if let timeSlot = timeSlots.first(where: { timeSlot in
                                return timeSlot.id?.uuidString == ID
                            }){

                                EntryDetailSuper(timeSlot: timeSlot)
//                                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
//                                    .padding(20)
//                                    .padding(.trailing, 2.5)
                                    .background(LinearGradient(colors: [Color(hex: timeSlot.classEntity?.color1 ?? timeSlot.splitterEntity?.color1 ?? ""),
                                                                        Color(hex: timeSlot.classEntity?.color2 ?? timeSlot.splitterEntity?.color2 ?? "")
                                                                       ], startPoint: .topLeading, endPoint: .bottomTrailing).opacity(0.22))
                                                                .background(Color.white.opacity(0.1))



                                                            .transition(.blur.animation(.smooth(duration: 0.37)))
                                                            .navigationTitle(((timeSlot.classEntity?.name ?? timeSlot.splitterEntity?.name ?? "Untitled Class").shortenedClassName(maxLength: 16)))

                            }
                        }
                        else{
                            Color.white.opacity(0.1)
                                .onAppear{
                                    let timeSlots = timeSlots.first { TimeSlot in
                                        return TimeSlot.day?.id?.uuidString == schedule_SelectedDayID && (TimeHelper.getTimeState(timeSlot: TimeSlot) == .upcoming || TimeHelper.getTimeState(timeSlot: TimeSlot) == .upcomingOnOtherDay)
                                    }
                                    planner_selectedTimeSlotDetailID = timeSlots?.id?.uuidString
                                }
                        }
                    }
                    .onChange(of: schedule_SelectedDayID, initial: true){
                        if let timeSlots = timeSlots.first(where: { TimeSlot in
                            return TimeSlot.day?.id?.uuidString == schedule_SelectedDayID && (TimeHelper.getTimeState(timeSlot: TimeSlot) == .upcoming || TimeHelper.getTimeState(timeSlot: TimeSlot) == .upcomingOnOtherDay)
                        }){
                            planner_selectedTimeSlotDetailID = timeSlots.id?.uuidString
                        }
                        else{
                            let timeSlots = timeSlots.last(where: { TimeSlot in
                                return TimeSlot.day?.id?.uuidString == schedule_SelectedDayID
                            })
                            planner_selectedTimeSlotDetailID = timeSlots?.id?.uuidString
                        }
                    }
                }



            }
#endif
        }







        .animation(.bouncy, value: planner_View)
        .sheet(isPresented: $showTimeSlotCreation) {
            NavigationStack{
                TimeSlotWorkshop(color1: color, color2: color)
                    .frame(idealWidth: 570, idealHeight:  640)
            }
                        .interactiveDismissDisabled()
            .presentationCornerRadius(25)
        }

    }

    var navigationBarButtons: some View {
        HStack(spacing: 10){
            // Check if edit is true
            if edit{
                // If edit is true, display a "Done" button
                Button {
                    // Toggle edit state and clear the selectedItemsArray when the button is pressed
                    withAnimation(.bouncy(duration: 0.45)){
                        edit.toggle()
                    }
                } label: {
                    Text("Done")
                        .scaledFrame(width: 60, height: 44, relativeTo: .body)
                }
                .buttonStyle(NavigationButton(color: color, scrolled: $scrolled))

                .modify {
                    if #available(iOS 17.0, *) {
                        $0.buttonStyle(NavigationButton(color: color, scrolled: $scrolled))

                    } else {
                        $0.menuStyle(NavigationMenu(color: color, scrolled: $scrolled))
                    }
                }

            }
            //            planner_View = plannerViewMode.pages

            if !edit{
#if os(macOS) || os(visionOS)

#else
                Menu{


                    //                    Toggle(isOn: $planner_Suggestions, label: {
                    //                        Label("Mark Gaps", systemImage: "circle.dashed")
                    //                    })
                    //#if !os(macOS)
                    //                    .menuActionDismissBehavior(.disabled)
                    //#endif
                    //
                    //                    if planner_Style == .threads{
                    //                        Toggle(isOn: $planner_TimelineBubbles) {
                    //                            Label("Show Bubbles", systemImage: "circle")
                    //                        }
                    //
                    //#if !os(macOS)
                    //                        .menuActionDismissBehavior(.disabled)
                    //#endif
                    //                    }

                    //                    if planner_View == .pages{
                    //                        Toggle(isOn: $alwaysShowButtons) {
                    //                            Label("Show Buttons", systemImage: "capsule")
                    //                        }
                    //                    }
                    //                    if planner_Style == .blocks{
                    //                        Toggle(isOn: $global_Compact, label: {
                    //                            Label("Compact Mode", systemImage: "rectangle.arrowtriangle.2.inward")
                    //                        })
                    //
                    //#if !os(macOS)
                    //                        .menuActionDismissBehavior(.disabled)
                    //#endif
                    //                    }

                    //                    if planner_TimelineBubbles || planner_View != .timeline{
                    //                        Picker(selection: $scalePlannerFactor, label: Label("Size", systemImage: "square.resize.up")) {
                    //                            ForEach(plannerScaleMode.allCases, id:\.self){ mode in
                    //                                VStack{
                    //                                    Label("\(mode.rawValue)", systemImage: mode.icon)
                    //                                }
                    //                                .tag(mode)
                    //                            }
                    //                        }
                    //                        .pickerStyle(MenuPickerStyle())
                    //                    }

                    //                    plannerViewMode
                    Picker(selection: $planner_Style, label: Label("Style", systemImage: kyoPlus_hasPlus ? "paintbrush" : "lock")) {
                        ForEach(typeEntryViewMode.allCases, id:\.self){ mode in
                            VStack{
                                Label("\(mode.rawValue.capitalized)", systemImage: mode.icon)
                            }

                        }
                    }
                    .disabled(!kyoPlus_hasPlus)


#if !os(macOS)
                    .menuActionDismissBehavior(.disabled)
#endif
                    .pickerStyle(MenuPickerStyle())

                    if !schedule_SingleDayMode{


                        ControlGroup{
                            Button {
                                planner_View = plannerViewMode.pages
                            } label: {
                                Label("Paged", systemImage: "rectangle.portrait.on.rectangle.portrait.angled")
                            }
                            Button {
                                planner_View = plannerViewMode.timeline
                            } label: {
                                Label("Timeline", systemImage: "lineweight")
                            }
                            Button {
                                planner_View = plannerViewMode.week
                            } label: {
                                Label("Week", systemImage: "rectangle.split.3x1")
                            }

                        }
                        .disabled(!kyoPlus_hasPlus)
                    }
                    Divider()

                    NavigationLink {
                        PlannerSettings(color: color)
                    } label: {
                        Label("All Settings", systemImage: "calendar.day.timeline.left")
                    }
                    .menuActionDismissBehavior(.disabled)


                } label: {
                    if UIDevice.current.userInterfaceIdiom != .pad{
                        Image(systemName: schedule_SingleDayMode ? "paintbrush" : planner_View.icon)
                            .scaledFrame(width: 44, height: 44, relativeTo: .body)
                            .dynamicTypeSize(.medium ... .xLarge)
                            .contentShape(Rectangle())
                    }
                    else{
                        Image(systemName: schedule_SingleDayMode ? "paintbrush" : planner_View.icon)
                                                    .scaledFrame(width: 44, height: 44, relativeTo: .body)
                    }
                }
                .modify {
                    if #available(iOS 17.0, *) {
                        $0.buttonStyle(NavigationButton(color: color, scrolled: $scrolled))

                    } else {
                        $0.menuStyle(NavigationMenu(color: color, scrolled: $scrolled))
                    }
                }
#endif

                #if os(iOS)
                if UIDevice.current.userInterfaceIdiom != .pad{
                    Button {
                        showTimeSlotCreation.toggle()

                    } label: {

                        Image(systemName: "plus")

                            .scaledFrame(width: 44, height: 44, relativeTo: .body)
                            .dynamicTypeSize(.medium ... .xLarge)

                    }
                    .buttonStyle(NavigationButton(color: color, scrolled: $scrolled))

                }
                else{
                    Button {
                                           showTimeSlotCreation.toggle()

                                       } label: {

                                           Image(systemName: "plus")


                                       }
                }
                #else
                Button {
                                        showTimeSlotCreation.toggle()

                                    } label: {

                                        Image(systemName: "plus")


                                    }
                #endif


            }
        }

    }


}

