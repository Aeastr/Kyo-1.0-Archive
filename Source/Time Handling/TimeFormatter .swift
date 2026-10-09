//
//  TimeFormatter .swift
//  Kyo
//
//  Created by Aether on 15/09/2022.
//

import SwiftUI
import Foundation


struct TimeFormatter {
    // The static property `dateFormatFull` is initialized using the `getFullDateFormat()` function
    // which gets the current user's full date format.
    static let dateFormatFull = getFullDateFormat()
    static var debug = false
    // The static property `dateFormatTime` is initialized using `getTimeFormat()` function which
    // gets the current user's current time format.
    static let dateFormatTime = getTimeFormat()

    /**
     Converts a string representing a time to a `Date` object.

     - Parameters:
     - input: The string representing the time to be converted.
     - mode: The mode to use for converting the time to a `Date` object. The default value is `.fullDate`.

     - Returns: A `Date` object representing the input time, or `nil` if the input is invalid or the mode is not supported.
     */
    static func toDate(_ input: String, mode: TimeFormatterMode = .fullDate) -> Date? {
        // If the `mode` parameter is `.fullDate`, create a `DateFormatter` object with the date format
        // specified in the `dateFormatFull` property.
        if mode == .fullDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = TimeFormatter.dateFormatFull

            log("[TimeFormatter, toDate] input is \(input), ensured correct format as: \(ensureCorrectFormat(input: input)), using the format \(TimeFormatter.dateFormatFull)", debug: debug)

            let string = "\(Calendar.current.component(.day, from: Date())), \(Calendar.current.component(.month, from: Date())), \(Calendar.current.component(.year, from: Date())), \(ensureCorrectFormat(input: input))"

            log("[TimeFormatter, toDate] string is \(string), output is \(dateFormatter.date(from: string))", debug: debug)


            return dateFormatter.date(from: string)
        }

        // If the `mode` parameter is `.time`, create a `DateFormatter` object with the date format specified
        // in the `dateFormatTime` property.
        if mode == .time {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = TimeFormatter.dateFormatTime

            // Print the date obtained from parsing the `input` parameter with the `dateFormatter`.
            // print("toDate: returning \(dateFormatter.date(from: ensureCorrectFormat(input :input) ))")

            // Return the `Date` object obtained from parsing the `input` parameter.
            return dateFormatter.date(from: ensureCorrectFormat(input :input) )
        }

        // Return `nil` if `mode` parameter is neither `.fullDate` nor `.time`.
        return nil
    }

    /**
     Gets the day code (e.g. "Mon", "Tue", etc.) for a given date.

     - Parameter date: The date to get the day code for.

     - Returns: A string representing the day code for the input date.
     */
    static func getDayCode(date: Date) -> String? {
        let dayFormatter = DateFormatter()
        dayFormatter.locale = Locale(identifier: "en") // Use English language for day abbreviations
        dayFormatter.dateFormat = "EEE"

        return dayFormatter.string(from: date)
    }
    /**
     Converts a `Date` object to a string representing the time in the format specified in the `dateFormatTime` property.

     - Parameter input: The `Date` object to convert to a time string.

     - Returns: A string representing the time for the input `Date` object in the format specified in the `dateFormatTime` property.
     */
    static func getTimeString(_ input: Date) -> String {

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = TimeFormatter.dateFormatTime
        return dateFormatter.string(from: input)
    }
    

}

