// FIX: Use archive identifiers to keep this build and its data separate from the original app.
//
//  ScheduleManager.swift
//  KyoNeo
//
//  Created by Aether on 15/07/2023.
//

import SwiftUI
import CoreData

struct ScheduleData {
    var day: Day
    var onOtherDay: Bool = false
}

struct ScheduleManager {
    @AppStorage("schedule_SingleDayMode", store: UserDefaults(suiteName: "group.com.example.kyoarchive")) var schedule_SingleDayMode: Bool = false

    var context: NSManagedObjectContext {
            PersistenceController.shared.container.viewContext
    }
    var debug: Bool
    var weekWizard: WeekWizard
    var findOnlyNonEmptyDays: Bool
    var findNextWithUpcomingCurrentSlots: Bool

    init(debug: Bool = false, customWeekWizard: WeekWizard? = nil, findOnlyNonEmptyDays: Bool  = false, findNextWithUpcomingCurrentSlots: Bool  = false, fromCode: String? = nil) {
        self.debug = debug
        self.findOnlyNonEmptyDays = findOnlyNonEmptyDays
        self.findNextWithUpcomingCurrentSlots = findNextWithUpcomingCurrentSlots
        self.weekWizard = customWeekWizard ?? WeekWizard(customMessage: "backup - non provided")

        if let fromCode{
            log("[ScheduleManager] [init] from: \(fromCode)", debug: debug)
        }
    }

    var weeks: [Week] {
            let request: NSFetchRequest<Week> = Week.fetchRequest()
            let sort = NSSortDescriptor(key: "number", ascending: true)

            let predicate = schedule_SingleDayMode ? NSPredicate(format: "singleDayWeek == %@", NSNumber(value: true)) : NSPredicate(format: "singleDayWeek == nil OR singleDayWeek == %@", NSNumber(value: false))
            request.predicate = predicate
            request.sortDescriptors = [sort]
            do {
                let weeks = try context.fetch(request)
                        for (index, week) in weeks.enumerated() {
                            week.number = Int64(index + 1)
                        }

                
                return weeks
            } catch {
                print("Error fetching Weeks: \(error.localizedDescription)")
                return []
            }
    }

    var days: [Day] {
            let request: NSFetchRequest<Day> = Day.fetchRequest()
            let sort = NSSortDescriptor(key: "number", ascending: true)
            request.sortDescriptors = [sort]
            do {
                return try context.fetch(request)
            } catch {
                print("Error fetching Days: \(error.localizedDescription)")
                return []
            }
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

    /**
     Retrieves the current day's schedule for a given week.

     - Parameter forWeek: The week number for which the schedule is to be retrieved.
     - Returns: A `Day` object representing the current day's schedule for the specified week.
     */
    func getCurrentDay(_ week: Int, forDate: Date = Date()) -> ScheduleData? {
        // Early return if there are no time slots and we're looking only for non-empty days or next with upcoming current slots
        if (findOnlyNonEmptyDays || findNextWithUpcomingCurrentSlots) && timeSlots.isEmpty {
            log("[ScheduleManager] No time slots available", debug: debug)
            return nil
        }

        let forWeek = schedule_SingleDayMode ? 0 : week
        log("[ScheduleManager] [Get Current Day] Start with week \(week) and date \(forDate)", debug: debug)

        let currentDayCode = schedule_SingleDayMode ? "Single0" : (TimeFormatter.getDayCode(date: forDate) ?? "")

        guard currentDayCode != "",
              let findWeek = findWeek(number: forWeek),
              let firstDay = days.first(where: { $0.week == findWeek && $0.name == currentDayCode }) else {
            log("[ScheduleManager] Precondition failed for \(currentDayCode):\(forWeek)", debug: debug)
            return getNextDay(previousSearchWeek: forWeek, forDayCode: currentDayCode)
        }

        if let timeSlotCount = firstDay.timeSlots?.count, timeSlotCount > 0 {
            log("[ScheduleManager] Found \(timeSlotCount) timeslot(s) for \(currentDayCode):\(forWeek)", debug: debug)

            if let timeSlots = (firstDay.timeSlots?.allObjects as? [TimeSlot])?.sorted(by: { TimeFormatter.toDate($0.endTime!, mode: .fullDate)! < TimeFormatter.toDate($1.endTime!, mode: .fullDate)! }),
               let lastTimeSlotEndTime = timeSlots.last?.endTime,
               let lastTimeSlotEndTimeDate = TimeFormatter.toDate(lastTimeSlotEndTime, mode: .fullDate),
               lastTimeSlotEndTimeDate < Date(),
               findNextWithUpcomingCurrentSlots,
               currentDayCode == firstDay.name {
                log("[ScheduleManager] Last time slot (with end time \(lastTimeSlotEndTime)) is inactive for \(currentDayCode):\(forWeek)", debug: debug)
                return getNextDay(previousSearchWeek: forWeek, forDayCode: currentDayCode)
            }

            log("[ScheduleManager] Returning \(currentDayCode):\(forWeek) with time slots", debug: debug)
            return ScheduleData(day: firstDay, onOtherDay: false)
        } else if !findOnlyNonEmptyDays {
            log("[ScheduleManager] Returning \(currentDayCode):\(forWeek) even though it has no time slots", debug: debug)
            return ScheduleData(day: firstDay, onOtherDay: false)
        }

        log("[ScheduleManager] No timeslots available for \(currentDayCode):\(forWeek)", debug: debug)
        return getNextDay(previousSearchWeek: forWeek, forDayCode: currentDayCode)
    }


    func getDay(forWeek: Int, forDayCode: String) -> ScheduleData?{

        let currentDayCode = forDayCode
        log("[ScheduleManager] [getDay] getting day for \(forDayCode):\(forWeek)", debug: debug)
            let dayFilter = days.filter { day in
                day.week?.number == Int64(forWeek) && day.name == forDayCode
            }
        if let todayCode = TimeFormatter.getDayCode(date: Date()) ,!(dayFilter.isEmpty){
                if dayFilter.first?.timeSlots?.count != 0{
                    log("[ScheduleManager] day \(currentDayCode):\(forWeek) had \(dayFilter.first?.timeSlots?.count) timeslots, returning! (Did not check for active state since it is assumed to be in the future)", debug: debug)
                    return ScheduleData(day: dayFilter[0], onOtherDay: true)
                }
                else if !findOnlyNonEmptyDays{
                    return ScheduleData(day: dayFilter[0], onOtherDay: true)
                }
                log("[ScheduleManager] day \(currentDayCode):\(forWeek) had no timeslots.. \(dayFilter.first?.timeSlots?.count)", debug: debug)
                return getNextDay(previousSearchWeek: forWeek, forDayCode: currentDayCode)
            }
            else if dayFilter.count > 1{
                log("[ScheduleManager] multiple \(currentDayCode) days for week \(forWeek) found", debug: debug)
                return nil
            }
            else{
                log("[ScheduleManager] could not find \(currentDayCode) for week \(forWeek), trying next", debug: debug)
                return getNextDay(previousSearchWeek: forWeek, forDayCode: forDayCode)
            }

    }

    func getNextDay(previousSearchWeek: Int, forDayCode: String) -> ScheduleData?{

        if let foundWeek = findWeek(number: previousSearchWeek){

            if let lastDayOfWeekName = getLastDayOfWeek(previousSearchWeek)?.name {
                // need to check if the last day of the week is before the current date, if it is, the week is over and we must move on
                log("[ScheduleManager] Last day in week \(previousSearchWeek) is \(lastDayOfWeekName), the current dayCode would be \(TimeFormatter.getDayCode(date: Date()) ?? "")", debug: debug)

                // checks if the day after the previous check is in the week
                if !(isFirstDayBeforeLast(firstDayInput: lastDayOfWeekName, lastDayInput: forDayCode)) && isFirstDayBeforeLast(firstDayInput: getNextDay(day: forDayCode), lastDayInput: lastDayOfWeekName){
                    log("[ScheduleManager] more days! hooray!", debug: debug)

                    return getDay(forWeek: previousSearchWeek, forDayCode: getNextDay(day: forDayCode))
                }

                else{
                    log("[ScheduleManager] no more days after in week: \(previousSearchWeek), need to check next week! (if it exists)", debug: debug)


                    if let nextWeek = weekWizard.getNextWeek(relativeTo: previousSearchWeek){
                        log("[ScheduleManager] found next week \(nextWeek)", debug: debug)
                        return getDay(forWeek: nextWeek, forDayCode:  "Mon")
                    }
                    else{
                        print("failed to get next week")
                    }
                }


            }

        }


        return nil
    }


    func getLastDayOfWeek(_ weekNumber: Int = 2) -> Day? {
        let days = self.days // Assuming you are inside a class or struct with the `days` property.
        let filteredDays = days.filter{ day in
            day.week?.number ?? 0 == weekNumber
        }
        guard let lastDay = filteredDays.last else {
            return nil // There are no days in the 'days' array.
        }
        return lastDay
    }

    func isFirstDayBeforeLast(firstDayInput: String, lastDayInput: String) -> Bool {
        let weekdays = [ "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

//        log("[ScheduleManager] [isFirstDayBeforeLast] recieved input \(firstDayInput) \(lastDayInput)", debug: debug)

        guard let firstWeekdayIndex = weekdays.firstIndex(of: firstDayInput == "Single0" ? "Mon" : firstDayInput),
              let lastWeekdayIndex = weekdays.firstIndex(of: lastDayInput == "Single0" ? "Mon" :  lastDayInput) else {
            fatalError("Invalid input. Both days must be valid day abbreviations (e.g., 'Mon', 'Tue')")
        }

//        log("[ScheduleManager] [isFirstDayBeforeLast] checking if the 'last day' is before the day we're looking at", debug: debug)

//        log("[ScheduleManager] [isFirstDayBeforeLast] is \(firstDayInput) before \(lastDayInput)? \(firstWeekdayIndex < lastWeekdayIndex)", debug: debug)

        if firstWeekdayIndex == lastWeekdayIndex {
//            log("[ScheduleManager] [isFirstDayBeforeLast] days were the same, so returning false for logic", debug: debug)
            return true
        } else if firstWeekdayIndex == 0 { // 0 corresponds to Sunday
            return false
        }

        return firstWeekdayIndex < lastWeekdayIndex
    }



    func getNextDay(day: String) -> String {
        log("[ScheduleManager] [getNextDay] Recived \(day)", debug: debug)
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en") // Use English language for day abbreviations
        dateFormatter.dateFormat = "EEE"

        guard let inputDate = dateFormatter.date(from: day) else {
//            fatalError("Invalid input: \(day)") // Handle the error by crashing in this example, but you can choose other error-handling strategies.
            return "Mon"

        }

        let calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.day = 1

            log("[ScheduleManager] [getNextDay] Adding 1 to \(day)", debug: debug)
        guard let nextDate = calendar.date(byAdding: dateComponents, to: inputDate) else {
            fatalError("Could not calculate the next day.") // Handle the error by crashing in this example, but you can choose other error-handling strategies.
        }

            log("[ScheduleManager] [getNextDay] Returning \(dateFormatter.string(from: nextDate)) from orig: \(day)", debug: debug)
        return dateFormatter.string(from: nextDate)
    }

    private func findWeek(number: Int) -> Week?{
        let weekFilter = weeks.filter { week in
            week.number == number
        }.prefix(1)
        if weekFilter.count == 1{
            return weekFilter[0]
        }
        else if weekFilter.count > 1{
            log("multiple weeks with \(number) found", debug: debug)
            return nil
        }
        else{
            log("could not find week \(number)", debug: debug)
            return nil
        }
    }

    private func doesDayExistIn(_ week: Week){

    }
}


func decimalToFraction(_ number: Double) -> String {
    let roundedNumber = round(number * 100) / 100

    switch roundedNumber {
    case 0.5:
        return "½"
    case 0.25:
        return "¼"
    case 0.75:
        return "¾"
    case 0.33:
        return "⅓"
    case 0.67:
        return "⅔"
    case 0.2:
        return "⅕"
    case 0.4:
        return "⅖"
    case 0.6:
        return "⅗"
    case 0.8:
        return "⅘"
    case 0.125:
        return "⅛"
    case 0.375:
        return "⅜"
    case 0.625:
        return "⅝"
    case 0.875:
        return "⅞"
    default:
        let numberFormatter = NumberFormatter()
        if roundedNumber.truncatingRemainder(dividingBy: 1) == 0 {
            numberFormatter.minimumFractionDigits = 0
            numberFormatter.maximumFractionDigits = 0
        } else {
            numberFormatter.minimumFractionDigits = 1
            numberFormatter.maximumFractionDigits = 1
        }
        numberFormatter.roundingMode = .halfUp

        if let formattedString = numberFormatter.string(for: roundedNumber) {
            return formattedString
        } else {
            return "\(roundedNumber)"
        }
    }
}
