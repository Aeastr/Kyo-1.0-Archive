// FIX: Use archive identifiers to keep this build and its data separate from the original app.
//
//  todayView.swift
//  KyoNeo
//
//  Created by Aether on 19/11/2022.
//

import SwiftUI
#if canImport(RiveRuntime)
import RiveRuntime
#endif
import AmethystUI

enum typeEntryViewMode: String, CaseIterable{
    case blocks
    case threads

    public var icon: String {
        switch self{
        case .blocks:
            return "rectangle.grid.1x2"
        case .threads:
            return "point.forward.to.point.capsulepath"
        }
    }
}

struct todayView: View {


    @AppStorage("schedule_SingleDayMode", store: UserDefaults(suiteName: "group.com.example.kyoarchive")) var schedule_SingleDayMode: Bool = false

    //devie logic
    //core data
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "timestamp", ascending: true)]) var timeSlots: FetchedResults<TimeSlot>
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "number", ascending: true)]) var days: FetchedResults<Day>
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "due", ascending: true)]) var tasks: FetchedResults<TaskEntity>
    @FetchRequest(sortDescriptors: []) var weeks: FetchedResults<Week>

    @Environment(\.colorScheme) var colorScheme

    @AppStorage("name") var name = ""

    //scroll logic
    @State var scrollValue = 0.0
    @State var scrolled: Bool = false


    @State var edit: Bool = false

    @State var showClassManage: Bool = false
    @State var showClassCreation: Bool = false

    @State var showTeacherManage: Bool = false

    @State var showSplitterManage: Bool = false

    @State var showTimeSlotCreation: Bool = false

    //filters
    @AppStorage("schedule_SelectedDayID") var schedule_SelectedDayID: String?
    @AppStorage("schedule_SelectedWeekID") var schedule_SelectedWeekID: String?

    @AppStorage("global_Compact") var global_Compact  = false
    //nav color logic
    var color: Color = Color("1")

    //sheet logic
    @State var showWeekCreation = false
    @State var showDatabaseEdit = false

    //animations + class-view logic
    @Namespace var namespace
    @State var fontBig = false
    @State var selectedState: timeState = .error
    @EnvironmentObject var columnVisibilitySettings: ColumnVisibilitySettings

    //general models

    @AppStorage("allowCustomDayToday") var allowCustomDayToday = false

    @AppStorage("Contrast") var contrast = false
    @AppStorage("tintPages") var tintPages = false

    @AppStorage("actualDay") var actualDay: String = "Mon"

    @State var differentDay: String = "Mon"
    @State var differentWeek: Int = 0

    @AppStorage("countdownOnlyCurrent") var countdownOnlyCurrent = true
    @AppStorage("showTodayMap") var showTodayMap = false
    //filters
    @State private var filter = "Mon"
    let predicate = NSPredicate(format: "name == %@", "Mon")
    @AppStorage("todayExists") var todayExists = true
    @Environment(\.dismiss) var dismiss

    @State var selectedID: NSObject? = nil
    @State var expandCardID: UUID?

    @AppStorage("planner_Style") var planner_Style:  typeEntryViewMode = .blocks
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State var shownTimeSlot: TimeSlot?
    @State var viewTimeSlot: TimeSlot?
    @State var classForTask: ClassEntity?
    @State var shareTimeSlot: TimeSlot?

    // AppStorage variables

    @AppStorage("planner_Suggestions") var planner_Suggestions: Bool = true


#if os(iOS)
    @AppStorage("planner_View") var planner_View: plannerViewMode = .pages
#else
    @AppStorage("planner_View") var planner_View: plannerViewMode = .week
#endif
    @AppStorage("alwaysShowButtons") var alwaysShowButtons = false
    @AppStorage("planner_TimelineBubbles") var planner_TimelineBubbles:  Bool = true
    
    #if !os(iOS)
    @AppStorage("today_viewSettings_twoColumn") var today_viewSettings_twoColumn : Bool = true
    #else
    var today_viewSettings_twoColumn : Bool = false
    #endif

    @AppStorage("kyoPlus_hasPlus") var kyoPlus_hasPlus: Bool = false
    @State var kyoPlus_showPurchaseScreen: Bool = false

    var body: some View {

        let DataFactory = knDataFactory()
        
        var weekWizard: WeekWizard = WeekWizard(customMessage: "from today view")
        let actualWeek = weekWizard.getCurrentWeek() ?? -1
        let actualDay = TimeFormatter.getDayCode(date: Date()) ?? "Mon"



        Group{
            HStack{
                ScrollView() {
#if os(iOS)
                    ScrollDetector(scrolled: $scrolled)
#endif



                    if kyoPlus_hasPlus{
                        let dayVarToUse = ScheduleManager(debug: true, findOnlyNonEmptyDays: true, findNextWithUpcomingCurrentSlots: true, fromCode: "today").getCurrentDay(actualWeek)?.day.name ?? "Mon"
                               let wweekVarToUse = Int(ScheduleManager(debug: true, findOnlyNonEmptyDays: true, findNextWithUpcomingCurrentSlots: true).getCurrentDay(actualWeek)?.day.week?.number ?? -1)

                        VStack{

                                                Group{
                                                    if #available(iOS 17.0, *) {
//                                                        if showTodayMap{
//                                                            Text("Campus")
//                                                                .sectionTitle()
//                                                                .padding(.horizontal, 20)
//                                                                .transition(.blur.animation(.smooth))
//
//                                                            VStack{
//                                                                if MapItemStorage.isMapItemSet(forKey: "savedMapItem"){
//                                                                    MapView2()
//                                                                        .disabled(true)
//                                                                }
//                                                                else{
//                                                                    Text("Configure Maps in Settings")
//                                                                        .font(.caption)
//                                                                }
//
//
//                                                            }
//                                                            .frame(height: 130)
//                                                            .frame(maxWidth: .infinity)
//                                                            .background {
//                                                                Color("NeoButton").opacity(0.6)
//                                                            }
//                                                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
//                                                            .regularOutline()
//                                                            .padding(.horizontal, 30)
//                                                            .transition(.blur.animation(.smooth))
//                                                        }
                                                    }
                                                    let today = Date()
                                                    let calendar = Calendar.current
                                                    var filteredTodayTasks: [TaskEntity] {
                                                        return tasks.filter { task in
                                                            guard let dueDate = task.due else { return false }
                                                            return calendar.isDate(dueDate, inSameDayAs: today) || calendar.isDateInTomorrow(dueDate)
                                                        }
                                                    }
                                                    VStack(spacing: 0){
                                                        VStack(spacing: 0){
                                                            HStack{
                                                                Text("Tasks")
                                                                    .sectionTitle()

                                                            }
                                                            .padding(.horizontal, 20)

                                                            ForEach(filteredTodayTasks, id: \.self) { task in
                                                                TaskItem(data: task)
                                                                    .padding(.horizontal, global_Compact ? 0 : 25)
                                                                    .padding(.vertical, 7)
                                                            }

                                                            if filteredTodayTasks.count == 0{
                                                                Text("No Tasks!")
                                                                    .frame(maxWidth: .infinity)
                                                                    .font(.caption)
                                                                    .neoSettingsCard()
                                                                    .padding(.horizontal, 30)
                                                            }
                                                        }



                                                        if !today_viewSettings_twoColumn{
                                                        let filteredSlotsToday = timeSlots.filter { timeSlot in

                                                            return  schedule_SingleDayMode ? timeSlot.day?.week == weeks.filter{ week in
                                                                return week.singleDayWeek == true
                                                            }.first : timeSlot.day?.name == dayVarToUse
                                                        }

                                                        let filteredSlotsNow = timeSlots.filter { timeSlot in
                                                            return schedule_SingleDayMode ?
                                                            timeSlot.day?.week == weeks.filter{ week in
                                                                return week.singleDayWeek == true
                                                            }.first && (TimeHelper.getTimeState(startTime: timeSlot.startTime ?? "00:00", endTime: timeSlot.endTime ?? "00:01") == .current)
                                                            :
                                                            timeSlot.day?.name == dayVarToUse && timeSlot.day?.week?.id?.uuidString == schedule_SelectedWeekID && (TimeHelper.getTimeState(startTime: timeSlot.startTime ?? "00:00", endTime: timeSlot.endTime ?? "00:01") == .current)
                                                        }
                                                        let filteredSlotsUpNext = timeSlots.filter { timeSlot in
                                                            return schedule_SingleDayMode ?

                                                            timeSlot.day?.week == weeks.filter{ week in
                                                                return week.singleDayWeek == true
                                                            }.first &&  (TimeHelper.getTimeState(startTime: timeSlot.startTime ?? "00:00", endTime: timeSlot.endTime ?? "00:01") == .upcoming)
                                                            :
                                                            timeSlot.day?.name == dayVarToUse && timeSlot.day?.week?.id?.uuidString == schedule_SelectedWeekID && ( (actualWeek == wweekVarToUse && actualDay == dayVarToUse) ? (TimeHelper.getTimeState(startTime: timeSlot.startTime ?? "00:00", endTime: timeSlot.endTime ?? "00:01") == .upcoming) : true)
                                                        }.prefix(100)

                                                        HStack{
                                                            Text("Planner")
                                                                .zIndex(1)
                                                                .framelessSectionTitle()
                                                                .zIndex(1)

                                                            Spacer()
                                                        }
                                                        .padding(.horizontal, 20)
                                                        .zIndex(1)
                                                        if filteredSlotsToday.count == 0{

                                                            Button {
                                                                //    selectedTab = .planner
                                                            } label: {
                                                                VStack(spacing: 4){
                                                                    Text("You haven't added any entries for today, want to add some?")
                                                                        .foregroundStyle(.primary)
                                                                    HStack(spacing: 2){
                                                                        Text("Get Started")
                                                                        Image(systemName: "arrow.right")
                                                                    } .foregroundStyle(color)



                                                                }
                                                                .frame(maxWidth: .infinity)
                                                                .font(.caption)
                                                                .neoSettingsCard()
                                                                .padding(.horizontal, 30)
                                                            }
                                                            .buttonStyle(bounceButton())




                                                        }

                                                        if filteredSlotsNow.count != 0 && filteredSlotsToday.count != 0{
                                                            


                                                            VStack(spacing:global_Compact ? 0 : 10){



                                                                let array = filteredSlotsNow
                                                                VStack(spacing: planner_Style == .threads ? 0 : 10){
                                                                    ForEach(Array(array.enumerated()), id:\.element) { index, timeSlot in

                                                                        let prevSlot = (index != 0) ? array[index - 1] : timeSlot
                                                                        let nextSlot = (index != (array.endIndex - 1)) ? array[index + 1] : timeSlot

                                                                        if planner_Style == .threads{
                                                                            EntryThread(timeSlot: timeSlot,timeSlotPrev: prevSlot, timeSlotNext: nextSlot, index: index, widthBubble: 70, shownTimeSlot: $shownTimeSlot, viewTimeSlot: $viewTimeSlot, classForTask: $classForTask, editMode: .constant(false))
                                                                        }
                                                                        else{
                                                                            EntryBlock(timeSlot: timeSlot, context: viewContext, shownTimeSlot: $shownTimeSlot, viewTimeSlot: $viewTimeSlot, classForTask: $classForTask, shareTimeSlot: $shareTimeSlot, editMode: .constant(false))
                                                                        }



                                                                    }
                                                                }

                                                            }
                                                        }
                                                        else if filteredSlotsToday.count != 0 && actualWeek == wweekVarToUse && actualDay == dayVarToUse{
                                                            Text("All clear for now!")
                                                                .frame(maxWidth: .infinity)
                                                                .font(.caption)
                                                                .neoSettingsCard()
                                                                .padding(.horizontal, 30)
                                                        }

                                                        if filteredSlotsToday.count != 0  && actualWeek == wweekVarToUse && actualDay == dayVarToUse{
                                                            Divider()
                                                                .padding(.horizontal, 30)
                                                                .padding(.vertical, 11)
                                                        }


                                                        if filteredSlotsUpNext.count != 0{


                                                            let array = filteredSlotsUpNext
                                                            VStack(spacing: planner_Style == .threads ? 0 : 10){
                                                                ForEach(Array(array.enumerated()), id:\.element) { index, timeSlot in

                                                                    let prevSlot = (index != 0) ? array[index - 1] : timeSlot
                                                                    let nextSlot = (index != (array.endIndex - 1)) ? array[index + 1] : timeSlot

                                                                    if planner_Style == .threads{
                                                                        EntryThread(timeSlot: timeSlot,timeSlotPrev: prevSlot, timeSlotNext: nextSlot, index: index, widthBubble: 70, shownTimeSlot: $shownTimeSlot, viewTimeSlot: $viewTimeSlot, classForTask: $classForTask, editMode: .constant(false))
                                                                    }
                                                                    else{
                                                                        EntryBlock(timeSlot: timeSlot, context: viewContext, shownTimeSlot: $shownTimeSlot, viewTimeSlot: $viewTimeSlot, classForTask: $classForTask, shareTimeSlot: $shareTimeSlot, editMode: .constant(false))
                                                                    }



                                                                }
                                                            }



                                                        }
                                                        else if filteredSlotsToday.count != 0 && actualWeek == wweekVarToUse && actualDay == dayVarToUse{
                                                            Text("Nothings coming up")
                                                                .frame(maxWidth: .infinity)
                                                                .font(.caption)
                                                                .neoSettingsCard()
                                                                .padding(.horizontal, 30)
                                                        }

                                                        //
                                                        //                Text("Updates")
                                                        //                    .sectionTitle()
                                                        //                    .padding(.horizontal, 20)
                                                        //
                                                        //
                                                        //                Text("No Updates!")
                                                        //                    .frame(maxWidth: .infinity)
                                                        //                    .font(.caption)
                                                        //                    .neoSettingsCard()
                                                        //                    .padding(.horizontal, 30)
                                                        //
                                                        //                    Color.clear.frame(height: 30)
                                                    }
                                                    }

                                                }


                                            }

                                            .sheet(item: $shownTimeSlot) { item in

                                                NavigationStack{
                                                    TimeSlotWorkshop(entity: item)
                                                        .interactiveDismissDisabled()
                                                }
                                                .presentationCornerRadius(25)
                                            }

                                            //            .sheet(item: $viewTimeSlot) { item in
                                            //                EntryDetailSuper(timeSlot: item, currentState: countdownOnlyCurrent ? item.day?.name == TimeFormatter.getDayCode(date: Date()) ? TimeHelper.getTimeState(startTime: item.startTime ?? "00:00", endTime: item.endTime ?? "00:01") : .upcoming : TimeHelper.getTimeState(startTime: item.startTime ?? "00:00", endTime: item.endTime ?? "00:01"))
                                            //                    .presentationDetents([.fraction(0.64), .large])
                                            //                    .presentationDragIndicator(.hidden)
                                            //                    .presentationCornerRadius(25)
                                            //            }

                                            .sheet(item: $classForTask) { item in

                                                NavigationStack{
                                                    TaskWorkshop(selectedClass: item)
                                                        .interactiveDismissDisabled()
                                                        .presentationCornerRadius(25)
                                                }
                                            }

                                            .sheet(item: $shareTimeSlot) { item in

                                                NavigationStack{
                                                    PlannerShareView(timeSlot: item)
                                                        .presentationCornerRadius(25)
                                                }

                                            }

                                            //            .sheet(item: $viewTimeSlot) { item in
                                            //                EntryDetail(timeSlot: item, currentState: countdownOnlyCurrent ? item.day?.name == TimeFormatter.getDayCode(date: Date()) ? TimeHelper.getTimeState(startTime: item.startTime ?? "00:00", endTime: item.endTime ?? "00:01") : .upcoming : TimeHelper.getTimeState(startTime: item.startTime ?? "00:00", endTime: item.endTime ?? "00:01"))
                                            //                    .presentationDetents([.fraction(0.64), .large])
                                            //                    .presentationDragIndicator(.hidden)
                                            //                    .presentationCornerRadius(25)
                                            //            }
                                            //
                                            //            .sheet(item: $classForTask) { item in
                                            //                TaskWorkshop(selectedClass: classForTask)
                                            //                    .interactiveDismissDisabled()
                                            //                    .presentationCornerRadius(25)
                                            //            }
                                            //
                                            //            .sheet(item: $shareTimeSlot) { item in
                                            //                PlannerShareView(timeSlot: item)
                                            //                    .presentationCornerRadius(25)
                                            //
                                            //            }
                                            //
                                            //            .animation(.smooth, value: showTodayMap)
                                            //            .animation(.smooth, value: selectedDay)
                                            //            .animation(.smooth, value: schedule_SelectedWeek)
                                            //            .animation(.bouncy(duration: 0.35), value: selectedID)
                    }
                    else{
                        Image("todayExample")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: 400)
                            .padding(.top, 10)
                            .padding(.horizontal, 40)
                    }


                }
            }
            .animation(.smooth, value: showTodayMap)
            .coordinateSpace(name: "scroll")
            //            .onAppear{
            //                for week in weeks {
            //                    if week.number == Int64(schedule_SelectedWeek) {
            //                        for day in days {
            //                            let currentDayCode = TimeFormatter.getDayCode(date: Date()) ?? "Mon"
            //                            if day.name == currentDayCode {
            //                                actualDay = TimeFormatter.getDayCode(date: Date()) ?? "Mon"
            //                                differentDay = TimeFormatter.getDayCode(date: Date()) ?? "Mon"
            //                            }
            //                        }
            //                    }
            //                }
            //            }



    #if os(iOS)
            .safeAreaInset(edge: .top, content: {
                Color.clear.frame(height: horizontalSizeClass == .compact ? 80 : 40)
            })
    #endif
            .safeAreaInset(edge: .bottom) {
                                KyoPlusButtonBinding(color: color, kyoPlus_hasPlus: $kyoPlus_hasPlus, kyoPlus_showPurchaseScreen: $kyoPlus_showPurchaseScreen, text: "Upgrade to Kyo+ to access the today view", emoji: "👀", rotation: 10 , position: CGPoint(x: 13 ,y: 8))
#if os(visionOS)
                                    .padding(.bottom, 25)
                                    .padding(.horizontal, 5)
                #else
                                    .padding(.bottom, 15)
                #endif
                            }
            .amethystNavigationBar(title: /*kyoPlus_hasPlus ? schedule_SingleDayMode ? "Today" : "\(getFullDayName(from: dayVarToUse) ?? dayVarToUse)" : "Today"*/ "Today", titleColor: .primary,   tintColor: color, compactMode: true, overrideType: .regular, scrolled: $scrolled, content: {
    #if !os(macOS)
                    Menu(content: {
//                        Toggle(isOn: $showTodayMap) {
//                            Label("Show Map", systemImage: "map")
//                        }

                        Section("View"){
                            Picker(selection: $planner_Style, label: Label("View", systemImage: "eye")) {
                                ForEach(typeEntryViewMode.allCases, id:\.self){ mode in
                                    VStack{

                                            Label("\(mode.rawValue.capitalized)", systemImage: mode.icon)

                                    }
                                    .tag(mode)
                                }
                            }
                        }

                    }, label: {

                        Image(systemName: planner_Style.icon)
                        #if !os(visionOS)
                                .scaledFrame(width: 44, height: 44, relativeTo: .body)
                        #endif

                    })
                    .opacity(kyoPlus_hasPlus ? 1.0 : 0.0)
                #if !os(visionOS)
                    .modify {
                        if #available(iOS 17.0, *) {
                            $0.buttonStyle(NavigationButton(color: color, scrolled: $scrolled))

                        } else {
                            $0.menuStyle(NavigationMenu(color: color, scrolled: $scrolled))
                        }
                    }
    #endif
                
    #endif

                }, toolbar: {
                    #if os(iOS)
                    if !schedule_SingleDayMode{
                                            HStack(spacing: 0){
                                                Text(TimeHelper.generateGreeting(userName: name))

                                            }
                                            .foregroundStyle(color)
                                        }
                                        else{
                                            HStack(spacing: 0){
                                                Text(TimeHelper.generateGreeting(userName: name))
                                            }
                    .foregroundStyle(color)
                                        }
                    #endif
                })
#if os(visionOS)
            .toolbar {
                ToolbarItem(placement: .bottomOrnament) {
                    if !schedule_SingleDayMode{
                                            HStack(spacing: 0){
                                                Text(TimeHelper.generateGreeting(userName: name))

                                            }
                                            .foregroundStyle(Color.primary)
                                        }
                                        else{
                                            HStack(spacing: 0){
                                                Text(TimeHelper.generateGreeting(userName: name))
                                            }
                    .foregroundStyle(Color.primary)
                                        }
                }
            }
#endif
        }

    }






}


struct ExampleView: View {

    // MARK: - Presentation Conditions
    @State private var showViewNavStack: Bool = false
    @State private var showView: Bool = false

    var body: some View {
        VStack(spacing: 20){
            Button {
                showViewNavStack.toggle()
            } label: {
                Label("Open View with NavStack", systemImage: "square")
            }

            Button {
                showView.toggle()
            } label: {
                Label("Open View without NavStack", systemImage: "square")
            }
        }
        .sheet(isPresented: $showView) {
            Text("View")
            // doesnt display a 'lag' or delay upon presentation
        }
        .sheet(isPresented: $showViewNavStack) {
            NavigationStack{
                Text("View")
            }
            // displays a 'lag' or delay upon presentation
        }
    }
}




