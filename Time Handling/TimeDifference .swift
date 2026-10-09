//
//  TimeDifference .swift
//  Kyo
//
//  Created by Aether on 15/09/2022.
//

import SwiftUI
import Foundation

func differenceBetweenForHeight(start: String, end: String, scaleDownFactor: Double = 0.7) -> Double {

    // Convert the "start" parameter to a Date object using the "toDate" method of the "TimeFormatter" class. If the conversion fails, assign the current date and time to "s".
    let s = TimeFormatter.toDate(start) ?? Date()

    // Convert the "end" parameter to a Date object using the "toDate" method of the "TimeFormatter" class. If the conversion fails, assign the current date and time to "e".
    let e = TimeFormatter.toDate(end) ?? Date()

    // Calculate the difference in hours between "e" and "s" using the "hoursSinceMidnight" method of the "Date" class.
    var diff = (((e.hoursSinceMidnight()) - (s.hoursSinceMidnight())))

    // If the difference is greater than or equal to 2, adjust the difference by multiplying it by 0.7.


    if(diff <= 0.5){
        diff = (((e.hoursSinceMidnight()) - (s.hoursSinceMidnight()))) * 1.4
    }
    else{
        if(diff > 0.5 && diff < 2){
            diff = (((e.hoursSinceMidnight()) - (s.hoursSinceMidnight()))) * (scaleDownFactor * 1.5)
        }
        if(diff >= 2){
            diff = (((e.hoursSinceMidnight()) - (s.hoursSinceMidnight()))) * scaleDownFactor * 1.4
        }
    }

    // Return the final difference value.
    return diff
}

func differenceBetween(_ startInput: String,_ endInput: String, debug: Bool = false) -> Double {

    // Convert the "start" parameter to a Date object using the "toDate" method of the "TimeFormatter" class. If the conversion fails, assign the current date and time to "s".
    if let s = TimeFormatter.toDate(startInput, mode: .time), let e = TimeFormatter.toDate(endInput, mode: .time) {
        let diff = (((e.hoursSinceMidnight()) - (s.hoursSinceMidnight())))
        log("[differenceBetween] difference is \(diff), with start input \(startInput) and output \(s) and end input \(endInput) and output \(e)", debug: debug)

        // Return the final difference value.
        return diff
    }

    return 1.5
}

func differenceBetween(_ startDate: Date, _ endDate: Date, debug: Bool = false) -> Double {
    let startHours = startDate.hoursSinceMidnight()
    let endHours = endDate.hoursSinceMidnight()

    let diff = endHours - startHours

    log("[differenceBetween] difference is \(diff), with start input \(startDate) and end input \(endDate)", debug: debug)

    return diff
}



func calculateTimeDifference(startDate: Date, endDate: Date) -> String {

    print("CTD compare \(startDate) and \(endDate)")
    let calendar = Calendar.current

    let components = calendar.dateComponents([.hour, .minute], from: startDate, to: endDate)

    guard let hours = components.hour, let minutes = components.minute else {
        return "00:00"
    }

    return String(format: "%02d:%02d", hours, minutes)
}


/**
 Calculates a dynamic height multiplier for a time slot based on the time difference between start and end times.

 - Parameters:
   - start: The start time of the time slot.
   - end: The end time of the time slot.

 - Returns: A dynamic height multiplier value based on the time difference.
 */
func getTimeSlotHeightMultiplier(start: String, end: String, mode: plannerScaleMode = .regular, dynamic: Bool = true) -> Double {
    // Convert start and end times to Date objects, defaulting to current date if conversion fails
    let startTime = TimeFormatter.toDate(ensureCorrectFormat(input: start)) ?? Date()
    let endTime = TimeFormatter.toDate(ensureCorrectFormat(input: end)) ?? Date()

    // Calculate the time difference in hours
    let timeDifference = endTime.hoursSinceMidnight() - startTime.hoursSinceMidnight()
    // Check for invalid time range
    if !dynamic{
        return timeDifference
    }
    if timeDifference < 0 {

        return 0.0 // Invalid time range, return 0
    } else {
        // Calculate a boost factor that gradually increases for time differences under 1 hour
        let boostFactor = timeDifference < 1 ? 1.0 + min(timeDifference, 1.0) * 0.2 : 1 // Adjust the boost factor as needed

                // Calculate a decrease factor that increases as time difference increases
                let decreaseFactor = max(1.0 - (timeDifference - 1.0) * 0.1, 0.4) // Adjust the rate of decrease as needed

                // Combine the boost and decrease factors to calculate the dynamic factor

        let baseFactor = mode == .regular ? 2.2 : 3 // Adjust the base factor as needed
        let dynamicFactor = (baseFactor / (1.0 + timeDifference)) * boostFactor * decreaseFactor

        return dynamicFactor
    }
}

func getHeightMultiplierForTimeRange(_ startDate: Date,_  endDate: Date, mode: plannerScaleMode = .regular) -> Double {
    // Calculate the time difference in hours
    let timeDifference = endDate.hoursSinceMidnight() - startDate.hoursSinceMidnight()

    // Check for an invalid time range
    if timeDifference < 0 {
        return 0.0 // Invalid time range, return 0
    } else {
        // Calculate a boost factor that gradually increases for time differences under 1 hour
        let boostFactor = timeDifference < 1 ? 1.0 + min(timeDifference, 1.0) * 0.2 : 1 // Adjust the boost factor as needed

        // Calculate a decrease factor that increases as the time difference increases
        let decreaseFactor = max(1.0 - (timeDifference - 1.0) * 0.1, 0.4) // Adjust the rate of decrease as needed

        // Combine the boost and decrease factors to calculate the dynamic factor
        let baseFactor = mode == .regular ? 2.2 : 3 // Adjust the base factor as needed
        let dynamicFactor = (baseFactor / (1.0 + timeDifference)) * boostFactor * decreaseFactor

        return dynamicFactor
    }
}


enum plannerScaleMode : String, CaseIterable{
    case large = "Large"
    case regular = "Regular"

    public var number: Double {
        switch self {
        case .large:
            return 1
//        case .none:
//            return 1.0
//        case .medium:
//            return 0.9
        case .regular:
            return 0.8
//        case .small:
//            return 0.65
        }
    }

    public var icon: String {
        switch self{
        case .large:
            return "rectangle.expand.vertical"
        case .regular:
                return "rectangle"

        }
    }
}
