// FIX: Use archive identifiers to keep this build and its data separate from the original app.
//
//  CreateTimeSlot.swift
//  KyoNeo
//
//  Created by Aether on 20/01/2023.
//

import SwiftUI
import CoreData

import AmethystUI

struct timeSlotTimesHandler{
    var context: NSManagedObjectContext {
        PersistenceController.shared.container.viewContext
    }
    var timeSlots: [TimeSlot] {
        let request: NSFetchRequest<TimeSlot> = TimeSlot.fetchRequest()
        let sort = NSSortDescriptor(key: "timestamp", ascending: true)
        request.sortDescriptors = [sort]
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching Days: \(error.localizedDescription)")
            return []
        }
    }


    @AppStorage("lastClassDuration") var lastClassDuration: Double = 1.0
    // use differenceBetween((timeSlot.startTime ?? ""), (timeSlot.endTime ?? ""))

    @AppStorage("lastSplitDuration") var lastSplitDuration: Double = 0.5
    // use differenceBetween((timeSlot.startTime ?? ""), (timeSlot.endTime ?? ""))

    func getRecomendedStart(dayID: String, weekID: String) -> String?{
        if !timeSlots.isEmpty{

            let filter = timeSlots.filter({ TimeSlot in
                guard let dayWeekID = TimeSlot.day?.week?.id?.uuidString,
                      TimeSlot.day?.id?.uuidString == dayID && weekID == dayWeekID
                else {
                    return false
                }
                return true
            })

            return filter.last?.endTime

        }
        return nil
    }
}

#if os(iOS) || os(visionOS)
struct TimeSlotWorkshop: View, KeyboardReadable {

    var entity: TimeSlot?
    var classEntry = true
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    /// Core Data
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "timestamp", ascending: true)]) var timeslots: FetchedResults<TimeSlot>
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)]) var classes: FetchedResults<ClassEntity>
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)]) var splitters: FetchedResults<SplitterEntity>
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)]) var teachers: FetchedResults<TeacherEntity>
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "number", ascending: true)],
                  predicate: NSPredicate(format: "singleDayWeek == nil OR singleDayWeek == %@", NSNumber(value: false))
    ) var weeks: FetchedResults<Week>


    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "number", ascending: true),
                                    // Add more sort descriptors if needed
                                   ],
                  predicate: NSPredicate(format: "singleDayWeek == %@", NSNumber(value: true))
    ) var singleDayweeks: FetchedResults<Week>
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "number", ascending: true)]) var days: FetchedResults<Day>
    @Environment(\.managedObjectContext) private var viewContext

    /// AppStorage
    @AppStorage("timeGap") var timeGap = 0
    @AppStorage("schedule_SelectedDayID") var schedule_SelectedDayID: String?
    @AppStorage("schedule_SelectedWeekID") var schedule_SelectedWeekID: String?



    /// Time Logic
    @AppStorage("lastClassDuration") var lastClassDuration: Double = 1.0
    @AppStorage("lastSplitDuration") var lastSplitDuration: Double = 0.5
    @State var systemEditingTime: Bool = true
    @State var hasTimeBeenUserEdited: Bool = false

    /// scroll logic
    @State var scrolled: Bool = false
    @State var room = ""
    @State var teacherName = ""
    @State var showsPopoverStart = false
    @State var showsPopoverEnd = false
    @State var startTime: Date = Date()
    @State var endTime: Date = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
    @State var color1: Color = Color(hex: "84C7D3")
    @State var color2: Color = Color(hex: "94CAED")

    /// text fields focus
    enum FocusField: Hashable {
        case name
        case room
        case teacherName
        case none
    }
    @FocusState private var focusedField: FocusField?

    @State private var isKeyboardVisible = false

    @State var notes = ""


    //classes logic
    @State var selectedClass: ClassEntity?

    //teacher logic
    @State var selectedTeacher: TeacherEntity?
    @State private var isAlertTeacherPresented = false
    @State var teacherNameAdd: String = ""

    //splitters logic
    @State var selectedSplitter: SplitterEntity?

    @State var teacherEdit: Bool = false

    //day logic
    @State var currentSelectedDay: Day?
    @State var dayHasBeenSelected: Bool = false

    //week logic
    @State var currentschedule_SelectedWeek: Week?
    @State var weekHasBeenSelected: Bool = false

    //creation logic
    @State var selectedType: TimeSlotTypeModel = .none
    @State var editMode: Bool = false
    @State var ButtonText = "Select"
    @State var splitterName = "Select"

    @State var isLoadingAllSave = false

    func occuranceWeekBinding(occurance: OccuranceModel) -> Binding<Week?> {
        return Binding<Week?>(
            get: { occurance.week },
            set: { _ in }
        )
    }

    //screen logic
    @State var showColorEdit = false
    @State var showClassCreate = false
    @State var showClassEdit: Bool
    @State var showSplitterCreate = false
    @State var showWeekCreate = false
    @Environment(\.dismiss) var dismiss

    @State var cancelAlert: Bool = false

    //colorScheme

    @Environment(\.colorScheme) var colorScheme

    @State var extraOccurances: [OccuranceModel] = []


    @AppStorage("schedule_SingleDayMode", store: UserDefaults(suiteName: "group.com.example.kyoarchive")) var schedule_SingleDayMode: Bool = false

    // FIX: Archive access is unconditional; do not read or update a persisted purchase flag.

    private var kyoPlus_hasPlus: Bool { true }


    init(entity: TimeSlot? = nil, color1: Color = .white, color2: Color = .white){
        self._showClassEdit = .init(initialValue: false)

        if entity != nil{
            self.entity = entity
            self._hasTimeBeenUserEdited = .init(initialValue: true)
            self._editMode = .init(initialValue: true)

            if let entRoom = entity?.room{
                self._room = .init(initialValue: entRoom)
            }

            if let entNote = entity?.notes{
                self._notes = .init(initialValue: entNote)
            }

            if let entTeacher = entity?.taughtBy{
                self._selectedTeacher = .init(initialValue: entTeacher)
            }

            if let entStartTime = entity?.startTime, let startDate = TimeFormatter.toDate(entStartTime) {
                self._startTime = .init(initialValue: startDate)
            }
            if let entEndTime = entity?.endTime, let endDate = TimeFormatter.toDate(entEndTime) {
                self._endTime = .init(initialValue: endDate)
            }

            if let day = entity?.day {
                self._currentSelectedDay = .init(initialValue: day)

            }

            if let week = entity?.day?.week {
                self._currentschedule_SelectedWeek = .init(initialValue: week)

            }
#if !os(visionOS)
            if let classEn = entity?.classEntity, let classEnC1 = classEn.color1, let classEnC2 = classEn.color2{
                self._selectedClass = .init(initialValue: classEn)
                self._selectedType = .init(initialValue: .classes)

                self._color1 = .init(initialValue:  colorScheme == .light ?  Color(hex: classEnC1).getBrightness() > 0.73 ? Color(hex: classEnC1).darken(by: 0.4) : Color(hex: classEnC1) : Color(hex: classEnC1))
                self._color2 = .init(initialValue:  colorScheme == .light ? Color(hex: classEnC2).getBrightness() > 0.73 ? Color(hex: classEnC2).darken(by: 0.4) : Color(hex: classEnC2) : Color(hex: classEnC2))
            }
            if let splitter = entity?.splitterEntity, let splitterC1 = splitter.color1, let splitterC2 = splitter.color2{
                self._selectedSplitter = .init(initialValue: splitter)
                self._selectedType = .init(initialValue: .splitters)

                self._color1 = .init(initialValue: colorScheme == .light ?  Color(hex: splitterC1).getBrightness() > 0.73 ? Color(hex: splitterC1).darken(by: 0.4) : Color(hex: splitterC1): Color(hex: splitterC1))
                self._color2 = .init(initialValue: colorScheme == .light ?  Color(hex: splitterC2).getBrightness() > 0.73 ? Color(hex: splitterC2).darken(by: 0.4) : Color(hex: splitterC2) : Color(hex: splitterC2))
            }
#else
            self._color1 = .init(initialValue: Color.primary)
            self._color2 = .init(initialValue: Color.primary)
#endif
        }
        else{

#if !os(visionOS)
            self._color1 = .init(initialValue: colorScheme == .light ? color1.getBrightness() > 0.73 ? color1.darken(by: 0.4) : color1 : color1)
            self._color2 = .init(initialValue: colorScheme == .light ? color2.getBrightness() > 0.73 ? color2.darken(by: 0.4) : color2 : color2)

            print("ent is nill")

#else
            self._color1 = .init(initialValue: Color.primary)
            self._color2 = .init(initialValue: Color.primary)
#endif
        }


    }

    init(color1: Color = .white, color2: Color = .white, startTime: Date, endTime: Date){



        self._showClassEdit = .init(initialValue: false)
#if !os(visionOS)
        self._color1 = .init(initialValue: color1)
        self._color2 = .init(initialValue: color2)

#else
        self._color1 = .init(initialValue: Color.primary)
        self._color2 = .init(initialValue: Color.primary)
#endif
        self._startTime = .init(initialValue: startTime)
        self._endTime = .init(initialValue: endTime)

        print("ent is nill!")
    }


    var body: some View {
        ZStack{
            Color("bw")
                .opacity(0.6)
                .ignoresSafeArea()
            //                NeoDotBackground(color1: selectedClass != nil ? Color(hex: selectedClass?.color1 ?? "#85A2EC") : Color(hex: selectedSplitter?.color1 ?? "#85A2EC") , color2: selectedClass != nil ? Color(hex: selectedClass?.color2 ?? "#85A2EC") : Color(hex: selectedSplixtter?.color2 ?? "#85A2EC") , gradient: true, opacity: 0.035)

            ScrollViewReader{ proxy in
                ScrollView{

                    ScrollDetector(scrolled: $scrolled)
                        .onAppear{
                            if let schedule_SelectedDayID = schedule_SelectedDayID, let schedule_SelectedWeekID = schedule_SelectedWeekID, entity == nil{
                                if let startCalc = timeSlotTimesHandler().getRecomendedStart(dayID: schedule_SelectedDayID, weekID: schedule_SelectedWeekID), let start = TimeFormatter.toDate(startCalc, mode: .time){
                                    print("set time start to \(start)!")
                                    startTime = start
                                    endTime = Calendar.current.date(byAdding: .minute, value: Int(lastClassDuration * 60), to: start)!
                                }
                            }
                        }
                        .onChange(of: selectedClass) { change in
                            if let schedule_SelectedDayID = schedule_SelectedDayID, let schedule_SelectedWeekID = schedule_SelectedWeekID, change != nil && !hasTimeBeenUserEdited{
                                if let startCalc = timeSlotTimesHandler().getRecomendedStart(dayID: schedule_SelectedDayID, weekID: schedule_SelectedWeekID), let start = TimeFormatter.toDate(startCalc, mode: .time){
                                    print("set time start to \(start)!")
                                    startTime = start
                                    endTime = Calendar.current.date(byAdding: .minute, value: Int(lastClassDuration * 60), to: start)!
                                }
                            }
                        }
                        .onChange(of: selectedSplitter) { change in
                            if let schedule_SelectedDayID = schedule_SelectedDayID, let schedule_SelectedWeekID = schedule_SelectedWeekID, change != nil && !hasTimeBeenUserEdited{
                                if let startCalc = timeSlotTimesHandler().getRecomendedStart(dayID: schedule_SelectedDayID, weekID: schedule_SelectedWeekID), let start = TimeFormatter.toDate(startCalc, mode: .time){
                                    print("set time start to \(start)!")
                                    startTime = start
                                    endTime = Calendar.current.date(byAdding: .minute, value: Int(lastSplitDuration * 60), to: start)!
                                }
                            }
                        }
                    // Text(checkColor(color: selectedClass.color1 ?? "84C7D3") ? "Light" : "Not Light")
                    VStack{
                        Group{
                            typeSelector
                                .sheet(isPresented: $showClassEdit, onDismiss: {
#if !os(visionOS)
                                    if let selectedClass = selectedClass, let selectedClassColor1 = selectedClass.color1,  let selectedClassColor2 = selectedClass.color2{


                                        color1 = colorScheme == .light ? Color(hex: selectedClassColor1).getBrightness() > 0.73 ? Color(hex: selectedClassColor1).darken(by: 0.4) : Color(hex: selectedClassColor1) : Color(hex: selectedClassColor1)
                                        color2 = colorScheme == .light ? Color(hex: selectedClassColor2).getBrightness() > 0.73 ? Color(hex: selectedClassColor2).darken(by: 0.4) : Color(hex: selectedClassColor2) : Color(hex: selectedClassColor2)
                                    }
                                    if let selectedSplitter = selectedSplitter, let selectedSplitterColor1 = selectedSplitter.color1, let selectedSplitterColor2 = selectedSplitter.color2{


                                        color1 = colorScheme == .light ? Color(hex: selectedSplitterColor1).getBrightness() > 0.73 ? Color(hex: selectedSplitterColor1).darken(by: 0.4) : Color(hex: selectedSplitterColor1) : Color(hex: selectedSplitterColor1)
                                        color2 = colorScheme == .light ? Color(hex: selectedSplitterColor2).getBrightness() > 0.73 ? Color(hex: selectedSplitterColor2).darken(by: 0.4) : Color(hex: selectedSplitterColor2) : Color(hex: selectedSplitterColor2)
                                    }
#endif
                                }) {

                                    NavigationStack{
                                        if let selectedClass = selectedClass{
                                            ClassComposer(entity: selectedClass, passThroughClass: $selectedClass)
                                                .interactiveDismissDisabled()
                                        }
                                        else if let selectedSplitter = selectedSplitter{
                                            SplitterEdit(entity: selectedSplitter)
                                        }

                                    }
                                    .presentationCornerRadius(25)
                                }

                            roomField
                                .sheet(isPresented: $showWeekCreate) {
                                    NavigationStack{
                                        WeekSlider(color: color1)
                                    }
                                    .presentationCornerRadius(25)
                                }
                            teacherField
                                .sheet(isPresented: $teacherEdit) {
                                    NavigationStack{
                                        ManageTeachers(back: false, color: color1)
                                    }
                                    .presentationCornerRadius(25)
                                }
                            if !schedule_SingleDayMode{
                                dateSelector
                                    .sheet(isPresented: $showClassCreate) {
                                        NavigationStack{
                                            ClassComposer(color1: color1, color2: color2, passThroughClass: $selectedClass)
                                                .interactiveDismissDisabled()
                                        }
                                        .presentationCornerRadius(25)
                                    }
                            }

                            timeSelector
                                .zIndex(4)
                            //   .animation(.bouncy(duration: 0.45))

                            if extraOccurances.count != 0{
                                multiOccurnceView.padding(.bottom, 3)

                            }

                            VStack{
                                HStack{
                                    if !kyoPlus_hasPlus{
                                        Image(systemName: "lock")
                                            .framelessSectionTitle()
                                    }

                                    Text("Notes")
                                        .sectionTitle()
                                }

                                TextField("Add some notes about this entry..", text: $notes,axis: .vertical)
                                    .lineLimit(3...10)
                                    .padding(.leading, 10)
                                    .padding(.trailing, 10)
#if !os(visionOS)
            .neoFieldCard(color: color2)
#else
            .padding(.vertical, 13.5)
            .background(Color.white.opacity(0.3))
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
#endif

                                    .opacity(kyoPlus_hasPlus ? 1.0 : 0.5)
                                    .disabled(!kyoPlus_hasPlus)

                            }
                            .padding(.horizontal, 20)

                            VStack{
                                HStack{
                                    if !kyoPlus_hasPlus{
                                        Image(systemName: "lock")
                                            .framelessSectionTitle()
                                    }

                                    Text("More")
                                        .sectionTitle()
                                }
                                Menu {
                                    if !schedule_SingleDayMode{
                                        Section("Add for all Days in Week"){
                                            ForEach(weeks, id: \.self){ week in
                                                Button {
                                                    if let days = (week.days?.allObjects as? [Day])?.sorted(by: { $0.number < $1.number }) {
                                                        if let first = days.first {
                                                            currentSelectedDay = first
                                                            print("changed currently selected Day")
                                                        }
                                                        for day in days {

                                                            if currentSelectedDay != day{
                                                                if extraOccurances.count == 0{
                                                                    extraOccurances.append(OccuranceModel(week: week, day: day, start: startTime, end: endTime))
                                                                }
                                                                else{
                                                                    if let start = extraOccurances.last?.start, let end = extraOccurances.last?.end {
                                                                        extraOccurances.append(OccuranceModel(week: week, day: day, start: start, end: end))
                                                                    }
                                                                    else{
                                                                        extraOccurances.append(OccuranceModel(week: week, day: day, start: startTime, end: endTime))
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                } label: {
                                                    Label("Week \(week.number)", systemImage: "calendar")
                                                }

                                            }
                                        }




                                    }
                                } label: {
                                    ZStack{
                                        HStack(spacing: 0) {
                                            Image(systemName: "plus")
                                                .padding(.trailing, 8)


                                            VStack(alignment: .leading){
                                                Text("Add Occurrence")
                                                    .font(.body)
                                                    .foregroundColor(color2)
                                                if !schedule_SingleDayMode{
                                                    Text("Hold for more options")
                                                        .font(.caption)
                                                        .opacity(0.6)
                                                }
                                            }


                                            Spacer()

                                        }


                                        .font(Font.body.weight(.semibold))
                                        .foregroundColor(color2)
                                        .padding(.leading, 15)
                                        .padding(.trailing, 5)

                                    }
                                    .frame(minHeight:  60)

                                    .neoFieldCard(padding: 0, color: color2)
                                } primaryAction: {
                                    if extraOccurances.count == 0{
                                        extraOccurances.append(OccuranceModel(start: startTime, end: endTime))
                                    }
                                    else{
                                        if let start = extraOccurances.last?.start, let end = extraOccurances.last?.end {
                                            extraOccurances.append(OccuranceModel(start: start, end: end))
                                        }
                                        else{
                                            extraOccurances.append(OccuranceModel(start: startTime, end: endTime))
                                        }
                                    }
                                }
                                .opacity(kyoPlus_hasPlus ? 1.0 : 0.5)
                                .disabled(!kyoPlus_hasPlus)


                                if entity != nil{

                                    Menu {

                                        Button(action: {



                                            isLoadingAllSave = true // Show the progress view
                                            let originalClass = entity?.classEntity
                                            let dispatchGroup = DispatchGroup()
                                            var count = 0
                                            for timeSlot in timeslots {
                                                if timeSlot.classEntity != nil && timeSlot.classEntity == originalClass{
                                                    dispatchGroup.enter()

                                                    let dataFactory = knDataFactory()

                                                    dataFactory.updateTimeSlot(
                                                        timeSlot: timeSlot,
                                                        dayEntity: timeSlot.day!,
                                                        classEntity: selectedClass,
                                                        splitterEntity: selectedSplitter,
                                                        room: room,
                                                        teacher: selectedTeacher,
                                                        startTime: TimeFormatter.toDate(timeSlot.startTime!)!,
                                                        endTime: TimeFormatter.toDate(timeSlot.endTime!)!,
                                                        notes: (notes != "" ? notes : nil),
                                                        debug: true,
                                                        dispatchGroup: dispatchGroup
                                                    )

                                                    count = count + 1
                                                }
                                                else if timeSlot.splitterEntity != nil && timeSlot.splitterEntity == entity?.splitterEntity{
                                                    dispatchGroup.enter()

                                                    let dataFactory = knDataFactory()

                                                    dataFactory.updateTimeSlot(
                                                        timeSlot: timeSlot,
                                                        dayEntity: timeSlot.day!,
                                                        classEntity: selectedClass,
                                                        splitterEntity: selectedSplitter,
                                                        room: room,
                                                        teacher: selectedTeacher,
                                                        startTime: TimeFormatter.toDate(timeSlot.startTime!)!,
                                                        endTime: TimeFormatter.toDate(timeSlot.endTime!)!,
                                                        notes: (notes != "" ? notes : nil),
                                                        debug: true,
                                                        dispatchGroup: dispatchGroup
                                                    )

                                                    count = count + 1
                                                }
                                            }

                                            dispatchGroup.wait() // Wait for all tasks to complete
#if !os(macOS)
                                            UIApplication.shared.inAppNotification(adaptForDynamicIsland: true, timeout: 7, swipeToClose: true, tint: .accentColor) { Bool in
                                                UpdatedEntryNotification(viewContext: viewContext, timeout: 7, color: .accentColor, count: count)
                                            }
                                            #endif

                                            isLoadingAllSave = false // Hide the progress view
                                            dismiss()

                                        }
                                        ) {
                                            Text("Apply edits universally")
                                        }

                                        Button(action: {



                                            isLoadingAllSave = true // Show the progress view
                                            let originalClass = entity?.classEntity
                                            let dispatchGroup = DispatchGroup()
                                            var count = 0
                                            for timeSlot in timeslots {
                                                if timeSlot.classEntity != nil && timeSlot.classEntity == originalClass{
                                                    dispatchGroup.enter()

                                                    let dataFactory = knDataFactory()

                                                    dataFactory.updateTimeSlot(
                                                        timeSlot: timeSlot,
                                                        dayEntity: timeSlot.day!,
                                                        classEntity: selectedClass,
                                                        splitterEntity: selectedSplitter,
                                                        room: timeSlot.room ?? "",
                                                        teacher: selectedTeacher,
                                                        startTime: TimeFormatter.toDate(timeSlot.startTime!)!,
                                                        endTime: TimeFormatter.toDate(timeSlot.endTime!)!,
                                                        notes: (notes != "" ? notes : nil),
                                                        debug: true,
                                                        dispatchGroup: dispatchGroup
                                                    )

                                                    count = count + 1
                                                }
                                                else if timeSlot.splitterEntity != nil && timeSlot.splitterEntity == entity?.splitterEntity{
                                                    dispatchGroup.enter()

                                                    let dataFactory = knDataFactory()

                                                    dataFactory.updateTimeSlot(
                                                        timeSlot: timeSlot,
                                                        dayEntity: timeSlot.day!,
                                                        classEntity: selectedClass,
                                                        splitterEntity: selectedSplitter,
                                                        room: room,
                                                        teacher: selectedTeacher,
                                                        startTime: TimeFormatter.toDate(timeSlot.startTime!)!,
                                                        endTime: TimeFormatter.toDate(timeSlot.endTime!)!,
                                                        notes: (notes != "" ? notes : nil),
                                                        debug: true,
                                                        dispatchGroup: dispatchGroup
                                                    )

                                                    count = count + 1
                                                }
                                            }

                                            dispatchGroup.wait() // Wait for all tasks to complete
#if !os(macOS)
                                            UIApplication.shared.inAppNotification(adaptForDynamicIsland: true, timeout: 7, swipeToClose: true, tint: .accentColor) { Bool in
                                                UpdatedEntryNotification(viewContext: viewContext, timeout: 7, color: .accentColor, count: count)
                                            }
                                            #endif

                                            isLoadingAllSave = false // Hide the progress view
                                            dismiss()

                                        }
                                        ) {
                                            Text("Apply edits universally")
                                            Text("Excluding Room")
                                        }
                                    } label: {
                                        ZStack{
                                            HStack(spacing: 0) {
                                                Image(systemName: "pencil")
                                                    .padding(.trailing, 8)
                                                VStack(alignment: .leading){
                                                    Text("Apply edits universally")
                                                        .font(.body)
                                                        .foregroundColor(color2)

                                                    Text("Except for Week, Day and Time")
                                                        .font(.caption)
                                                        .opacity(0.6)
                                                }
                                                Spacer()

                                                if isLoadingAllSave{
                                                    ProgressView()

                                                }

                                            }


                                            .font(Font.body.weight(.semibold))
                                            .foregroundColor(color2)
                                            .padding(.leading, 15)
                                            .padding(.trailing, 10)

                                        }
                                        .frame(minHeight:  60)

                                        .neoFieldCard(padding: 0, color: color2)
                                    }
                                    .opacity(kyoPlus_hasPlus ? 1.0 : 0.5)
                                    .disabled(!kyoPlus_hasPlus)




                                }
                            }
                            .padding(.horizontal, 20)

                            if let entity{

                                Text("Danger Zone")
                                    .textCase(.uppercase)
                                    .sectionTitle(bottomPadding: 2)
                                    .padding(.horizontal, 20)
                                Menu(content: {
                                    Button(role: .destructive) {
                                        //    viewContext.delete(timeSlot)
                                        // remove from classes!!

                                        if let classEntity = entity.classEntity{
                                            classEntity.removeFromTimeSlot(entity)
                                            print("remove from classes")
                                        }
                                        if let splitterEntity = entity.splitterEntity{
                                            splitterEntity.removeFromTimeSlot(entity)
                                            print("remove from splitters")
                                        }
                                        if let day = entity.day{
                                            day.removeFromTimeSlots(entity)
                                            print("remove from day")
                                        }

                                        withAnimation(.smooth){
                                            viewContext.delete(entity)
                //                            do {
                //                                try viewContext.save()
                //                                print("deleted week entry")
                //                            } catch {
                //                                let nsError = error as NSError
                //                                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                //                            }
                #if !os(macOS)
                                            UIApplication.shared.inAppNotification(adaptForDynamicIsland: true, timeout: 5, swipeToClose: true, tint: .red) { Bool in
                                                DeletedEntryNotification(viewContext: viewContext, timeout: 5, color: .red)
                                            }
                                            #endif
                                        }

                                        dismiss()
                                                } label: {
                                        Label("Delete", systemImage: "trash.fill")
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    Button {

                                    } label: {
                                        Text("Cancel")
                                    }

                                }, label: {

                                    Label("Delete", systemImage: "trash.fill")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                })
                                .menuStyle(regularNeoMenu(role: .destructive))
                                .padding(.horizontal, 20)
                            }



                        }

                        .animation(.smoothCard, value: focusedField)
                    }



                }
#if !os(visionOS)
                .scrollDismissesKeyboard(.interactively)
#endif
                .coordinateSpace(name: "scroll")

#if os(iOS)

                .safeAreaInset(edge: .top, content: {
                    Color.clear.frame(height: horizontalSizeClass == .compact ? 95 : 50)
                })
                .safeAreaInset(edge: .bottom, content: {
                    Color.clear.frame(height: 30)
                })

#else

#endif
                .alert("Hold on", isPresented: $cancelAlert) {
                    Button(role: .destructive) {
                        dismiss()
                    } label: {
                        Text("Discard")
                    }
                    Button {
                        cancelAlert.toggle()
                    } label: {
                        Text("Keep Editing")
                    }

                } message: {
                    Text(entity == nil ?  "Are you sure you want to discard this draft?" : "Are you sure you want to discard your changes?" )
                }

            }
        }

        .animation(.bouncy(duration: 0.35), value: isKeyboardVisible)
        .animation(.smoothCard, value: extraOccurances.count)
        .animation(.smoothCard, value: selectedClass)
        .animation(.smoothCard, value: selectedSplitter)
        .onAppear{
            for week in weeks {
                if week.id?.uuidString == schedule_SelectedWeekID{
                    currentschedule_SelectedWeek = week

                    weekHasBeenSelected = true
                }
            }
            for day in days {

                if let dayWeekNumber = day.week?.id?.uuidString, let schedule_SelectedDayID = schedule_SelectedDayID, day.id == UUID(uuidString: schedule_SelectedDayID) && dayWeekNumber == schedule_SelectedWeekID{
                    currentSelectedDay = day
                    dayHasBeenSelected = true
                }
            }


        }
        .amethystNavigationBar(title: editMode ? "Edit Entry" : "New Entry", titleColor: .primary,   tintColor: color1, compactMode: true, overrideType: .regular, scrolled: $scrolled, inSheet: true) {
            navBarContent
#if os(iOS)
                .padding(.trailing, -5)
                .padding(.top, 15)
#endif
        }toolbar: {

            let condition = entity == nil ? (selectedClass != nil || selectedSplitter != nil || room != "" || selectedTeacher != nil) : selectedClass != entity?.classEntity || selectedSplitter != entity?.splitterEntity || selectedTeacher != entity?.taughtBy
            Button {
                if condition || selectedTeacher != nil{
                    cancelAlert.toggle()
                }
                else{
                    dismiss()
                }
            } label: {

                Text(condition ? "Discard" : "Cancel")
                    .foregroundColor(scrolled ? .primary : color2)
                    .font(.body.weight(.regular))


                    .scaledFrame(width: nil, height: 42, relativeTo: .body, alignment: .leading)
                //  .neoNavigationButtonStyle(cornerRadius: 14, color: color)
            }.buttonStyle(borderlessButton(color: color2, scrolled: $scrolled))

                .scaledFrame(width: nil, height: 42, relativeTo: .body, alignment: .leading)
#if os(iOS)
                .padding(.top, 15)
#endif
        }
    }

    var multiOccurnceView: some View {
        VStack(spacing: 10){


            ForEach(extraOccurances.indices, id: \.self) { index in
                let occurrence = extraOccurances[index]
                VStack(){
                    HStack{
                        Text("Occurance \(index + 2)")
                            .sectionTitle()
                        if schedule_SingleDayMode{
                            Button {
                                extraOccurances.remove(at: index)
                            } label: {
                                Image(systemName: "minus.circle")
                                    .padding(.trailing, 13)
                                    .foregroundColor(color1)
                            }
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                    }
                    .padding(.vertical, 3)


                    if !schedule_SingleDayMode{
                        HStack{

                            Menu {
                                ForEach(weeks, id: \.id) { week in

                                    Menu {
                                        if let days = (week.days?.allObjects as? [Day])?.sorted(by: { $0.number < $1.number }) {
                                            ForEach(days, id: \.id) { day in
                                                Button {
                                                    extraOccurances[index].week = week
                                                    extraOccurances[index].day = day
                                                } label: {
                                                    Text("\(day.name ?? "Unknown Day")")
                                                }
                                            }
                                        }
                                    } label: {
                                        Text("Week \(week.number)")
                                    }
                                }
                                Divider()
                                Button {
                                    showWeekCreate.toggle()
                                } label: {
                                    Text("Edit Weeks")
                                    Image(systemName: "plus")
                                }
                            } label: {
                                HStack(spacing: 0) {
                                    Image(systemName: "calendar.day.timeline.leading")
                                        .font(Font.body.weight(.semibold))
                                        .foregroundColor(color1)
                                        .padding(.leading, 13)
                                        .padding(.trailing, 5)
                                    if let week = extraOccurances[index].week{
                                        Text("Week \(extraOccurances[index].week?.number ?? 0), \(extraOccurances[index].day?.name ?? "")")
                                            .foregroundColor(color1)
                                            .autocapitalization(.none)
                                            .textContentType(.name)
                                    }
                                    else{
                                        Text("Select Week & Day")
                                            .foregroundColor(color1)
                                            .autocapitalization(.none)
                                            .textContentType(.name)
                                    }

                                    Spacer()



                                }
                                .padding(.vertical, 15)
                            }
                            Button {
                                extraOccurances.remove(at: index)
                            } label: {
                                Image(systemName: "minus.circle")
                                    .padding(.trailing, 13)
                                    .foregroundColor(color1)
                            }
                        }
                        .neoFieldCard(padding: 0, color: color1)
                    }


                }
                extraOccuranceTime(occurance: occurrence, color1: color1, color2: color2, index: index, occurancedArray: $extraOccurances, selectedSplitter: $selectedSplitter)
            }
        }.padding(.horizontal, 20)

    }


    var preview: some View {
        VStack{
            if let prop = selectedClass{
                Text("Preview")
                    .sectionTitle()

                EntryTemplate(title: prop.name ?? "Untitled", room: room, start: TimeFormatter.getTimeString(startTime), end: TimeFormatter.getTimeString(endTime), color1: Color(hex: prop.color1 ?? "#85A2EC"), color2: Color(hex: prop.color2 ?? "#85A2EC"), idle: true, currentState: .upcoming)
                    .padding(.bottom, 5)
            }
        }
    }

    var typeSelector: some View{
        VStack{


            //            let color2 = Color.getAdjustedColor(color: selectedClass != nil ? Color(hex: (selectedClass?.color2 ?? color2.hexString) ?? "#85A2EC" ) : Color(hex: (selectedSplitter?.color2 ?? color2.hexString) ?? "#85A2EC") , colorScheme: colorScheme)
            HStack {
                Text("Type")
                    .sectionTitle(topPadding: 0)
                Spacer()
#if !os(visionOS)
                if let name = selectedClass?.name ?? selectedSplitter?.name {
                    Button {

                        showClassEdit.toggle()


                    } label: {

                        Text("Edit \(name)")
                            .framelessSectionTitle(topPadding: 0)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .foregroundColor(color1)
                            .transition(.blur.animation(.smooth))
                    }

                }
#endif

            }.padding(.horizontal, 20)
            HStack{
                Menu {
                    Section(VariableDataNames().classesName()) {
                        Picker(VariableDataNames().classesName(), selection: $selectedClass) {

                            ForEach(classes, id: \.self) { c in
                                Label(c.name ?? "", systemImage: c.icon ?? "book.closed")
                                    .tag(c as ClassEntity?)
                            }
                        }

                    }
                    if splitters.count > 10{

                        Section("Splits"){
                            Picker("Splits", selection: $selectedSplitter) {

                                ForEach(splitters, id: \.self) { s in
                                    Text(s.name ?? "")
                                        .tag(s as SplitterEntity?)
                                }
                            }
                            .pickerStyle(.menu)
                        }

                    }
                    else{
                        Section("Splits"){
                            Picker("Splits", selection: $selectedSplitter) {

                                ForEach(splitters, id: \.self) { s in
                                    Text(s.name ?? "")
                                        .tag(s as SplitterEntity?)
                                }
                            }
                        }
                    }
                    Button {
                        showClassCreate.toggle()
                    } label: {
                        Text(VariableDataNames().newClassName())
                        Image(systemName: "plus")
                    }



                } label: {

                    HStack(spacing: 0) {
                        Image(systemName: selectedType == .classes ? (selectedClass?.icon ?? "book.closed") : "character.cursor.ibeam")

                            .font(Font.body.weight(.semibold))

                            .frame(width: 20, height: 15)

#if !os(visionOS)
                            .padding(.leading, 13)
                            .foregroundColor(color1)
#endif
                            .padding(.trailing, 5)
                        if let c = selectedClass{
                            Text(c.name ?? "No Name")

                                .lineLimit(1)
                                .foregroundColor(color1)
                        }
                        else if let s = selectedSplitter{
                            Text(s.name ?? "No Name")

                                .lineLimit(1)

#if !os(visionOS)
                                .foregroundColor(color1)
#endif
                        }
                        else{
                            Text("Select Type")

                                .lineLimit(1)

#if !os(visionOS)
                                .foregroundColor(color1)
#endif
                        }

                        Spacer()
                    }
#if !os(visionOS)
                    .neoFieldCard(color: color1)
#else
                    .padding(.vertical, 14)

#endif
                }
#if os(visionOS)
                if let name = selectedClass?.name ?? selectedSplitter?.name {
                    Button {

                        showClassEdit.toggle()


                    } label: {

                        Text("Edit \(name)")
                            .foregroundColor(color1)
                            .transition(.blur.animation(.smooth))
                            .padding(.vertical, 13)
                    }

                }
#endif
            }
            .padding(.horizontal, 20)
#if !os(visionOS)
            .onChange(of: selectedClass) { new in
                if let selectedClass = selectedClass, let selectedClassColor1 = selectedClass.color1,  let selectedClassColor2 = selectedClass.color2{
                    selectedSplitter = nil

                    color1 = colorScheme == .light ? Color(hex: selectedClassColor1).getBrightness() > 0.73 ? Color(hex: selectedClassColor1).darken(by: 0.4) : Color(hex: selectedClassColor1) : Color(hex: selectedClassColor1)
                    color2 = colorScheme == .light ? Color(hex: selectedClassColor2).getBrightness() > 0.73 ? Color(hex: selectedClassColor2).darken(by: 0.4) : Color(hex: selectedClassColor2) : Color(hex: selectedClassColor2)
                }

            }
            .onChange(of: selectedSplitter) { new in
                if let selectedSplitter = selectedSplitter, let selectedSplitterColor1 = selectedSplitter.color1, let selectedSplitterColor2 = selectedSplitter.color2{
                    selectedClass = nil

                    color1 = colorScheme == .light ? Color(hex: selectedSplitterColor1).getBrightness() > 0.73 ? Color(hex: selectedSplitterColor1).darken(by: 0.4) : Color(hex: selectedSplitterColor1) : Color(hex: selectedSplitterColor1)
                    color2 = colorScheme == .light ? Color(hex: selectedSplitterColor2).getBrightness() > 0.73 ? Color(hex: selectedSplitterColor2).darken(by: 0.4) : Color(hex: selectedSplitterColor2) : Color(hex: selectedSplitterColor2)
                }
            }
#endif
        }
    }

    var roomField: some View{
        VStack{
            HStack {
                Text("Room/Link")
                    .sectionTitle(horizontalPadding: 0)
                Spacer()
                Text("Optional")
                    .foregroundColor(color2)
                    .font(.caption)
                    .padding(.bottom, 6)
                    .padding(.top, 8)
                    .padding(.vertical,  3)


            }



            HStack(spacing: 0) {
                Image(systemName: "square.split.bottomrightquarter")


                    .font(Font.body.weight(.semibold))
                    .foregroundColor(color2)
#if !os(visionOS)
                    .padding(.leading, 13)
#else
                    .padding(.leading, 20)
#endif

                    .padding(.trailing, 5)
                TextField("Room number, name or a link", text: $room)
                // .focused($focusedField, equals: .room)

#if os(iOS) || os(visionOS)
                    .textContentType(.name)
                    .keyboardType(.asciiCapable)
#endif

                    .autocorrectionDisabled(true)
            }
#if !os(visionOS)
            .neoFieldCard(color: color2)
#else
            .padding(.vertical, 13.5)
            .background(Color.white.opacity(0.3))
            .clipShape(Capsule())
#endif
        }
        .padding(.horizontal, 20)
    }

    var teacherField: some View{
        VStack{
            HStack {
                if !kyoPlus_hasPlus{
                    Image(systemName: "lock")
                        .framelessSectionTitle()
                }
                Text("Teacher")
                    .sectionTitle(horizontalPadding: 0)
                Spacer()
                Text("Optional")
                    .foregroundColor(color2)
                    .font(.caption)
                    .padding(.bottom, 6)
                    .padding(.top, 8)
                    .padding(.vertical,  3)


            }

            Menu {


                Section("Teacher") {


                    Picker("Teachers", selection: $selectedTeacher) {

                        Text("None")
                            .tag(nil as TeacherEntity?)

                        ForEach(teachers, id: \.self) { c in
                            Label(c.name ?? "", systemImage: kyoPlus_hasPlus ? "person" : "lock")
                                .tag(c as TeacherEntity?)


                        }
                    }
                    .disabled(!kyoPlus_hasPlus)

                }
                Button {
                    teacherEdit.toggle()
                } label: {
                    Text("Edit")
                    Image(systemName: "pencil")
                }
                .disabled(!kyoPlus_hasPlus)
                Button {
                    isAlertTeacherPresented.toggle()
                } label: {
                    Text("Add Teacher")
                    Image(systemName: "plus")
                }
                .disabled(!kyoPlus_hasPlus)





            } label: {

                HStack(spacing: 0) {
                    Image(systemName: "person")

                        .font(Font.body.weight(.semibold))


                        .frame(width: 20, height: 15)

#if !os(visionOS)
                        .padding(.leading, 13)
#else

#endif
                        .padding(.trailing, 5)
                    if let t = selectedTeacher{
                        Text(t.name ?? "No Name")

                            .lineLimit(1)

                    }
                    else{
                        Text("Select Teacher")

                            .lineLimit(1)

                    }

                    Spacer()
                }
#if !os(visionOS)
                .neoFieldCard(color: color1)
                .foregroundColor(color1)
#else
                .padding(.vertical, 15)
#endif
                .opacity(kyoPlus_hasPlus ? 1.0 : 0.5)

            }
        }
        .padding(.horizontal, 20)
        .onAppear{

            // FIX: No purchase check or access-state write is needed; Kyo+ is permanently unlocked.

        }

        .alert("Teacher", isPresented: $isAlertTeacherPresented) {
            TextField("Enter Teacher name", text: $teacherNameAdd)
            Button("Add",action: {
                let newTeacher = TeacherEntity(context: viewContext)
                newTeacher.id = UUID()
                newTeacher.name = teacherNameAdd

                do {
                    try viewContext.save()
                } catch {
                    let nsError = error as NSError
                    fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                }
                selectedTeacher = newTeacher
            })
            Button("Cancel", role: .cancel) { }

        }
    }

    var dateSelector: some View{
        HStack(spacing: 15){


            VStack(alignment: .leading){
                HStack {
                    Text(extraOccurances.count == 0 ? weeks.count != 1 ? "Week & Day" : "Day" : "Primary Occurance")
                        .font(.caption)
                        .padding(.bottom, 6)
                        .padding(.top, 8)
                        .padding(.vertical,  3)

                    Spacer()


                }

                VStack(spacing: 0) {
                    Menu {
                        if  weeks.count != 1{
                            ForEach(weeks, id: \.self){ week in

                                Menu {

                                    filteredDays(filter: week.number, selectedDay: $currentSelectedDay, schedule_SelectedWeek: $currentschedule_SelectedWeek, weekHasBeenSelected: $weekHasBeenSelected, week: week)


                                } label: {
                                    Text("Week \(week.number)")

                                }



                            }
                        }
                        else{
                            if let week = weeks.first{
                                filteredDays(filter: week.number, selectedDay: $currentSelectedDay, schedule_SelectedWeek: $currentschedule_SelectedWeek, weekHasBeenSelected: $weekHasBeenSelected, week: week)
                            }
                        }
                        Divider()



                        Button {
                            showWeekCreate.toggle()
                        } label: {
                            Text("Edit Weeks")
                            Image(systemName: "pencil")
                        }
                    } label: {

                        HStack(spacing: 0) {
                            Image(systemName: "calendar.day.timeline.leading")

                                .font(Font.body.weight(.semibold))
#if !os(visionOS)
                                .padding(.leading, 13)
#endif
                                .padding(.trailing, 5)
                            if let schedule_SelectedWeek = currentschedule_SelectedWeek?.number, let selectedDay = currentSelectedDay?.name{
                                Text("\(weeks.count != 1 ? "Week \(Int(schedule_SelectedWeek)), " : "")\(selectedDay)")
                            }
                            else{
                                Text("Select")
                            }
                            Spacer()
                        }
                        .padding(.vertical, 15)

                    }
                }
#if !os(visionOS)
                .neoFieldCard(padding: 0, color: color1)

                .foregroundColor(color2)
#endif

            }

        }
        .padding(.horizontal, 20)
    }

    var timeSelector: some View{
#if os(iOS)
        VStack{


            if extraOccurances.count == 0{
                HStack{
                    Text("Times")
                        .sectionTitle()
                    Group{
                        if !hasTimeBeenUserEdited{
                            Text(Image(systemName: "sparkles"))
                            +
                            Text(" Automatically Set")
                        }
                        else{
                            Menu {
                                Button("Automatically Set", systemImage: "sparkles", action:
                                        {
                                    hasTimeBeenUserEdited = false

                                    if selectedClass != nil{
                                        if let schedule_SelectedDayID = schedule_SelectedDayID, let schedule_SelectedWeekID = schedule_SelectedWeekID, let startCalc = timeSlotTimesHandler().getRecomendedStart(dayID: schedule_SelectedDayID, weekID: schedule_SelectedWeekID), let start = TimeFormatter.toDate(startCalc, mode: .time){
                                            print("set time start to \(start)!")
                                            startTime = start
                                            endTime = Calendar.current.date(byAdding: .minute, value: Int(lastClassDuration * 60), to: start)!
                                        }
                                    }
                                    else if selectedSplitter != nil{
                                        if let schedule_SelectedDayID = schedule_SelectedDayID, let schedule_SelectedWeekID = schedule_SelectedWeekID, let startCalc = timeSlotTimesHandler().getRecomendedStart(dayID: schedule_SelectedDayID, weekID: schedule_SelectedWeekID), let start = TimeFormatter.toDate(startCalc, mode: .time){
                                            print("set time start to \(start)!")
                                            startTime = start
                                            endTime = Calendar.current.date(byAdding: .minute, value: Int(lastSplitDuration * 60), to: start)!
                                        }
                                    }
                                    else{
                                        if let schedule_SelectedDayID = schedule_SelectedDayID, let schedule_SelectedWeekID = schedule_SelectedWeekID, let startCalc = timeSlotTimesHandler().getRecomendedStart(dayID: schedule_SelectedDayID, weekID: schedule_SelectedWeekID), let start = TimeFormatter.toDate(startCalc, mode: .time){
                                            print("set time start to \(start)!")
                                            startTime = start
                                            endTime = Calendar.current.date(byAdding: .minute, value: Int(lastClassDuration * 60), to: start)!
                                        }
                                    }


                                }

                                )
                                .labelStyle(.iconOnly)
                            } label: {
                                Text("Manual")
                            }
                        }
                    }
                    .transition(.blur.animation(.smooth))
                    .framelessSectionTitle()
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .foregroundStyle(color2)
                    .opacity(0.8)
                }

            }
            VStack(spacing: 15) {
                Button {
                    if horizontalSizeClass == .compact{
                        hasTimeBeenUserEdited = true
                    }
                    else{
                        showsPopoverStart = true
                    }
#if os(visionOS)
                    showsPopoverStart = true
#endif
                } label: {
                    if horizontalSizeClass == .compact{
                        SegmentedTime(selectedDate: $startTime, title: "Start", color: color1)
#if !os(visionOS)
                            .overlay(
                                DatePicker("Start", selection: $startTime, displayedComponents: .hourAndMinute)
                                    .scaleEffect(x: 6, y: 2.63)
                                    .labelsHidden()
                                    .blendMode(.destinationOver)
                            )
#else
                            .popover(isPresented: $showsPopoverStart, content: {
                                DatePicker("Start", selection: $startTime, displayedComponents: .hourAndMinute)
                                    .datePickerStyle(.wheel)

                                    .labelsHidden()
                                    .frame(width: 250, height: 200)
                                    .padding()

                            })
#endif
                    }
                    else{
                        SegmentedTime(selectedDate: $startTime, title: "Start", color: color1)
                            .popover(isPresented: $showsPopoverStart, content: {
                                DatePicker("Start", selection: $startTime, displayedComponents: .hourAndMinute)
                                    .datePickerStyle(.wheel)

                                    .labelsHidden()
                                    .frame(width: 250, height: 200)
                                    .padding()

                            })
                    }

                }
                .buttonStyle(bounceButton())


                Button {
                    hasTimeBeenUserEdited = true
#if os(visionOS)
                    showsPopoverEnd = true
#endif
                } label: {
                    SegmentedTime(selectedDate: $endTime, title: "End", color: color2)
#if !os(visionOS)
                        .overlay(
                            DatePicker("End", selection: $endTime, in: Calendar.current.date(byAdding: .minute, value: Int(5), to: startTime)!..., displayedComponents: .hourAndMinute)
                                .scaleEffect(x: 6, y: 2.63)
                                .labelsHidden()
                                .blendMode(.destinationOver)
                        )
#else
                        .popover(isPresented: $showsPopoverEnd, content: {
                            DatePicker("Start", selection: $endTime, displayedComponents: .hourAndMinute)
                                .datePickerStyle(.wheel)

                                .labelsHidden()
                                .frame(width: 250, height: 200)
                                .padding()

                        })
#endif

                }
                .buttonStyle(bounceButton())
                .onChange(of: startTime) { change in
                    if change > endTime{
                        if selectedSplitter != nil{
                            endTime = Calendar.current.date(byAdding: .minute, value: Int(lastSplitDuration * 60), to: startTime)!
                        }
                        else{
                            endTime = Calendar.current.date(byAdding: .minute, value: Int(lastClassDuration * 60), to: startTime)!
                        }

                    }
                }


                //                    .onChange(of: startTime){ change in
                //                        if !systemEditingTime{
                //                            hasTimeBeenUserEdited = true
                //                            print("AAAA")
                //                        }
                //                    }
                //                    .onChange(of: endTime){ change in
                //                        if showsPopoverStart || showsPopoverEnd{
                //                            hasTimeBeenUserEdited = true
                //                        }
                //                    }

            }

        }
        .padding(.horizontal, 20)
        .padding(.top, extraOccurances.count == 0 ? 0 : 3)


        //        .padding(.vertical, (showsPopoverStart || showsPopoverEnd) && isKeyboardVisible ? -300 : 5)

        .onReceive(keyboardPublisher) { newIsKeyboardVisible in
            print("Is keyboard visible? ", newIsKeyboardVisible)
            isKeyboardVisible = newIsKeyboardVisible
        }
#else
        VStack{


            if extraOccurances.count == 0{
                HStack{
                    Text("Times")
                        .sectionTitle()
                    Group{
                        if !hasTimeBeenUserEdited{
                            Text(Image(systemName: "sparkles"))
                            +
                            Text(" Automatically Set")
                        }
                        else{
                            Menu {
                                Button("Automatically Set", systemImage: "sparkles", action:
                                        {
                                    hasTimeBeenUserEdited = false

                                    if selectedClass != nil{
                                        if let schedule_SelectedDayID = schedule_SelectedDayID, let schedule_SelectedWeekID = schedule_SelectedWeekID, let startCalc = timeSlotTimesHandler().getRecomendedStart(dayID: schedule_SelectedDayID, weekID: schedule_SelectedWeekID), let start = TimeFormatter.toDate(startCalc, mode: .time){
                                            print("set time start to \(start)!")
                                            startTime = start
                                            endTime = Calendar.current.date(byAdding: .minute, value: Int(lastClassDuration * 60), to: start)!
                                        }
                                    }
                                    else if selectedSplitter != nil{
                                        if let schedule_SelectedDayID = schedule_SelectedDayID, let schedule_SelectedWeekID = schedule_SelectedWeekID, let startCalc = timeSlotTimesHandler().getRecomendedStart(dayID: schedule_SelectedDayID, weekID: schedule_SelectedWeekID), let start = TimeFormatter.toDate(startCalc, mode: .time){
                                            print("set time start to \(start)!")
                                            startTime = start
                                            endTime = Calendar.current.date(byAdding: .minute, value: Int(lastSplitDuration * 60), to: start)!
                                        }
                                    }
                                    else{
                                        if let schedule_SelectedDayID = schedule_SelectedDayID, let schedule_SelectedWeekID = schedule_SelectedWeekID, let startCalc = timeSlotTimesHandler().getRecomendedStart(dayID: schedule_SelectedDayID, weekID: schedule_SelectedWeekID), let start = TimeFormatter.toDate(startCalc, mode: .time){
                                            print("set time start to \(start)!")
                                            startTime = start
                                            endTime = Calendar.current.date(byAdding: .minute, value: Int(lastClassDuration * 60), to: start)!
                                        }
                                    }


                                }

                                )
                                .labelStyle(.iconOnly)
                            } label: {
                                Text("Manual")

                            }



                        }
                    }
                    .transition(.blur.animation(.smooth))
                    .framelessSectionTitle()
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .foregroundStyle(color2)
                    .opacity(0.8)
                }

            }
            HStack(spacing: 15) {
                Button {
                    hasTimeBeenUserEdited = true
#if os(visionOS)
                    showsPopoverStart = true
#endif
                } label: {
                    SegmentedTime(selectedDate: $startTime, title: "Start", color: color1)
#if !os(visionOS)
                        .overlay(
                            DatePicker("Start", selection: $startTime, displayedComponents: .hourAndMinute)
                                .scaleEffect(x: 6, y: 2.63)
                                .labelsHidden()
                                .blendMode(.destinationOver)
                        )
#else
                        .popover(isPresented: $showsPopoverStart, content: {
                            DatePicker("Start", selection: $startTime, displayedComponents: .hourAndMinute)
                                .datePickerStyle(.wheel)

                                .labelsHidden()
                                .frame(width: 250, height: 200)
                                .padding()

                        })
#endif
                }
                .buttonStyle(bounceButton())


                Button {
                    hasTimeBeenUserEdited = true
#if os(visionOS)
                    showsPopoverEnd = true
#endif
                } label: {
                    SegmentedTime(selectedDate: $endTime, title: "End", color: color2)
#if !os(visionOS)
                        .overlay(
                            DatePicker("End", selection: $endTime, in: Calendar.current.date(byAdding: .minute, value: Int(5), to: startTime)!..., displayedComponents: .hourAndMinute)
                                .scaleEffect(x: 6, y: 2.63)
                                .labelsHidden()
                                .blendMode(.destinationOver)
                        )
#else
                        .popover(isPresented: $showsPopoverEnd, content: {
                            DatePicker("Start", selection: $endTime, displayedComponents: .hourAndMinute)
                                .datePickerStyle(.wheel)

                                .labelsHidden()
                                .frame(width: 250, height: 200)
                                .padding()

                        })
#endif

                }
                .buttonStyle(bounceButton())
                .onChange(of: startTime) { change in
                    if change > endTime{
                        if selectedSplitter != nil{
                            endTime = Calendar.current.date(byAdding: .minute, value: Int(lastSplitDuration * 60), to: startTime)!
                        }
                        else{
                            endTime = Calendar.current.date(byAdding: .minute, value: Int(lastClassDuration * 60), to: startTime)!
                        }

                    }
                }


                //                    .onChange(of: startTime){ change in
                //                        if !systemEditingTime{
                //                            hasTimeBeenUserEdited = true
                //                            print("AAAA")
                //                        }
                //                    }
                //                    .onChange(of: endTime){ change in
                //                        if showsPopoverStart || showsPopoverEnd{
                //                            hasTimeBeenUserEdited = true
                //                        }
                //                    }

            }

        }
        .padding(.horizontal, 20)
        .padding(.top, extraOccurances.count == 0 ? 0 : 3)


        //        .padding(.vertical, (showsPopoverStart || showsPopoverEnd) && isKeyboardVisible ? -300 : 5)

        .onReceive(keyboardPublisher) { newIsKeyboardVisible in
            print("Is keyboard visible? ", newIsKeyboardVisible)
            isKeyboardVisible = newIsKeyboardVisible
        }
#endif
    }


    func getWidthDiv(date: Date) -> Double{
        var dateFormat = getsegmentedTimeFormat()
        var dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        var calc = dateFormatter.string(from: date)

        let characters = Array(calc)

        dateFormat = "a"
        dateFormatter.dateFormat = dateFormat
        let first = "\(characters[0])"
        if first == "0"{
            return 90
        }

        return 100
    }

    var navBarContent: some View{
        HStack(spacing: 13){

            //            Button {
            //
            //                dismiss()
            //            } label: {
            //
            //                Text("Cancel")
            //                    .foregroundColor(scrolled ? .primary : color2)
            //                    .font(.body.weight(.regular))
            //
            //                .scaledFrame(width: 70, height: 40, relativeTo: .body)
            //                //  .neoNavigationButtonStyle(cornerRadius: 14, color: color)
            //            }.buttonStyle(borderlessButton(color: color2, scrolled: $scrolled))


            Button {
#if !os(macOS)
                UIApplication.shared.inAppNotification(adaptForDynamicIsland: true, timeout: 1.5, swipeToClose: true, tint: color1) { Bool in
                    CreatedEntryNotification(viewContext: viewContext, timeout: 1.5, color: color1, update: entity != nil)
                        .padding(15)
                        .background {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(.black)
                        }
                }
                #endif
                if userFilledData(){
                    let dataFactory = knDataFactory()
                    if !editMode{
                        if !schedule_SingleDayMode{
                            lastClassDuration = differenceBetween(TimeFormatter.getTimeString(startTime), TimeFormatter.getTimeString(endTime))
                            if let currentSelectedDay = currentSelectedDay{
                                dataFactory.addTimeSlot(dayEntity: currentSelectedDay,
                                                        classEntity: selectedClass,
                                                        splitterEntity: selectedSplitter,
                                                        room: room,
                                                        teacher: selectedTeacher,
                                                        startTime: startTime,
                                                        endTime: endTime,
                                                        notes: (notes != "" ? notes : nil),
                                                        debug: true)
                            }
                            if extraOccurances.count != 0 {
                                for occurance in extraOccurances {
                                    if let day = occurance.day, let start = occurance.start, let end = occurance.end{
                                        dataFactory.addTimeSlot(dayEntity: day,
                                                                classEntity: selectedClass,
                                                                splitterEntity: selectedSplitter,
                                                                room: room,
                                                                teacher: selectedTeacher,
                                                                startTime: start,
                                                                endTime: end,
                                                                notes: (notes != "" ? notes : nil),
                                                                debug: true)
                                    }
                                }

                            }
                        }
                        else{
                            if let schedule_SelectedWeeks = singleDayweeks.filter({ week in
                                return week.singleDayWeek == true
                            }).first?.days?.allObjects as? [Day]{
                                if let day = schedule_SelectedWeeks.first{
                                    lastClassDuration = differenceBetween(TimeFormatter.getTimeString(startTime), TimeFormatter.getTimeString(endTime))
                                    dataFactory.addTimeSlot(dayEntity: day,
                                                            classEntity: selectedClass,
                                                            splitterEntity: selectedSplitter,
                                                            room: room,
                                                            teacher: selectedTeacher,
                                                            startTime: startTime,
                                                            endTime: endTime,
                                                            notes: (notes != "" ? notes : nil),
                                                            debug: true)
                                    if extraOccurances.count != 0 {
                                        for occurance in extraOccurances {
                                            if let start = occurance.start, let end = occurance.end{
                                                dataFactory.addTimeSlot(dayEntity: day,
                                                                        classEntity: selectedClass,
                                                                        splitterEntity: selectedSplitter,
                                                                        room: room,
                                                                        teacher: selectedTeacher,
                                                                        startTime: start,
                                                                        endTime: end,
                                                                        notes: (notes != "" ? notes : nil),
                                                                        debug: true)
                                            }
                                        }

                                    }
                                }
                                else{
                                    print("couldn't grab day")
                                }
                            }
                            else{
                                print("could not get array")
                            }
                        }
                    }
                    if editMode{

                        if !schedule_SingleDayMode{
                            dataFactory.updateTimeSlot(
                                timeSlot: entity,
                                dayEntity: currentSelectedDay!,
                                classEntity: selectedClass,
                                splitterEntity: selectedSplitter,
                                room: room,
                                teacher: selectedTeacher,
                                startTime: startTime,
                                endTime: endTime,
                                notes: (notes != "" ? notes : nil),
                                debug: true
                            )

                            if extraOccurances.count != 0 {
                                for occurance in extraOccurances {
                                    if let day = occurance.day, let start = occurance.start, let end = occurance.end{
                                        dataFactory.addTimeSlot(dayEntity: day,
                                                                classEntity: selectedClass,
                                                                splitterEntity: selectedSplitter,
                                                                room: room,
                                                                teacher: selectedTeacher,
                                                                startTime: start,
                                                                endTime: end,
                                                                notes: (notes != "" ? notes : nil),
                                                                debug: true)
                                    }
                                }

                            }
                        }
                        else{
                            if let schedule_SelectedWeeks = singleDayweeks.filter({ week in
                                return week.singleDayWeek == true
                            }).first?.days?.allObjects as? [Day]{

                                if let day = schedule_SelectedWeeks.first{
                                    dataFactory.updateTimeSlot(
                                        timeSlot: entity,
                                        dayEntity: day,
                                        classEntity: selectedClass,
                                        splitterEntity: selectedSplitter,
                                        room: room,
                                        teacher: selectedTeacher,
                                        startTime: startTime,
                                        endTime: endTime,
                                        notes: (notes != "" ? notes : nil),
                                        debug: true
                                    )

                                    if extraOccurances.count != 0 {
                                        for occurance in extraOccurances {
                                            if let start = occurance.start, let end = occurance.end{
                                                dataFactory.addTimeSlot(dayEntity: day,
                                                                        classEntity: selectedClass,
                                                                        splitterEntity: selectedSplitter,
                                                                        room: room,
                                                                        teacher: selectedTeacher,
                                                                        startTime: start,
                                                                        endTime: end,
                                                                        notes: (notes != "" ? notes : nil),
                                                                        debug: true)
                                            }
                                        }

                                    }
                                }
                            }

                        }
                    }
                    dismiss()
                }
                else{

                }
            } label: {
                Text(editMode ? extraOccurances.isEmpty ? "Save" : "Save & Create" : extraOccurances.isEmpty ? "Create" : "Create All")

#if os(iOS)
                    .font(.body.weight(.regular))

                    .scaledFrame(width: nil, height: 42, relativeTo: .body, alignment: .center)
                    .padding(.horizontal, 15)
#endif

            }
#if os(iOS)
            .buttonStyle(NavigationButton(color: color1, scrolled: $scrolled))
#endif


        }


    }


    private func userFilledData() -> Bool{

        if selectedClass != nil && (schedule_SingleDayMode ? true : currentschedule_SelectedWeek != nil){
            print("true")
            return true
        }
        else if selectedSplitter != nil && (schedule_SingleDayMode ? true : currentschedule_SelectedWeek != nil){
            print("true")
            return true
        }
        print("false")
        return false

    }

    private func addItem() {

        print("Create TimeSlot: Adding new TimeSlot entity")

        withAnimation {
            let item = TimeSlot(context: viewContext)
            item.id = UUID()
            item.day = currentSelectedDay
            item.classEntity = selectedClass
            item.room = room
            item.startTime = TimeFormatter.getTimeString(startTime)
            item.endTime = TimeFormatter.getTimeString(endTime)
            item.timestamp = TimeFormatter.toDate(TimeFormatter.getTimeString(startTime), mode: .time)
            selectedClass?.addToTimeSlot(item)
            currentSelectedDay!.addToTimeSlots(item)

            print("Create TimeSlot: New TimeSlot entity created with attributes: \(item)")

            do {
                try viewContext.save()
                print("Create TimeSlot: Changes saved to Core Data")
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func addSplitterItem() {
        let item = TimeSlot(context: viewContext)
        item.id = UUID()
        item.day = currentSelectedDay
        item.timestamp = TimeFormatter.toDate(TimeFormatter.getTimeString(startTime), mode: .time)
        item.startTime = TimeFormatter.getTimeString(startTime)
        item.endTime = TimeFormatter.getTimeString(endTime)
        item.splitterEntity = selectedSplitter
        currentSelectedDay!.addToTimeSlots(item)
        selectedSplitter?.addToTimeSlot(item)


        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }

    }

    private func updateItem() {

        withAnimation {

            for t in timeslots{
                if t ==  entity?.splitterEntity{
                    viewContext.delete(t)
                }
            }

            for c in classes{
                if c == entity?.classEntity{
                    if let itemToRemove = entity{
                        c.removeFromTimeSlot(itemToRemove)
                    }
                }
            }

            for s in splitters{
                if s == entity?.splitterEntity{
                    if let itemToRemove = entity{
                        s.removeFromTimeSlot(itemToRemove)
                    }
                }
            }

            if let item = entity {
                // If the entity exists, update its properties
                print("TimeSlotUpdate: Updating existing entity...")

                // Reset the entity's class and splitter
                item.classEntity = nil
                item.splitterEntity = nil
                print("TimeSlotUpdate: Reset class and splitter.")

                // Update the entity's day, room, start and end time, and timestamp
                item.day = currentSelectedDay
                item.room = room
                item.startTime = TimeFormatter.getTimeString(startTime)
                item.endTime = TimeFormatter.getTimeString(endTime)
                item.timestamp = TimeFormatter.toDate(TimeFormatter.getTimeString(startTime), mode: .time)

                // If a class was selected, add the entity to its time slot
                if let destinationClass = selectedClass {
                    item.classEntity = destinationClass
                    destinationClass.addToTimeSlot(item)
                    print("TimeSlotUpdate: Added to classes destination at \(destinationClass.name ?? "No name")")
                }else {
                    // If no splitter was selected, print a message indicating so
                    print("TimeSlotUpdate: No class selected.")
                }

                // If a splitter was selected, add the entity to its time slot
                if let destinationSplitter = selectedSplitter {
                    item.splitterEntity = destinationSplitter
                    destinationSplitter.addToTimeSlot(item)
                    print("TimeSlotUpdate: Added to splitter destination at \(destinationSplitter.name ?? "No name")")
                } else {
                    // If no splitter was selected, print a message indicating so
                    print("TimeSlotUpdate: No splitter selected.")
                }
            } else {
                // If the entity doesn't exist, print a message indicating so
                print("TimeSlotUpdate: Could not update entity.")
            }



            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }

        }
    }

    private func checkColor(color: String)-> Bool{
        if selectedType != .none{

            return Color(hex: color).isLight() ?? true
        }
        else{
            return false
        }
    }

    private func getPercent(color: String) -> Double{

        return Double(Color(hex: color).getBrightness()) * 0.2

    }
}




#elseif os(macOS) || os(visionOS)
struct TimeSlotWorkshop: View {
    var entity: TimeSlot?
    var classEntry = true
    /// Core Data
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "timestamp", ascending: true)]) var timeslots: FetchedResults<TimeSlot>
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)]) var classes: FetchedResults<ClassEntity>
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)]) var splitters: FetchedResults<SplitterEntity>
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)]) var teachers: FetchedResults<TeacherEntity>
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "number", ascending: true)],
                  predicate: NSPredicate(format: "singleDayWeek == nil OR singleDayWeek == %@", NSNumber(value: false))
    ) var weeks: FetchedResults<Week>


    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "number", ascending: true),
                                    // Add more sort descriptors if needed
                                   ],
                  predicate: NSPredicate(format: "singleDayWeek == %@", NSNumber(value: true))
    ) var singleDayweeks: FetchedResults<Week>
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "number", ascending: true)]) var days: FetchedResults<Day>
    @Environment(\.managedObjectContext) private var viewContext

    /// AppStorage
    @AppStorage("timeGap") var timeGap = 0
    @AppStorage("schedule_SelectedWeekID") var schedule_SelectedWeekID: String?
    @AppStorage("schedule_SelectedDayID") var schedule_SelectedDayID: String?

    /// scroll logic
    @State var scrolled: Bool = false
    @State var room = ""
    @State var teacherName = ""
    @State var showsPopoverStart = false
    @State var showsPopoverEnd = false
    @State var startTime: Date = Date()
    @State var endTime: Date = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
    @State var color1: Color = Color.accentColor
    @State var color2: Color = Color.accentColor

    /// text fields focus
    enum FocusField: Hashable {
        case name
        case room
        case teacherName
        case none
    }
    @FocusState private var focusedField: FocusField?

    @State private var isKeyboardVisible = false


    //classes logic
    @State var selectedClass: ClassEntity?

    //teacher logic
    @State var selectedTeacher: TeacherEntity?
    @State private var isAlertTeacherPresented = false
    @State var teacherNameAdd: String = ""

    //splitters logic
    @State var selectedSplitter: SplitterEntity?

    @State var teacherEdit: Bool = false

    //day logic
    @State var currentSelectedDay: Day = Day()
    @State var dayHasBeenSelected: Bool = false

    //week logic
    @State var currentschedule_SelectedWeek: Week?
    @State var weekHasBeenSelected: Bool = false

    //creation logic
    @State var selectedType: TimeSlotTypeModel = .none
    @State var editMode: Bool = false
    @State var ButtonText = "Select"
    @State var splitterName = "Select"

    func occuranceWeekBinding(occurance: OccuranceModel) -> Binding<Week?> {
        return Binding<Week?>(
            get: { occurance.week },
            set: { _ in }
        )
    }

    //screen logic
    @State var showColorEdit = false
    @State var showClassCreate = false
    @State var showClassEdit: Bool
    @State var showSplitterCreate = false
    @State var showWeekCreate = false
    @Environment(\.dismiss) var dismiss

    //colorScheme

    @Environment(\.colorScheme) var colorScheme

    @State var extraOccurances: [OccuranceModel] = []

    init(entity: TimeSlot? = nil, color1: Color = .white, color2: Color = .white){
        self._showClassEdit = .init(initialValue: false)

        if entity != nil{
            self.entity = entity
            self._editMode = .init(initialValue: true)

            if let entRoom = entity?.room{
                self._room = .init(initialValue: entRoom)
            }

            if let entTeacher = entity?.taughtBy{
                self._selectedTeacher = .init(initialValue: entTeacher)
            }

            if let entStartTime = entity?.startTime, let startDate = TimeFormatter.toDate(entStartTime) {
                self._startTime = .init(initialValue: startDate)
            }
            if let entEndTime = entity?.endTime, let endDate = TimeFormatter.toDate(entEndTime) {
                self._endTime = .init(initialValue: endDate)
            }

            if let day = entity?.day {
                self._currentSelectedDay = .init(initialValue: day)

            }

            if let week = entity?.day?.week {
                self._currentschedule_SelectedWeek = .init(initialValue: week)

            }

            if let classEn = entity?.classEntity, let classEnC1 = classEn.color1, let classEnC2 = classEn.color2{
                self._selectedClass = .init(initialValue: classEn)
                self._selectedType = .init(initialValue: .classes)

                self._color1 = .init(initialValue:  colorScheme == .light ?  Color(hex: classEnC1).getBrightness() > 0.73 ? Color(hex: classEnC1).darken(by: 0.4) : Color(hex: classEnC1) : Color(hex: classEnC1))
                self._color2 = .init(initialValue:  colorScheme == .light ? Color(hex: classEnC2).getBrightness() > 0.73 ? Color(hex: classEnC2).darken(by: 0.4) : Color(hex: classEnC2) : Color(hex: classEnC2))
            }
            if let splitter = entity?.splitterEntity, let splitterC1 = splitter.color1, let splitterC2 = splitter.color2{
                self._selectedSplitter = .init(initialValue: splitter)
                self._selectedType = .init(initialValue: .splitters)

                self._color1 = .init(initialValue: colorScheme == .light ?  Color(hex: splitterC1).getBrightness() > 0.73 ? Color(hex: splitterC1).darken(by: 0.4) : Color(hex: splitterC1): Color(hex: splitterC1))
                self._color2 = .init(initialValue: colorScheme == .light ?  Color(hex: splitterC2).getBrightness() > 0.73 ? Color(hex: splitterC2).darken(by: 0.4) : Color(hex: splitterC2) : Color(hex: splitterC2))
            }
        }
        else{


            print("ent is nill")
        }


    }

    init(color1: Color = .white, color2: Color = .white, startTime: Date, endTime: Date){

        self._showClassEdit = .init(initialValue: false)
        self._color1 = .init(initialValue: color1)
        self._color2 = .init(initialValue: color2)
        self._startTime = .init(initialValue: startTime)
        self._endTime = .init(initialValue: endTime)
        print("ent is nill")
    }

    var body: some View {
        ScrollView{
            VStack{
                typeSelector
                    .sheet(isPresented: $showClassEdit) {
                        EditClass(entity: selectedClass!, color1: color1, color2: color2, backButton: false)
                            .interactiveDismissDisabled()
                            .presentationCornerRadius(25)
                    }

                roomField
                    .sheet(isPresented: $showWeekCreate) {
                        WeekSlider(color: color1)
                            .presentationCornerRadius(25)
                    }
                teacherField
                    .sheet(isPresented: $teacherEdit) {
                        ManageTeachers(back: false, color: color1)
                            .presentationCornerRadius(25)
                    }

                dateSelector
                    .sheet(isPresented: $showClassCreate) {
                        ClassComposer(color1: color1, color2: color2, passThroughClass: $selectedClass)
                            .interactiveDismissDisabled()
                            .presentationCornerRadius(25)
                    }

                timeSelector
                    .zIndex(4)
                    .animation(.bouncy(duration: 0.45))

                if extraOccurances.count != 0{
                    multiOccurnceView.padding(.bottom, 3)

                }

                //
                //                VStack{
                //
                //                    Text("Notifications")
                //                        .sectionTitle()
                //                    Toggle(isOn: .constant(false)) {
                //                        HStack{
                //                            Image(systemName: "app.badge.fill")
                //                                .frame(width: 20, alignment: .center)
                //                                .symbolRenderingMode(/*@START_MENU_TOKEN@*/.hierarchical/*@END_MENU_TOKEN@*/)
                //                                .foregroundColor(color1)
                //
                //                            VStack(alignment: .leading, spacing: 3){
                //                                Text("Notification ")
                //                                    .frame(maxWidth: .infinity, alignment: .leading)
                //                                Text("You'll recieve notifications for this entry")
                //                                    .font(.caption).opacity(0.5)
                //                                    .offset(x: 1)
                //                            }
                //                        }
                //                    }
                //                    .padding(.horizontal, 13)
                //                    .tint(color1)
                //                    .opacity(0.5)
                //                    .neoFieldCard()
                //                    .disabled(true)
                //                }
                //                .padding(.horizontal, 20)
                if entity == nil{
                    VStack{
                        Text("More")
                            .sectionTitle()

                        Button {
                            if extraOccurances.count == 0{
                                extraOccurances.append(OccuranceModel(start: startTime, end: endTime))
                            }
                            else{
                                if let start = extraOccurances.last?.start, let end = extraOccurances.last?.end {
                                    extraOccurances.append(OccuranceModel(start: start, end: end))
                                }
                                else{
                                    extraOccurances.append(OccuranceModel(start: startTime, end: endTime))
                                }
                            }

                        } label: {
                            ZStack{
                                HStack(spacing: 0) {
                                    Image(systemName: "plus")
                                        .padding(.trailing, 8)
                                    Text("Add Occurance")
                                        .font(.body)
                                        .foregroundColor(color2)
#if os(iOS) || os(visionOS)
                                        .autocapitalization(.none)
                                        .textContentType(.name)
#endif
                                    Spacer()

                                }


                                .font(Font.body.weight(.semibold))
                                .foregroundColor(color2)
                                .padding(.leading, 15)
                                .padding(.trailing, 5)

                            }
                        }
                        .buttonStyle(regularOutlineMenu(color: color1))
                    }
                    .padding(.horizontal, 20)
                }
                if let entity = entity{

                    Text("Danger Zone")  // Displaying the text "Days"
                        .textCase(.uppercase)  // Setting the text case to uppercase
                        .sectionTitle(bottomPadding: 2)  // Applying a section title style with a bottom padding of 2
                        .padding(.horizontal, 20)
                    Menu(content: {
                        Button(role: .destructive) {
                            
                            dismiss()
                        } label: {
                            Label("Delete", systemImage: "trash.fill")
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        Button {

                        } label: {
                            Text("Cancel")
                        }

                    }, label: {

                        Label("Delete", systemImage: "trash.fill")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    })
                    .menuStyle(regularNeoMenu(role: .destructive))
                    .padding(.horizontal, 20)
                }


            }
            .padding(.vertical, 20)
        }

        .animation(.smooth, value: extraOccurances)
        .navigationTitle("New\(selectedClass?.name != nil || selectedSplitter?.name != nil ? " ": "")\(selectedClass?.name ?? selectedSplitter?.name ?? "") Entry")
        .toolbar{
            ToolbarItem(placement: .confirmationAction, content: {
                Button {
                    if userFilledData(){
                        let dataFactory = knDataFactory()
                        if !editMode{
                            dataFactory.addTimeSlot(dayEntity: currentSelectedDay,
                                                    classEntity: selectedClass,
                                                    splitterEntity: selectedSplitter,
                                                    room: room,
                                                    teacher: selectedTeacher,
                                                    startTime: startTime,
                                                    endTime: endTime,
                                                    debug: true)
                            if extraOccurances.count != 0 {
                                for occurance in extraOccurances {
                                    if let day = occurance.day, let start = occurance.start, let end = occurance.end{
                                        dataFactory.addTimeSlot(dayEntity: day,
                                                                classEntity: selectedClass,
                                                                splitterEntity: selectedSplitter,
                                                                room: room,
                                                                teacher: selectedTeacher,
                                                                startTime: start,
                                                                endTime: end,
                                                                debug: true)
                                    }
                                }

                            }
                        }
                        if editMode{
                            dataFactory.updateTimeSlot(
                                timeSlot: entity,
                                dayEntity: currentSelectedDay,
                                classEntity: selectedClass,
                                splitterEntity: selectedSplitter,
                                room: room,
                                teacher: selectedTeacher,
                                startTime: startTime,
                                endTime: endTime,
                                debug: true
                            )
                        }
                        dismiss()
                    }
                    else{

                    }
                } label: {
                    Text(editMode ? "Save" : "Create")
                        .font(.body.weight(.regular))

                }
            })

            ToolbarItem(placement: .destructiveAction, content: {
                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                        .font(.body.weight(.regular))

                }
            })
        }
        .animation(.smoothCard, value: selectedClass)
        .animation(.smoothCard, value: selectedSplitter)
        .onAppear{
            for week in weeks {
                if week.id?.uuidString == schedule_SelectedWeekID{
                    currentschedule_SelectedWeek = week

                    weekHasBeenSelected = true
                }
            }
            for day in days {

                if let dayWeekID = day.week?.id?.uuidString, day.id?.uuidString == schedule_SelectedDayID && dayWeekID == schedule_SelectedWeekID{
                    currentSelectedDay = day
                    dayHasBeenSelected = true
                }
            }
            if weekHasBeenSelected && dayHasBeenSelected {
                if let num = currentschedule_SelectedWeek?.number{
                    ButtonText = "Week \(num), \(currentSelectedDay.name ?? "Error")"
                }
            }

        }
    }
    var dateSelector: some View{
        HStack(spacing: 15){


            VStack(alignment: .leading){
                HStack {
                    Text(extraOccurances.count == 0 ? "Week & Day" : "Primary Occurance")
                        .font(.caption)
                        .padding(.bottom, 6)
                        .padding(.top, 8)
                        .padding(.vertical,  3)

                    Spacer()


                }

                VStack(spacing: 0) {
                    Menu {

                        ForEach(weeks, id: \.self){ week in

                            Menu {




                            } label: {
                                Text("Week \(week.number)")

                            }



                        }
                        Divider()



                        Button {
                            showWeekCreate.toggle()
                        } label: {
                            Text("Edit Weeks")
                            Image(systemName: "pencil")
                        }
                    } label: {

                        HStack(spacing: 0) {
                            Image(systemName: "calendar.day.timeline.leading")

                                .font(Font.body.weight(.semibold))
                                .foregroundColor(color1)
                                .padding(.leading, 13)
                                .padding(.trailing, 5)
                            Text(ButtonText)
                                .foregroundColor(color2)

#if os(iOS) || os(visionOS)
                                .autocapitalization(.none)
                                .textContentType(.name)
#endif
                            Spacer()
                        }

                    }

                    .buttonStyle(regularOutlineMenu())

                    .contentShape(Rectangle())
                }



            }

            .foregroundColor(color2)
        }
        .padding(.horizontal, 20)
    }
    var timeSelector: some View{

        VStack{


            if extraOccurances.count == 0{
            }
            HStack(spacing: 15) {
                VStack{
                    Text("Start Time")
                        .sectionTitle()
                    DatePicker("Start Time", selection: $startTime, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                    //                    .transformEffect(.init(scaleX: 1.3, y: 1.3))
                        .frame(maxWidth: .infinity)
                        .neoFieldCard(color: color1)
                }
                VStack{
                    Text("End Time")
                        .sectionTitle()
                    DatePicker("End Time", selection: $endTime, displayedComponents: .hourAndMinute)
                        .frame(maxWidth: .infinity)
                        .labelsHidden()
                        .neoFieldCard(color: color2)
                }
            }

        }
        .padding(.horizontal, 20)
        .padding(.top, extraOccurances.count == 0 ? 0 : 3)

    }

    var multiOccurnceView: some View {
        VStack(spacing: 10){


            ForEach(Array(extraOccurances.enumerated()), id:\.element) { index, occurance in

                VStack(){
                    Text("Occurance \(index + 2)")
                        .sectionTitle()
                        .padding(.bottom, 3)

                    HStack{

                        Menu {
                            ForEach(weeks, id: \.id) { week in


                                Menu {
                                    if let days = (week.days?.allObjects as? [Day])?.sorted(by: { $0.number < $1.number }) {
                                        ForEach(days, id: \.id) { day in
                                            Button {
                                                extraOccurances[index].week = week
                                                extraOccurances[index].day = day
                                            } label: {
                                                Text("\(day.name ?? "Unknown Day")")
                                            }
                                        }
                                    }
                                } label: {
                                    Text("Week \(week.number)")
                                }
                            }
                            Divider()
                            Button {
                                showWeekCreate.toggle()
                            } label: {
                                Text("Edit Weeks")
                                Image(systemName: "plus")
                            }
                        } label: {
                            HStack(spacing: 0) {
                                Image(systemName: "calendar.day.timeline.leading")
                                    .font(Font.body.weight(.semibold))
                                    .foregroundColor(color1)
                                    .padding(.leading, 13)
                                    .padding(.trailing, 5)
                                if let week = occurance.week{
                                    Text("Week \(week.number ?? 0), \(occurance.day?.name ?? "")")
                                        .foregroundColor(color1)
                                        .textContentType(.name)
                                }
                                else{
                                    Text("Select Week & Day")
                                        .foregroundColor(color1)
                                        .textContentType(.name)
                                }

                                Spacer()



                            }
                        }

                        .buttonStyle(regularOutlineMenu())

                        .contentShape(Rectangle())

                        Button {
                            extraOccurances.remove(at: index)
                        } label: {
                            Image(systemName: "minus.circle")
                                .foregroundStyle(Color.red)
                        }
                        .buttonStyle(BentoButton(role: .destructive))
                        .padding(.leading, 10)
                    }


                }
                .transition(.blur.animation(.smooth))

            }
        }.padding(.horizontal, 20)

    }


    var preview: some View {
        VStack{
            if let prop = selectedClass{
                Text("Preview")
                    .sectionTitle()
            }
        }
    }

    var typeSelector: some View{
        VStack{


            //            let color2 = Color.getAdjustedColor(color: selectedClass != nil ? Color(hex: (selectedClass?.color2 ?? color2.hexString) ?? "#85A2EC" ) : Color(hex: (selectedSplitter?.color2 ?? color2.hexString) ?? "#85A2EC") , colorScheme: colorScheme)
            HStack {
                Text("Type")
                    .sectionTitle(topPadding: 0)

            }.padding(.horizontal, 20)

            Menu {

                Section(VariableDataNames().classesName()) {
                    Picker(VariableDataNames().classesName(), selection: $selectedClass) {

                        ForEach(classes, id: \.self) { c in
                            Label(c.name ?? "", systemImage: c.icon ?? "book.closed")
                                .tag(c as ClassEntity?)
                        }
                    }

                }
                if splitters.count > 10{
                    Picker("Splits", selection: $selectedSplitter) {

                        ForEach(splitters, id: \.self) { s in
                            Text(s.name ?? "")
                                .tag(s as SplitterEntity?)
                        }
                    }
                    .pickerStyle(.menu)

                }
                else{
                    Section("Splits"){
                        Picker("Splits", selection: $selectedSplitter) {

                            ForEach(splitters, id: \.self) { s in
                                Text(s.name ?? "")
                                    .tag(s as SplitterEntity?)
                            }
                        }
                    }
                }
                Button {
                    showClassCreate.toggle()
                } label: {
                    Text(VariableDataNames().newClassName())
                    Image(systemName: "plus")
                }



            } label: {

                HStack(spacing: 0) {
                    Image(systemName: selectedType == .classes ? (selectedClass?.icon ?? "book.closed") : "character.cursor.ibeam")

                        .font(Font.body.weight(.semibold))
                        .foregroundColor(color1)

                        .frame(width: 20, height: 15)
                        .padding(.leading, 13)
                        .padding(.trailing, 5)
                    if let c = selectedClass{
                        Text(c.name ?? "No Name")

                            .lineLimit(1)
                            .foregroundColor(color1)
                    }
                    else if let s = selectedSplitter{
                        Text(s.name ?? "No Name")

                            .lineLimit(1)
                            .foregroundColor(color1)
                    }
                    else{
                        Text("Select Type")

                            .lineLimit(1)
                            .foregroundColor(color1)
                    }

                    Spacer()
                }
            }
            .buttonStyle(regularOutlineMenu())

            .contentShape(Rectangle())


            .padding(.horizontal, 20)
            .onChange(of: selectedClass) { new in
                if let selectedClass = selectedClass, let selectedClassColor1 = selectedClass.color1,  let selectedClassColor2 = selectedClass.color2{
                    selectedSplitter = nil

                    color1 = colorScheme == .light ? Color(hex: selectedClassColor1).getBrightness() > 0.73 ? Color(hex: selectedClassColor1).darken(by: 0.4) : Color(hex: selectedClassColor1) : Color(hex: selectedClassColor1)
                    color2 = colorScheme == .light ? Color(hex: selectedClassColor2).getBrightness() > 0.73 ? Color(hex: selectedClassColor2).darken(by: 0.4) : Color(hex: selectedClassColor2) : Color(hex: selectedClassColor2)
                }
            }
            .onChange(of: selectedSplitter) { new in
                if let selectedSplitter = selectedSplitter, let selectedSplitterColor1 = selectedSplitter.color1, let selectedSplitterColor2 = selectedSplitter.color2{
                    selectedClass = nil

                    color1 = colorScheme == .light ? Color(hex: selectedSplitterColor1).getBrightness() > 0.73 ? Color(hex: selectedSplitterColor1).darken(by: 0.4) : Color(hex: selectedSplitterColor1) : Color(hex: selectedSplitterColor1)
                    color2 = colorScheme == .light ? Color(hex: selectedSplitterColor2).getBrightness() > 0.73 ? Color(hex: selectedSplitterColor2).darken(by: 0.4) : Color(hex: selectedSplitterColor2) : Color(hex: selectedSplitterColor2)
                }
            }
        }
    }

    var roomField: some View{
        VStack{
            HStack {
                Text("Room/Link")
                    .sectionTitle(horizontalPadding: 0)
                Spacer()
                Text("Optional")
                    .foregroundColor(color2)
                    .font(.caption)
                    .padding(.bottom, 6)
                    .padding(.top, 8)
                    .padding(.vertical,  3)


            }



            HStack(spacing: 0) {
                Image(systemName: "square.split.bottomrightquarter")

                    .font(Font.body.weight(.semibold))
                    .foregroundColor(color2)
                    .padding(.leading, 13)
                    .padding(.trailing, 5)
                TextField("Room number, name or a link", text: $room)
                // .focused($focusedField, equals: .room)


                    .autocorrectionDisabled(true)
                    .textFieldStyle(.plain)
            }

            .neoFieldCard()
        }
        .padding(.horizontal, 20)
    }

    var teacherField: some View{
        VStack{
            HStack {
                Text("Teacher")
                    .sectionTitle(horizontalPadding: 0)
                Spacer()
                Text("Optional")
                    .foregroundColor(color2)
                    .font(.caption)
                    .padding(.bottom, 6)
                    .padding(.top, 8)
                    .padding(.vertical,  3)


            }

            Menu {


                Section("Teacher") {
                    Picker("Teachers", selection: $selectedTeacher) {

                        ForEach(teachers, id: \.self) { c in
                            Label(c.name ?? "", systemImage: "person")
                                .tag(c as TeacherEntity?)


                        }
                    }

                }
                Button {
                    teacherEdit.toggle()
                } label: {
                    Text("Edit")
                    Image(systemName: "pencil")
                }
                Button {
                    isAlertTeacherPresented.toggle()
                } label: {
                    Text("Add Teacher")
                    Image(systemName: "plus")
                }




            } label: {

                HStack(spacing: 0) {
                    Image(systemName: "person")

                        .font(Font.body.weight(.semibold))
                        .foregroundColor(color1)

                        .frame(width: 20, height: 15)
                        .padding(.leading, 13)
                        .padding(.trailing, 5)
                    if let t = selectedTeacher{
                        Text(t.name ?? "No Name")

                            .lineLimit(1)
                            .foregroundColor(color1)
                    }
                    else{
                        Text("Select Teacher")

                            .lineLimit(1)
                            .foregroundColor(color1)
                    }

                    Spacer()
                }

            }

            .buttonStyle(regularOutlineMenu())

            .contentShape(Rectangle())
        }
        .padding(.horizontal, 20)


        .alert("Teacher", isPresented: $isAlertTeacherPresented) {
            TextField("Enter Teacher name", text: $teacherNameAdd)
            Button("Add",action: {
                let newTeacher = TeacherEntity(context: viewContext)
                newTeacher.id = UUID()
                newTeacher.name = teacherNameAdd

                do {
                    try viewContext.save()
                } catch {
                    let nsError = error as NSError
                    fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                }
                selectedTeacher = newTeacher
                teacherNameAdd = ""
            })
            Button("Cancel", role: .cancel) { }

        }
    }

    var navBarContent: some View{
        HStack(spacing: 13){

            Button {

                dismiss()
            } label: {

                Text("Cancel")
                    .foregroundColor(scrolled ? .primary : color2)
                    .font(.body.weight(.regular))

                    .scaledFrame(width: 70, height: 40, relativeTo: .body)
                //  .neoNavigationButtonStyle(cornerRadius: 14, color: color)
            }.buttonStyle(borderlessButton(color: color2, scrolled: $scrolled))


            Button {
                if userFilledData(){
                    let dataFactory = knDataFactory()
                    if !editMode{
                        dataFactory.addTimeSlot(dayEntity: currentSelectedDay,
                                                classEntity: selectedClass,
                                                splitterEntity: selectedSplitter,
                                                room: room,
                                                teacher: selectedTeacher,
                                                startTime: startTime,
                                                endTime: endTime,
                                                debug: true)
                        if extraOccurances.count != 0 {
                            for occurance in extraOccurances {
                                if let day = occurance.day, let start = occurance.start, let end = occurance.end{
                                    dataFactory.addTimeSlot(dayEntity: day,
                                                            classEntity: selectedClass,
                                                            splitterEntity: selectedSplitter,
                                                            room: room,
                                                            teacher: selectedTeacher,
                                                            startTime: start,
                                                            endTime: end,
                                                            debug: true)
                                }
                            }

                        }
                    }
                    if editMode{
                        dataFactory.updateTimeSlot(
                            timeSlot: entity,
                            dayEntity: currentSelectedDay,
                            classEntity: selectedClass,
                            splitterEntity: selectedSplitter,
                            room: room,
                            teacher: selectedTeacher,
                            startTime: startTime,
                            endTime: endTime,
                            debug: true
                        )
                    }
                    dismiss()
                }
                else{

                }
            } label: {
                Text(editMode ? "Save" : "Create")

                    .font(.body.weight(.regular))
                    .scaledFrame(width: 70, height: 40, relativeTo: .body)

            }
            .buttonStyle(NavigationButton(color: color1, scrolled: $scrolled))


        }


    }


    private func userFilledData() -> Bool{

        if selectedClass != nil && currentschedule_SelectedWeek != nil{
            return true
        }
        else if selectedSplitter != nil && currentschedule_SelectedWeek != nil{
            return true
        }
        return false

    }

    private func addItem() {

        print("Create TimeSlot: Adding new TimeSlot entity")

        withAnimation {
            let item = TimeSlot(context: viewContext)
            item.id = UUID()
            item.day = currentSelectedDay
            item.classEntity = selectedClass
            item.room = room
            item.startTime = TimeFormatter.getTimeString(startTime)
            item.endTime = TimeFormatter.getTimeString(endTime)
            item.timestamp = TimeFormatter.toDate(TimeFormatter.getTimeString(startTime), mode: .time)
            selectedClass?.addToTimeSlot(item)
            currentSelectedDay.addToTimeSlots(item)

            print("Create TimeSlot: New TimeSlot entity created with attributes: \(item)")

            do {
                try viewContext.save()
                print("Create TimeSlot: Changes saved to Core Data")
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func addSplitterItem() {
        let item = TimeSlot(context: viewContext)
        item.id = UUID()
        item.day = currentSelectedDay
        item.timestamp = TimeFormatter.toDate(TimeFormatter.getTimeString(startTime), mode: .time)
        item.startTime = TimeFormatter.getTimeString(startTime)
        item.endTime = TimeFormatter.getTimeString(endTime)
        item.splitterEntity = selectedSplitter
        currentSelectedDay.addToTimeSlots(item)
        selectedSplitter?.addToTimeSlot(item)


        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }

    }

    private func updateItem() {

        withAnimation {

            for t in timeslots{
                if t ==  entity?.splitterEntity{
                    viewContext.delete(t)
                }
            }

            for c in classes{
                if c == entity?.classEntity{
                    if let itemToRemove = entity{
                        c.removeFromTimeSlot(itemToRemove)
                    }
                }
            }

            for s in splitters{
                if s == entity?.splitterEntity{
                    if let itemToRemove = entity{
                        s.removeFromTimeSlot(itemToRemove)
                    }
                }
            }

            if let item = entity {
                // If the entity exists, update its properties
                print("TimeSlotUpdate: Updating existing entity...")

                // Reset the entity's class and splitter
                item.classEntity = nil
                item.splitterEntity = nil
                print("TimeSlotUpdate: Reset class and splitter.")

                // Update the entity's day, room, start and end time, and timestamp
                item.day = currentSelectedDay
                item.room = room
                item.startTime = TimeFormatter.getTimeString(startTime)
                item.endTime = TimeFormatter.getTimeString(endTime)
                item.timestamp = TimeFormatter.toDate(TimeFormatter.getTimeString(startTime), mode: .time)

                // If a class was selected, add the entity to its time slot
                if let destinationClass = selectedClass {
                    item.classEntity = destinationClass
                    destinationClass.addToTimeSlot(item)
                    print("TimeSlotUpdate: Added to classes destination at \(destinationClass.name ?? "No name")")
                }else {
                    // If no splitter was selected, print a message indicating so
                    print("TimeSlotUpdate: No class selected.")
                }

                // If a splitter was selected, add the entity to its time slot
                if let destinationSplitter = selectedSplitter {
                    item.splitterEntity = destinationSplitter
                    destinationSplitter.addToTimeSlot(item)
                    print("TimeSlotUpdate: Added to splitter destination at \(destinationSplitter.name ?? "No name")")
                } else {
                    // If no splitter was selected, print a message indicating so
                    print("TimeSlotUpdate: No splitter selected.")
                }
            } else {
                // If the entity doesn't exist, print a message indicating so
                print("TimeSlotUpdate: Could not update entity.")
            }



            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }

        }
    }

    private func checkColor(color: String)-> Bool{
        if selectedType != .none{

            return Color(hex: color).isLight() ?? true
        }
        else{
            return false
        }
    }

    private func getPercent(color: String) -> Double{

        return Double(Color(hex: color).getBrightness()) * 0.2

    }
}
#endif

#Preview{
    Text("A")
}

struct filteredDays: View {

    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "number", ascending: true)]) var days: FetchedResults<Day>

    @Binding var selectedDay: Day?
    @Binding var schedule_SelectedWeek: Week?
    @Binding var weekHasBeenSelected: Bool
    var week: Week


    var body: some View {
        ForEach(days, id: \.self) { day in


            Button {
                selectedDay = day
                schedule_SelectedWeek = week
                weekHasBeenSelected = true


            } label: {
                Label(day.name ?? "error", systemImage: selectedDay == day ? "checkmark" : "")
            }


        }


    }

    init(filter: Int64, selectedDay: Binding<Day?>, schedule_SelectedWeek: Binding<Week?>, weekHasBeenSelected: Binding<Bool>, week: Week){
        _days = FetchRequest<Day>(sortDescriptors: [NSSortDescriptor(key: "number", ascending: true)], predicate: NSPredicate(format: "week.number == %i", filter))
        self._selectedDay = selectedDay
        self._schedule_SelectedWeek = schedule_SelectedWeek
        self._weekHasBeenSelected = weekHasBeenSelected
        self.week = week
    }

}


struct filteredDaysOccurance: View {

    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "number", ascending: true)]) var days: FetchedResults<Day>

    @Binding var selectedDay: Day
    @Binding var schedule_SelectedWeek: Week
    @Binding var ButtonText: String
    @Binding var weekHasBeenSelected: Bool
    var week: Week


    var body: some View {
        ForEach(days, id: \.self) { day in


            Button {
                selectedDay = day
                schedule_SelectedWeek = week
                weekHasBeenSelected = true
                ButtonText = "Week \(week.number), \(day.name ?? "error")"

            } label: {
                Label(day.name ?? "error", systemImage: selectedDay == day ? "checkmark" : "")
            }


        }


    }

    init(filter: Int64, selectedDay: Binding<Day>, schedule_SelectedWeek: Binding<Week>, ButtonText: Binding<String>, weekHasBeenSelected: Binding<Bool>, week: Week){
        _days = FetchRequest<Day>(sortDescriptors: [NSSortDescriptor(key: "number", ascending: true)], predicate: NSPredicate(format: "week.number == %i", filter))
        self._selectedDay = selectedDay
        self._schedule_SelectedWeek = schedule_SelectedWeek
        self._ButtonText = ButtonText
        self._weekHasBeenSelected = weekHasBeenSelected
        self.week = week
    }

}

#if os(iOS) || os(visionOS)
struct extraOccuranceTime: View{
    var occurance: OccuranceModel
    var color1: Color
    var color2: Color
    var index: Int

    @State var showsPopoverStart: Bool = false
    @State var showsPopoverEnd: Bool = false
    @State var startTime: Date = Date()
    @State var endTime: Date = Date()

    @Binding var occurancedArray: [OccuranceModel]
    @Binding var selectedSplitter: SplitterEntity?

    @AppStorage("timeGap") var timeGap = 0
    @AppStorage("lastClassDuration") var lastClassDuration: Double = 1.0
    @AppStorage("lastSplitDuration") var lastSplitDuration: Double = 0.5

    init(occurance: OccuranceModel, color1: Color, color2: Color, index: Int, occurancedArray: Binding<[OccuranceModel]>, selectedSplitter: Binding<SplitterEntity?>) {
        self.occurance = occurance
        self.color1 = color1
        self.color2 = color2
        self.index = index
        self._occurancedArray = occurancedArray
        if let start = occurance.start, let end = occurance.end{
            self._startTime = .init(initialValue: start)
            self._endTime = .init(initialValue: end)
        }
        self._selectedSplitter = selectedSplitter
    }

    var body: some View{

        VStack(spacing: 15) {
            Button {
                //   hasTimeBeenUserEdited = true
            } label: {
                SegmentedTime(selectedDate: $startTime, title: "End", color: color1)
                    .overlay(
                        DatePicker("Start", selection: $startTime, displayedComponents: .hourAndMinute)
                            .scaleEffect(x: 4, y: 2.6)
                            .labelsHidden()
                            .blendMode(.destinationOver)
                    )
            }
            .buttonStyle(bounceButton())


            Button {
                // hasTimeBeenUserEdited = true
            } label: {
                SegmentedTime(selectedDate: $endTime, title: "End", color: color2)
                    .overlay(
                        DatePicker("End", selection: $endTime, in: Calendar.current.date(byAdding: .minute, value: Int(5), to: startTime)!..., displayedComponents: .hourAndMinute)
                            .scaleEffect(x: 4, y: 2.6)
                            .labelsHidden()
                            .blendMode(.destinationOver)
                    )
            }
            .buttonStyle(bounceButton())
            .onChange(of: startTime) { change in
                if change > endTime{
                    if selectedSplitter != nil{
                        endTime = Calendar.current.date(byAdding: .minute, value: Int(lastSplitDuration * 60), to: startTime)!
                    }
                    else{
                        endTime = Calendar.current.date(byAdding: .minute, value: Int(lastClassDuration * 60), to: startTime)!
                    }

                }
            }


            //                    .onChange(of: startTime){ change in
            //                        if !systemEditingTime{
            //                            hasTimeBeenUserEdited = true
            //                            print("AAAA")
            //                        }
            //                    }
            //                    .onChange(of: endTime){ change in
            //                        if showsPopoverStart || showsPopoverEnd{
            //                            hasTimeBeenUserEdited = true
            //                        }
            //                    }

        }

        .padding(.top, 3)
        .onChange(of: startTime) { newValue in
            occurancedArray[index].start = newValue
        }.onChange(of: endTime) { newValue in
            occurancedArray[index].end = newValue
        }
    }

    func isEven(number: Int) -> Bool {
        return number % 2 == 0
    }
}
#elseif os(macOS)
struct extraOccuranceTime: View{
    var occurance: OccuranceModel
    var color1: Color
    var color2: Color
    var index: Int

    @State var showsPopoverStart: Bool = false
    @State var showsPopoverEnd: Bool = false
    @State var startTime: Date = Date()
    @State var endTime: Date = Date()

    @Binding var occurancedArray: [OccuranceModel]

    @AppStorage("timeGap") var timeGap = 0

    init(occurance: OccuranceModel, color1: Color, color2: Color, index: Int, occurancedArray: Binding<[OccuranceModel]>) {
        self.occurance = occurance
        self.color1 = color1
        self.color2 = color2
        self.index = index
        self._occurancedArray = occurancedArray
        if let start = occurance.start, let end = occurance.end{
            self._startTime = .init(initialValue: start)
            self._endTime = .init(initialValue: end)
        }
    }

    var body: some View{

        VStack{
            HStack(spacing: 15) {
                VStack{
                    Text("Start Time")
                        .sectionTitle()
                    DatePicker("Start Time", selection: $startTime, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                    //                    .transformEffect(.init(scaleX: 1.3, y: 1.3))
                        .frame(maxWidth: .infinity)
                        .neoFieldCard()
                }
                VStack{
                    Text("End Time")
                        .sectionTitle()
                    DatePicker("End Time", selection: $endTime, displayedComponents: .hourAndMinute)
                        .frame(maxWidth: .infinity)
                        .labelsHidden()
                        .neoFieldCard()
                }
            }

        }

        .padding(.top, 3)
        .onChange(of: startTime) { newValue in
            occurancedArray[index].start = newValue
        }.onChange(of: endTime) { newValue in
            occurancedArray[index].end = newValue
        }
    }

    func isEven(number: Int) -> Bool {
        return number % 2 == 0
    }
}
#endif
