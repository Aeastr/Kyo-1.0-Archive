// FIX: Use archive identifiers to keep this build and its data separate from the original app.
//
//  ContentView.swift
//  KyoWatch Watch App
//
//  Created by Aether on 04/08/2023.
//

import SwiftUI

struct ContentView: View {
    @State private var isTodayViewActive = true // Set the default selection to WatchTodayView

    @AppStorage("singleDayMode", store: UserDefaults(suiteName: "group.com.example.kyoarchive")) var singleDayMode: Bool = false

    @AppStorage("skipEmpty") var skipEmpty = true
    @AppStorage("skipPast") var skipPast = true

    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "number", ascending: true)],
                      predicate: NSPredicate(format: "singleDayWeek == nil OR singleDayWeek == %@", NSNumber(value: false))
        ) var weeks: FetchedResults<Week>


    @FetchRequest(sortDescriptors: []) var tasks: FetchedResults<TaskEntity>


    @AppStorage("selectedWeekUUID") var selectedWeekUUID: String?
    @AppStorage("selectedWeekUUID") var selectedDayUUID: String?

    @State var startErrorType: startErrors = .parentlessTimeSlots
    @State var showStartErrorAlert = false

    var body: some View {
        if weeks.isEmpty && tasks.isEmpty {
            VStack{
                Text("Syncing")
                ProgressView()
            }
        }
        else{
            NavigationView {
                List {
                    NavigationLink(
                        destination: WatchTodayView(),
                        isActive: $isTodayViewActive,
                        label: {
                            Text("Today")
                        }
                    )

                    NavigationLink(
                        destination: EmptyView(), // Replace EmptyView() with the desired view for the "Tasks" tab
                        isActive: .constant(false), // Set isActive to false as we don't want to navigate to this by default
                        label: {
                            Text("Tasks")
                        }
                    )



                    NavigationLink(
                        destination: ClassTestView(), // Replace EmptyView() with the desired view for the "Tasks" tab
                        label: {
                            Text(VariableDataNames().classesName())
                        }
                    )




                    NavigationLink(
                        destination: WeeksView(), // Replace EmptyView() with the desired view for the "Tasks" tab
                        label: {
                            Text("Weeks")
                        }
                    )




                    NavigationLink(
                        destination: TimeSlotsView(), // Replace EmptyView() with the desired view for the "Tasks" tab
                        label: {
                            Text("Automatic Rotation Settings")
                        }
                    )
                }
                .navigationTitle("Kyo")
            }
            .onAppear {


                let dispatchGroup = DispatchGroup()

                dispatchGroup.enter()

                if !singleDayMode{
                    // Automatically selects the current day if enabled

                    let weekWizard: WeekWizard = WeekWizard()
                    let x = timeSlotChecks()
                    if weekWizard.totalWeeks != nil && !x.checkForParentlessTimeSlots() {
                        print("get")
                        let scheduleManager = ScheduleManager( debug: true, findOnlyNonEmptyDays: x.empty() ? false : false,  findNextWithUpcomingCurrentSlots: x.empty() ? false :  false)


                    if let foundWeek = weekWizard.getCurrentWeek(), let selectedWeek = weeks.first { Week in
                        Week.number == Int64(foundWeek)
                    }, let scheduleData = scheduleManager.getCurrentDay(Int(selectedWeek.number)), let week = scheduleData.day.week {
                        selectedDayUUID = scheduleData.day.id?.uuidString
                    }

                }
                    else{
                        print("errr")
                        if x.checkForParentlessTimeSlots(){
                            startErrorType = .parentlessTimeSlots
                            showStartErrorAlert.toggle()
                        }

                    }

                    dispatchGroup.leave()
                                }
                else{
                    dispatchGroup.leave()
                }

            }
            .alert(isPresented: $showStartErrorAlert, error: startErrorType) { LocalizedError in
                Button(role: .cancel) {
                    LocalizedError.fixAction()
                } label: {
                    Text("Fix")
                }
                Button(role: .destructive) {

                } label: {
                    Text("Ignore")
                }
            } message: { LocalizedError in
                Text(LocalizedError.failureReason ?? "Unkown Error")
            }
        }
    }
}

#Preview {
    ContentView()

}

struct TimeSlotsView: View {
    @FetchRequest(sortDescriptors: []) var timeSlots: FetchedResults<TimeSlot>
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var weekWizard = WeekWizard()

    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "number", ascending: true)],
                  predicate: NSPredicate(format: "singleDayWeek == nil OR singleDayWeek == %@", NSNumber(value: false))
    ) var weeks: FetchedResults<Week>
    var body: some View {
        VStack{
            Group {
                Text("Auto rotation automatically selects the current week and day for you, you can set any week as the 'current week' and we'll take it from here - no further setup needed! When you add or remove weeks, we'll try to adjust this for you, but you may need to manually set this up again for it to be correct")
                              .font(.body)
                              .frame(maxWidth: .infinity, alignment: .leading)
                              .padding(.vertical, 10)
                              .padding(.horizontal, 20)

                    VStack {
                        NavigationLink {
                            Text("Select")
                            ForEach(weeks) { week in
                                Button(action: {
                                    weekWizard.schedule_SelectedWeekNumber = Int(week.number)

                                    let newAnchorWeekDate = Date() // Replace with the desired anchor week date
                                    weekWizard.anchorWeekDate = newAnchorWeekDate
                                }) {
                                    Text("Week \(week.number)")

                                }
                            }

                        } label: {
                            Group{
                                if let selectedWeek = weekWizard.schedule_SelectedWeekNumber {
                                    Text("Selected Week: \(selectedWeek)")
                                }

                                else{
                                    Text("Select Current Week")
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)

                        }


                        .padding(.horizontal, 20)


                    }
                    .padding(.bottom, 10)



                Divider()
                    .padding(.vertical, 8)
                    .padding(.horizontal, 20)

                if let selectedWeek = weekWizard.schedule_SelectedWeekNumber {
                        Group{
                            Text("It's week \(weekWizard.getCurrentWeek() ?? -1), for this week")
                                .font(.body)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 1)
                                .padding(.horizontal, 20)
                            ForEach(0...weeks.count, id:\.self){ i in
                                let nextWeekDate = Calendar.current.date(byAdding: .weekOfYear, value: (i + 1) , to: Date())
                                Text("\(i > 0 ? "then the week after it's" : "then, next week it's") \(weekWizard.getCurrentWeek(nextWeekDate!) ?? -1)")
                                    .font(.body)
                                    .frame(maxWidth: .infinity, alignment: .leading).padding(.vertical, 1)
                                    .padding(.horizontal, 20)
                            }

                        }
                        .opacity(weeks.count < 2 ? 0.3 : 0.7)
                    }


            }
        }
    }
}

struct ClassTestView: View {
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)]) var classes: FetchedResults<ClassEntity>
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)]) var splitters: FetchedResults<SplitterEntity>

    @Environment(\.managedObjectContext) private var viewContext
    var body: some View {
        TabView {
            ForEach(classes, id: \.self) { entity in
                VStack(spacing: 10){
                    HStack(spacing: 7){
                        Text(entity.name ?? "Untitled")
                            .fontWeight(.semibold)
                    }
                    .font(.title3)

                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 7)
                    .font(.body)
                    Group{
                        Text("Synced from Phone")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 7)
                    .font(.caption)
                    Spacer()
                    Button {

                    } label: {
                        Text("View Entries")
                    }


                }
                .containerBackground((Color(hex: entity.color1 ?? "")).gradient, for: .tabView)

            }

            ForEach(splitters, id: \.self) { entity in
                VStack(spacing: 10){
                    HStack(spacing: 7){
                        Text(entity.name ?? "Untitled")
                            .fontWeight(.semibold)
                    }
                    .font(.title3)

                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 7)
                    .font(.body)
                    Group{
                        Text("Synced from Phone")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 7)
                    .font(.caption)
                    Spacer()
                    Button {

                    } label: {
                        Text("View Entries")
                    }


                }
                .containerBackground((Color(hex: entity.color1 ?? "")).gradient, for: .tabView)

            }
        }
//        .tabViewStyle(.verticalPage)
        .navigationTitle((VariableDataNames().classesAndSplitsName()))
    }
}
struct WatchTodayView: View {
    @State private var showOptions: Bool = false
    @State private var selectedTab: Int = 1 // Index of the second tab is 1


    @State private var selectedTimeSlotTab: Int = 1 // Index of the second tab is 1

    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(sortDescriptors: []) var classes: FetchedResults<ClassEntity>
    @FetchRequest(sortDescriptors: []) var spliters: FetchedResults<SplitterEntity>
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "number", ascending: true)],
                      predicate: NSPredicate(format: "singleDayWeek == nil OR singleDayWeek == %@", NSNumber(value: false))
        ) var weeks: FetchedResults<Week>
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "number", ascending: true)]) var days: FetchedResults<Day>
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "timestamp", ascending: true)]) var timeSlots: FetchedResults<TimeSlot>
    @FetchRequest(sortDescriptors: []) var tasks: FetchedResults<TaskEntity>

    @AppStorage("selectedWeekUUID") var selectedWeekUUID: String?
    @AppStorage("selectedWeekUUID") var selectedDayUUID: String?

    @AppStorage("setAutomaticallyWatch") var setAutomaticallyWatch: Bool = true

    @AppStorage("tasksFilter_showCompleted") var tasksFilter_showCompleted = false
    @AppStorage("tasksFilter_showArchived") var tasksFilter_showArchived = false
    var body: some View {
        Group{
            if weeks.isEmpty && tasks.isEmpty {
                        VStack{
                            Text("Syncing")
                            ProgressView()
                        }
                    }
            else{
                TabView(selection: $selectedTab) {

                    let currentDayString = days.first { element in
                        return element.id?.uuidString == selectedDayUUID
                    }?.name
                    let titleString = currentDayString != nil ? "\(currentDayString!) - " : ""

                        dayOverview()



                    .tag(0)
                    TabView(selection: $selectedTimeSlotTab) {
                        let currentDay = days.first { element in
                            return element.id?.uuidString == selectedDayUUID
                        }

                        if let timeSlotsArray = (Array(currentDay?.timeSlots ?? []) as? [TimeSlot])?.sorted(by: { $0.timestamp ?? Date() < $1.timestamp ?? Date() }) {
                            ForEach(Array(timeSlotsArray.enumerated()), id:\.element) { index, timeSlot in
                                NavigationStack{
                                    currentEntryView(timeSlot: timeSlot)
                                        .background(content: {
                                            Image("doodle1")
                                                .resizable()
                                                .scaledToFill()
                                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                                .ignoresSafeArea()
                                                .foregroundStyle(LinearGradient(colors: [Color.white.opacity(0.06), Color.white.opacity(0.0)], startPoint: .top, endPoint: .bottom))
                                                .clipShape(Rectangle())
                                                .ignoresSafeArea()
                                        })
                                        .containerBackground(Color(hex: timeSlot.classEntity?.color1 ?? timeSlot.splitterEntity?.color1 ?? "").gradient, for: .tabView)
                                        .navigationTitle("\(titleString)\(TimeHelper.getTimeState(startTime: timeSlot.startTime ?? "00:00", endTime: timeSlot.endTime ?? "00:01").rawValue.capitalized)")

                                }
                                .tag(index)

                            }
                            .onAppear(perform: {

                                if let currentElement = timeSlotsArray.firstIndex(where: { element in
                                    return (TimeHelper.getTimeState(startTime: element.startTime ?? "00:00", endTime: element.endTime ?? "00:01")) == .current
                                }){
                                    selectedTimeSlotTab = currentElement
                                }
                            })
                        }
                        else{
                            Text("Day Issue")
                        }
                    }

                    .tabViewStyle(.verticalPage)
                    .tag(1)
        //            NavigationStack{
        //                wholeDay()
        //            }
        //            .tag(2)


                }
                .tint(.white)
        //        .tabViewStyle(.verticalPage)
                .toolbar{
                    ToolbarItemGroup(placement: .topBarLeading) {

                            Button(action: {
                                showOptions.toggle()
                            }, label: {
                                if selectedTab == 1{
                                    Image(systemName: "calendar.day.timeline.left")
                                        .transition(.blur.animation(.smooth))
                                }
                                else{
                                        Image(systemName: "line.3.horizontal.decrease")
                                            .transition(.blur.animation(.smooth))
                                }

                            })

                    }
                                        }
        //                                .tabViewStyle(.verticalPage)
                .sheet(isPresented: $showOptions, content: {
                    NavigationStack{

                            if selectedTab == 1{
                        List{
                            Section("Today"){
                                Button {


                                    let dispatchGroup = DispatchGroup()

                                    dispatchGroup.enter()

                                    // Automatically selects the current day if enabled

                                    let weekWizard: WeekWizard = WeekWizard()
                                    let x = timeSlotChecks()
                                    if weekWizard.totalWeeks != nil && !x.checkForParentlessTimeSlots() {
                                        print("get")
                                        let scheduleManager = ScheduleManager( debug: true, findOnlyNonEmptyDays: x.empty() ? false : false,  findNextWithUpcomingCurrentSlots: x.empty() ? false :  false)


                                        if let foundWeek = weekWizard.getCurrentWeek(), let selectedWeek = weeks.first { Week in
                                            Week.number == Int64(foundWeek)
                                        }, let scheduleData = scheduleManager.getCurrentDay(Int(selectedWeek.number)), let week = scheduleData.day.week {
                                            selectedDayUUID = scheduleData.day.id?.uuidString

                                        }
                                        else{
                                            print("couldn't set, data issue")
                                        }

                                        showOptions.toggle()

                                    }
                                    else{
                                        print("errr")
                                        if x.checkForParentlessTimeSlots(){
                                            //                        startErrorType = .parentlessTimeSlots
                                            //                        showStartErrorAlert.toggle()
                                        }

                                    }

                                    dispatchGroup.leave()



                                } label: {

                                    // Automatically selects the current day if enabled

                                    let weekWizard: WeekWizard = WeekWizard()
                                    let x = timeSlotChecks()
                                    if weekWizard.totalWeeks != nil && !x.checkForParentlessTimeSlots() {

                                        let scheduleManager = ScheduleManager( debug: true, findOnlyNonEmptyDays: x.empty() ? false : false,  findNextWithUpcomingCurrentSlots: x.empty() ? false :  false)


                                        if let foundWeek = weekWizard.getCurrentWeek(), let selectedWeek = weeks.first { Week in
                                            Week.number == Int64(foundWeek)
                                        }, let scheduleData = scheduleManager.getCurrentDay(Int(selectedWeek.number)), let week = scheduleData.day.week {

                                            Text("Week \(week.number), \(scheduleData.day.name ?? "Untitled") ")
                                        }
                                        else{

                                            Text("Current ")
                                        }

                                    }
                                    else{

                                        Text("Current ")
                                    }


                                }
                            }

                            Section("Weeks"){
                                ForEach(weeks, id: \.id){ week in
                                    NavigationLink {
                                        ScrollView{
                                            let dayFilter = days.filter { Day in
                                                Day.week == week
                                            }
                                            ForEach(dayFilter, id: \.id){ day in
                                                Button {
                                                    if let weekID = week.id {
                                                        selectedWeekUUID = weekID.uuidString
                                                    }
                                                    if let dayID = day.id {
                                                        selectedDayUUID = dayID.uuidString
                                                    }
                                                    showOptions.toggle()
                                                } label: {
                                                    Text(day.name ?? "Untitled")
                                                }

                                            }
                                        }
                                    } label: {
                                        if let name = week.name, name != "" {
                                            VStack(alignment: .leading){
                                                Text("\(name)")
                                                Text("Week \(week.number)")
                                                    .font(.body)
                                            }

                                        }
                                        else{
                                            Text("Week \(week.number)")
                                        }
                                    }


                                }
                            }
                            //                    Section("Settings"){
                            //                        Toggle(isOn: $setAutomaticallyWatch) {
                            //                            Text("Set Automatically")
                            //                        }
                            //                    }


                        }
                        .navigationTitle("Select Week/Day")
                    }
                        else{
                            List{
                                Section("Filters"){
                                    Toggle(isOn: $tasksFilter_showCompleted) {
                                        Text("Show completed Tasks")
                                    }
                                    Toggle(isOn: $tasksFilter_showArchived) {
                                        Text("Show archived Tasks")
                                    }
                                }

                            }
                            .navigationTitle("Options")
                        }
                }

                                        })

            }
        }
    }
}

struct dayOverview: View {
    @FetchRequest(sortDescriptors: []) var taskEntities: FetchedResults<TaskEntity>
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)]) var classEntities: FetchedResults<ClassEntity>
    @AppStorage("tasksFilter_showCompleted") var tasksFilter_showCompleted = false
    @AppStorage("tasksFilter_showArchived") var tasksFilter_showArchived = false

    private var sortedClassEntities: [ClassEntity] {
        classEntities.sorted { classEntity1, classEntity2 in
            let taskCount1 = taskEntities.filter { $0.classEntity == classEntity1 && (tasksFilter_showArchived ? true : !$0.archived) && (tasksFilter_showCompleted ? true : !$0.completed) }.count
            let taskCount2 = taskEntities.filter { $0.classEntity == classEntity2 && (tasksFilter_showArchived ? true : !$0.archived) && (tasksFilter_showCompleted ? true : !$0.completed) }.count
            return taskCount1 > taskCount2
        }
    }

    var body: some View {
        TabView {
            ForEach(sortedClassEntities, id: \.id) { entity in
                let taskFilter = taskEntities.filter { TaskEntity in
                    TaskEntity.classEntity == entity && (tasksFilter_showArchived ? true : !TaskEntity.archived) && (tasksFilter_showCompleted ? true : !TaskEntity.completed)
                }
                NavigationStack{
                    List {
                        ForEach(taskFilter, id: \.id) { task in
                            Label(task.label ?? "Untitled", systemImage: task.archived ? "archivebox" : task.completed ? "circle.fill" : "circle")
                        }
                    }.navigationTitle(entity.name ?? "Untitled Class")
                }
            }
        }
        .tabViewStyle(.verticalPage)
    }
}


struct wholeDay: View {
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)]) var classEntities: FetchedResults<ClassEntity>


    @AppStorage("selectedWeekUUID") var selectedWeekUUID: String?
    @AppStorage("selectedWeekUUID") var selectedDayUUID: String?
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "number", ascending: true)],
                      predicate: NSPredicate(format: "singleDayWeek == nil OR singleDayWeek == %@", NSNumber(value: false))
        ) var weeks: FetchedResults<Week>

    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)]) var days: FetchedResults<Day>
    @State var selectedTS: TimeSlot?
    var body: some View {

        if let day = days.first(where: { $0.id?.uuidString == selectedDayUUID }) {
            if let timeSlotsArray = (Array(day.timeSlots ?? []) as? [TimeSlot])?.sorted(by: { $0.timestamp ?? Date() < $1.timestamp ?? Date() }) {
                if timeSlotsArray.isEmpty{
                    Text("No entries found")
                }
                else{
                    List {
                        ForEach(timeSlotsArray, id: \.self) { timeSlot in
                            NavigationLink {

                                currentEntryView(timeSlot: timeSlot)

                                    .background(
                                        Color(hex: timeSlot.classEntity?.color1 ?? timeSlot.splitterEntity?.color1 ?? "").gradient.opacity(0.2)
                                    )

                            } label: {
                                VStack(alignment: .leading, spacing: 5){
                                    Text(timeSlot.classEntity?.name ?? timeSlot.splitterEntity?.name ?? "Unassigned Entry")

                                    if let room = timeSlot.room, room  != "" {
                                        Group{
                                            Text(Image(systemName: "square.split.bottomrightquarter"))
                                            + Text(" \(room)")
                                        }
                                        .font(.body)

                                    }

                                    if let teacher = timeSlot.taughtBy{
                                        Group{
                                            Text(Image(systemName: "person"))
                                            + Text(" \(teacher.name ?? "Untitled")")
                                        }
                                        .font(.body)
                                    }
                                    Divider()
                                        .padding(.trailing, 20)
                                        .frame(maxHeight: .infinity)
                                    if let startTime = timeSlot.startTime, let endTime = timeSlot.endTime{
                                        Group{
                                            Text("\(startTime) - \(endTime)")
                                                .font(.body)
                                                .opacity(0.8)
                                                .padding(.bottom, 2)
                                            if TimeHelper.getTimeState(startTime: startTime, endTime: endTime) == .current{
                                                Text("\(TimeFormatter.toDate(endTime) ?? Date(), style: .timer) \("Remaining")")
                                                    .monospacedDigit()
                                                    .fontWeight(.medium)
                                                    .contentTransition(.numericText())
                                                    .animation(.smooth)
                                                    .font(.body)
                                                    .opacity(0.4)
                                            }

                                        }

                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                }
                                .padding(.vertical)
                            }
                            .listRowBackground(Color(hex: timeSlot.classEntity?.color1 ?? timeSlot.splitterEntity?.color1 ?? "").opacity(0.4).clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous)))


                        }

                    }
                    .navigationTitle(day.name ?? "Day")
            }

            }
        }

    }
}

struct currentEntryView: View {
    @ObservedObject var timeSlot: TimeSlot

    var body: some View {
        ScrollView{
            VStack(spacing: 7.5){
                        HStack(spacing: 7){
                            Text(timeSlot.classEntity?.name ?? timeSlot.splitterEntity?.name ?? "Untitled")
                                .fontWeight(.semibold)
                        }
                        .font(.title2)

                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 7)
                        .font(.body)
                        if let room = timeSlot.room, room  != "" {
                            Group{
                                Text(Image(systemName: "square.split.bottomrightquarter"))
                                + Text(" \(room)")
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 7)
                            .font(.caption)
                        }
                        if let teacher = timeSlot.taughtBy{
                            Group{
                                Text(Image(systemName: "person"))
                                + Text(" \(teacher.name ?? "Untitled")")
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 7)
                            .font(.caption)
                        }

                        if let notes = timeSlot.notes{
                            Group{
                                Text(Image(systemName: "list.bullet.clipboard"))
                                + Text(" \(notes ?? "Untitled")")
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 7)
                            .font(.caption)
                        }
                        Divider()
                            .padding(.horizontal, 7)
                        if let startTime = timeSlot.startTime, let endTime = timeSlot.endTime{
                            Group{
                                if TimeHelper.getTimeState(startTime: startTime, endTime: endTime) == .current{
                                    Text("\(TimeFormatter.toDate(endTime) ?? Date(), style: .timer) \("Remaining")")
                                        .monospacedDigit()
                                        .fontWeight(.medium)
                                        .contentTransition(.numericText())
                                        .animation(.smooth)
                                }
                                else if TimeHelper.getTimeState(startTime: startTime, endTime: endTime) == .upcoming{
                                    Text("in \(TimeFormatter.toDate(endTime) ?? Date(), style: .timer)")
                                        .monospacedDigit()
                                        .fontWeight(.medium)
                                        .contentTransition(.numericText())
                                        .animation(.smooth)
                                }
                                Text("\(startTime) - \(endTime)")
                                    .font(.body)
                                    .opacity(0.8)
                            }

                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 7)
                        }
                    }
            .frame(maxHeight: .infinity, alignment: .center)
        }
    }
}
