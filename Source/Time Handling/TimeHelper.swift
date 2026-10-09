//
//  CurrentTime.swift
//  Kyo
//
//  Created by Aether on 16/09/2022.
//

import SwiftUI


enum taskTimeState: String, CaseIterable {
    case overdue = "Overdue"
    case today = "Today"
    case upcoming = "Upcoming"
    case completed = "Completed"
//    case all = "All"

    var symbol: String {
        switch self {
        case .today:
            return "pin"
        case .upcoming:
            return "alarm"
        case .overdue:
            return "exclamationmark.triangle"
        case .completed:
            return "checkmark"
//        case .all:
//            return "rectangle.grid.1x2"
        }
    }

    var number: Int {
        switch self {
        case .today:
            return 0
        case .upcoming:
            return 1
        case .overdue:
            return 2
        case .completed:
            return 3
//        case .all:
//            return 4
        }
    }
}

func getFullDayName(from abbreviation: String) -> String? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "E"

    guard let date = dateFormatter.date(from: abbreviation) else {
        return nil
    }

    dateFormatter.dateFormat = "EEEE"
    return dateFormatter.string(from: date)
}

struct TimeHelper {
    // Returns the current state of the given time, based on the current time and the given start and end times.
    static var debug = false
    // The startTime and endTime parameters should be strings in the format returned by the getFullDateFormat function.
    static func getRemainingMinutes(for input: String) -> Double{
        if let date = TimeFormatter.toDate(input, mode: .fullDate){
            
            return (date.hoursSinceMidnight() - Date().hoursSinceMidnight()) * 60
        }
        return -1
    }

    static func getTotalMinutes(for start: String, for end: String) -> Double{
        if let startDate = TimeFormatter.toDate(start, mode: .fullDate), let endDate = TimeFormatter.toDate(end, mode: .fullDate){

            return (endDate.hoursSinceMidnight() - startDate.hoursSinceMidnight()) * 60
        }
        return -1
    }
    static func getTimeState(startTime: String, endTime: String, currentTime: Date = Date()) -> timeState {

        // Convert the start and end times from strings to date objects.
        guard let start = (TimeFormatter.toDate(startTime)),
              let end = (TimeFormatter.toDate(endTime)) else {
            log("[TimeHelper, getTimeState] an error occured", debug: debug)
            return .error // Return upcoming if there's an error in date formatting
        }
        log("[TimeHelper, getTimeState] start is \(start), end is \(end), current is \(Date())", debug: debug)

        // If the current time is between start and end times, return .current time state.
        if currentTime.isBetween(start, and: end) {
            return .current
        }
        // If the end time has already passed, return .past time state.
        else if currentTime.hasPassed(date: end) {
            
            return .past
        }
        // Otherwise, return .upcoming time state.
        else {
            return .upcoming
        }
    }


    static func getTimeState(timeSlot: TimeSlot, currentTime: Date = Date()) -> timeState {

        // Convert the start and end times from strings to date objects.
        guard let startString = timeSlot.startTime,
              let endString = timeSlot.endTime,
              let start = (TimeFormatter.toDate(startString)),
              let end = (TimeFormatter.toDate(endString)) else {
            log("[TimeHelper, getTimeState] an error occured", debug: debug)
            return .error // Return upcoming if there's an error in date formatting
        }
        log("[TimeHelper, getTimeState] start is \(start), end is \(end), current is \(Date())", debug: debug)
        if let weekNum = timeSlot.day?.week?.number, let currentWeekNum = WeekWizard(customMessage: "from TimeHelper").getCurrentWeek(), timeSlot.day?.name != TimeFormatter.getDayCode(date: Date()) || weekNum != currentWeekNum{
            return .upcomingOnOtherDay
        }
        // If the current time is between start and end times, return .current time state.
        if currentTime.isBetween(start, and: end) {
            return .current
        }
        // If the end time has already passed, return .past time state.
        else if currentTime.hasPassed(date: end) {

            return .past
        }
        // Otherwise, return .upcoming time state.
        else {
            return .upcoming
        }
    }


    static func getTimeState(startTime: Date, endTime: Date, currentTime: Date = Date()) -> timeState {
        log("[TimeHelper, getTimeState] start is \(startTime), end is \(endTime), current is \(currentTime)", debug: debug)

        // If the current time is between start and end times, return .current time state.
        if currentTime.isBetween(startTime, and: endTime) {
            return .current
        }
        // If the end time has already passed, return .past time state.
        else if currentTime.hasPassed(date: endTime) {
            return .past
        }
        // Otherwise, return .upcoming time state.
        else {
            return .upcoming
        }
    }


    /**
     Returns the time state of a task's due date relative to the current date.

     - Parameter task: The `TaskEntity` instance representing the task to check.
     - Returns: A `taskTimeState` value representing the time state of the task's due date.
     */
    static func getTaskTimeState(task: TaskEntity) -> taskTimeState {
        let currentTime = Date()
        let calendar = Calendar.current

        // Safely unwrap the optional `due` date property of the `TaskEntity` object
        if let due = task.due {
            // If the task is due tomorrow, return .dueTomorrow time state.
//            if calendar.isDateInTomorrow(due) {
//                return .tomorrow
//            }
            // If the task is due today, return .today time state.
            if task.completed{
                return .completed
            }
            if calendar.isDateInToday(due) {
                return .today
            }
            // If the task was due yesterday, return .past time state.
            else if calendar.isDateInYesterday(due) {
                return .overdue
            }
            // If the task is due in the future, return .upcoming time state.
            else if due > currentTime {
                return .upcoming
            }
            // Otherwise, return .past time state.
            else {
                return .overdue
            }
        } else {
            // If the `due` date property is nil, return .noDueDate time state.
            return .upcoming
        }
    }

    static func calculateDaysBetween(start: String, end: String) -> Int {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE"

        guard let startDate = dateFormatter.date(from: start),
              let endDate = dateFormatter.date(from: end) else {
            return 0
        }

        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: startDate, to: endDate)

        var daysBetween = components.day ?? 0

        if daysBetween < 0 {
            daysBetween += 7
        }

        return daysBetween
    }

    /**
     Returns the time state of a task's due date relative to the current date,
     given a `due` date parameter. This function is used in the task workshop to
     display a preview of what the task's time state will be once it is created,
     before the task has been saved to the Core Data entity. Once the task has been
     saved, the `getTaskTimeState` function can be used to determine the actual
     time state of the task based on the `due` date property of the `TaskEntity` instance.

     - Parameter due: The due date of the task being created.
     - Returns: A `taskTimeState` value representing the time state of the task's due date.
     */
    static func getTaskTemplateTimeState(due: Date) -> taskTimeState {
            let currentTime = Date()
            let calendar = Calendar.current

            // If the task is due tomorrow, return .dueTomorrow time state.
//            if calendar.isDateInTomorrow(due) {
//                return .tomorrow
//            }
            // If the task is due today, return .today time state.
            if calendar.isDateInToday(due) {
                return .today
            }
            // If the task was due yesterday, return .past time state.
            else if calendar.isDateInYesterday(due) {
                return .overdue
            }
            // If the task is due in the future, return .upcoming time state.
            else if due > currentTime {
                return .upcoming
            }
            // Otherwise, return .past time state.
            else {
                return .overdue
            }
        }


    // Generates a greeting message based on the current hour of the day and the user's name.
    static func generateGreeting(userName: String) -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        var greeting = ""
        let split = userName.isEmpty ? "" : ", "
        var after = ""

        switch hour {
        case 0..<5:
            greeting = "Good Night"
        case 5..<7:
            greeting = "Morning"
        case 7..<12:
            greeting = "Hello"
        case 12..<17:
            greeting = "Afternoon"
        case 17..<20:
            greeting = "Evening"
        case 20..<22:
            greeting = "Good Night"
        default:
            greeting = "Late Night"
            after = "?"
        }

        return "\(greeting)\(split)\(userName)\(after)"
    }

    // Calculates the percentage of time completed between a start and end time, based on the current time.
    static func getCompletionPercentage(start: Date, end: Date) -> Double {
        let currentTime = Date()
        let totalTime = end.timeIntervalSince(start)
        let elapsedTime = currentTime.timeIntervalSince(start)
        let percentageCompleted = elapsedTime / totalTime
        return percentageCompleted
    }

    func validateDateRange(startDate: Date, endDate: Date) -> Date {
        let calendar = Calendar.current

        if endDate <= startDate {
            // If the end date is before or equal to the start date, return a date that is one hour after the start date
            print("checked date, changed")
            let oneHourAfterStartDate = calendar.date(byAdding: .hour, value: 1, to: startDate) ?? startDate

            // Check if the resulting date goes past midnight
            let nextDay = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: oneHourAfterStartDate)) ?? oneHourAfterStartDate
            let midnight = calendar.date(byAdding: .second, value: -1, to: nextDay) ?? oneHourAfterStartDate

            return midnight
        } else {
            // If the end date is after the start date, return the original end date
            print("checked date")
            return endDate
        }
    }

}

// An enumeration of possible time states.
enum timeState: String {
    case error
    case upcoming
    case upcomingOnOtherDay
    case upcomingLater
    case past
    case current
    case today
}

// An enumeration of possible time states for a task.


