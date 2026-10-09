// FIX: Use archive identifiers to keep this build and its data separate from the original app.
//
//  Widgets.swift
//  Widgets
//
//  Created by Aether on 05/08/2023.
//


#if !os(visionOS)
import WidgetKit
import SwiftUI
import CoreData

struct currentUpcomingPlannerProvider: AppIntentTimelineProvider {


    typealias Entry = PlannerEntry

    typealias Intent = PlannerWidgetIntents

    //    @AppStorage("schedule_SelectedDayID") var schedule_SelectedDayID: String?
    //    @AppStorage("schedule_SelectedWeek") var schedule_SelectedWeek: Int = 1
    //    @AppStorage("useCustomScheduleValues", store: UserDefaults(suiteName: "group.com.example.kyoarchive")) var useCustomScheduleValues: Bool = false

    func recommendations() -> [AppIntentRecommendation<PlannerWidgetIntents>] {
        // Create an array with all the preconfigured widgets to show.
        [AppIntentRecommendation(intent: PlannerWidgetIntents(), description: "Example Widget")]
    }

    let debug = true
    let viewContext = PersistenceController.shared.container.viewContext

    func fetchTimeSlots(for dayName: String, weekNumber: Int, context: NSManagedObjectContext) -> NSFetchRequest<TimeSlot> {
        let request: NSFetchRequest<TimeSlot> = TimeSlot.fetchRequest()
        request.sortDescriptors = [
//            NSSortDescriptor(keyPath: \TimeSlot.day?.week?.number, ascending: true),
//            NSSortDescriptor(keyPath: \TimeSlot.day?.number, ascending: true),
            NSSortDescriptor(keyPath: \TimeSlot.timestamp, ascending: true)
        ]

        // Filter based on the day name
        let dayPredicate = NSPredicate(format: "day.name == %@", dayName)

        // Filter based on the week number
        let weekPredicate = NSPredicate(format: "day.week.number == %d", weekNumber)

        // Combine the day and week predicates using AND
        let compoundPredicate = NSCompoundPredicate(type: .and, subpredicates: [dayPredicate, weekPredicate])

        request.predicate = compoundPredicate
        // print("fetched timeSlots! \(dayName) \(weekNumber)")

        return request
    }


    func fetchAllTimeSlots(context: NSManagedObjectContext) -> NSFetchRequest<TimeSlot> {
        let request: NSFetchRequest<TimeSlot> = TimeSlot.fetchRequest()
        request.sortDescriptors = [
//            NSSortDescriptor(keyPath: \TimeSlot.day?.week?.number, ascending: true),
//            NSSortDescriptor(keyPath: \TimeSlot.day?.number, ascending: true),
            NSSortDescriptor(keyPath: \TimeSlot.timestamp, ascending: true)
        ]
        // print("fetched ALL timeSlots!")

        return request
    }

    func fetchWeeks(context: NSManagedObjectContext) -> NSFetchRequest<Week>{
        let request: NSFetchRequest<Week> = Week.fetchRequest()
        return request
    }
    
    func placeholder(in context: Context) -> PlannerEntry {
        do {
            let timeSlots = try viewContext.fetch(fetchTimeSlots(for: "Tue", weekNumber: 1, context: viewContext))
            let slot = timeSlots.first
            let entry = PlannerEntry(date: Date(), timeSlot: slot, state: .upcoming)
            if slot == nil{
                // print("slot no ):")
            }
            else{

                // print("slot (:")
            }
            return entry
        }
        catch {
            // print("placeholder fallback!")
            return PlannerEntry(date: Date())
        }

    }

//    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
    func snapshot(for configuration: PlannerWidgetIntents, in context: Context) async -> PlannerEntry {

        do{

            var entry = PlannerEntry(date: Date(), state: .error)
            // print("getSnapshot")

            let allTimeSlots = try viewContext.fetch(fetchAllTimeSlots(context: viewContext))
            // print(allTimeSlots.count)
            // print(allTimeSlots.endIndex)
            if !(allTimeSlots.isEmpty){

            var weekWizard = WeekWizard()
            let currentWeekReal = weekWizard.getCurrentWeek() ?? 1
                let scheduleManager = ScheduleManager( debug: true, findOnlyNonEmptyDays: true, findNextWithUpcomingCurrentSlots: true)
                var usingWeek = Int((scheduleManager.getCurrentDay(1)?.day.week?.number ?? 1))
            let currentDayCode = TimeFormatter.getDayCode(date: Date())




                if var usingDay = (scheduleManager.getCurrentDay(currentWeekReal)?.day.name), var usingWeek64 = (scheduleManager.getCurrentDay(currentWeekReal)?.day.week?.number){
                // print("get slots with \(usingDay), \(usingWeek)")
                let usingWeek = Int(usingWeek64)
                let timeSlots = try viewContext.fetch(fetchTimeSlots(for: usingDay, weekNumber: usingWeek, context: viewContext))
                var defualtState: timeState = .current
                var upcomingOrComingSlots = timeSlots.filter{ slot in
                    return !((TimeFormatter.toDate(slot.endTime ?? "", mode: .fullDate) ?? Date()) < Date())
                }
                // print("fdfdfgdgdfgf \(currentWeekReal != weekWizard.getCurrentWeek())")
                    if currentDayCode != (scheduleManager.getCurrentDay(usingWeek)?.day.name!) || currentWeekReal != usingWeek{
                    // print("adjusting settings \(timeSlots.count)")
                    upcomingOrComingSlots = [timeSlots.first!]
                }
                // print("get slots with222 \(usingDay), \(usingWeek), crw \(currentWeekReal)")

                var index = 0
                // print("adding timeSlots to entries now \(upcomingOrComingSlots.count)")
                for timeSlot in upcomingOrComingSlots.prefix(1){
                    if let startString = timeSlot.startTime, let startTime = TimeFormatter.toDate(startString, mode: .fullDate),  let endString = timeSlot.endTime, let endTime = TimeFormatter.toDate(endString, mode: .fullDate){
                        if index == 0{
                            if Date() < startTime{

                                let newEntry = PlannerEntry(date: Date(), timeSlot: timeSlot, state: defualtState == .current ? .upcoming : .upcomingOnOtherDay, dayName: usingDay, weekNumber: usingWeek)
                                // log("[getTimeline] created special intro entry with index: \(index), and upcoming state, and attached date: \(Date()), with an attached timeSlot (timeSlot has class of \(timeSlot.classEntity?.name ?? "No Attached Name Found") \(timeSlot.room)", debug: debug)
                                entry = newEntry
                            }
                            else{
                                let newEntry = PlannerEntry(date: startTime, timeSlot: timeSlot, state: defualtState, dayName: usingDay, weekNumber: usingWeek)
                                // log("[getTimeline] created new entry with index: \(index), and attached date: \(startTime), with an attached timeSlot (timeSlot has class of \(timeSlot.classEntity?.name ?? "No Attached Name Found")", debug: debug)
                                entry = newEntry
                            }
                        }
                        else{
                            let newEntry = PlannerEntry(date: startTime, timeSlot: timeSlot, state: defualtState, dayName: usingDay, weekNumber: usingWeek)
                            // log("[getTimeline] created new entry with index: \(index), and attached date: \(startTime), with an attached timeSlot (timeSlot has class of \(timeSlot.classEntity?.name ?? "No Attached Name Found")", debug: debug)
                            entry = newEntry
                        }

                    }
                    else{
                        // log("[getTimeline] could not get startString or startTime", debug: debug)
                    }
                    index = index + 1
                }
                if upcomingOrComingSlots.isEmpty{
                    let newEntry = PlannerEntry(date: Date(), state: .error)
                    entry = newEntry
                }




            }






        }
            else{

                    // print("NO TIMESLOTS!")
                    let emptyNotice = PlannerEntry(date: Date(), state: .error)
                entry = emptyNotice
            }

            return entry

        } catch {
            // print("Widget failed to fetch days in timeline!")
        }

        return PlannerEntry(date: Date(), state: .error)
    }

//    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
    func timeline(for configuration: PlannerWidgetIntents, in context: Context) async -> Timeline<PlannerEntry> {
        var entries: [PlannerEntry] = []
        var timeline = Timeline(entries: entries, policy: .atEnd)

        // print("getting timeline!!!")

        let showDetails = configuration.showDetails == true
        let showCountdowns = configuration.showCountdowns == true

        do{
            let allTimeSlots = try viewContext.fetch(fetchAllTimeSlots(context: viewContext))
            // print(allTimeSlots.count)
            // print(allTimeSlots.endIndex)
            if !(allTimeSlots.isEmpty){
            entries = []

                var weekWizard = WeekWizard()

                let scheduleManager = ScheduleManager(debug: true, findOnlyNonEmptyDays: true, findNextWithUpcomingCurrentSlots: true)

                if let actualCurrentWeek = weekWizard.getCurrentWeek(), let scheduleData = (scheduleManager.getCurrentDay(actualCurrentWeek)){
                    let timeSlotState: timeState = (scheduleData.onOtherDay ) ? .upcomingOnOtherDay : .current
                                    let currentDayCode = TimeFormatter.getDayCode(date: Date())



                    if let usingDay = (scheduleData.day.name), let usingWeek64 = (scheduleData.day.week?.number){
                                    let usingWeek = Int(usingWeek64)
                                    let timeSlots = try viewContext.fetch(fetchTimeSlots(for: usingDay, weekNumber: usingWeek, context: viewContext))

                                    var upcomingOrComingSlots = timeSlots.filter{ slot in
                                        return !((TimeFormatter.toDate(slot.endTime ?? "", mode: .fullDate) ?? Date()) < Date())
                                    }
                                        if timeSlotState == .upcomingOnOtherDay{
                                        upcomingOrComingSlots = [timeSlots.first!]
                                    }

                                    // print("adding timeSlots to entries now \(upcomingOrComingSlots.count)")
                                        for (index, timeSlot) in upcomingOrComingSlots.enumerated(){
                                        if let startString = timeSlot.startTime, let startTime = TimeFormatter.toDate(startString, mode: .fullDate){

                                            if timeSlotState == .upcomingOnOtherDay{
                                                // log("[getTimeline] Creating other day entry with upcoming state and attached date: \(Date())", debug: debug)
                                                let newEntry = PlannerEntry(date: Date(), timeSlot: timeSlot, state: .upcomingOnOtherDay, dayName: usingDay, weekNumber: usingWeek, showDetails: showDetails, showCountdowns: showCountdowns)
                                                entries.append(newEntry)
                                            }
                                            else if index == 0{
                                                if Date() < startTime {
                                                    // log("[getTimeline] Creating intro entry with upcoming state and attached date: \(Date())", debug: debug)
                                                    let newEntry = PlannerEntry(date: Date(), timeSlot: timeSlot, state: timeSlotState == .current ? .upcoming : .upcomingOnOtherDay, dayName: usingDay, weekNumber: usingWeek, showDetails: showDetails, showCountdowns: showCountdowns)
                                                    entries.append(newEntry)
                                                }
                                            }
                                            else if startString != upcomingOrComingSlots[index - 1].endTime{

                                                // log("[getTimeline] Creating intermediate entry with upcoming state and attached date: \(Date())", debug: debug)
                                                if let previousEndDateString = upcomingOrComingSlots[index - 1].endTime, let previousEndDate = TimeFormatter.toDate(previousEndDateString, mode: .fullDate) {
                                                    let newEntry = PlannerEntry(date: previousEndDate, timeSlot: timeSlot, state: .upcoming , dayName: usingDay, weekNumber: usingWeek, showDetails: showDetails, showCountdowns: showCountdowns)
                                                    entries.append(newEntry)
                                                }
                                                else{
                                                    // log("[getTimeline] Warning, could not create intermediate entry, could not get/compute previous date", debug: debug)
                                                }
                                            }

                                            if timeSlotState != .upcomingOnOtherDay{
                                                // log("[getTimeline] Creating new entry with attached date: \(startTime))", debug: debug)
                                                let newEntry = PlannerEntry(date: startTime, timeSlot: timeSlot, state: .current, dayName: usingDay, weekNumber: usingWeek, showDetails: showDetails, showCountdowns: showCountdowns)
                                                entries.append(newEntry)
                                            }

                                            if timeSlotState == .upcomingOnOtherDay{
                                                if let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: Date()),
                                                   let nextDayWithTime = Calendar.current.date(bySettingHour: 0, minute: 5, second: 0, of: nextDay) {

                                                    // log("[getTimeline] Added a refresh for other day entry, for midnight", debug: debug)
                                                    let newEntry = PlannerEntry(date: nextDayWithTime, timeSlot: timeSlot, state: timeSlotState, dayName: usingDay, weekNumber: usingWeek, showDetails: showDetails, showCountdowns: showCountdowns)
                                                    entries.append(newEntry)
                                                }

                                            }

                                        }


                                    }
                                    if upcomingOrComingSlots.isEmpty{
                                        let entry = PlannerEntry(date: Date(), state: .error, showDetails: showDetails, showCountdowns: showCountdowns)
                                        entries.append(entry)
                                    } else{
                                        let refreshDateString = upcomingOrComingSlots.last?.endTime
                                        let refreshDate = TimeFormatter.toDate(refreshDateString!, mode: .fullDate)!
                                        let endOfDay = PlannerEntry(date: refreshDate, endOfDayNotice: true, showDetails: showDetails, showCountdowns: showCountdowns)
                                        entries.append(endOfDay)
                                        // print("added end of day entry at \(refreshDate)")


                                    }

                                        timeline = Timeline(entries: entries, policy: .atEnd)


                                }






                }
                else{
                    let errorNotice = PlannerEntry(date: Date(), setupWeeksNotice: true, showCountdowns: showCountdowns)
                    entries.append(errorNotice)

                    timeline = Timeline(entries: entries, policy: .atEnd)
                }

        }
            else{

                    // print("NO TIMESLOTS!")
                    let emptyNotice = PlannerEntry(date: Date(), state: .error, showCountdowns: showCountdowns)
                    entries.append(emptyNotice)

                timeline = Timeline(entries: entries, policy: .atEnd)
            }

            // print("refresh at \(timeline.policy.self)")
            // print("entries! \(entries)")
            return timeline
        } catch {
            // print("Widget failed to fetch days in timeline!")
        }

        let emptyNotice = PlannerEntry(date: Date(), state: .error, showCountdowns: showCountdowns)
        entries.append(emptyNotice)

        // print("entries! \(entries)")
        return Timeline(entries: entries, policy: .atEnd)

    }
}

struct PlannerEntry: TimelineEntry {
    let date: Date
    var timeSlot: TimeSlot? = nil
    var state: timeState = .upcoming
    var dayName: String? = nil
    var weekNumber: Int? = nil
    var endOfDayNotice: Bool = false
    var setupWeeksNotice: Bool = false

    // parameters
    var showDetails: Bool = true
    var showCountdowns: Bool = true
}

struct PlannerUpNextCurrentWidget : View {
    var entry: currentUpcomingPlannerProvider.Entry
    @Environment(\.widgetFamily) var family
    @AppStorage("global_breakMode", store: UserDefaults(suiteName: "group.com.example.kyoarchive")) var global_breakMode: Bool = false

    var body: some View {
        if !global_breakMode{
        Group{
            switch family {
#if !os(watchOS)
            case .systemSmall, .systemMedium, .systemLarge, .systemExtraLarge:
                if let timeSlot = entry.timeSlot, let color1String = timeSlot.classEntity?.color1 ?? timeSlot.splitterEntity?.color1, !entry.endOfDayNotice, !entry.setupWeeksNotice{
                    let color1 = Color(hex: color1String)
                    let brightness1 = (color1.getBrightness())
                    HStack{

                        VStack(alignment: .leading, spacing: 4){


                            if let name = timeSlot.classEntity?.name ?? timeSlot.splitterEntity?.name{
                                Text(name)
                                    .font((family == .systemMedium ? Font.title2 : Font.title3).weight(.bold))
                                //                                    .textCase(.uppercase)
                                    .padding(.vertical, 1.1)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .lineLimit(3)
                                    .minimumScaleFactor(0.65)
                            }
                            ViewThatFits(content: {
                                VStack(alignment: .leading, spacing: 6.5){

                                    if let room = timeSlot.room, room != "" && entry.showDetails {
                                        if findURL(in: room) == nil{
                                            VStack(alignment: .leading, spacing: 5){
                                                HStack{
                                                    Text(Image(systemName: "square.split.bottomrightquarter"))
                                                    + Text(" " + room)
                                                }
                                                .lineLimit(1)


                                            }

                                        }
                                        else{
                                            HStack(spacing: 2){
                                                Text(Image(systemName: getIconForURL(findURL(in: room) ?? "link")))
                                                    .lineLimit(1)
                                            }
                                        }
                                    }
                                    if let teacherEntity = timeSlot.taughtBy, let teacher = teacherEntity.name, entry.showDetails{
                                        HStack(spacing: 2){
                                            Text(Image(systemName: "person"))
                                            Text(teacher)

                                        }
                                        .lineLimit(1)
                                    }
                                }
                                ZStack{
                                    if let room = timeSlot.room, room != "" && entry.showDetails {
                                        if findURL(in: room) == nil{
                                            VStack(alignment: .leading, spacing: 5){
                                                HStack{
                                                    Text(Image(systemName: "square.split.bottomrightquarter"))
                                                    + Text(" " + room)
                                                }
                                                .lineLimit(1)


                                            }

                                        }
                                        else{
                                            HStack(spacing: 2){
                                                Text(Image(systemName: "link"))
                                                    .lineLimit(1)
                                            }
                                        }
                                    }
                                }
                                HStack(alignment: .center, spacing: 6.5){

                                    if let room = timeSlot.room, room != "", entry.showDetails {
                                        if findURL(in: room) == nil{
                                            VStack(alignment: .leading, spacing: 5){
                                                HStack{
                                                    Text(Image(systemName: "square.split.bottomrightquarter"))
                                                    + Text(" " + room)
                                                }
                                                .lineLimit(1)


                                            }

                                        }
                                        else{
                                            HStack(spacing: 2){
                                                Text(Image(systemName: "link"))
                                                    .lineLimit(1)
                                            }
                                        }
                                    }
                                    if let teacherEntity = timeSlot.taughtBy, let teacher = teacherEntity.name{
                                        HStack(spacing: 2){
                                            Text(Image(systemName: "person"))
                                            Text(teacher)

                                        }
                                        .lineLimit(1)
                                    }
                                }
                            })
                            .font(.footnote)
                            .foregroundColor(brightness1 > 0.73 ? color1.darken(by: 0.5) : Color.white)
                            if let startString = timeSlot.startTime, let endString = timeSlot.endTime{
                                if entry.state == .upcoming{
                                    VStack(alignment: .trailing, spacing: 2){
                                        HStack( alignment: .center){
                                            Text(Image(systemName: "arrow.right"))
                                            +
                                            Text(" \(startString)")
                                        }

#if os(iOS) || os(visionOS)
                                        .font((family == .systemMedium ? Font.title3 : family == .accessoryRectangular ? Font.body : Font.headline).weight(.bold))
#else
                                        .font((family == .systemMedium ? Font.title3 : Font.headline).weight(.bold))
#endif

                                        if entry.showCountdowns{
                                            Text("in \(TimeFormatter.toDate(startString, mode: .fullDate) ?? Date(), style: .timer)")
                                                .font(.footnote)
                                                .multilineTextAlignment(.trailing)
                                                .opacity(0.7)
                                                .monospacedDigit()
                                        }
                                        else{

                                            Text("Up Next")
                                                .font(.footnote)
                                                .multilineTextAlignment(.trailing)
                                                .opacity(0.7)
                                        }

                                    }
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                                }
                                if entry.state == .current{
                                    VStack(alignment: .trailing, spacing: 2){
                                        HStack( alignment: .center){
                                            //                                Text(Image(systemName: "arrow.right"))
                                            //                                +

                                            if entry.showCountdowns{
                                                Text(" \(TimeFormatter.toDate(endString, mode: .fullDate) ?? Date(), style: .timer)")
                                                    .monospacedDigit()
                                                    .multilineTextAlignment(.trailing)
                                            }
                                            else{
                                                Text("Current")
                                                    .multilineTextAlignment(.trailing)
                                            }
                                        }
#if os(iOS) || os(visionOS)
                                        .font((family == .systemMedium ? Font.title3 : family == .accessoryRectangular ? Font.body : Font.headline).weight(.bold))
#else
                                        .font((family == .systemMedium ? Font.title3 :  Font.headline).weight(.bold))
#endif
                                        Group{
                                            Text(Image(systemName: "arrow.right"))
                                            +
                                            Text(" \(endString)")
                                        }
                                        .textCase(.uppercase)
                                        .font(.footnote)
                                        .multilineTextAlignment(.trailing)
                                        .opacity(0.7)
                                        .monospacedDigit()
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                                }
                                if let weekNum = entry.weekNumber, let dayName = entry.dayName, let w = WeekWizard().getCurrentWeek(), entry.state == .upcomingOnOtherDay{
                                    VStack(alignment: .trailing, spacing: 2){
                                        HStack( alignment: .center){
                                            //                                Text(Image(systemName: "arrow.right"))
                                            //                                +
                                            ViewThatFits{
                                                Text(abs((w - weekNum)) == 0 ? getFullDayName(from: dayName) ?? dayName : "\(getFullDayName(from: dayName) ?? dayName), Week \(weekNum)")

                                                    .fixedSize(horizontal: false, vertical: true)
                                                    .multilineTextAlignment(.trailing)
                                                    .lineLimit(2)

                                                Text(abs((w - weekNum)) == 0 ? "\(dayName)" : "\(dayName), Week \(weekNum)")

                                                    .fixedSize(horizontal: false, vertical: true)
                                                    .multilineTextAlignment(.trailing)
                                                    .lineLimit(2)
                                            }
                                        }
                                        .font((family == .systemMedium ? Font.title3 : Font.headline).weight(.bold))
                                        //

                                        Group {
                                            if abs(w - weekNum) == 1 /*|| (weekNum - 1) == 0*/ {
                                                Text("Next Week")
                                            } else if abs(w - weekNum) == 0 {
                                                let daysBetween = TimeHelper.calculateDaysBetween(start: TimeFormatter.getDayCode(date: Date()) ?? "Mon", end: dayName)
                                                if daysBetween == 1 {
                                                    Text("Tomorrow, \(startString)")
                                                } else if daysBetween > 0 {
                                                    Text("^[\(daysBetween) Day](inflect: true)")
                                                }
                                                // Else: Don't display anything for daysBetween <= 0
                                            } else {
                                                Text("In \(weekNum - 1) Weeks")
                                            }
                                        }
                                        //                                        .textCase(.uppercase)
                                        .font(.footnote)
                                        .multilineTextAlignment(.trailing)
                                        .opacity(0.7)
                                        .minimumScaleFactor(0.7)
                                        .lineLimit(2)



                                    }
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                                }
                            }
                        }
                        //                if family == .systemMedium{
                        //                    Color.clear.frame(width: 10)
                        //                    VStack(spacing: 7){
                        //
                        //                            Label("Task", systemImage: "plus")
                        //                            .font(.footnote)
                        //                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        //                                .background(Color(.white).opacity(0.3))
                        //                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        //                        Label("Edit", systemImage: "pencil")
                        //                            .font(.footnote)
                        //                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        //                            .background(Color(.white).opacity(0.3))
                        //                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        //                        Label("Mute", systemImage: "bell.slash")
                        //                            .font(.footnote)
                        //                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        //                            .background(Color(.white).opacity(0.3))
                        //                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        //                    }
                        //                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        //                }
                    }
                    .foregroundColor(brightness1 > 0.73 ? Color(hex: color1String).darken(by: 0.5) : Color.white)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .animation(.bouncy)
                }
                else if entry.setupWeeksNotice{
                    VStack(alignment: .leading){
                                            Text("Please set the current week in settings")
                                                .font(.title3.weight(.semibold))
                                                .padding(.vertical, 1.1)
                                                .fixedSize(horizontal: false, vertical: true)
                                                .lineLimit(3)
                                                .minimumScaleFactor(0.65)

                                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                                            Text("Couldn't find current week")

                                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                else if entry.state == .error {
                    VStack(alignment: .leading){
                        Text("Add some entries in your planner to get started")
                            .font(.title3.weight(.semibold))
                            .padding(.vertical, 1.1)
                            .fixedSize(horizontal: false, vertical: true)
                            .lineLimit(2)
                            .minimumScaleFactor(0.65)

                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        Text("No entries for today or later found")

                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                else if entry.endOfDayNotice{
                    VStack(alignment: .leading){
                        Text("Day Finished\n🎉")
                            .font((family == .systemMedium ? Font.title2 : Font.title3).weight(.bold))
                            .padding(.vertical, 1.1)
                            .fixedSize(horizontal: false, vertical: true)
                            .lineLimit(2)
                            .minimumScaleFactor(1.8)

                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        Text("Showing upcoming entries shortly ")
                            .font((Font.body).weight(.bold))
                            .minimumScaleFactor(0.65)

                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
#endif
#if os(iOS) || os(visionOS) || os(watchOS)
            case .accessoryRectangular:
                if let timeSlot = entry.timeSlot, let color1String = timeSlot.classEntity?.color1 ?? timeSlot.splitterEntity?.color1{
                    let color1 = Color(hex: color1String)
                    let brightness1 = (color1.getBrightness())
                    VStack(alignment: .leading, spacing: 4){

                        if let name = timeSlot.classEntity?.name ?? timeSlot.splitterEntity?.name{
                            Text(name)
                                .font(.headline.weight(.bold))
                            //                                .textCase(.uppercase)
                                .padding(.vertical, 1.1)
                                .fixedSize(horizontal: false, vertical: true)
                                .lineLimit(1)
                                .minimumScaleFactor(0.65)
                        }
                        HStack{

                            ZStack(alignment: .top){


                                VStack(alignment: .leading, spacing: 6.5){

                                    if let room = timeSlot.room, room != "" && entry.showDetails {
                                        if findURL(in: room) == nil{
                                            VStack(alignment: .leading, spacing: 5){
                                                HStack{
                                                    Text(Image(systemName: "square.split.bottomrightquarter"))
                                                    + Text(" " + room)
                                                }
                                                .lineLimit(1)


                                            }

                                        }
                                        else{
                                            HStack(spacing: 2){
                                                Text(Image(systemName: getIconForURL(findURL(in: room) ?? "link")))
                                                    .lineLimit(1)
                                            }
                                        }
                                    }
                                    //                                if let teacherEntity = timeSlot.taughtBy, let teacher = teacherEntity.name{
                                    //                                    HStack(spacing: 2){
                                    //                                        Text(Image(systemName: "person"))
                                    //                                        Text(teacher)
                                    //
                                    //                                    }
                                    //                                    .lineLimit(1)
                                    //                                }
                                }
                                .font(.footnote)


                            }
                            .frame(maxHeight: .infinity, alignment: .topLeading)

                            if let startString = timeSlot.startTime, let endString = timeSlot.endTime{
                                if entry.state == .upcoming{
                                    VStack(alignment: .trailing, spacing: 2){
                                        HStack( alignment: .center){
                                            Text(Image(systemName: "arrow.right"))
                                            +
                                            Text(" \(startString)")
                                        }
                                        .font((Font.headline).weight(.bold))


                                        if entry.showCountdowns{
                                            Text("in \(TimeFormatter.toDate(startString, mode: .fullDate) ?? Date(), style: .timer)")
                                                .font(.footnote)
                                                .multilineTextAlignment(.trailing)
                                                .opacity(0.7)
                                                .monospacedDigit()
                                        }
                                        else{
                                            Text("Up Next")
                                                .font(.footnote)
                                                .multilineTextAlignment(.trailing)
                                                .opacity(0.7)
                                                .monospacedDigit()
                                        }

                                    }
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                                }
                                if entry.state == .current{
                                    VStack(alignment: .trailing, spacing: 2){
                                        HStack( alignment: .center){
                                            //                                Text(Image(systemName: "arrow.right"))
                                            //

                                            if entry.showCountdowns{
                                                Text(" \(TimeFormatter.toDate(endString, mode: .fullDate) ?? Date(), style: .timer)")
                                                    .monospacedDigit()
                                                    .multilineTextAlignment(.trailing)
                                            }
                                            else{
                                                Text("Now")
                                                    .multilineTextAlignment(.trailing)
                                            }
                                        }
                                        .font((Font.headline).weight(.bold))
                                        Group{
                                            Text(Image(systemName: "arrow.right"))
                                            +
                                            Text(" \(endString)")
                                        }
                                        .textCase(.uppercase)
                                        .font(.footnote)
                                        .multilineTextAlignment(.trailing)
                                        .opacity(0.7)
                                        .monospacedDigit()
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                                }
                                if let weekNum = entry.weekNumber, let dayName = entry.dayName, let w = WeekWizard().getCurrentWeek(), entry.state == .upcomingOnOtherDay{
                                    VStack(alignment: .trailing, spacing: 2){
                                        HStack( alignment: .center){
                                            //                                Text(Image(systemName: "arrow.right"))
                                            //                                +
                                            ViewThatFits{
                                                Text(abs((w - weekNum)) == 0 ? getFullDayName(from: dayName) ?? dayName : "\(getFullDayName(from: dayName) ?? dayName), Week \(weekNum)")

                                                    .fixedSize(horizontal: false, vertical: true)
                                                    .multilineTextAlignment(.trailing)
                                                    .lineLimit(2)

                                                Text(abs((w - weekNum)) == 0 ? "\(dayName)" : "\(dayName), Week \(weekNum)")

                                                    .fixedSize(horizontal: false, vertical: true)
                                                    .multilineTextAlignment(.trailing)
                                                    .lineLimit(2)
                                            }
                                        }
                                        .font((Font.headline).weight(.bold))
                                        //



                                        Group {
                                            if abs(w - weekNum) == 1 /*|| (weekNum - 1) == 0 */{
                                                Text("Next Week")
                                            } else if abs(w - weekNum) == 0 {
                                                let daysBetween = TimeHelper.calculateDaysBetween(start: TimeFormatter.getDayCode(date: Date()) ?? "Mon", end: dayName)
                                                if daysBetween == 1 {
                                                    Text("Tomorrow")
                                                } else if daysBetween > 0 {
                                                    Text("^[\(daysBetween) Day](inflect: true)")
                                                }
                                                // Else: Don't display anything for daysBetween <= 0
                                            } else {
                                                Text("In \(weekNum - 1) Weeks")
                                            }
                                        }
                                        //                                    .textCase(.uppercase)
                                        .font(.footnote)
                                        .multilineTextAlignment(.trailing)
                                        .opacity(0.7)



                                    }
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                                }
                            }
                        }
                    }
                    .foregroundColor(brightness1 > 0.73 ? Color(hex: color1String).darken(by: 0.5) : Color.white)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .animation(.bouncy)
                }
                else if entry.endOfDayNotice{
                    VStack(alignment: .leading){
                        Text("Day Finished 🎉")
                            .font((Font.headline).weight(.bold))
                            .padding(.vertical, 1.1)
                            .fixedSize(horizontal: false, vertical: true)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)

                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        Text("Showing upcoming entries shortly ")

                            .font(.footnote.weight(.bold))
                            .minimumScaleFactor(0.65)

                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            case .accessoryCircular:
                if let timeSlot = entry.timeSlot, let name = timeSlot.classEntity?.name ?? timeSlot.splitterEntity?.name{
                    CrookedText(text: name, radius: 50, textModifier: { Text in
                        Text
                            .font(.system(size: 23).bold())
                            .foregroundColor(.white)
                    })
                    .scaleEffect(0.4)
                    .background{
                        VStack{
                            if let weekNum = entry.weekNumber, let dayName = entry.dayName, let w = WeekWizard().getCurrentWeek(), entry.state == .upcomingOnOtherDay{
                                Group {
                                    if abs(w - weekNum) == 1 /*|| (weekNum - 1) == 0 */{
                                        Image(systemName: "arrowshape.zigzag.right")
                                    } else if abs(w - weekNum) == 0 {
                                        let daysBetween = TimeHelper.calculateDaysBetween(start: TimeFormatter.getDayCode(date: Date()) ?? "Mon", end: dayName)
                                        if daysBetween == 1 {
                                            Image(systemName: "arrowshape.right")
                                        } else if daysBetween > 0 {
                                            Image(systemName: "arrowshape.right")
                                        }
                                        // Else: Don't display anything for daysBetween <= 0
                                    } else {
                                        Image(systemName: "arrowshape.zigzag.right")
                                    }
                                }
                                .font(.system(size: 9).bold())
                            }
                            if let room = timeSlot.room, room != "" && entry.showDetails {
                                if let weekNum = entry.weekNumber, let dayName = entry.dayName, let w = WeekWizard().getCurrentWeek(), entry.state == .upcomingOnOtherDay{
                                    Group {
                                        if abs(w - weekNum) == 1 /*|| (weekNum - 1) == 0 */{
                                            Text("Next Week")
                                        } else if abs(w - weekNum) == 0 {
                                            let daysBetween = TimeHelper.calculateDaysBetween(start: TimeFormatter.getDayCode(date: Date()) ?? "Mon", end: dayName)
                                            if daysBetween == 1 {
                                                Text("Tomorrow")
                                            } else if daysBetween > 0 {
                                                Text("^[\(daysBetween) Day](inflect: true)")
                                            }
                                            // Else: Don't display anything for daysBetween <= 0
                                        } else {
                                            Text("In \(weekNum - 1) Weeks")
                                        }
                                    }
                                    .font(.system(size: 7).bold())
                                    .offset(y: 5)
                                }
                            }
                        }
                    }
                }

#endif
            default:
                Text("Error")
            }
        }
#if os(iOS) || os(visionOS)
        .modify{
            if #unavailable(iOS 17.0), family != .accessoryRectangular{
                $0.padding().background(Color(hex: entry.timeSlot?.classEntity?.color1 ?? entry.timeSlot?.splitterEntity?.color1 ?? "60AFDB").gradient)
            }
            else{
                $0
            }
        }
#endif

    }
        else{
            
            switch family {
            case .accessoryRectangular:
                GeometryReader { GeometryProxy in

                                                  HStack{
                                                      Image(systemName: "beach.umbrella")
                                                          .font(.system(size: 33))
                                                      Text("Break Mode")

                                                  }
                                                  .frame(width: GeometryProxy.size.width, height: GeometryProxy.size.height)


                                          }
            case .accessoryCircular:
                GeometryReader { GeometryProxy in

                                                                  HStack{
                                                                      Image(systemName: "beach.umbrella")
                                                                  }
                                                                  .font(.system(size: 33))
                                                                  .frame(width: GeometryProxy.size.width, height: GeometryProxy.size.height)



                                                          }
            default:
                GeometryReader { GeometryProxy in
                                              VStack{
                                                  HStack{
                                                      // Umbrella Icon from SF Symbols
                                                      Image(systemName: "sun.max.fill")
                                                      // Umbrella Icon from SF Symbols
                                                      Image(systemName: "beach.umbrella")
                                                      // Umbrella Icon from SF Symbols
                                                      Image(systemName: "snowflake")
                                                      // Umbrella Icon from SF Symbols
                                                      Image(systemName: "car.side")
                                                  }
                                                  .font(.system(size: 35))
                                                  .frame(width: GeometryProxy.size.width, height: 30)

                                                  // Description
                                                  Text("Widgets are disabled\nin break mode.")
                                                      .padding(.horizontal, -10)
                                                      .font(.caption)
                                                      .padding(.top, 20)
                                                      .bold()
                                              }
                                              .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                                              .foregroundColor(Color(hex: entry.timeSlot?.classEntity?.color1 ?? entry.timeSlot?.splitterEntity?.color1 ?? "60AFDB").getBrightness() > 0.73 ? Color(hex: entry.timeSlot?.classEntity?.color1 ?? entry.timeSlot?.splitterEntity?.color1 ?? "60AFDB").darken(by: 0.5) : Color.white)
                                          }
            }


        }
    }
}

struct PlannerWidget: Widget {
    let kind: String = "PlannerWidget"

    var body: some WidgetConfiguration {


        AppIntentConfiguration(kind: kind, intent: PlannerWidgetIntents.self, provider: currentUpcomingPlannerProvider()) { entry in
            if #available(macOS 14.0, iOS 17.0, watchOS 10.0, *) {

                PlannerUpNextCurrentWidget(entry: entry)

                    .containerBackground(Color(hex: entry.timeSlot?.classEntity?.color1 ?? entry.timeSlot?.splitterEntity?.color1 ?? "60AFDB").gradient, for: .widget)




            } else {
                PlannerUpNextCurrentWidget(entry: entry)

            }
        }

        .configurationDisplayName("Planner")
        .description("Displays current/upcoming entry")
#if os(iOS) || os(visionOS)
        .supportedFamilies(
            [
                .systemSmall,
                .systemMedium,
                .accessoryRectangular
            ]
        )
        #elseif os(watchOS)

//        .supportedFamilies([.accessoryRectangular])
#elseif os(macOS)
        .supportedFamilies(
            [
                .systemSmall,
                .systemMedium,
            ]
        )
        #endif
    }
}

#endif

