//
//  checkRange.swift
//  Kyo
//
//  Created by Aether on 14/09/2022.
//

import SwiftUI

// This function returns a string that represents the date and time format for the current locale
func getFullDateFormat(opp: Bool = false) -> String {
    // This variable stores the date format template for the current locale
    var dateFormat = DateFormatter.dateFormat(fromTemplate: "j", options: 0, locale: Locale.current)!
    // This condition checks if the date format template contains the "a" symbol, which indicates whether the time format is 12-hour or 24-hour
    if dateFormat.firstIndex(of: "a") == nil { // if time format is 24hr
        if opp {
            // This returns a string that represents the date and time format in 12-hour mode with AM/PM
            return "dd, MM, yyyy, hh:mm a"
        } else {
            // This returns a string that represents the date and time format in 24-hour mode
            return "dd, MM, yyyy, HH:mm"
        }
    } else { // if time format is not 24hr
        if opp {
            // This returns a string that represents the date and time format in 24-hour mode
            return "dd, MM, yyyy, HH:mm"
        } else {
            // This returns a string that represents the date and time format in 12-hour mode with AM/PM
            return "dd, MM, yyyy, hh:mm a"
        }
    }
}

// added write up

func getTimeFormat(opp: Bool = false ) -> String {
    // Get the current device's time format
    let dateFormat = DateFormatter.dateFormat(fromTemplate: "j", options: 0, locale: Locale.current)!

    // Check if the time format is 24-hour (no "a" in the format string)
    if(dateFormat.firstIndex(of: "a") == nil){ // if time format is 24hr
        // If the caller wants the opposite time format and the current format is 24-hour,
        if opp{
            // return the format in 12-hour AM/PM
            return "hh:mm a"

        }
        // Otherwise, return the 24-hour format
        return "HH:mm"
    }
    // If the time format is not 24-hour (contains "a" in the format string),
    // assume it's 12-hour AM/PM
    else{
        // If the caller wants the opposite time format and the current format is 12-hour AM/PM,
        if opp{
            // return the format in 24-hour
            return "HH:mm"
        }
        // Otherwise, return the 12-hour AM/PM format
        return "hh:mm a"
    }
}

func ensureCorrectFormat(input: String) -> String {
    let dateFormatter = DateFormatter()

    // Get the user's current time format
    let currentFormat = getTimeFormat()

    // Set the locale to a known value to avoid parsing issues
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")

    // Set the date formatter to be lenient
    dateFormatter.isLenient = true

    // Attempt to parse the input string in the current format
    dateFormatter.dateFormat = currentFormat
    if let date = dateFormatter.date(from: input) {
        // Successfully parsed in the current format, return in the current format
        let result = dateFormatter.string(from: date)
        return result
    }

    // Attempt to parse the input string in the opposite format
    dateFormatter.dateFormat = getTimeFormat(opp: true)
    if let date = dateFormatter.date(from: input) {
        // Successfully parsed in the opposite format, return in the current format
        dateFormatter.dateFormat = currentFormat
        let result = dateFormatter.string(from: date)
        return result
    }

    // Parsing failed in both formats, return an error message
    let errorMessage = "Invalid time format: \(input)"
    return errorMessage
}



func ensureCorrectDateFormat(date: Date) -> Date {
    // Create a DateFormatter object with the current device's date and time format
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = getFullDateFormat()

    // Convert the date object to a string using the current format
    var dateString = dateFormatter.string(from: date)

    // Attempt to parse the date string using the DateFormatter object
    var parsedDate = dateFormatter.date(from: dateString)

    // If the parsed date is nil (i.e. input could not be parsed in the current format),
    // try parsing it in the opposite format (i.e. if current format is 12-hour AM/PM, try 24-hour;
    // if current format is 24-hour, try 12-hour AM/PM)
    if parsedDate == nil {
        dateFormatter.dateFormat = getFullDateFormat(opp: true)
        dateString = dateFormatter.string(from: date)
        parsedDate = dateFormatter.date(from: dateString)
        dateFormatter.dateFormat = getFullDateFormat()
    }

    // Return the parsed date in the correct format
    return parsedDate ?? date
}


func getsegmentedTimeFormat() -> String {
    // Get the current device's time format
    let dateFormat = DateFormatter.dateFormat(fromTemplate: "j", options: 0, locale: Locale.current)!

    // Check if the time format is 24-hour (no "a" in the format string)
    if(dateFormat.firstIndex(of: "a") == nil){ // if time format is 24hr
         // Return the 24-hour format
        return "HH:mm"
    }
    // If the time format is not 24-hour (contains "a" in the format string),
    // assume it's 12-hour AM/PM
    else{
        // Return the 12-hour AM/PM format
        return "hh:mm"
    }
}


func timeType() -> TimeModel{
    let dateFormat = DateFormatter.dateFormat(fromTemplate: "j", options: 0, locale: Locale.current)!
    if(dateFormat.firstIndex(of: "a") == nil){ // if time format is 24hr
        return .twentyfour
    }
    else{  // if time format is not 24hr
        return .twelve
    }
}
