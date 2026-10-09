// FIX: Use archive identifiers to keep this build and its data separate from the original app.
//
//  WeekManager.swift
//  KyoNeo
//
//  Created by Aether on 14/07/2023.
//

import SwiftUI
import CoreData

class WeekWizard: ObservableObject {
    var context: NSManagedObjectContext {
                PersistenceController.shared.container.viewContext
        }

    private struct Keys {
        static let anchorWeekDate = "anchorWeekDate"
        static let schedule_SelectedWeekNumber = "schedule_SelectedWeekNumber"
        static let totalWeeks = "totalWeeks"
    }

    private var debug = true
    private var customMessage = ""
    var alertManager: AlertManager?

    @AppStorage(Keys.anchorWeekDate, store: UserDefaults(suiteName: "group.com.example.kyoarchive"))
    private var anchorWeekData: Data?

    var anchorWeekDate: Date? {
        get {
            guard let data = anchorWeekData else { return nil }
            return try? JSONDecoder().decode(Date.self, from: data)
        }
        set {
            anchorWeekData = try? JSONEncoder().encode(newValue)
        }
    }

    @AppStorage(Keys.schedule_SelectedWeekNumber, store: UserDefaults(suiteName: "group.com.example.kyoarchive"))
    var schedule_SelectedWeekNumber: Int?

//    @AppStorage(Keys.totalWeeks, store: UserDefaults(suiteName: "group.com.example.kyoarchive"))
//    var totalWeeks: Int?

    var totalWeeks: Int? {
        let request: NSFetchRequest<Week> = Week.fetchRequest()
        let sort = NSSortDescriptor(key: "number", ascending: true)

        let predicate = NSPredicate(format: "singleDayWeek == nil OR singleDayWeek == %@", NSNumber(value: false))
        request.predicate = predicate
        request.sortDescriptors = [sort]
        do {
            let weeks = try context.fetch(request)

            // Return the count of weeks instead of the weeks array
            if weeks.isEmpty { return nil} else { return weeks.count }
        } catch {
            print("Error fetching Weeks: \(error.localizedDescription)")
            return nil
        }
    }

    init(debug: Bool = true, alertManager: AlertManager? = nil, customMessage: String = "") {
        self.debug = debug
        self.alertManager = alertManager
        self.customMessage = customMessage

        log("[WeekWizard] [Init] Initlaised with debug \(debug) and alertManager \(alertManager), \(customMessage)", debug: debug)

//        (format: "singleDayWeek == nil OR singleDayWeek == %@", NSNumber(value: false))
    }

    func calculateWeekDifference(from startDate: Date, to endDate: Date) -> Int {
        log("[WeekWizard - calculateWeekDifference] Start", debug: debug)
        let calendar = Calendar.current
        let startWeek = calendar.component(.weekOfYear, from: startDate)
        let endWeek = calendar.component(.weekOfYear, from: endDate)

        var weekDifference = endWeek - startWeek

        if weekDifference < 0 {
            let numberOfWeeksInYear = calendar.range(of: .weekOfYear, in: .year, for: startDate)?.count ?? 52
            weekDifference += numberOfWeeksInYear
        }

        return weekDifference
    }

    func reset() {
        log("[WeekWizard - reset] Start", debug: debug)
        anchorWeekDate = nil
        schedule_SelectedWeekNumber = nil
    }

    func fallback(_ to: Int) {
        log("[WeekWizard - fallback] Start", debug: debug)
        anchorWeekDate = nil
        schedule_SelectedWeekNumber = to
    }

    func getCurrentWeek(_ forDate: Date = Date()) -> Int? {
        log("[WeekWizard] {getCurrentWeek} Begin", debug: debug)


        guard let anchorWeekDate = anchorWeekDate else {
            log("[WeekWizard] {getCurrentWeek} Couldn't get current week", debug: debug)
            if let alertManager = alertManager{
                alertManager.showAlert(title: "An error occured", message: "Failed to get current week") {
                    
                }
            }
            else{
                print("could not pass alert \(alertManager)")
            }

            return nil
        }

        let currentDate = forDate
        let weekDifference = calculateWeekDifference(from: anchorWeekDate, to: currentDate)

        var currentWeek = weekDifference
        if let schedule_SelectedWeekNumber = schedule_SelectedWeekNumber {
            currentWeek += schedule_SelectedWeekNumber
        }

        if let totalWeeks = totalWeeks {
            while currentWeek > totalWeeks {
                currentWeek -= totalWeeks
            }
        }

        log("[WeekWizard] {getCurrentWeek} Succes, returning: \(currentWeek)", debug: debug)
        return currentWeek
    }

    func getNextWeek() -> Int? {
        log("[WeekWizard - getNextWeek] Start", debug: debug)
        if let nextWeekDate = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: Date()) {
            return getCurrentWeek(nextWeekDate)
        }
        return nil
    }

    func getNextWeek(relativeTo referenceWeek: Int) -> Int? {
        log("[WeekWizard - getNextWeek(relativeTo:)] Start", debug: debug)
        if let totalWeeks = totalWeeks {
            var nextWeek = referenceWeek + 1
            if nextWeek > totalWeeks {
                nextWeek -= totalWeeks
            }
            return nextWeek
        }
        return nil
    }

    func calculateWeekWithOffset(for weekNum: Int) -> Int? {
        if let totalWeeks = totalWeeks {
            if weekNum > totalWeeks {
                return weekNum - totalWeeks
            } else {
                return weekNum
            }
        }
        return nil
    }

}




