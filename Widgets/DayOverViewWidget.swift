//
//  DayOverViewWidget.swift
//  KyoNeo
//
//  Created by Aether on 12/11/2023.
//

#if canImport(WidgetKit)
import SwiftUI
import WidgetKit
import CoreData
import AppIntents



extension WidgetConfiguration
{
    func contentMarginsDisabledIfAvailable() -> some WidgetConfiguration
    {
        if #available(iOSApplicationExtension 17.0, *)
        {
            return self.contentMarginsDisabled()
        }
        else
        {
            return self
        }
    }
}

enum DetailsEnum: Int{
    case currnet
    case upcomping
    case all
    case none
}

struct DailyWidgetDetailsMode: AppEntity{
    var id: String
    var mode: Int

    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Details Mode"
    static var defaultQuery = DailyWidgetDetailsQuery()

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(id)")
    }

    static let allModes: [DailyWidgetDetailsMode] = [
        DailyWidgetDetailsMode(id: "Current", mode: DetailsEnum.currnet.rawValue),
        DailyWidgetDetailsMode(id: "Upcoming", mode: DetailsEnum.upcomping.rawValue),
        DailyWidgetDetailsMode(id: "All", mode: DetailsEnum.all.rawValue),
        DailyWidgetDetailsMode(id: "None", mode: DetailsEnum.none.rawValue)
    ]

}

struct DailyWidgetDetailsQuery: EntityQuery{
    func entities(for identifiers: [DailyWidgetDetailsMode.ID]) async throws -> [DailyWidgetDetailsMode] {
        DailyWidgetDetailsMode.allModes.filter {
            identifiers.contains($0.id)
        }
    }

    func suggestedEntities() async throws -> [DailyWidgetDetailsMode] {
        DailyWidgetDetailsMode.allModes
    }

    func defaultResult() async -> DailyWidgetDetailsMode? {
        DailyWidgetDetailsMode(id: "Upcoming", mode: DetailsEnum.upcomping.rawValue)
    }
}

struct PlannerDailyWidgetIntents: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Daily Planner Widgit"
    static var description = IntentDescription("Shows a daily overview your planenr for today or the next day")

    // An example configurable parameter.
    @Parameter(title: "Show Countdowns", default: true)
    var showCountdowns: Bool
    @Parameter(title: "Colourful", default: true)
    var colors: Bool
    @Parameter(title: "Force show next day", default: false)
    var nextDay: Bool
    @Parameter(title: "Hide first entry", default: false)
    var hideFirst: Bool
    @Parameter(title: "Show Details for")
    var detailSettings: DailyWidgetDetailsMode

}


//extension PlannerDailyWidgetIntents {
//    fileprivate static var def: PlannerDailyWidgetIntents {
//        let intent = PlannerDailyWidgetIntents()
//        intent.showCountdowns = true
//        intent.maxEntries = 6
//        intent.colors = true
//        return intent
//    }
//    fileprivate static var noCountDown: PlannerDailyWidgetIntents {
//        let intent = PlannerDailyWidgetIntents()
//        intent.showCountdowns = false
//        intent.maxEntries = 6
//        intent.colors = true
//        return intent
//    }
//}

struct DayOverViewWidget: Widget {
    let kind: String = "DayOverViewWidget"

    var body: some WidgetConfiguration {


        AppIntentConfiguration(kind: kind, intent: PlannerDailyWidgetIntents.self, provider: dayOverviewProvider()) { entry in
            if #available(macOS 14.0, iOS 17.0, watchOS 10.0, *) {
                DailyEntryWidget(providerEntry: entry)
//
                    .containerBackground(Color("bw").gradient, for: .widget)





            } else {
                DailyEntryWidget(providerEntry: entry)

            }
        }


        .configurationDisplayName("Up Next Daily")
        .description("Shows all entries for today or tomorrow")
        .supportedFamilies(
            [
                .systemSmall,
                .systemMedium,
                .systemLarge
            ]
        )
        .contentMarginsDisabledIfAvailable()

    }
}

extension Date {
   static var tomorrow:  Date { return Date().dayAfter }
   static var today: Date {return Date()}
   var dayAfter: Date {
      return Calendar.current.date(byAdding: .day, value: 1, to: Date())!
   }
}

struct dayOverviewProvider: AppIntentTimelineProvider {


    typealias Entry = DailyEntry

    typealias Intent = PlannerDailyWidgetIntents

    //    @AppStorage("schedule_SelectedDayID") var schedule_SelectedDayID: String?
    //    @AppStorage("schedule_SelectedWeek") var schedule_SelectedWeek: Int = 1
    //    @AppStorage("useCustomScheduleValues", store: UserDefaults(suiteName: "group.com.example.kyoarchive")) var useCustomScheduleValues: Bool = false

    func recommendations() -> [AppIntentRecommendation<PlannerDailyWidgetIntents>] {
        // Create an array with all the preconfigured widgets to show.
        [AppIntentRecommendation(intent: PlannerDailyWidgetIntents(), description: "Example Widget")]
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
        print("fetched timeSlots! \(dayName) \(weekNumber)")

        return request
    }


    func fetchAllTimeSlots(context: NSManagedObjectContext) -> NSFetchRequest<TimeSlot> {
        let request: NSFetchRequest<TimeSlot> = TimeSlot.fetchRequest()
        request.sortDescriptors = [
//            NSSortDescriptor(keyPath: \TimeSlot.day?.week?.number, ascending: true),
//            NSSortDescriptor(keyPath: \TimeSlot.day?.number, ascending: true),
            NSSortDescriptor(keyPath: \TimeSlot.timestamp, ascending: true)
        ]
        print("fetched ALL timeSlots!")

        return request
    }

    func fetchWeeks(context: NSManagedObjectContext) -> NSFetchRequest<Week>{
        let request: NSFetchRequest<Week> = Week.fetchRequest()
        return request
    }

    func placeholder(in context: Context) -> DailyEntry {
//        do {
//            let timeSlots = try viewContext.fetch(fetchTimeSlots(for: "Tue", weekNumber: 1, context: viewContext))
//            let slot = timeSlots.first
//            let entry = PlannerEntry(date: Date(), timeSlot: slot, state: .upcoming)
//            if slot == nil{
//                print("slot no ):")
//            }
//            else{
//
//                print("slot (:")
//            }
//            return entry
//        }
//        catch {
//            print("placeholder fallback!")
//            return PlannerEntry(date: Date())
//        }

        return DailyEntry(date: Date(), timeSlots: [])

    }

//    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
    func snapshot(for configuration: PlannerDailyWidgetIntents, in context: Context) async -> DailyEntry {

        return DailyEntry(date: Date(), timeSlots: [])
    }

//    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
    func timeline(for configuration: PlannerDailyWidgetIntents, in context: Context) async -> Timeline<DailyEntry> {
        var entries: [DailyEntry] = []
        var timeline = Timeline(entries: entries, policy: .atEnd)

        let scheduleManager = ScheduleManager(debug: true, findOnlyNonEmptyDays: true, findNextWithUpcomingCurrentSlots: true)

        print("getting timeline!!!")

        var weekWizard = WeekWizard()

        let actualCurrentWeek = weekWizard.getCurrentWeek() ?? 1
        let currentDayCode = TimeFormatter.getDayCode(date: Date())

        var nextDay = configuration.nextDay
        let scheduleData = (scheduleManager.getCurrentDay(actualCurrentWeek, forDate: nextDay ? Date.tomorrow : Date.today))



        let showDetails = configuration.detailSettings
        let showCountdowns = configuration.showCountdowns == true

        let color = configuration.colors
        let hideFirst = configuration.hideFirst
        let fillSpace = /*configuration.fillSpace*/ false

        let upcomingVarToUse: timeState = nextDay ? .upcomingOnOtherDay : .upcoming

        if let usingDay = scheduleData?.day.name, let usingWeek64 = scheduleData?.day.week?.number, currentDayCode != (scheduleManager.getCurrentDay(Int(usingWeek64))?.day.name!) || actualCurrentWeek != Int(usingWeek64){
        // print("adjusting settings \(timeSlots.count)")
            nextDay = true
    }
        do{
            let allTimeSlots = try viewContext.fetch(fetchAllTimeSlots(context: viewContext))
            print(allTimeSlots.count)
            print(allTimeSlots.endIndex)
            if !(allTimeSlots.isEmpty){
            entries = []




                if let usingDay = (scheduleData?.day.name), let usingWeek64 = (scheduleData?.day.week?.number){
                let usingWeek = Int(usingWeek64)
                let timeSlots = try viewContext.fetch(fetchTimeSlots(for: usingDay, weekNumber: usingWeek, context: viewContext))

                    let upcomingLaterOnVarToUse: timeState = nextDay ? .upcomingOnOtherDay : .upcomingLater

                    let scheduleData = (scheduleManager.getCurrentDay(actualCurrentWeek, forDate: nextDay ? Date.tomorrow : Date.today))
                    let timeSlotState: timeState = (scheduleData?.onOtherDay ?? false) ? upcomingLaterOnVarToUse : .current

                var upcomingOrComingSlots = timeSlots.filter{ slot in
                    return !((TimeFormatter.toDate(slot.endTime ?? "", mode: .fullDate) ?? Date()) < Date())
                }

                    if currentDayCode != (scheduleManager.getCurrentDay(usingWeek)?.day.name!) || actualCurrentWeek != usingWeek{
                    // print("adjusting settings \(timeSlots.count)")
                      

                        upcomingOrComingSlots = timeSlots
                }

                print("adding timeSlots to entries now \(upcomingOrComingSlots.count)")
                    for (index, timeSlot) in upcomingOrComingSlots.enumerated(){
                    if let startString = timeSlot.startTime, let startTime = TimeFormatter.toDate(startString, mode: .fullDate){

//                        if timeSlotState == upcomingLaterOnVarToUse{
//                            log("[getTimeline] Creating other day entry with upcoming state and attached date: \(Date())", debug: debug)
//                            let newEntry = PlannerEntry(date: Date(), timeSlot: timeSlot, state: upcomingLaterOnVarToUse, dayName: usingDay, weekNumber: usingWeek, showDetails: showDetails, showCountdowns: showCountdowns)
//                            entries.append(newEntry)
//                        }
//                        else 
                        print("at index \(index), \(timeSlot.classEntity?.name ?? "noClassName")")
                        if index == 0{
                            print("at index 0!")
                            if Date() < startTime {
                                log("[getTimeline] Creating intro entry with upcoming state and attached date: \(Date())", debug: debug)
//                                let newEntry = PlannerEntry(date: Date(), timeSlot: timeSlot, state: timeSlotState == .current ? .upcoming : upcomingLaterOnVarToUse, dayName: usingDay, weekNumber: usingWeek, showDetails: showDetails, showCountdowns: showCountdowns)
//                                entries.append(newEntry)
                                var slots: [PlannerEntry] = []
                                for (index, timeSlot2) in upcomingOrComingSlots.enumerated(){
                                    if timeSlot2 != timeSlot{

                                        let state: timeState = nextDay ? .upcomingOnOtherDay : (index - (upcomingOrComingSlots.firstIndex(of: timeSlot) ?? -1)) == 1 ? .upcoming : .upcomingLater

                                        let newEntry = PlannerEntry(date: Date(), timeSlot: timeSlot2, state: state, dayName: usingDay, weekNumber: usingWeek, showCountdowns: showCountdowns)
                                        slots.append(newEntry)
                                    }
                                    else{
                                        let newEntry = PlannerEntry(date: Date(), timeSlot: timeSlot, state: timeSlotState == .current ? upcomingVarToUse : upcomingLaterOnVarToUse, dayName: usingDay, weekNumber: usingWeek,  showCountdowns: showCountdowns)
                                        slots.append(newEntry)
                                    }
                                }

                                entries.append(DailyEntry(date: Date(), timeSlots: slots, showCountdowns: showCountdowns, showDetails: showDetails,  colors: color, hideFirst: hideFirst, fillSpace: fillSpace))
                            }
                            else{

                                print("current date is not before start time, must be current !")
                                var slots: [PlannerEntry] = []
                                for (index, timeSlot2) in upcomingOrComingSlots.enumerated(){
                                    if timeSlot2 != timeSlot{
                                        let state: timeState = nextDay ? .upcomingOnOtherDay : (index - (upcomingOrComingSlots.firstIndex(of: timeSlot) ?? -1)) == 1 ? .upcoming : .upcomingLater

                                        let newEntry = PlannerEntry(date: Date(), timeSlot: timeSlot2, state: state, dayName: usingDay, weekNumber: usingWeek,  showCountdowns: showCountdowns)
                                        slots.append(newEntry)
                                    }
                                    else{
                                        let newEntry = PlannerEntry(date: Date(), timeSlot: timeSlot, state: timeSlotState == .current ?  nextDay ? .upcomingOnOtherDay : .current : upcomingLaterOnVarToUse, dayName: usingDay, weekNumber: usingWeek, showCountdowns: showCountdowns)
                                        slots.append(newEntry)
                                    }
                                }

                                entries.append(DailyEntry(date: Date(), timeSlots: slots, showCountdowns: showCountdowns, showDetails: showDetails,  colors: color, hideFirst: hideFirst, fillSpace: fillSpace))
                            }
                        }
                        else if startString != upcomingOrComingSlots[index - 1].endTime{

                            log("[getTimeline] Creating intermediate entry with upcoming state and attached date: \(Date())", debug: debug)
                            if let previousEndDateString = upcomingOrComingSlots[index - 1].endTime, let previousEndDate = TimeFormatter.toDate(previousEndDateString, mode: .fullDate) {
//                              
                                var slots: [PlannerEntry] = []
                                for (index, timeSlot2) in upcomingOrComingSlots.enumerated(){
                                    if timeSlot2 != timeSlot{
                                        let state: timeState = nextDay ? .upcomingOnOtherDay : (index - (upcomingOrComingSlots.firstIndex(of: timeSlot) ?? -1)) == 1 ? .upcoming : .upcomingLater

                                        let newEntry = PlannerEntry(date: Date(), timeSlot: timeSlot2, state: state, dayName: usingDay, weekNumber: usingWeek,  showCountdowns: showCountdowns)
                                        slots.append(newEntry)
                                    }
                                    else{
                                        let newEntry = PlannerEntry(date: Date(), timeSlot: timeSlot, state: upcomingVarToUse, dayName: usingDay, weekNumber: usingWeek,  showCountdowns: showCountdowns)

                                        if !nextDay{
                                            slots = Array(slots.suffix(from: index))
                                        }

                                        slots.append(newEntry)
                                    }
                                }

                                entries.append(DailyEntry(date: previousEndDate, timeSlots: slots, showCountdowns: showCountdowns, showDetails: showDetails,  colors: color, hideFirst: hideFirst, fillSpace: fillSpace))


                            }
                            else{
                                log("[getTimeline] Warning, could not create intermediate entry, could not get/compute previous date", debug: debug)
                            }
                        }
                        else if startString == upcomingOrComingSlots[index - 1].endTime{


                            if let previousEndDateString = upcomingOrComingSlots[index - 1].endTime, let previousEndDate = TimeFormatter.toDate(previousEndDateString, mode: .fullDate) {
//                              
                                var slots: [PlannerEntry] = []
                                for (index, timeSlot2) in upcomingOrComingSlots.enumerated(){
                                    if timeSlot2 != timeSlot{
                                        let state: timeState = nextDay ? .upcomingOnOtherDay : (index - (upcomingOrComingSlots.firstIndex(of: timeSlot) ?? -1)) == 1 ? .upcoming : .upcomingLater

                                        let newEntry = PlannerEntry(date: Date(), timeSlot: timeSlot2, state: state, dayName: usingDay, weekNumber: usingWeek,  showCountdowns: showCountdowns)
                                        slots.append(newEntry)
                                    }
                                    else{
                                        let newEntry = PlannerEntry(date: Date(), timeSlot: timeSlot, state: nextDay ? .upcomingOnOtherDay : .current, dayName: usingDay, weekNumber: usingWeek, showCountdowns: showCountdowns)

                                        if !nextDay{
                                            slots = Array(slots.suffix(from: index))
                                        }

                                        slots.append(newEntry)
                                    }
                                }

                                if slots.count > 6 {
                                    entries.append(DailyEntry(date: previousEndDate, timeSlots: slots, showCountdowns: showCountdowns, showDetails: showDetails,  colors: color, hideFirst: hideFirst, fillSpace: fillSpace))
                                } else {
                                    // Handle the case where there are fewer than 6 elements in slots
                                    // You can choose to append all elements or handle it in another way based on your requirements.
                                    entries.append(DailyEntry(date: previousEndDate, timeSlots: slots, showCountdowns: showCountdowns, showDetails: showDetails,  colors: color, hideFirst: hideFirst, fillSpace: fillSpace))
                                }

                                log("[getTimeline] Creating direct-next entry with upcoming state and attached date: \(previousEndDate)", debug: debug)

                            }
                            else{
                                log("[getTimeline] Warning, could not create intermediate entry, could not get/compute previous date", debug: debug)
                            }
                        }



                        if timeSlotState == upcomingLaterOnVarToUse{
                            if let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: Date()),
                               let nextDayWithTime = Calendar.current.date(bySettingHour: 0, minute: 5, second: 0, of: nextDay) {

                                log("[getTimeline] Added a refresh for other day entry, for midnight", debug: debug)
//                                let newEntry = PlannerEntry(date: nextDayWithTime, timeSlot: timeSlot, state: timeSlotState, dayName: usingDay, weekNumber: usingWeek, showDetails: showDetails, showCountdowns: showCountdowns)
//                                entries.append(newEntry)

                                var slots: [PlannerEntry] = []
                                for (index, timeSlot2) in upcomingOrComingSlots.enumerated(){
                                    print("add item")
                                    if timeSlot2 != upcomingOrComingSlots.first{
                                        let newEntry = PlannerEntry(date: Date(), timeSlot: timeSlot, state: timeSlotState, dayName: usingDay, weekNumber: usingWeek,  showCountdowns: showCountdowns)
                                        slots.append(newEntry)
                                    }
                                    else{
                                        let newEntry = PlannerEntry(date: Date(), timeSlot: timeSlot, state: upcomingVarToUse, dayName: usingDay, weekNumber: usingWeek, showCountdowns: showCountdowns)
                                        slots.append(newEntry)
                                    }
                                }

                                entries.append(DailyEntry(date: nextDayWithTime, timeSlots: slots, showCountdowns: showCountdowns, showDetails: showDetails,  colors: color, hideFirst: hideFirst, fillSpace: fillSpace))
                            }

                        }

                    }


                }
                if upcomingOrComingSlots.isEmpty{
//                    let entry = PlannerEntry(date: Date(), state: .error, showDetails: showDetails, showCountdowns: showCountdowns)
//                    entries.append(entry)
                } else{
                    let refreshDateString = upcomingOrComingSlots.last?.endTime
                    let refreshDate = TimeFormatter.toDate(refreshDateString!, mode: .fullDate)!
//                    let endOfDay = PlannerEntry(date: refreshDate, endOfDayNotice: true, showDetails: showDetails, showCountdowns: showCountdowns)
//                    entries.append(endOfDay)
//                    print("added end of day entry at \(refreshDate)")
                    entries.append(DailyEntry(date: refreshDate, timeSlots: [PlannerEntry(date: Date(), timeSlot: timeSlots.first!)], showCountdowns: showCountdowns, showDetails: showDetails,  colors: color, hideFirst: hideFirst, fillSpace: fillSpace))


                }

                    timeline = Timeline(entries: entries, policy: .atEnd)


            }






        }
            else{

                    print("NO TIMESLOTS!")
//                    let emptyNotice = PlannerEntry(date: Date(), state: .error, showCountdowns: showCountdowns)
//                    entries.append(emptyNotice)
                entries.append(DailyEntry(date: Date(), timeSlots: [], showCountdowns: showCountdowns, showDetails: showDetails,  colors: color, hideFirst: hideFirst, fillSpace: fillSpace))

                timeline = Timeline(entries: entries, policy: .atEnd)
            }

            print("refresh at \(timeline.policy.self)")
            print("entries! \(entries)")
            for entry in entries {
                print("entry date \(entry.date)")
            }
            return timeline
        } catch {
            print("Widget failed to fetch days in timeline!")
        }

//        let emptyNotice = PlannerEntry(date: Date(), state: .error, showCountdowns: showCountdowns)
//        entries.append(emptyNotice)
        entries.append(DailyEntry(date: Date(), timeSlots: [], showCountdowns: showCountdowns, showDetails: showDetails,  colors: color, hideFirst: hideFirst, fillSpace: fillSpace))

        for entry in entries {
            print("entry date \(entry.date)")
        }
        return Timeline(entries: entries, policy: .atEnd)

    }
}

struct DailyEntry: TimelineEntry {
    let date: Date
    var timeSlots: [PlannerEntry]

    // parameters
    var showCountdowns: Bool = true
    var showDetails: DailyWidgetDetailsMode = DailyWidgetDetailsMode(id: "Upcoming", mode: DetailsEnum.upcomping.rawValue)
    var maxEntries: Int = 6
    var colors: Bool = true
    var hideFirst: Bool = false
    var fillSpace: Bool = false
}

struct DailyEntryWidget : View {
    @Environment(\.showsWidgetContainerBackground) var showsWidgetContainerBackground

    var providerEntry: dayOverviewProvider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        GeometryReader { GeometryProxy in

                let maxEntries = providerEntry.maxEntries
                let colors = providerEntry.colors
                let hideFirst = providerEntry.hideFirst
                let hideX = (hideFirst && providerEntry.timeSlots.count > 1) ? Array(providerEntry.timeSlots.suffix(from: 1)) : providerEntry.timeSlots

            let currentShown = !(hideX.filter{ element in
                element.state == .current
            }.isEmpty)

            let currentCount = providerEntry.showDetails.mode != DetailsEnum.none.rawValue || providerEntry.showDetails.mode != DetailsEnum.all.rawValue ? hideX.filter{ element in
                providerEntry.showDetails.mode == DetailsEnum.currnet.rawValue ?
                element.state == .current :  element.state == .upcoming
            }.count : 0

            let slotsInStack = family == .systemMedium || family == .systemSmall ? (providerEntry.showDetails.mode == DetailsEnum.all.rawValue ? 2 : currentCount != 0 ? 2 : 3) : (providerEntry.showDetails.mode == DetailsEnum.all.rawValue ? 5 : currentCount != 0 && (providerEntry.showDetails.mode == DetailsEnum.currnet.rawValue || providerEntry.showDetails.mode == DetailsEnum.upcomping.rawValue) ? 6 : 6)

            let x = hideX.count > slotsInStack ? Array(hideX.prefix(upTo: slotsInStack)) : hideX

                let moreToBeShow = hideX.count != x.count

                let splitterCount = x.filter{ element in
                    element.timeSlot?.splitterEntity != nil
                }.count



            VStack(spacing: 0){
                //                        ForEach(Array(tasksFilter.enumerated()), id: \.element) { index, task in
                ForEach(Array(x.enumerated()), id: \.offset){ index, entry in
                    let timeSlot = entry.timeSlot!
                    ZStack{

                        let color1 = Color(hex: timeSlot.classEntity?.color1 ?? timeSlot.splitterEntity?.color1 ?? "")
                        let color2 = Color(hex: timeSlot.classEntity?.color2 ?? timeSlot.splitterEntity?.color2 ?? "")


                        let brightness1 = color1.getBrightness()

                        VStack(spacing: 0){
                            if timeSlot.classEntity != nil{
                                HStack{
                                    if family != .systemSmall{
                                        Image(systemName: timeSlot.classEntity?.icon ?? "book.closed")
                                            .frame(width: 40, height: 40)
                                            .font(.system(size: 23))
                                    }

                                VStack(alignment: .leading, spacing: 4){



                                        HStack{
                                            ViewThatFits(in: .vertical) {
                                                if family != .systemSmall{
                                                    Text(timeSlot.classEntity?.name ?? "A")

                                                        .lineLimit(2)
                                                }

                                                Text((timeSlot.classEntity?.name ?? "A").shortenedClassName(maxLength: family == .systemSmall ? 20 : 50))
                                                    .lineLimit(1)
                                                    .minimumScaleFactor(0.5)

                                            }
                                            //                            .textCase(.uppercase)
                                                .font(.body.weight(.semibold))

                                                .italic(timeSlot.muted)
                                            Spacer()
                                            if timeSlot.muted{
                                                Image(systemName: "bell.slash")
                                                    .transition(.blur.animation(.smooth))
                                            }
                                        }


                                    switch entry.state {
                                    case .error:
                                        Group{
                                            Text("State Error")
                                                .font(.footnote.weight(.regular))
                                        }
                                    case .upcoming:
                                        HStack{

                                                Text(timeSlot.startTime ?? "")
                                                    .font(.footnote.weight(.regular))

                                            if let startString = timeSlot.startTime, let date = TimeFormatter.toDate(startString, mode: .fullDate), entry.showCountdowns && family != .systemSmall, !currentShown{
                                                Text("in \(date, style: .timer)")
                                                    .font(.footnote)
                                                    .opacity(0.7)
                                                    .monospacedDigit()
                                            }
                                            else{

                                                    Text("Up Next")
                                                        .font(.footnote)
                                                        .opacity(0.7)
                                            }
                                        }
                                    case .upcomingLater:

                                        if family != .systemSmall{
                                            Group{
                                                Text(timeSlot.startTime ?? "")
                                                    .font(.footnote.weight(.regular))
                                                +
                                                Text(" - ")
                                                    .font(.footnote.weight(.regular))
                                                +
                                                Text(timeSlot.endTime ?? "")
                                                    .font(.footnote.weight(.regular))
                                            }
                                        }
                                        else{
                                            Group{
                                                Text(timeSlot.startTime ?? "")
                                                    .font(.footnote.weight(.regular))
                                                +
                                                Text(" - ")
                                                    .font(.footnote.weight(.regular))
                                                +
                                                Text(timeSlot.endTime ?? "")
                                                    .font(.footnote.weight(.regular))
                                            }
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.5)
                                        }
                                    case .upcomingOnOtherDay:
                                        if family != .systemSmall{
                                            HStack{
                                                if let weekNum = entry.weekNumber, let dayName = entry.dayName, let w = WeekWizard().getCurrentWeek(){
                                                    Group {
                                                        let daysBetween = TimeHelper.calculateDaysBetween(start: TimeFormatter.getDayCode(date: Date()) ?? "Mon", end: dayName)

                                                        if abs(w - weekNum) == 1 && index == 0 && daysBetween == 7{
                                                            Text("Next Week")
                                                        } else if daysBetween == 1 && index == 0  {
                                                            Text("Tomorrow, \(timeSlot.startTime ?? "")")
                                                        }  else if daysBetween == 1 {
                                                            Text("\(timeSlot.startTime ?? "")")
                                                        }
                                                        else if daysBetween < 7 && index == 0  {
                                                            Text("in ^[\(daysBetween) Day](inflect: true)")
                                                        }
                                                        else if index == 0 {
                                                            Text("In \(weekNum - 1) Weeks")
                                                        }
                                                        else{
                                                            Text("Later")
                                                        }
                                                    }
                                                    .font(.footnote.weight(.regular))
                                                }

                                            }
                                        }
                                        else{


                                                Group{
                                                    Text(timeSlot.startTime ?? "")
                                                        .font(.footnote.weight(.regular))
                                                    +
                                                    Text(" - ")
                                                        .font(.footnote.weight(.regular))
                                                    +
                                                    Text(timeSlot.endTime ?? "")
                                                        .font(.footnote.weight(.regular))
                                                }
                                                .lineLimit(1)
                                                .minimumScaleFactor(0.5)

                                        }
                                    case .past:

                                            Group{
                                                Text("Ended ")
                                                    .font(.footnote.weight(.regular))
                                                +
                                                Text(timeSlot.endTime ?? "")
                                                    .font(.footnote.weight(.regular))
                                            }
                                    case .current:
                                        HStack{
                                            if entry.showCountdowns{
                                                Text("\("Remaining") \(TimeFormatter.toDate((timeSlot.endTime ?? "")) ?? Date(), style: .timer)")
                                                    .monospacedDigit()
                                                    .font(.footnote.weight(.regular))
                                            }
                                            else{
                                                Text("Now")
                                                    .monospacedDigit()
                                                    .font(.footnote.weight(.regular))
                                            }


                                            Spacer()
                                            Text(Image(systemName: "arrow.right"))
                                                .font(.footnote.weight(.light))
                                            +
                                            Text(" " + (timeSlot.endTime ?? ""))
                                                .font(.footnote.weight(.regular))
                                        }
                //                        .textCase(.uppercase)

                                    case .today:
                                        Group{
                                            Text("State Error")
                                                .font(.footnote.weight(.regular))
                                        }
                                    default:
                                        EmptyView()
                                    }




                                    if ((timeSlot.room != "" || timeSlot.taughtBy != nil) && true) && (providerEntry.showDetails.mode == DetailsEnum.all.rawValue ? true : (entry.state == .current && providerEntry.showDetails.mode == DetailsEnum.currnet.rawValue || entry.state == .upcoming && providerEntry.showDetails.mode == DetailsEnum.upcomping.rawValue)) {


                                        HStack(spacing: 3){
                                            if let room = timeSlot.room, timeSlot.room != "" && findURL(in: room) == nil{
                                                Group{
                                                    Text(Image(systemName: "square.split.bottomrightquarter"))
                                                        .font(.caption.weight(.regular))
                                                    + Text(" ")
                                                        .font(.caption2)
                                                    + Text((room) + (timeSlot.taughtBy != nil ? "," : ""))
                                                        .font(.caption.weight(.regular))
                                                }
                                            }
                                            else if let room = timeSlot.room, findURL(in: room) != nil{
                                                Group{
                                                    Text(Image(systemName: getIconForURL(room)))
                                                        .font(.caption.weight(.regular))
                                                    + Text(" ")
                                                        .font(.caption2)
                                                    + Text((cleanUpURLForDisplay(room).shortenedClassName(maxLength: 23)) + (timeSlot.taughtBy != nil ? "," : ""))
                                                        .font(.caption.weight(.regular))
                                                }
                                            }
                                            if timeSlot.taughtBy != nil, let teacher = timeSlot.taughtBy?.name {
                                                Group{
                                                    Text(Image(systemName: "person"))
                                                        .font(.caption.weight(.regular))
                                                    + Text(" ")
                                                        .font(.caption2)
                                                    + Text((teacher))
                                                        .font(.caption.weight(.regular))
                                                }
                                            }


                                        }
                                        .transition(.blur)

                                    }
                                }

                            }



                                .padding(.horizontal, family != .systemSmall ? 15 : 12)

                                .frame(maxWidth: .infinity,
                                       maxHeight:

                                        ((GeometryProxy.size.height / CGFloat(slotsInStack))
                                         + ((20 * CGFloat(splitterCount)) / CGFloat(slotsInStack - splitterCount)))
                                       + (providerEntry.showDetails.mode == DetailsEnum.all.rawValue ? 20 : ((entry.state == .current && providerEntry.showDetails.mode == DetailsEnum.currnet.rawValue || entry.state == .upcoming && providerEntry.showDetails.mode == DetailsEnum.upcomping.rawValue) ? 20 : (currentCount != 0 && (providerEntry.showDetails.mode == DetailsEnum.currnet.rawValue || providerEntry.showDetails.mode == DetailsEnum.upcomping.rawValue) ? -20 : 0) / CGFloat(slotsInStack - currentCount)))

                                       , alignment: .leading)

                                .background(LinearGradient(gradient: Gradient(colors: [color1, color2]), startPoint: .topLeading, endPoint: .bottomTrailing).grayscale(colors ? 0 : 1).opacity(showsWidgetContainerBackground ? colors ? 1 : 0.2 : 0))
                                .foregroundStyle(colors ? brightness1 > 0.73 ? color1.darken(by: 0.5) : Color.white : Color.primary)
                                .overlay(Rectangle().frame(height: x.last?.timeSlot?.id == entry.timeSlot?.id ? 0.0 : 0.5).foregroundColor(Color.primary.opacity(0.20)), alignment: .bottom)

                                if x.count < slotsInStack && x.last?.timeSlot?.id == entry.timeSlot?.id{
                                    Text("That's all!")
                                        .bold()
                                        .italic()
                                        .opacity(0.7)
                                        .font(.caption.weight(.regular))
                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                        .background(LinearGradient(gradient: Gradient(colors: [color1.opacity(0.8), color2.opacity(0.73)]), startPoint: .top, endPoint: .bottom).grayscale(colors ? 0 : 1).opacity(showsWidgetContainerBackground ? colors ? 0.7 : 0.2 : 0))
                                }

                            }


                            else if let splitter = timeSlot.splitterEntity, splitter.type == SplitterType.divider.rawValue{
                                HStack{
                                    if family != .systemSmall{
                                        Color.clear
                                            .frame(width: 40, height: 1)
                                    }

                                    if family != .systemSmall{
                                        HStack{

                                            Text(timeSlot.splitterEntity?.name ?? "A")

                                            //                        .textCase(.uppercase)
                                                .font(.footnote.weight(.semibold))
                                                .lineLimit(1)
                                            Group{
                                                Text(timeSlot.startTime ?? "")
                                                    .font(.footnote.weight(.regular))
                                                +
                                                Text(" - ")
                                                    .font(.footnote.weight(.regular))
                                                +
                                                Text(timeSlot.endTime ?? "")
                                                    .font(.footnote.weight(.regular))
                                            }

                                        }
                                    }
                                    else{
                                        VStack(alignment: .leading){

                                            Text((timeSlot.splitterEntity?.name ?? "A").shortened(maxLength: 13))

                                            //                        .textCase(.uppercase)
                                                .font(.footnote.weight(.semibold))
                                                .lineLimit(1)
                                                .minimumScaleFactor(0.5)
                                            Group{
                                                Text(timeSlot.startTime ?? "")
                                                    .font(.footnote.weight(.regular))
                                                +
                                                Text(" - ")
                                                    .font(.footnote.weight(.regular))
                                                +
                                                Text(timeSlot.endTime ?? "")
                                                    .font(.footnote.weight(.regular))
                                            }
                                            .lineLimit(1)

                                            .minimumScaleFactor(0.5)

                                        }
                                    }

                                }
                                .frame(maxWidth: .infinity,
                                       maxHeight:

                                        ((GeometryProxy.size.height / CGFloat(slotsInStack))
                                         - 20)
                                         + (providerEntry.showDetails.mode == DetailsEnum.all.rawValue ? 0 : (entry.state == .current && providerEntry.showDetails.mode == DetailsEnum.currnet.rawValue || entry.state == .upcoming && providerEntry.showDetails.mode == DetailsEnum.upcomping.rawValue ? 20 : (currentCount != 0 && (providerEntry.showDetails.mode == DetailsEnum.currnet.rawValue || providerEntry.showDetails.mode == DetailsEnum.upcomping.rawValue) ? -20 : 0) / CGFloat(slotsInStack - currentCount)))

                                       , alignment: .leading)
                                .padding(.horizontal, family != .systemSmall ? 15 : 12)
                                .background(LinearGradient(gradient: Gradient(colors: [color1, color2]), startPoint: .topLeading, endPoint: .bottomTrailing).grayscale(colors ? 0 : 1).opacity(showsWidgetContainerBackground ? colors ? 1 : 0.2 : 0))
                                .foregroundStyle(colors ? brightness1 > 0.73 ? color1.darken(by: 0.5) : Color.white : Color.primary)
                                .overlay(Rectangle().frame(height: x.last?.timeSlot?.id == entry.timeSlot?.id ? 0.0 : 0.5).foregroundColor(Color.primary.opacity(0.20)), alignment: .bottom)


                            }
                            else if let splitter = timeSlot.splitterEntity, splitter.type == SplitterType.free.rawValue{
                                HStack{

                                    Image(systemName: "line.3.horizontal")
                                        .frame(width: 40, height: 40)
                                        .font(.system(size: 23))

                                VStack(alignment: .leading, spacing: 4){
                                    HStack{
                                        Text(splitter.name ?? "A")
                //                            .textCase(.uppercase)
                                            .font(.body.weight(.semibold))
                                            .lineLimit(1)

                                            .italic(timeSlot.muted)
                                        Spacer()
                                        if timeSlot.muted{
                                            Image(systemName: "bell.slash")
                                                .transition(.blur.animation(.smooth))
                                        }
                                    }
    //                                        switch currentState {
    //                                        case .error:
    //                                            Group{
    //                                                Text("State Error")
    //                                                    .font(.footnote.weight(.regular))
    //                                            }
    //                                        case .upcoming:
    //                                            Group{
    //                                                Text(timeSlot.startTime ?? "")
    //                                                    .font(.footnote.weight(.regular))
    //                                                +
    //                                                Text(" - ")
    //                                                    .font(.footnote.weight(.regular))
    //                                                +
    //                                                Text(timeSlot.endTime ?? "")
    //                                                    .font(.footnote.weight(.regular))
    //                                            }
    //                                        case upcomingLaterOnVarToUse:
    //                                            Group{
    //                                                Text("State Error")
    //                                                    .font(.footnote.weight(.regular))
    //                                            }
    //                                        case .past:
    //
    //                                                Group{
    //                                                    Text("Ended ")
    //                                                        .font(.footnote.weight(.regular))
    //                                                    +
    //                                                    Text(timeSlot.endTime ?? "")
    //                                                        .font(.footnote.weight(.regular))
    //                                                }
    //                                        case .current:
    //                                            HStack{
    //                                                Text("\("Remaining") \(TimeFormatter.toDate((timeSlot.endTime ?? "")) ?? Date(), style: .timer)")
    //                                                    .monospacedDigit()
    //                                                    .font(.footnote.weight(.regular))
    //
    //
    //
    //                                                Spacer()
    //                                                Text(Image(systemName: "arrow.right"))
    //                                                    .font(.footnote.weight(.light))
    //                                                +
    //                                                Text(" " + (timeSlot.endTime ?? ""))
    //                                                    .font(.footnote.weight(.regular))
    //                                            }
    //                    //                        .textCase(.uppercase)
    //                                                .animation(.smooth)
    //                                        case .today:
    //                                            Group{
    //                                                Text("State Error")
    //                                                    .font(.footnote.weight(.regular))
    //                                            }
    //                                        }




                                    if (timeSlot.room != "" || timeSlot.taughtBy != nil) {


                                        HStack(spacing: 3){
                                            if let room = timeSlot.room, timeSlot.room != "" && findURL(in: room) == nil{
                                                Group{
                                                    Text(Image(systemName: "square.split.bottomrightquarter"))
                                                        .font(.caption.weight(.regular))
                                                    + Text(" ")
                                                        .font(.caption2)
                                                    + Text((room) + (timeSlot.taughtBy != nil ? "," : ""))
                                                        .font(.caption.weight(.regular))
                                                }
                                            }
                                            else if let room = timeSlot.room, findURL(in: room) != nil{
                                                Group{
                                                    Text(Image(systemName: getIconForURL(room)))
                                                        .font(.caption.weight(.regular))
                                                    + Text(" ")
                                                        .font(.caption2)
                                                    + Text((cleanUpURLForDisplay(room).shortenedClassName(maxLength: 23)) + (timeSlot.taughtBy != nil ? "," : ""))
                                                        .font(.caption.weight(.regular))
                                                }
                                            }
                                            if timeSlot.taughtBy != nil, let teacher = timeSlot.taughtBy?.name {
                                                Group{
                                                    Text(Image(systemName: "person"))
                                                        .font(.caption.weight(.regular))
                                                    + Text(" ")
                                                        .font(.caption2)
                                                    + Text((teacher))
                                                        .font(.caption.weight(.regular))
                                                }
                                            }
                                        }
                                    }
                                }

                                }

                                .padding(.horizontal, family != .systemSmall ? 15 : 12)
                                .background(LinearGradient(gradient: Gradient(colors: [color1, color2]), startPoint: .topLeading, endPoint: .bottomTrailing).grayscale(colors ? 0 : 1).opacity(showsWidgetContainerBackground ? colors ? 1 : 0.2 : 0))
                                .foregroundStyle(colors ? brightness1 > 0.73 ? color1.darken(by: 0.5) : Color.white : Color.primary)
                                .overlay(Rectangle().frame(height: x.last?.timeSlot?.id == entry.timeSlot?.id ? 0.0 : 0.5).foregroundColor(Color.primary.opacity(0.20)), alignment: .bottom)

                            }
                        }




                    }


                }





            }
            .overlay(alignment: .bottom) {
                if moreToBeShow && family != .systemSmall{
                    Image(systemName: "arrow.down.circle")
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                        .padding()
                }
            }
        }
//#if os(iOS) || os(visionOS)
//        .modify{
//            if #unavailable(iOS 17.0), family != .accessoryRectangular{
//                $0.padding().background(Color(hex: entry.timeSlot?.classEntity?.color1 ?? entry.timeSlot?.splitterEntity?.color1 ?? "60AFDB").gradient)
//            }
//            else{
//                $0
//            }
//        }
//        #endif


    }
}
#endif
