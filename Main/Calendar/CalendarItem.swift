//
//  CalendarItem.swift
//  KyoNeo
//
//  Created by Aether on 09/09/2023.
//

import SwiftUI
import EventKit

struct CalendarItem: View {
    var event: EKEvent
    @AppStorage("scaleWithDuration") var scaleWithDuration: Bool = true
    @AppStorage("global_Compact") var global_Compact  = false
    @AppStorage("scaleMode") var scaleMode:  plannerScaleMode = .regular

    @State var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State var currentState: timeState = .upcoming
    
    @AppStorage("showLength") var showLength = true
    @AppStorage("planner_CountDown") var planner_CountDown : Bool = true
    @AppStorage("showDetails") var showDetails = true

    var eventDetails: (notes: String?, room: String?, teachers: [String]?, otherDetails: [String: String]?) {
        if let eventDescription = event.notes {
            return extractEventDetails(from: eventDescription)
        } else {
            return (nil, nil, nil, nil)
        }
    }


    var body: some View {
        ZStack{
            if let cal = event.calendar{

                let color = Color(cgColor: cal.cgColor)
                let brightness = color.getBrightness()

                VStack(alignment: .leading, spacing: 8){
                    VStack(alignment: .leading, spacing: 6.5){
                        Text(event.title ?? "Untitled Event")
                            .font(.body.weight(.semibold))

                        switch currentState {

                        case .upcoming:
                            HStack{
                                Group{
                                    Text(event.startDate, style: .time)
                                        .font(.footnote.weight(.regular))
                                    +
                                    Text(" - ")
                                        .font(.footnote.weight(.regular))
                                    +
                                    Text(event.endDate, style: .time)
                                        .font(.footnote.weight(.regular))
                                }
                                Spacer()

                                if showLength{
                                    let number = differenceBetween(event.startDate, event.endDate)
                                    let roundedNumber = decimalToFraction(number)
                                    Text(roundedNumber + "\(differenceBetween(event.startDate, event.endDate) > 1 ? " hrs" : " hr")")
                                        .textCase(.uppercase)
                                        .font(Font.footnote.weight(.semibold))
                                        .fixedSize(horizontal: true, vertical: false)
                                        .opacity(0.7)
                                        .transition(.blur)
                                }
                            }

                        case .past:

                            Group{
                                Text("Ended ")
                                    .font(.footnote.weight(.regular))
                                +
                                Text(event.startDate, style: .time)
                                    .font(.footnote.weight(.regular))
                            }
                        case .current:
                            HStack{
                                if planner_CountDown{
                                    Text("\("Remaining") \(event.endDate, style: .timer)")
                                        .monospacedDigit()
                                        .font(.footnote.weight(.regular))
                                        .transition(.blur)
                                }
                                else{
                                    Text("Now")
                                        .monospacedDigit()
                                        .font(.footnote.weight(.regular))
                                        .transition(.blur)
                                }



                                Spacer()
                                Text(Image(systemName: "arrow.right"))
                                    .font(.footnote.weight(.light))
                                +
                                Text(" \(event.endDate, style: .time)")
                                    .font(.footnote.weight(.regular))
                            }.textCase(.uppercase)
                                .animation(.smooth)
                        default:
                            Group{
                                Text("State Error")
                                    .font(.footnote.weight(.regular))
                            }
                        }

                        Divider()
                            .padding(.vertical, 2)
                            .tint(color.darken(by: 0.5))
                    }

                    if let notes = eventDetails.notes {
                                            Text("\(notes)")
                                                .font(.caption)
                                        }

                                        if let room = eventDetails.room {

                                            Group{
                                                Text(Image(systemName: "square.split.bottomrightquarter"))
                                                    .font(.caption.weight(.regular))
                                                + Text(" ")
                                                    .font(.caption2)
                                                + Text("\(room)")
                                                    .font(.caption.weight(.regular))
                                            }
                                        }

                                        if let teachers = eventDetails.teachers {
                                            Group{
                                                Text(Image(systemName: "person"))
                                                    .font(.caption.weight(.regular))
                                                + Text(" ")
                                                    .font(.caption2)
                                                + Text("\(teachers.joined(separator: ", "))")
                                                    .font(.caption.weight(.regular))
                                            }
                                        }

                    if let extra = eventDetails.otherDetails {
                            ForEach(extra.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                                Text("\(key): \(value)")
                                    .font(.caption)
                            }
                        }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(minHeight: scaleWithDuration ? ((differenceBetween(event.startDate, event.endDate) * (global_Compact ? 65 : 70)) * getHeightMultiplierForTimeRange( event.startDate , event.endDate, mode: scaleMode)): 92)
                .padding(.vertical , differenceBetween(event.startDate, event.endDate) * 11.2)

                .padding()
                .padding(.horizontal, 4)
                .background(

                    color.gradient

                )
                .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
                .foregroundStyle(brightness > 0.73 ? color.darken(by: 0.5) : Color.white)
                // You can display other event details as needed.
            }
        }
        .onAppear{
            getState()
            if currentState == .past{
                   self.timer.upstream.connect().cancel()
            }
        }
                .onReceive(timer) { input in
                    getState()
                    if currentState == .past{
                        self.timer.upstream.connect().cancel()
                    }
                }
    }

    func getState() {

            withAnimation(.smoothCard) {
                self.currentState = TimeHelper.getTimeState(startTime: event.startDate, endTime: event.endDate)
            }

//            if TimeHelper.getRemainingMinutes(for: timeSlot.endTime ?? "01:00") > 8.0 {
//                print("Adjusting state timer refresh to longer interval")
//                changeTimerInterval(to: 300) // Change interval to 5 minutes
//            } else {
//                if timer.upstream.interval != 1 {
//                    print("Adjusting timer refresh to shorter interval")
//                    changeTimerInterval(to: 1) // Change interval back to 1 second if not already
//                }
//            }

    }

    func changeTimerInterval(to interval: TimeInterval) {
        timer.upstream.connect().cancel() // Cancel the existing timer
        timer = Timer.publish(every: interval, on: .main, in: .common).autoconnect() // Create a new timer with the specified interval
    }

    func extractEventDetails(from eventDescription: String) -> (notes: String?, room: String?, teachers: [String]?, otherDetails: [String: String]?) {
        // Initialize variables to store extracted information
        var notes: String?
        var room: String?
        var teachers: [String]?
        var otherDetails: [String: String]?

        // Define the category prefixes
        let categoryPrefixes = ["Notes:", "Room:", "Teachers:", "Staff:", "Location:"]

        // Create a set of valid prefixes
        let validPrefixSet = Set(categoryPrefixes)

        // Split the eventDescription by new lines
        let lines = eventDescription.components(separatedBy: "\n")

        for line in lines {
            // Check if the line starts with a valid prefix
            for prefix in validPrefixSet {
                if line.hasPrefix(prefix) {
                    // Store the current category
                    let currentCategory = prefix
                    let startIndex = line.index(line.startIndex, offsetBy: currentCategory.count)

                    // Extract the description following the prefix, trimming whitespace
                    let categoryDescription = line[startIndex...].trimmingCharacters(in: .whitespacesAndNewlines)

                    // Store the information based on the current category
                    switch currentCategory {
                    case "Notes:":
                        if notes == nil {
                            notes = categoryDescription
                        } else {
                            notes?.append("\n" + categoryDescription)
                        }
                    case "Room:", "Location:":
                        if room == nil {
                            room = categoryDescription
                        } else {
                            room?.append("\n" + categoryDescription)
                        }
                    case "Teachers:", "Staff:":
                        if teachers == nil {
                            teachers = categoryDescription.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                        } else {
                            teachers?.append(contentsOf: categoryDescription.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) })
                        }
                    default:
                        // If there's another prefix with ':', store it in the otherDetails dictionary
                        if currentCategory.contains(":") {
                            let parts = currentCategory.split(separator: ":", maxSplits: 1)
                            if parts.count == 2 {
                                let key = String(parts[0])
                                if otherDetails == nil {
                                    otherDetails = [key: categoryDescription]
                                } else {
                                    otherDetails?[key] = categoryDescription
                                }
                            }
                        }
                    }
                    break // Move to the next line after processing the current category
                }
            }
        }

        // Return the extracted information as a tuple
        return (notes, room, teachers, otherDetails)
    }




}


