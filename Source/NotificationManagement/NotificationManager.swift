//
//  NotificationHelper.swift
//  KyoNeo
//
//  Created by Aether on 18/07/2023.
//

import SwiftUI
import CoreData
import UserNotifications


struct notitest2: View {
    var body: some View {
        Button("Schedule Notifications") {
            scheduleNotifications()
        }
    }

    func scheduleNotifications() {
        let center = UNUserNotificationCenter.current()

        // Request notification permission
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted && error == nil {
                for index in 0...64 {
                    let content = UNMutableNotificationContent()
                    content.title = "Local Notification"
                    content.body = "This is notification number \(index)"
                    content.sound = UNNotificationSound.default

                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(index + 1), repeats: false)

                    let request = UNNotificationRequest(identifier: "notification_\(index)", content: content, trigger: trigger)

                    center.add(request) { error in
                        if let error = error {
                            print("Error scheduling notification \(index): \(error.localizedDescription)")
                        } else {
                            print("Notification \(index) scheduled successfully")
                        }
                    }
                }
            } else {
                print("Notification permission denied")
            }
        }




            // Request notification permission
            center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                if granted && error == nil {
                    for index in 0...64 {
                        let content = UNMutableNotificationContent()
                        content.title = "Local Notification2ndSet"
                        content.body = "This is notification number \(index)"
                        content.sound = UNNotificationSound.default

                        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(86400 + index + 1), repeats: false)

                        let request = UNNotificationRequest(identifier: "notification_\(index)", content: content, trigger: trigger)

                        center.add(request) { error in
                            if let error = error {
                                print("Error scheduling notification \(index): \(error.localizedDescription)")
                            } else {
                                print("Notification \(index) scheduled successfully2nd set")
                            }
                        }
                    }
                } else {
                    print("Notification permission denied")
                }
            }
    }
}




struct NotificationCreator{

    var debug: Bool = true


}

struct NotificationHelper{
    @AppStorage("plannerNotifications") var plannerNotifications = true
    @AppStorage("taskNotifications") var taskNotifications = true
    @AppStorage("plannerNotificationsMinutesBefore") var taskNotificationsMinutesBefore: Int = 20
    @AppStorage("taskOverdueReminders") var taskOverdueReminders: Bool = true

    var context: NSManagedObjectContext {
            PersistenceController.shared.container.viewContext
    }
    static var debug = true

    var weeks: [Week] {
      
            let request: NSFetchRequest<Week> = Week.fetchRequest()
            let sort = NSSortDescriptor(key: "number", ascending: true)
            request.sortDescriptors = [sort]
            do {
                log("[NotificationHelper - Weeks fetch] Fetching Weeks)", debug: NotificationHelper.debug)
                return try context.fetch(request)
            } catch {
                log("[NotificationHelper - Weeks fetch] Error fetching Weeks: \(error.localizedDescription)", debug: NotificationHelper.debug)
                return []
            }

        return []
    }

    func makeAllNotifications(){
        var weekWiz = WeekWizard(customMessage: "from makeAllNotifications")
        if let totalWeeks = weekWiz.totalWeeks, let currentWeek = weekWiz.getCurrentWeek(){
            log("[NotificationHelper - makeAllNotifications] Current Week is \(currentWeek)", debug: NotificationHelper.debug)
            var x: [Int] = []

            for i in 0...(totalWeeks - 1){
                if let number = weekWiz.calculateWeekWithOffset(for: currentWeek + i){
                    if let weekDate = Calendar.current.date(byAdding: .weekOfYear, value: i, to: Date()){
                        log("[NotificationHelper - makeAllNotifications] Working on Week \(number) (creating notis!) for date \(weekDate)", debug: NotificationHelper.debug)
                        makeWeekNotifications(for: weekDate)
                    }

                }
            }

            if x.count == totalWeeks{
                log("[NotificationHelper - makeAllNotifications] xcount, confirmed correct count!", debug: NotificationHelper.debug)

            }

        }
    }

    func makeWeekNotifications(for forDate: Date = Date()){
        if context != nil{
            var weekWiz = WeekWizard()
            log("[NotificationHelper - makeNotifications] Making Notifications for \(forDate)", debug: NotificationHelper.debug)
            if let currentWeekNumber = weekWiz.getCurrentWeek(forDate){
                log("[NotificationHelper - makeNotifications] Week Number is \(currentWeekNumber)", debug: NotificationHelper.debug)

                
                let currentWeek = weeks.filter{ week in
                    week.number == currentWeekNumber
                }.prefix(1)



                if currentWeek.count != 0{

                    let week = currentWeek[0]
                    log("[NotificationHelper - makeNotifications] Found Week \(week), from number \(currentWeekNumber)", debug: NotificationHelper.debug)
                    if let daysArray = (Array(week.days ?? []) as? [Day])?.sorted(by: { $0.number < $1.number }) {
                        log("[NotificationHelper - makeNotifications] Created days array", debug: NotificationHelper.debug)
                        for day in daysArray{
                            log("[NotificationHelper - makeNotifications] Found Day with name \(day.name ?? "No Name")", debug: NotificationHelper.debug)
                            if let timeSlotArray = (Array(day.timeSlots ?? []) as? [TimeSlot])?.sorted(by: { $0.timestamp ?? Date() < $1.timestamp ?? Date() }) {
                                for timeSlot in timeSlotArray{
                                    log("    [NotificationHelper - makeNotifications] Found TimeSlot within \(day.name ?? "No Name")", debug: NotificationHelper.debug)
                                        scheduleNotification(for: timeSlot, referenceDate: forDate)

                                }
                            }
                        }
                    }
                    else{
                        log("[NotificationHelper - makeNotifications] Could not compute daysArray for \(week)", debug: NotificationHelper.debug)
                    }
                }
                else{
                    log("[NotificationHelper - makeNotifications] No Week could be found for currentWeekNumber \(currentWeekNumber)", debug: NotificationHelper.debug)
                }

            }


        }
        else{
            log("[NotificationHelper - makeNotifications] No NSManagedObjectContext Provided", debug: NotificationHelper.debug)
        }
    }

    func requestPermission(completion: @escaping (Bool) -> Void) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                if success {
                    log("[NotificationHelper] Permission Allowed", debug: NotificationHelper.debug)
                    completion(true)
                } else if let error = error {
                    log("[NotificationHelper] Permission Failed \(error.localizedDescription)", debug: NotificationHelper.debug)
                    completion(false)
                }
            }
        }

        func checkNotificationPermission(completion: @escaping (UNAuthorizationStatus) -> Void) {
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                DispatchQueue.main.async {
                    completion(settings.authorizationStatus)
                }
            }
        }

    func scheduleNotification(for timeSlot: TimeSlot, minutesBefore: Int = 0, referenceDate: Date = Date()) {
            guard let startTime = timeSlot.startTime, let endTime = timeSlot.endTime else {
                log("[NotificationHelper] Error scheduling notification: Invalid time slot data.", debug: NotificationHelper.debug)
                return
            }
        let notificationDate = findDate(timeSlot, referenceDate: referenceDate)!
            let content = UNMutableNotificationContent()

            // Determine whether the timeslot has a class or a splitter
            if let classEntity = timeSlot.classEntity {
                // If it's a class, display class name, duration, and room
                if minutesBefore == 0{
                    content.title = "Now: \(classEntity.name ?? "Unknown \(VariableDataNames().className())")"
                }
                else{
                    content.title = "Upcoming: \(classEntity.name ?? "Unknown \(VariableDataNames().className())"), in \(minutesBefore) minutes"
                }
                let duration = differenceBetween(startTime, endTime) // Assuming your function returns the duration in minutes
                let roundedDuration = decimalToFraction(duration)
                if timeSlot.room != "" && timeSlot.room != nil  {
                    content.body = "Duration: \(roundedDuration) \(differenceBetween(startTime, endTime) > 1 ? " hrs - " : " hr - ") | Room: \(timeSlot.room ?? "Unknown Room")"
                }
                else{
                    content.body = "Duration: \(roundedDuration) \(differenceBetween(startTime, endTime) > 1 ? " hrs - " : " hr - ")"
                }

            } else if let splitterEntity = timeSlot.splitterEntity {
                // If it's a splitter, display splitter name and room
                content.title = "\(splitterEntity.name ?? "Unknown")"
                if timeSlot.room != "" && timeSlot.room != nil  {
                    content.body = "Room: \(timeSlot.room ?? "Unknown Room")"
                }
            }

            // Calculate the trigger time by subtracting minutesBefore from the notificationDate
            let triggerDate = Calendar.current.date(byAdding: .minute, value: -minutesBefore, to: notificationDate)

        if let triggerDate = triggerDate {
            if !(triggerDate < Date()){


            let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            
            // Create a unique identifier for the notification
            if let timeSlotidentifier = timeSlot.id?.uuidString{
                let identifier = "TimeSlotNotification_\(timeSlotidentifier)"
                
                let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
                
                UNUserNotificationCenter.current().add(request) { error in
                    if let error = error {
                        log("[NotificationHelper] Error scheduling notification: \(error.localizedDescription)", debug: NotificationHelper.debug)
                    } else {
                        log("[NotificationHelper] Notification scheduled successfully for \(timeSlot.classEntity?.name ?? timeSlot.splitterEntity?.name ?? "(No found class/splitter)") at \(triggerDate)", debug: NotificationHelper.debug)
                    }
                }
            }
            else{
                log("[NotificationHelper] Could not get timeSlotidentifier", debug: NotificationHelper.debug)
            }
            }
            else{
                log("[NotificationHelper] Trigger date would be before todays date", debug:
                NotificationHelper.debug)
            }
            } else {
                log("[NotificationHelper] Error scheduling notification: Invalid trigger date.", debug: NotificationHelper.debug)
            }
        }

    func findDate(_ slot: TimeSlot, referenceDate: Date) -> Date?{

        let df = DateFormatter()
        df.dateFormat = getFullDateFormat()

        let now = referenceDate
        let mondayDate = getMonday(now)

        log("[NotificationHelper - findDate] Found monDate \(df.string(from: mondayDate)) with \(df.string(from: now))", debug: NotificationHelper.debug)
        if let dayDifference = getDayDifferenceFromMonday(slot.day?.name ?? "Mon"), let modifiedDate = Calendar.current.date(byAdding: .day, value: dayDifference, to: mondayDate){
            log("[NotificationHelper - findDate] Found dayDifference \(dayDifference), so modified date is \(df.string(from: modifiedDate))", debug: NotificationHelper.debug)


            var string = "\(Calendar.current.component(.day, from: modifiedDate)), \(Calendar.current.component(.month, from: modifiedDate)), \(Calendar.current.component(.year, from: modifiedDate)), \(ensureCorrectFormat(input: slot.startTime!))"

            log("[NotificationHelper - findDate] string is \(string), return date is \(df.date(from: string)) {and in current format would be \(df.string(from: (df.date(from: string)!)))", debug: NotificationHelper.debug)

            return (df.date(from: string))
        }

        return nil
    }

    func getMonday(_ myDate: Date) -> Date {
        let cal = Calendar.current
        var comps = cal.dateComponents([.weekOfYear, .yearForWeekOfYear], from: myDate)
        comps.weekday = 2 // Monday
        let mondayInWeek = cal.date(from: comps)!

        let df = DateFormatter()
        df.dateFormat = getFullDateFormat()

        return mondayInWeek
    }

    func getDayDifferenceFromMonday(_ dayAbbreviation: String) -> Int? {
        let weekdays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

        // Make sure the input dayAbbreviation is valid
        guard let inputWeekdayIndex = weekdays.firstIndex(of: dayAbbreviation) else {
            return nil
        }

        // Get the index of Monday (1 for Sunday, 2 for Monday, ..., 7 for Saturday)
        let mondayIndex = weekdays.firstIndex(of: "Mon")!

        // Calculate the difference in days between the input day and the previous Monday
        var dayDifference = inputWeekdayIndex - mondayIndex
        if dayDifference < 0 {
            dayDifference += weekdays.count // Add a full week if the result is negative
        }

        return dayDifference
    }

    func cancelLocalNotification(identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
        print("Notification with identifier \(identifier) canceled.")
    }

    func cancelAllLocalNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    func checkNotificationPermission() -> UNAuthorizationStatus {
        let semaphore = DispatchSemaphore(value: 0)
        var notificationStatus: UNAuthorizationStatus = .notDetermined

        UNUserNotificationCenter.current().getNotificationSettings { settings in
            notificationStatus = settings.authorizationStatus
            semaphore.signal()
        }

        semaphore.wait()
        return notificationStatus
    }

    func makeTaskNotification(for task: TaskEntity, completion: @escaping (Result<Bool, TaskNotificationError>) -> Void) {
        guard let title = task.label, !title.isEmpty else {
            completion(.failure(.missingTitle))
            return
        }

        guard taskNotifications else {
                completion(.failure(.notificationCreationFailed(reason: "Task notifications are disabled. Please enable notifications in settings.")))
                return
            }
        
        let notificationStatus = checkNotificationPermission()
            guard notificationStatus == .authorized else {
                completion(.failure(.notificationCreationFailed(reason: "Notification permission not granted. Please allow notifications in settings.")))
                return
            }

        guard let classEntity = task.classEntity else {
            completion(.failure(.missingClassEntity))
            return
        }

        guard let taskType = task.taskType else {
            completion(.failure(.missingTaskType))
            return
        }

        guard let dueDate = task.due else {
            completion(.failure(.notificationCreationFailed(reason: "Task due date is missing. Please set a due date for the task.")))
            return
        }

        // Replace the following notification creation logic with your actual implementation
        let contentNow = UNMutableNotificationContent()
        contentNow.title = "\(title), \(classEntity.name ?? "Untitled \(VariableDataNames().className())"), now"
        contentNow.sound = UNNotificationSound.default
        if let notes = task.notes{
            contentNow.subtitle = "\(notes)"
        }
        contentNow.interruptionLevel = .timeSensitive

        let contentDayBefore = UNMutableNotificationContent()
        contentDayBefore.title = "\(title), \(classEntity.name ?? "Untitled \(VariableDataNames().className())"), tomorrow \(TimeFormatter.getTimeString(dueDate))"
        contentDayBefore.sound = UNNotificationSound.default
        if let notes = task.notes{
            contentDayBefore.subtitle = "\(notes)"
        }
        contentDayBefore.interruptionLevel = .timeSensitive

        let contentMinutesBefore = UNMutableNotificationContent()
        contentMinutesBefore.title = "\(title), \(classEntity.name ?? "Untitled \(VariableDataNames().className())"), in \(taskNotificationsMinutesBefore)"
        contentMinutesBefore.sound = UNNotificationSound.default
        if let notes = task.notes{
            contentMinutesBefore.subtitle = "\(notes)"
        }
        contentMinutesBefore.interruptionLevel = .timeSensitive

        // Create a calendar-based trigger using the due date
        let dueDateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: dueDate)
        let dueDateTrigger = UNCalendarNotificationTrigger(dateMatching: dueDateComponents, repeats: false)

        // Schedule the notification for the day before at 9 AM
        var dayBeforeComponents = dueDateComponents
        dayBeforeComponents.day! -= 1 // Subtract one day from the due date
        dayBeforeComponents.hour = 9 // Set the hour to 9 AM
        let dayBeforeTrigger = UNCalendarNotificationTrigger(dateMatching: dayBeforeComponents, repeats: false)

//        // Schedule the notification for the specified minutes before the due date
//        let minutesBefore: TimeInterval = Double(taskNotificationsMinutesBefore * 60)
//        let minutesBeforeTrigger = UNTimeIntervalNotificationTrigger(timeInterval: -minutesBefore, repeats: false)


        // Create the notification requests
        let identifierDueDate = "TaskNotification_DueDate_\(task.objectID.uriRepresentation().absoluteString)"
        let requestDueDate = UNNotificationRequest(identifier: identifierDueDate, content: contentNow, trigger: dueDateTrigger)

        let identifierDayBefore = "TaskNotification_DayBefore_\(task.objectID.uriRepresentation().absoluteString)"
        let requestDayBefore = UNNotificationRequest(identifier: identifierDayBefore, content: contentDayBefore, trigger: dayBeforeTrigger)

        let identifierMinutesBefore = "TaskNotification_MinutesBefore_\(task.objectID.uriRepresentation().absoluteString)"
//        let requestMinutesBefore = UNNotificationRequest(identifier: identifierMinutesBefore, content: content, trigger: minutesBeforeTrigger)

        // Add the notification requests to the notification center
        if !(dueDate < Date()){
            log("[NotificationHelper] [makeTaskNotification] Notification created with the following identifiers - Identifier Due Date: \(identifierDueDate), Identifier Minutes Before: \(identifierMinutesBefore), Identifier Day Before: \(identifierDayBefore) \n", debug: NotificationHelper.debug)

            UNUserNotificationCenter.current().add(requestDueDate) { error in
                if let error = error {
                    print("Error scheduling due date notification: \(error)")
                    completion(.failure(.notificationCreationFailed(reason: "Failed to create the notification. Please try again later.")))
                    return
                }
                else{
                    log("[NotificationHelper] [makeTaskNotification] Scheduled notification for the following date: \(dueDate)", debug: NotificationHelper.debug)
                    completion(.success(true))
                }
            }
        }
        else{
                log("[NotificationHelper] [makeTaskNotification] Did not schedule dueDate notification as the dueDate is passed the users current date! {dueDate: \(dueDate)} {usersDate: \(Date())} ", debug: NotificationHelper.debug)
        }

            let calendar = Calendar.current

            if let dayBeforeDate = calendar.date(from: dayBeforeComponents) {
                if !(dayBeforeDate < Date()){
                    UNUserNotificationCenter.current().add(requestDayBefore) { error in
                        if let error = error {
                            print("Error scheduling day before notification: \(error)")
                            completion(.failure(.notificationCreationFailed(reason: "Failed to create the notification. Please try again later.")))
                            return
                        }
                        else{
                            log("[NotificationHelper] [makeTaskNotification] Scheduled notification for the day before \(dueDate), set to \(dayBeforeDate), before the due date.", debug: NotificationHelper.debug)
                            completion(.success(true))
                        }
                    }
                }
                else{
                    log("[NotificationHelper] [makeTaskNotification] Did not assign day before notification for task since date would be before users current date! {date: \(dayBeforeDate)} {usersDate: \(Date())}", debug: NotificationHelper.debug)
                }
            }
            else{
                log("[NotificationHelper] [makeTaskNotification] Could not validate triggerDate for day before", debug: NotificationHelper.debug)
            }

            let minutesBeforeTriggerDate = Calendar.current.date(byAdding: .minute, value: -taskNotificationsMinutesBefore, to: dueDate)

            if let triggerDate = minutesBeforeTriggerDate {
                if !(triggerDate < Date()){
                    let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
                    let minutesBeforeTrigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
                    let requestMinutesBefore = UNNotificationRequest(identifier: identifierMinutesBefore, content: contentMinutesBefore, trigger: minutesBeforeTrigger)

                    UNUserNotificationCenter.current().add(requestMinutesBefore) { error in
                        if let error = error {
                            print("Error scheduling minutes before notification: \(error)")
                            completion(.failure(.notificationCreationFailed(reason: "Failed to create the notification. Please try again later.")))
                        } else {
                            log("[NotificationHelper] [makeTaskNotification] Scheduled notification for \(taskNotificationsMinutesBefore) minutes before the task, on date \(triggerDate).", debug: NotificationHelper.debug)

                            completion(.success(true))
                        }
                    }

                }
                else{
                    log("[NotificationHelper] [makeTaskNotification] Did not assign minutes before notification for task since date would be before users current date! {date: \(triggerDate)} {usersDate: \(Date())}", debug: NotificationHelper.debug)
                }

            }
            else{
                log("[NotificationHelper] [makeTaskNotification] Could not validate triggerDate for minutes before", debug: NotificationHelper.debug)
            }

    }

    func cancelTaskNotifications(for task: TaskEntity) {
        let identifiers = [
            "TaskNotification_DueDate_\(task.objectID.uriRepresentation().absoluteString)",
            "TaskNotification_DayBefore_\(task.objectID.uriRepresentation().absoluteString)",
            "TaskNotification_MinutesBefore_\(task.objectID.uriRepresentation().absoluteString)"
        ]

        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    func createPlannerNotifications(for date: Date) {
        var weekWiz = WeekWizard()

        guard let weekNumber = weekWiz.getCurrentWeek(date),
              let targetWeek = weeks.first(where: { $0.number == weekNumber }),
              let dayArray = (targetWeek.days?.allObjects as? [Day])?.sorted(by: { $0.number < $1.number })
        else {
            return
        }

        for day in dayArray {
            guard let timeSlotArray = (day.timeSlots?.allObjects as? [TimeSlot])?.sorted(by: { $0.timestamp! < $1.timestamp! }) else {
                continue
            }

            for timeSlot in timeSlotArray{

            }
        }
    }

    func createNotification(for timeSlot: TimeSlot, on day: Day, with date: Date) {
        // Calculate the week number based on the provided date
        var weekWiz = WeekWizard()

        guard let totalWeeks = weekWiz.totalWeeks else {
            return
        }
        guard let weekNumber = weekWiz.getCurrentWeek(date) else {
            return
        }

        // Extract day number from the Day entity
        let dayNumber = day.number

        // Convert the startTime string to a Date
        guard let startTimeDate = TimeFormatter.toDate(timeSlot.startTime!) else {
            return
        }

        // Calculate the interval between notifications (repeat every totalWeeks weeks)
        let weeksBetweenNotifications = totalWeeks

        // Calculate the notification date and time
        var notificationDateComponents = Calendar.current.dateComponents([.year, .month, .day], from: date)
        notificationDateComponents.hour = Calendar.current.component(.hour, from: startTimeDate)
        notificationDateComponents.minute = Calendar.current.component(.minute, from: startTimeDate)

        // Set the day of the week based on day number (0 - Monday, 6 - Sunday)
        notificationDateComponents.weekday = Int(dayNumber) + 2 // Adjust for Calendar's weekday representation

        // Create the notification content
        let content = UNMutableNotificationContent()
        content.title = timeSlot.classEntity?.name ?? timeSlot.splitterEntity?.name ?? "Untitled Entry"

        // Create the notification body based on available information
        var notificationBody = "You have a class"
        if let room = timeSlot.room, !room.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            notificationBody += " in \(room)"
        }
        if let teacher = timeSlot.taughtBy, let teacherName = teacher.name, !teacherName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            if notificationBody.last != " " { // Ensure a space between class and teacher
                notificationBody += " "
            }
            notificationBody += "with \(teacherName)"
        }
        content.body = notificationBody

        // Calculate the time interval in seconds
        let timeInterval = TimeInterval(weeksBetweenNotifications * 7 * 24 * 60 * 60) // Convert weeks to seconds

        // Create the trigger for the notification using UNTimeIntervalNotificationTrigger
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: true)


        // Create the notification request
        let identifier = "TimeSlotNotification_\(timeSlot.objectID.uriRepresentation().absoluteString)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        // Add the notification request to the notification center
        let center = UNUserNotificationCenter.current()
        center.add(request) { error in
            if let error = error {
                print("Error adding notification request: \(error)")
            }
        }
    }



}

enum TaskNotificationError: Error {
    case missingTitle
    case missingClassEntity
    case missingTaskType
    case notificationCreationFailed(reason: String)

    var reason: String {
        switch self {
        case .missingTitle:
            return "Task title is missing. Please provide a title."
        case .missingClassEntity:
            return "Type is missing. Please provide a type."
        case .missingTaskType:
            return "Task type is missing. Please provide a task type."
        case .notificationCreationFailed(let reason):
            return reason
        }
    }
}
