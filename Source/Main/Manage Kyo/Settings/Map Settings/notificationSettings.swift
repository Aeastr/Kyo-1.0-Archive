//
//  notificationSettings.swift
//  KyoNeo
//
//  Created by Aether on 19/07/2023.
//

import SwiftUI
import AmethystUI
import UserNotifications

struct NotificationSettings: View {
    @State var scrolled: Bool = false
    @State private var notificationStatus: UNAuthorizationStatus = .notDetermined

    
    @AppStorage("plannerNotifications") var plannerNotifications = true
    @AppStorage("taskNotifications") var taskNotifications = true
    @AppStorage("todayNotifications") var todayNotifications = true
    @AppStorage("plannerNotificationsMinutesBefore") var plannerNotificationsMinutesBefore: Int = 5
    @AppStorage("taskNotificationsMinutesBefore") var taskNotificationsMinutesBefore: Int = 20

    @Environment(\.managedObjectContext) private var viewContext

    var color: Color = .red

    var onboardMode = false
    @Binding var index: Int

    var body: some View {
        ScrollView{
            ScrollDetector(scrolled: $scrolled)
            VStack{
                Group{
                    Text("Kyo will use notifications to inform you of upcoming tasks and entries in your planner")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
#if os(macOS)
                        .padding(.top, 5)
#endif

                    Text("Permissions")
                        .sectionTitle()
                    Button {
                        NotificationHelper().requestPermission { success in
                            if success {
                                notificationStatus = .authorized
                            } else {
                                // Permission denied or an error occurred, handle it here
                            }
                        }

                    } label: {
                        if notificationStatus == .authorized {
                            Text("Permission Allowed")
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("Allow Permission")
                                .frame(maxWidth: .infinity)
                        }

                    }

                    .buttonStyle(BentoButton(color: color))

                }
                .padding(.horizontal, 20)

                //                Button {
                //                    if let nextWeekDate = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: Date()){
                //                        NotificationHelper(context: viewContext).makeNotifications(for: nextWeekDate)
                //                    }
                //                } label: {
                //                    Text("test make noti")
                //                }

                Text("Planner")
                    .sectionTitle()
                    .padding(.horizontal, 20)
                VStack{

                Toggle(isOn: notificationStatus == .authorized ? $plannerNotifications : .constant(false)) {
                    HStack{
                        Image(systemName: "square.text.square")
                            .frame(width: 20, alignment: .center)
                            .symbolRenderingMode(.hierarchical)
                            .foregroundColor(color)

                        VStack(alignment: .leading, spacing: 3){
                            Text("Planner Notifications")
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }

                }
                .frame(maxWidth: .infinity)
                .toggleStyle(.switch)
                .neoSettingsToggle()
                .padding(.horizontal, 20)
                .opacity(notificationStatus == .authorized ? 1 : 0.5)
                HStack{
                    VStack{
                        HStack(alignment: .top){
                            VStack{
                                Image(systemName: "clock.badge")
                                    .frame(width: 20, alignment: .center)
                                    .symbolRenderingMode(.hierarchical)
                                    .foregroundColor(color)
                            }

                            VStack(alignment: .leading, spacing: 3){
                                Text("Notification Time")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text("You can schedule notifcations to notify you before the actual time of your class")
                                    .font(.caption).opacity(0.5)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }

                    }

                    Picker("", selection: $plannerNotificationsMinutesBefore) {
                        ForEach(0...30, id: \.self) {
                            if $0 == 0{
                                Text("None")
                                    .id($0)
                            }
                            else{
                                Text("\($0) min\($0 > 1 ? "s" : "")")
                                    .id($0)
                            }
                        }
                    }
#if os(iOS) || os(visionOS)
                    .pickerStyle(WheelPickerStyle())
#endif
                    .frame(width: 100, height: 140)
                    .frame(width: 100, height: 100)
                    .clipShape(Rectangle())
                }
                .padding(.horizontal, 2)
                .padding(.horizontal, 13)
                .background {
                    Color("NeoButton").opacity(0.6)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .regularOutline(cornerRadius: 18)

                }
                .padding(.horizontal, 20)
                .opacity(notificationStatus == .authorized ? 1 : 0.5)
                .disabled(notificationStatus != .authorized)
            }
//                .disabled(true)
//                .blur(radius: 5)
//                .opacity(0.5)
//                .overlay {
//                    Text("Planner Notifications coming soon")
//                }

                Text("Tasks")
                    .sectionTitle()
                    .padding(.horizontal, 20)
                Toggle(isOn: notificationStatus == .authorized ? $taskNotifications : .constant(false)) {
                    HStack{
                        Image(systemName: "square.text.square")
                            .frame(width: 20, alignment: .center)
                            .symbolRenderingMode(.hierarchical)
                            .foregroundColor(color)
                        
                        VStack(alignment: .leading, spacing: 3){
                            Text("Task Notifications")
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    
                }
                .frame(maxWidth: .infinity)
                .toggleStyle(.switch)
                .neoSettingsToggle()
                .padding(.horizontal, 20)
                .opacity(notificationStatus == .authorized ? 1 : 0.5)

                HStack{
                    VStack{
                        HStack(alignment: .top){
                            VStack{
                                Image(systemName: "clock.badge")
                                    .frame(width: 20, alignment: .center)
                                    .symbolRenderingMode(.hierarchical)
                                    .foregroundColor(color)
                            }

                            VStack(alignment: .leading, spacing: 3){
                                Text("Notification Time")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text("You can schedule notifcations to notify you before the actual time of your task")
                                    .font(.caption).opacity(0.5)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }

                    }

                    Picker("", selection: $taskNotificationsMinutesBefore) {
                        ForEach(0...30, id: \.self) {
                            if $0 == 0{
                                Text("None")
                                    .id($0)
                            }
                            else{
                                Text("\($0) min\($0 > 1 ? "s" : "")")
                                    .id($0)
                            }
                        }
                    }
#if os(iOS) || os(visionOS)
                    .pickerStyle(WheelPickerStyle())
                    #endif
                        .frame(width: 100, height: 140)
                        .frame(width: 100, height: 100)
                        .clipShape(Rectangle())
                }
                .padding(.horizontal, 2)
                .padding(.horizontal, 13)
                .background {
                    Color("NeoButton").opacity(0.6)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .regularOutline(cornerRadius: 18)

                }
                .padding(.horizontal, 20)

                .opacity(notificationStatus == .authorized ? 1 : 0.5)
                .disabled(notificationStatus != .authorized)
            }
            .onAppear{
                notificationStatus = checkNotificationPermission()
            }
//            if !onboardMode{
//                Group {
//                    VStack {
//                        Text("debug")
//                            .sectionTitle()
//                        Text("⚠️ Use the buttons below with caution! These actions may affect your notifications.")
//                            .foregroundColor(.red)
//                            .font(.caption)
//                        
//                        
//                        Button(action: {
//                            // Action for the first button
//                        }) {
//                            Text("Enable notifications for all time slots")
//                                .frame(maxWidth: .infinity, alignment: .leading)
//                        }
//                        .buttonStyle(BentoButton(color: color))
//                        
//                        Button(action: {
//                            NotificationHelper(context: viewContext).makeAllNotifications()
//                        }) {
//                            Text("Schedule All Notifications")
//                                .frame(maxWidth: .infinity, alignment: .leading)
//                        }
//                        .buttonStyle(BentoButton(color: color))
//                        
//                        Button(action: {
//                            NotificationHelper(context: viewContext).cancelAllLocalNotifications()
//                        }) {
//                            Text("Cancel All Notifications")
//                                .frame(maxWidth: .infinity, alignment: .leading)
//                        }
//                        .buttonStyle(BentoButton(role: .destructive))
//                    }
//                }
//                .padding(.horizontal, 20)
//            }

        }
        .tint(color)
        #if os(iOS) || os(visionOS)
        .toolbar(.hidden)
        .safeAreaInset(edge: .top, content: {
            Color.clear.frame(height: 80)
        })

        .overlay(alignment: .top){
            if !onboardMode{
                FluidNavigationBar(title: "Notifications", titleColor: .primary,   tintColor: color, compactMode: true, type: .back, scrolled: $scrolled, content: {

                }, toolbar: {

                })
            }
            else{
                FluidNavigationBar(title: "Notifications", titleColor: .primary,   tintColor: color, compactMode: true, type: .back, scrolled: $scrolled, content: {

                }, toolbar: {

                }, overrideBackAction: {
                    withAnimation(.smoothCard){
                        index = index - 1
                    }
                })
            }

            }
        #endif
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
}
