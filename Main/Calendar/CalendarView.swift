//
//  CalendarView.swift
//  KyoNeo
//
//  Created by Aether on 30/08/2023.
//

import SwiftUI
import AmethystUI
import EventKit

extension Array {
    /// An array of events sorted by start date in ascending order.
    func sortedEventByAscendingDate() -> [EKEvent] {
        guard let self = self as? [EKEvent] else { return [] }

        return self.sorted(by: { (first: EKEvent, second: EKEvent) in
            return first.compareStartDate(with: second) == .orderedAscending
        })
    }
}

extension Date {

    /// The day of the week matching the specified date.
    var matchingDay: Int {
        Calendar.current.component(.weekday, from: self)
    }

    /// The next date for the given weekdays.
    func fetchNextDateFromDays(_ nextWeekDay: IndexSet) -> Date {
       var components: Int?
       let weekDay = Calendar.current.component(.weekday, from: self)

       if let nextWeekDay = nextWeekDay.integerGreaterThan(weekDay) {
           components = nextWeekDay
       } else {
           components = nextWeekDay.first
       }
       guard let foundWeekDay = components else { return self }
       return Calendar.current.nextDate(after: self, matching: DateComponents(weekday: foundWeekDay), matchingPolicy: .nextTime) ?? self
   }

    /// The formatted time of the date.
    var timeAsText: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }

    /// Thirty minutes from the current time.
    var thirtyMinutesLater: Date {
        Date(timeInterval: 1800, since: self)
    }

    /// A month from the current date.
    var oneMonthOut: Date {
        Calendar.current.date(byAdding: .month, value: 1, to: Date.now) ?? Date()
    }
}

enum EventStoreError: Error {
    case denied
    case restricted
    case unknown
    case upgrade
}

extension EventStoreError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .denied:
            return NSLocalizedString("The app doesn't have permission to Calendar in Settings.", comment: "Access denied")
         case .restricted:
            return NSLocalizedString("This device doesn't allow access to Calendar.", comment: "Access restricted")
        case .unknown:
            return NSLocalizedString("An unknown error occured.", comment: "Unknown error")
        case .upgrade:
            let access = "The app has write-only access to Calendar in Settings."
            let update = "Please grant it full access so the app can fetch and delete your events."
            return NSLocalizedString("\(access) \(update)", comment: "Upgrade to full access")
        }
    }
}

extension EventDataStore {

    var isFullAccessAuthorized: Bool {
        if #available(iOS 17.0, *) {
            EKEventStore.authorizationStatus(for: .event) == .fullAccess
        } else {
            // Fall back on earlier versions.
            EKEventStore.authorizationStatus(for: .event) == .authorized
        }
    }

    /// Prompts the user for full-access authorization to Calendar.
    private func requestFullAccess() async throws -> Bool {
        if #available(iOS 17.0, *) {
            return try await eventStore.requestFullAccessToEvents()
        } else {
            // Fall back on earlier versions.
            return try await eventStore.requestAccess(to: .event)
        }
    }

    /// Verifies the authorization status for the app.
    func verifyAuthorizationStatus() async throws -> Bool {
        let status = EKEventStore.authorizationStatus(for: .event)
        switch status {
        case .notDetermined:
            return try await requestFullAccess()
        case .restricted:
            throw EventStoreError.restricted
        case .denied:
            throw EventStoreError.denied
        case .fullAccess:
            return true
        case .writeOnly:
            throw EventStoreError.upgrade
        @unknown default:
            throw EventStoreError.unknown
        }
    }

    
    /// Fetches all events occuring within a month in all the user's calendars.
    func fetchEvents() -> [EKEvent] {
        guard isFullAccessAuthorized else { return [] }
        let start = Date.now
        let end = start.oneMonthOut
        let predicate = eventStore.predicateForEvents(withStart: start, end: end, calendars: nil)
        return eventStore.events(matching: predicate).sortedEventByAscendingDate()
    }

    func fetchEvents(for date: Date) -> [EKEvent] {

        // Create a calendar and set its timezone to match the desired date.
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: date)
        components.timeZone = TimeZone.current

        // Calculate the start and end dates for the specified day.
        let startDate = calendar.date(from: components)!
        let endDate = calendar.date(byAdding: .day, value: 1, to: startDate)!

        // Create a predicate to fetch events for the specified day.
        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: nil)

        // Fetch events that match the predicate.
        let events = eventStore.events(matching: predicate).sortedEventByAscendingDate()

        return events
    }

    /// Removes an event.
    private func removeEvent(_ event: EKEvent) throws {
        try self.eventStore.remove(event, span: .thisEvent, commit: false)
    }

    /// Batches all the remove operations.
    func removeEvents(_ events: [EKEvent]) throws {
        do {
            try events.forEach { event in
                try removeEvent(event)
            }
            try eventStore.commit()
         } catch {
             eventStore.reset()
             throw error
         }
    }
}

actor EventDataStore {
    let eventStore: EKEventStore

    init() {
        self.eventStore = EKEventStore()
    }
}

@MainActor
class EventStoreManager: ObservableObject {
    /// Contains fetched events when the app receives a full-access authorization status.
    @Published var events: [EKEvent]

    /// Specifies the authorization status for the app.
    @Published var authorizationStatus: EKAuthorizationStatus

    let dataStore: EventDataStore

    init(store: EventDataStore = EventDataStore()) {
        self.dataStore = store
        self.events = []
        self.authorizationStatus = EKEventStore.authorizationStatus(for: .event)
    }

    var isWriteOnlyOrFullAccessAuthorized: Bool {
        if #available(iOS 17.0, *) {
            return ((authorizationStatus == .writeOnly) || (authorizationStatus == .fullAccess))
        } else {
            // Fall back on earlier versions.
            return authorizationStatus == .authorized
        }
    }

}

@available(iOS 17.0, *)
struct CalendarView: View {


    var color: Color = Color.accentColor
    /// Scroll Logic
    @State var scrolled: Bool = false



    @StateObject private var storeManager: EventStoreManager = EventStoreManager()
    @State private var authorizationStatus: Bool = false

    @State private var fetchedEvents: [EKEvent] = []
    @State var selectedDate: Date = Date()
    init(color: Color) {
        self.color = color

        

    }
    @State var renderDateRangeIn = 0
    @State private var renderDateRange = 10

    var body: some View {
        GeometryReader(content: { GeometryProxy in
            ScrollView{
                ScrollDetector(scrolled: $scrolled)
    //            Button {
    //                Task {
    //                    do {
    //                        let isAuthorized = try await storeManager.dataStore.verifyAuthorizationStatus()
    //                        if isAuthorized {
    //                            print("Authorization successful")
    //                            // Authorization was successful, you can perform further actions here.
    //                        } else {
    //                            print("Authorization failed")
    //                            // Handle the case where authorization failed.
    //                        }
    //                    } catch let error {
    //                        print("Authorization error: \(error.localizedDescription)")
    //                        // Handle the error (e.g., denied, restricted, unknown, upgrade) here.
    //                    }
    //                }
    //            } label: {
    //
    //                Text("Get/Check Access")
    //            }



                DatePickerView(displayDate: $selectedDate)
                    .neoSettingsCard()
                    .padding(.horizontal, 20)
                    .tint(color)
                    .modify {
                        if #available(iOS 17.0, *) {
                            $0.scrollTransition { content, phase in
                                content
                                    .scaleEffect(phase.isIdentity ? 1 : 0.9)
                                    .offset(y: phase.isIdentity ? 0 : -30)
                            }

                        } else {
                            $0
                        }
                    }
                    .onAppear{
                        Task {
                            do {
                                let x = try await storeManager.dataStore.fetchEvents(for: selectedDate)
                                print(x.count)
                                print(x)
                                fetchedEvents = x
                            } catch let error {
                                print("Authorization error: \(error.localizedDescription)")
                                // Handle the error (e.g., denied, restricted, unknown, upgrade) here.
                            }
                        }
                    }
                    .onChange(of: selectedDate) { change in
                        Task {
                            do {
                                let x = try await storeManager.dataStore.fetchEvents(for: change)
                                print(x.count)
                                print(x)
                                fetchedEvents = x
                            } catch let error {
                                print("Authorization error: \(error.localizedDescription)")
                                // Handle the error (e.g., denied, restricted, unknown, upgrade) here.
                            }
                        }
                    }

                Divider()
                    .padding(.horizontal, 35)
                    .padding(.vertical, 10)
    //            ScrollView(.horizontal) {
    //                        HStack {
    //                            VStack{
//                                    ForEach(fetchedEvents, id: \.self) { event in
//                                        CalendarItem(event: event)
//                                            .transition(.blur.animation(.bouncy(duration: 0.35)))
//                                            .animation(.bouncy(duration: 0.35))
//                                            .padding(.bottom, 5)
//                                                }
    //                            }.scrollTargetLayout()
    //
    //                                VStack{
    //                                    ForEach(fetchedEvents, id: \.self) { event in
    //                                        CalendarItem(event: event)
    //                                            .transition(.blur.animation(.bouncy(duration: 0.35)))
    //                                            .animation(.bouncy(duration: 0.35))
    //                                            .padding(.bottom, 5)
    //                                                }
    //                                }.scrollTargetLayout()
    //                        }
    //
    //                    }
    //                    .scrollTargetBehavior(.viewAligned)
    //
    //
    //
    //
    //            .padding(.horizontal, 20)
                VStack{
                    ForEach(fetchedEvents, id: \.self) { event in
                        CalendarItem(event: event)
                            .transition(.blur.animation(.bouncy(duration: 0.35)))
                            .animation(.bouncy(duration: 0.35))
                            .padding(.bottom, 5)
                            .frame(width: GeometryProxy.size.width - 40)
                            .frame(width: GeometryProxy.size.width)
                                }
                }
//                Text("From \(renderDateRangeIn) to \(renderDateRange)")
//                ScrollView(.horizontal) {
//                    LazyHStack(spacing: 0){
//                        ForEach(renderDateRangeIn..<renderDateRange, id: \.self) { i in
//                                    VStack{
//
//                                        ForEach(fetchedEvents, id: \.self) { event in
//                                            CalendarItem(event: event)
//                                                .transition(.blur.animation(.bouncy(duration: 0.35)))
//                                                .animation(.bouncy(duration: 0.35))
//                                                .padding(.bottom, 5)
//                                                .frame(width: GeometryProxy.size.width - 40)
//                                                .frame(width: GeometryProxy.size.width)
//                                                    }
//
//                                    }
//                                    .onAppear{
//                                        print("show \(i)")
//                                        renderDateRange = renderDateRange + 1
//                                    }
//                                    .onDisappear{
//                                        print("hide \(i)")
//                                    }
//                                }
//                            }
//
//                        }
//                .scrollTargetBehavior(.paging)


    //            VStack {
    //                ForEach(storeManager.dataStore.eventsForDate, id: \.eventIdentifier) { event in
    //                        Text(event.title)
    //                        // You can display other event details as needed.
    //                    }
    //                }
                Color.clear.frame(height: 50)
            }

            .coordinateSpace(name: "scroll")
            .safeAreaInset(edge: .top, content: {
                Color.clear.frame(height: 100)
            })
            .animation(.smooth, value: selectedDate)
        })
        .overlay(alignment: .top) {
            FluidNavigationBar(title: "Calendar",   tintColor: color, scrolled: $scrolled) {
                HStack(spacing: 14){
                    Menu {
                        
                    } label: {
                        Image(systemName: "calendar")
                            .scaledFrame(width: 44, height: 44, relativeTo: .body)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(NavigationButton(color: color, scrolled: $scrolled))
                    
                    
                    Button {
                        
                    } label: {
                        Image(systemName: "plus")
                            .scaledFrame(width: 44, height: 44, relativeTo: .body)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(NavigationButton(color: color, scrolled: $scrolled))
                }

            } toolbar: {
                Text("^[\(fetchedEvents.count) Event](inflect: true) Found")
                    .contentTransition(.numericText(value: Double(fetchedEvents.count)))
                    .animation(.smooth, value: fetchedEvents.count)

            }

        }
    }
}

struct DatePickerView: View {
    @Binding var displayDate: Date

    let dateRange: ClosedRange<Date> = {
        let now = Date.now
        return now...Calendar.current.date(byAdding: .month, value: 1, to: now)!
    }()

    var body: some View {
        DatePicker(
                "Start Date",
                selection: $displayDate,
//                in: dateRange,
                displayedComponents: [.date]
        )
        .labelsHidden()
        .datePickerStyle(.graphical)
    }
}
