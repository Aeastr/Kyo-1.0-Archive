// FIX: RevenueCat is removed from the unlocked archive; original purchase code is on original-source.
// FIX: Use archive identifiers to keep this build and its data separate from the original app.
//
//  NavigationHandler.swift
//  KyoNeo
//
//  Created by Aether on 08/01/2023.
//

import SwiftUI 
#if os(iOS) || os(visionOS)
struct NavigationHandler: View {
    //Kyo+ Props
    @AppStorage("activeAppIcon") var activeAppIcon: String = "AppIconDefault"

    @AppStorage("multicolored") var multicolored = true
    @AppStorage("appAccentColor") var appAccentColor = "Default"

    @AppStorage("accentImageName") var accentImageName = "doodle1"

    @AppStorage("navigationFont") var fontDesign: navigationFont = .expanded
    
    @AppStorage("fontWeightIndex") private var fontWeightIndex: Int = 1
    @AppStorage("fontCaseIndex") private var fontCaseIndex: Int = 0
    //other

    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: []) var weeks: FetchedResults<Week> // Fetches weeks from Core Data
    @FetchRequest(sortDescriptors: []) var days: FetchedResults<Day> // Fetches weeks from Core Data
    @AppStorage("schedule_SingleDayMode", store: UserDefaults(suiteName: "group.com.example.kyoarchive")) var schedule_SingleDayMode: Bool = false
    @AppStorage("skipEmpty") var skipEmpty = true
    @AppStorage("skipPast") var skipPast = true
    @AppStorage("schedule_SelectedDayID") var schedule_SelectedDayID: String?
    @AppStorage("schedule_SelectedWeekID") var schedule_SelectedWeekID: String?

    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    // FIX: Archive access is unconditional; do not read or update a persisted purchase flag.
    private var kyoPlus_hasPlus: Bool { true }
    @StateObject var alertManager = AlertManager()
    @State var showWeekSetup: Bool = false

    @State var path = NavigationPath()

    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "number", ascending: true)],
                          predicate: NSPredicate(format: "singleDayWeek == nil OR singleDayWeek == %@", NSNumber(value: false))
            ) var weeks2: FetchedResults<Week>

    var body: some View {
        // If the current device is a phone, show the TabbedNavigation view
        Group{
        if (getDeviceType() == .phone || getDeviceType() == .vision ) || horizontalSizeClass == .compact {
#if os(iOS) && !targetEnvironment(macCatalyst)
            NavigationStack{
                TabbedNavigation()
                    .ignoresSafeArea(edges: [.bottom])
            }


#elseif !targetEnvironment(macCatalyst)

            TabbedNavigation()
#endif
        }
        // If the current device is not a phone (e.g. an iPad), show the sidebar navigation view
        else {


                Sidebar()
                    .navigationDestination(for: GroupItem.self) { item in
                        item.destinationView
                    }

        }
    }


//        .onAppear(){
//
//                    KyoPlus().checkPaymentStatus { Bool in
//                                                        kyoPlus_hasPlus = Bool
//                                                    }
//
//
//
//
//
//                    print("settings data and checking taasks")
//                    let dispatchGroup = DispatchGroup()
//
//                    dispatchGroup.enter()
//
//            if !kyoPlus_hasPlus{
//                                   if activeAppIcon != "AppIconDefault"{
//                                       UIApplication.shared.setAlternateIconName(nil)
//                                   }
//                                   activeAppIcon = "AppIconDefault"
//
//                                   multicolored = true
//                                   appAccentColor = "Default"
//
//                                   accentImageName = "doodle1"
//
//                                   if fontDesign != .expanded || fontDesign != .OpenDyslexic{
//                                       fontDesign = .expanded
//                                   }
//
//                                   fontWeightIndex = 1
//                                   fontCaseIndex = 0
//                               }
//
//                    if !schedule_SingleDayMode{
//                        // Automatically selects the current day if enabled
//
//
//                        for (index, week) in weeks2.enumerated() {
//                                                   week.number = Int64(index + 1)
//                                               }
//                        do {
//                                               try viewContext.save()
//                                               print("save!!")
//                                           } catch {
//                                               let nsError = error as NSError
//                                               fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//                                           }
//
//                        let weekWizard: WeekWizard = WeekWizard(alertManager: alertManager, customMessage: "fromOnAppear")
//                        let x = timeSlotChecks()
//                        if weekWizard.totalWeeks != nil && !x.checkForParentlessTimeSlots() {
//                            print("get")
//                            let scheduleManager = ScheduleManager( debug: true, customWeekWizard: weekWizard, findOnlyNonEmptyDays: x.empty() ? false : skipEmpty,  findNextWithUpcomingCurrentSlots: x.empty() ? false :  skipPast)
//
//                            if let foundWeek = weekWizard.getCurrentWeek(), let scheduleData = scheduleManager.getCurrentDay(foundWeek), let dayID = scheduleData.day.id?.uuidString, let week = scheduleData.day.week {
//                            schedule_SelectedDayID = dayID
//                            schedule_SelectedWeekID = week.id?.uuidString
//                        }
//                            else{
//                                print("uh oh")
//                            }
//
//                        }
//                        else if weekWizard.totalWeeks == nil && !weeks.isEmpty{
//                            alertManager.showAlert(title: "An error occured", message: "Failed to get current week") {
//                                Button {
//                                    showWeekSetup.toggle()
//                                } label: {
//                                    Label("Set Week", systemImage: "calendar")
//                                }
//
//
//                            }
//                        }
//                        else{
//                            print("errr")
//                            //                if x.checkForParentlessTimeSlots(){
//                            //                    startErrorType = .parentlessTimeSlots
//                            //                    showStartErrorAlert.toggle()
//                            //                }
//
//                        }
//
//                        dispatchGroup.leave()
//                    }
//                    else{
//                        print("single")
//                        let x = days.first(where: { day in
//                            day.name == "Single0"
//                        })?.id?.uuidString
//                        schedule_SelectedDayID = x
//                        let y = weeks.first { week in
//                            week.singleDayWeek == true
//                        }?.id?.uuidString
//                        schedule_SelectedWeekID = y
//                        dispatchGroup.leave()
//                    }
//
//
//                    dispatchGroup.enter()
//                    TaskArchiver().archiveTasks()
//                    dispatchGroup.leave()
//
//                    dispatchGroup.notify(queue: .main) {
//
//                    }
//                }
        .onChange(of: kyoPlus_hasPlus){
            if !kyoPlus_hasPlus{
                                   if activeAppIcon != "AppIconDefault"{
                                       UIApplication.shared.setAlternateIconName(nil)
                                   }
                                   activeAppIcon = "AppIconDefault"

                                   multicolored = true
                                   appAccentColor = "Default"

                                   accentImageName = "doodle1"

                                   if fontDesign != .expanded || fontDesign != .OpenDyslexic{
                                       fontDesign = .expanded
                                   }

                                   fontWeightIndex = 1
                                   fontCaseIndex = 0
                               }
        }
        .onChange(of: schedule_SingleDayMode ){

            // FIX: No purchase check or access-state write is needed; Kyo+ is permanently unlocked.

            print("settings data and checking taasks")
            let dispatchGroup = DispatchGroup()

            dispatchGroup.enter()

            if !schedule_SingleDayMode{
                // Automatically selects the current day if enabled

                let weekWizard: WeekWizard = WeekWizard(alertManager: alertManager, customMessage: "fromOnAppear")
                let x = timeSlotChecks()
                if weekWizard.totalWeeks != nil && !x.checkForParentlessTimeSlots() {
                    print("get")
                    let scheduleManager = ScheduleManager( debug: true, customWeekWizard: weekWizard, findOnlyNonEmptyDays: x.empty() ? false : skipEmpty,  findNextWithUpcomingCurrentSlots: x.empty() ? false :  skipPast, fromCode: "nav handler")

                    if let foundWeek = weekWizard.getCurrentWeek(), let scheduleData = scheduleManager.getCurrentDay(foundWeek), let dayID = scheduleData.day.id?.uuidString, let week = scheduleData.day.week {
                    schedule_SelectedDayID = dayID
                    schedule_SelectedWeekID = week.id?.uuidString
                }
                    else{
                        print("uh oh")
                    }

                }
                else if weekWizard.totalWeeks == nil && !weeks.isEmpty{
                    alertManager.showAlert(title: "An error occured", message: "Failed to get current week") {
                        Button {
                            showWeekSetup.toggle()
                        } label: {
                            Label("Set Week", systemImage: "calendar")
                        }


                    }
                }
                else{
                    print("errr")
                    //                if x.checkForParentlessTimeSlots(){
                    //                    startErrorType = .parentlessTimeSlots
                    //                    showStartErrorAlert.toggle()
                    //                }

                }

                dispatchGroup.leave()
            }
            else{
                print("single")
                let x = days.first(where: { day in
                    day.name == "Single0"
                })?.id?.uuidString
                schedule_SelectedDayID = x
                let y = weeks.first { week in
                    week.singleDayWeek == true
                }?.id?.uuidString
                schedule_SelectedWeekID = y
                dispatchGroup.leave()
            }


            dispatchGroup.enter()
            TaskArchiver().archiveTasks()
            dispatchGroup.leave()

            dispatchGroup.notify(queue: .main) {

            }
        }
        .alert(alertManager.alertTitle, isPresented: $alertManager.showAlert) {
            alertManager.alertContent()
        } message: {
            Text(alertManager.alertMessage)
        }
        .sheet(isPresented: $showWeekSetup) {
            AutomaticWeeks(color: Color.accentColor)
                .interactiveDismissDisabled()
                .presentationCornerRadius(25)
        }




    }

    // This function gets the device type based on the user interface idiom
    func getDeviceType() -> UIUserInterfaceIdiom {
        let deviceType = UIDevice.current.userInterfaceIdiom
        return deviceType
    }
}
#elseif os(macOS)
struct NavigationHandler: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: []) var weeks: FetchedResults<Week> // Fetches weeks from Core Data
    @AppStorage("schedule_SingleDayMode", store: UserDefaults(suiteName: "group.com.example.kyoarchive")) var schedule_SingleDayMode: Bool = false
    @AppStorage("skipEmpty") var skipEmpty = true
    @AppStorage("skipPast") var skipPast = true
    @AppStorage("schedule_SelectedDayID") var schedule_SelectedDayID: String?
    @AppStorage("schedule_SelectedWeekID") var schedule_SelectedWeekID: String?

    @StateObject var alertManager = AlertManager()
    @State var showWeekSetup: Bool = false

    var body: some View {

            Sidebar()

            .onAppear(){
                print("settings data and checking taasks")
                let dispatchGroup = DispatchGroup()

                dispatchGroup.enter()

                if !schedule_SingleDayMode{
                    // Automatically selects the current day if enabled

                    var weekWizard: WeekWizard = WeekWizard(alertManager: alertManager)
                    let x = timeSlotChecks()
                    if weekWizard.totalWeeks != nil && !x.checkForParentlessTimeSlots() {
                        print("get")
                        let scheduleManager = ScheduleManager( debug: true, customWeekWizard: weekWizard, findOnlyNonEmptyDays: x.empty() ? false : skipEmpty,  findNextWithUpcomingCurrentSlots: x.empty() ? false :  skipPast)

                        if let foundWeek = weekWizard.getCurrentWeek(), let scheduleData = scheduleManager.getCurrentDay(foundWeek), let dayID = scheduleData.day.id?.uuidString, let week = scheduleData.day.week {
                        schedule_SelectedDayID = dayID
                        schedule_SelectedWeekID = week.id?.uuidString
                    }

                    }
                    else if weekWizard.totalWeeks == nil{
                        alertManager.showAlert(title: "An error occured", message: "Failed to get current week") {
                            Button {
                                showWeekSetup.toggle()
                            } label: {
                                Label("Set Week", systemImage: "calendar")
                            }


                        }
                    }
                    else{
                        print("errr")
                        //                if x.checkForParentlessTimeSlots(){
                        //                    startErrorType = .parentlessTimeSlots
                        //                    showStartErrorAlert.toggle()
                        //                }

                    }

                    dispatchGroup.leave()
                }
                else{
                    dispatchGroup.leave()
                }


                dispatchGroup.enter()
                TaskArchiver().archiveTasks()
                dispatchGroup.leave()

                dispatchGroup.notify(queue: .main) {

                }
            }
            .alert(alertManager.alertTitle, isPresented: $alertManager.showAlert) {
                alertManager.alertContent()
            } message: {
                Text(alertManager.alertMessage)
            }
            .sheet(isPresented: $showWeekSetup) {
                AutomaticWeeks(color: Color.accentColor)
                    .frame(minHeight: 600)
                    .frame(maxWidth: 800)
                    .interactiveDismissDisabled()
                    .presentationCornerRadius(25)
            }

    }
}
#endif
