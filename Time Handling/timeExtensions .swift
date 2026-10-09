//
//  timeExtensions .swift
//  Kyo
//
//  Created by Aether on 27/09/2022.
//

import SwiftUI

extension Date {

    // Check if the date falls between two other dates (inclusive)
    func isBetween(_ date1: Date, and date2: Date) -> Bool {

        // Check if the current date falls between the minimum and maximum of the two input dates
        // The "..<" and "..." operators are Swift's range operators; in this case, they create a range from the smaller date to the larger date (inclusive)
        // The "contains" function checks if the current date is within this range
        return (min(date1, date2) ... max(date1, date2)).contains(self)
    }

    // Check if the current date has already passed the input date
    func hasPassed(date: Date) -> Bool {

        // If the current date is later than the input date, it has already passed
        if (self > date || self == date){
            return true
        }

        // If the current date is earlier than or equal to the input date, it has not passed yet
        return false
    }

    // Get the number of hours since midnight for the current date
    func hoursSinceMidnight() -> Double {

        // Get the start of the current day using the startOfDay(for:) method of Calendar.current
        let startOfDay = Calendar.current.startOfDay(for: self)

        // Calculate the number of hours and minutes between the start of the day and the current date using the dateComponents(_:from:to:) method of Calendar.current
        let components = Calendar.current.dateComponents(
            [.hour, .minute],
            from: startOfDay,
            to: self
        )

        // Extract the number of hours and minutes from the resulting DateComponents object
        let (hours, minutes) = (components.hour ?? 0, components.minute ?? 0)

        // Return the total number of hours since midnight as a Double value
        return Double(hours) + Double(minutes) / 60
    }
}
