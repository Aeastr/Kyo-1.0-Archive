// FIX: Use archive identifiers to keep this build and its data separate from the original app.
//
//  MainVie.swift
//  KyoNeo
//
//  Created by Aether on 20/11/2022.
//

import SwiftUI
import AmethystUI
import CoreData
#if canImport(RiveRuntime)
import RiveRuntime
#endif

// Our observable object class
class tabBarState: ObservableObject {
    @Published var show = true
}

#if !targetEnvironment(macCatalyst) && !os(visionOS)
struct TabbedNavigation: View {

    @StateObject private var errorObserver = ErrorObserver()
    
    
    @AppStorage("schedule_SingleDayMode", store: UserDefaults(suiteName: "group.com.example.kyoarchive")) var schedule_SingleDayMode: Bool = false
    // State variables
    @State var show: Bool = true // Controls the visibility of certain views, e.g., tab bar
    @State var edit: Bool = false // Indicates if the PlannerView is in edit mode
    @AppStorage("selectedTabIndex") var selectedTabIndex: Int = 2 // Holds the currently selected tab
    @State private var dragAmount: CGSize = CGSize.zero // Unused in the current implementation

    @AppStorage("animationModeKey") private var animationsMode: AnimationMode = .enabled
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.colorScheme) private var colorScheme
    // AppStorage variables
    @AppStorage("schedule_SelectedDayID") var schedule_SelectedDayID: String?
    @AppStorage("automaticDay") var automaticDay = true // Automatically selects the current day
    @AppStorage("automaticWeek") var automaticWeek = true
    @AppStorage("schedule_SelectedWeekID") var schedule_SelectedWeekID: String?

    @AppStorage("tintPages") var tintPages = false // Controls the opacity of the tint color
    @AppStorage("Contrast") var contrast = false // Increases contrast when enabled.font(.system(size: 10, weight: .bold))

    // FetchRequest variables
    @FetchRequest(sortDescriptors: []) var weeks: FetchedResults<Week> // Fetches weeks from Core Data

    @AppStorage("appAccentColor") var appAccentColor = "Default"
    @AppStorage("multicolored") var multicolored = true
    @AppStorage("appAccentColorIndex") var appAccentColorIndex = 1

    @AppStorage("todayExists") var todayExists = true

    @AppStorage("skipEmpty") var skipEmpty = true
    @AppStorage("skipPast") var skipPast = true
    // Main View Body

    @AppStorage("showSettingsPage") var showSettingsPage: Bool = false

    @State var startErrorType: startErrors = .parentlessTimeSlots
    @State var showStartErrorAlert = false


    @StateObject private var columnVisibilitySettings = ColumnVisibilitySettings()
    var body: some View {
        FluidTabBar(tabItems: [

            TabItem(label: String(localized: "today-title"), riveView: RiveViewModel(fileName: "iosicons", stateMachineName: "TODAY_state", artboardName: "TODAY"), color: Color(multicolored ? "\(appAccentColor)/1" : "\(appAccentColor)/\(appAccentColorIndex)"), content: {

                    todayView(color: Color(multicolored ? "\(appAccentColor)/1" : "\(appAccentColor)/\(appAccentColorIndex)"))
                    .navigationDestination(for: GroupItem.self) { item in
                                                        item.destinationView
                                                    }
                    .safeAreaInset(edge: .bottom) {
                                                Color.clear.frame(height: 45)
                                            }

            }),
            //
            TabItem(label: String(localized: "planner-title"), riveView: RiveViewModel(fileName: "iosicons", stateMachineName: "PLANNER_state", artboardName: "PLANNER"), color: Color(multicolored ? "\(appAccentColor)/2" : "\(appAccentColor)/\(appAccentColorIndex)"), content: {

                PlannerView(color: Color(multicolored ? "\(appAccentColor)/2" : "\(appAccentColor)/\(appAccentColorIndex)"))
                    .environmentObject(columnVisibilitySettings)
                    .navigationDestination(for: GroupItem.self) { item in
                                                        item.destinationView
                                                    }
            }),

            //                    TabItem(label: "Calendar", riveView: RiveViewModel(fileName: "iosicons", stateMachineName: "CALENDAR_state", artboardName: "CALENDAR"), color: Color(multicolored ? "\(appAccentColor)/3" : "\(appAccentColor)/\(appAccentColorIndex)"), content: {
            //                        if #available(iOS 17.0, *) {
            //                            CalendarView(color: Color(multicolored ? "\(appAccentColor)/3" : "\(appAccentColor)/\(appAccentColorIndex)"))
            //                        }
            //                    }),

            //
            ////
            TabItem(label: String(localized: "tasks-title"), riveView: RiveViewModel(fileName: "iosicons", stateMachineName: "TASKS_state", artboardName: "TASKS"), color: ColorEngine().getXColor(4, colorScheme: colorScheme), content: {

                    TaskView(color: ColorEngine().getXColor(4, colorScheme: colorScheme))
                    .navigationDestination(for: GroupItem.self) { item in
                                                        item.destinationView
                                                    }
                    .safeAreaInset(edge: .bottom) {
                                                                    Color.clear.frame(height: 45)
                                                                }

            }),

            //                TabItem(label: "Resources", riveView: RiveViewModel(fileName: "iosicons", stateMachineName: "SPARKLE_state", artboardName: "SPARKLE"), color: Color(multicolored ? "\(appAccentColor)/4" : "\(appAccentColor)/\(appAccentColorIndex)"), content: {
            //                    ResourcesView(color: Color(multicolored ? "\(appAccentColor)/4" : "\(appAccentColor)/\(appAccentColorIndex)"))
            //                }),
            ////
            TabItem(label: "Kyo", riveView: RiveViewModel(fileName: "iosicons", stateMachineName: "SPARKLE_state", artboardName: "SPARKLE"), color: ColorEngine().getXColor(5, colorScheme: colorScheme),  content: {
                KyoOverview(color: ColorEngine().getXColor(5, colorScheme: colorScheme))
                    .navigationDestination(for: GroupItem.self) { item in
                                                        item.destinationView
                                                    }
                    .safeAreaInset(edge: .bottom) {
                                                                    Color.clear.frame(height: 45)
                                                                }
            })
        ], selectedIndex: $selectedTabIndex, animateIcons: animationsMode != .disabled && !reduceMotion ? true :  false, pageAnimation: animationsMode == .enabled && !reduceMotion ? .full : animationsMode == .reduced ? .fade : .none, type: .regular)

        .ignoresSafeArea(edges: [.bottom])


        .alert(isPresented: $showStartErrorAlert, error: startErrorType) { LocalizedError in
            Button(role: .cancel) {
                LocalizedError.fixAction()
            } label: {
                Text("Fix")
            }
            Button(role: .destructive) {

            } label: {
                Text("Ignore")
            }
        } message: { LocalizedError in
            Text(LocalizedError.failureReason ?? "Unkown Error")
        }
       
#if !os(macOS)
        .fullScreenCover(isPresented: $showSettingsPage, content: {

                SettingsView(color: Color(cgColor: Color(multicolored ? "\(appAccentColor)/5" : "\(appAccentColor)/\(appAccentColorIndex)").convertToCGColor(name: (multicolored ? "\(appAccentColor)/5" : "\(appAccentColor)/\(appAccentColorIndex)"), in: colorScheme)), navigationButtons: {
                    Button(action: {

                            showSettingsPage.toggle()
                    }, label: {
                        Text("Done")
                            .scaledFrame(width: 60, height: 40, relativeTo: .body)
                    })
                    .buttonStyle(NavigationButton(color: Color(multicolored ? "\(appAccentColor)/1" : "\(appAccentColor)/\(appAccentColorIndex)"), scrolled: .constant(false)))
                })

            
        })
#endif

    }

}
#elseif os(visionOS)

struct TabbedNavigation: View {
    @Environment(\.colorScheme) private var colorScheme

    @AppStorage("selection") var selection = 1

    @AppStorage("appAccentColor") var appAccentColor = "Default"
    @AppStorage("multicolored") var multicolored = true
    @AppStorage("appAccentColorIndex") var appAccentColorIndex = 1
    var body: some View{
        TabView(selection: $selection) {
            NavigationStack{
                todayView(color: ColorEngine().getColor((multicolored ? "\(appAccentColor)/1" : "\(appAccentColor)/\(appAccentColorIndex)"), colorScheme: colorScheme))
            }
                    .tabItem { Label("Today", systemImage: "doc.text.image") }
                    .tag(0)

                PlannerView(color: ColorEngine().getColor((multicolored ? "\(appAccentColor)/2" : "\(appAccentColor)/\(appAccentColorIndex)"), colorScheme: colorScheme))


                .tabItem { Label("Planner", systemImage: "calendar.day.timeline.left") }
                .tag(1)

            NavigationStack{
                TaskView(color: ColorEngine().getColor((multicolored ? "\(appAccentColor)/3" : "\(appAccentColor)/\(appAccentColorIndex)"), colorScheme: colorScheme))
            }
                .tabItem { Label("Task", systemImage: "tray.full") }
                .tag(3)
            NavigationSplitView(sidebar: {
                KyoOverview(color: ColorEngine().getColor((multicolored ? "\(appAccentColor)/4" : "\(appAccentColor)/\(appAccentColorIndex)"), colorScheme: colorScheme))
                    .navigationDestination(for: GroupItem.self) { item in
                                    item.destinationView
                                }
                   
            }, detail: {

            })
                .tabItem { Label("Kyo", systemImage: "sparkles") }
                .tag(4)

            
            SettingsView(color: ColorEngine().getColor((multicolored ? "\(appAccentColor)/5" : "\(appAccentColor)/\(appAccentColorIndex)"), colorScheme: colorScheme))

                .tabItem { Label("Settings", systemImage: "gear") }
                .tag(5)
        }
    }
}
#endif


