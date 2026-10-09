//
//  Notifications.swift
//  KyoNeo
//
//  Created by Aether on 03/04/2023.
//

import Foundation
import SwiftUI
import UserNotifications

func scheduleNotification(at date: Date, with message: String, title: String, data: TaskEntity) {
    let content = UNMutableNotificationContent()
    content.title = title
    content.body = message
    content.sound = UNNotificationSound.default

    let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
    let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

    let uuidString = UUID().uuidString
    let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)

    let notificationCenter = UNUserNotificationCenter.current()

    notificationCenter.add(request) { (error) in
        if error != nil {
            print(error?.localizedDescription ?? "")
        }
    }

    let action = UNNotificationAction(identifier: "openTask", title: "Open Task", options: [.foreground])
    let category = UNNotificationCategory(identifier: "taskCategory", actions: [action], intentIdentifiers: [], options: [])

    notificationCenter.setNotificationCategories([category])

    content.categoryIdentifier = "taskCategory"
    content.userInfo = ["taskID": data.id]

    notificationCenter.add(request) { error in
        if let error = error {
            print("Error scheduling notification: \(error)")
        } else {
            print("Notification scheduled successfully.")
        }
    }
}
