// FIX: Use archive identifiers to keep this build and its data separate from the original app.
//
//  SidebarNavigation.swift
//  KyoNeo
//
//  Created by Aether on 14/03/2023.
//

import SwiftUI
import CoreData
import RevenueCat
#if canImport(RiveRuntime)
import RiveRuntime
let icon1 = RiveViewModel(fileName: "iosicons", stateMachineName: "TODAY_state", artboardName: "TODAY")
#endif
//NavigationLink(value:label:), or navigationDestination(isPresented:destination:),

class ColumnVisibilitySettings: ObservableObject {
    @Published var columnVisibility: NavigationSplitViewVisibility = .all
}

struct Sidebar: View {
    @AppStorage("selectedTabIndex") var selectedTabIndex: Int = 2 // Holds the currently selected tab
    @State var show: Bool = true
    @State var showSettings: Bool = false
    @State var state: NavigationSplitViewVisibility = .automatic


    @AppStorage("schedule_SingleDayMode", store: UserDefaults(suiteName: "group.com.example.kyoarchive")) var schedule_SingleDayMode: Bool = false
    @AppStorage("skipEmpty") var skipEmpty = true
    @AppStorage("skipPast") var skipPast = true
    @AppStorage("schedule_SelectedDayID") var schedule_SelectedDayID: String?
    @AppStorage("automaticDay") var automaticDay = true // Automatically selects the current day
    @AppStorage("automaticWeek") var automaticWeek = true
    @AppStorage("schedule_SelectedWeekID") var schedule_SelectedWeekID: String?
    
    @AppStorage("appAccentColor") var appAccentColor = "Default"
    @AppStorage("multicolored") var multicolored = true
    @AppStorage("appAccentColorIndex") var appAccentColorIndex = 1

    @State var startErrorType: startErrors = .parentlessTimeSlots
    @State var showStartErrorAlert = false

    @FetchRequest(sortDescriptors: []) var weeks: FetchedResults<Week> // Fetches weeks from Core Data
    // FIX: Archive access is unconditional; do not read or update a persisted purchase flag.
    private var kyoPlus_hasPlus: Bool { true }
    @State var kyoPlus_showPurchaseScreen: Bool = false

    @FetchRequest(sortDescriptors: []) var classes: FetchedResults<ClassEntity>

    @State var showEntryCreate: Bool = false
    @State var showTaskCreate: Bool = false

    @State var showCreate: Bool = false
    @State var editClass: ClassEntity? = nil

    @StateObject private var columnVisibilitySettings = ColumnVisibilitySettings()
        var body: some View {
            NavigationSplitView {

                List(/*selection: $selectedTabIndex*/) {
                    NavigationLink(destination: {
                        todayView(color: Color(multicolored ? "\(appAccentColor)/1" : "\(appAccentColor)/\(appAccentColorIndex)"))
#if !os(macOS)
                            .navigationViewStyle(StackNavigationViewStyle())
                        #endif

                    }, label: {
                        HStack(spacing: 4){

                                Label("Today", systemImage: "doc.text.image")

                        }
                    })
                        .tag(0)
                    
                    NavigationLink(destination: {

                        //
                        PlannerView(color: Color(multicolored ? "\(appAccentColor)/2" : "\(appAccentColor)/\(appAccentColorIndex)"))
#if !os(macOS)
                            .navigationViewStyle(StackNavigationViewStyle())
                        #endif


                    }, label: {
                        Label("Planner", systemImage: "calendar.day.timeline.left")
                    })
                        .tag(1)
                        .swipeActions {
                            Button {
                                showEntryCreate.toggle()
                            } label: {
                            Image(systemName: "plus")
                            }
                            .tint(Color(multicolored ? "\(appAccentColor)/2" : "\(appAccentColor)/\(appAccentColorIndex)")   )

                        }

                    NavigationLink(destination: {
                            TaskView(color: Color(multicolored ? "\(appAccentColor)/3" : "\(appAccentColor)/\(appAccentColorIndex)"))
#if !os(macOS)
                            .navigationViewStyle(StackNavigationViewStyle())
                        #endif
                            .onAppear{
                                selectedTabIndex = 3
                            }

                        }, label: {
                            Label("Tasks", systemImage: "tray.full")
                        })

                        .tag(2)
                        .swipeActions {
                            Button {
                                showTaskCreate.toggle()
                            } label: {
                            Image(systemName: "plus")
                            }
                            .tint(Color(multicolored ? "\(appAccentColor)/3" : "\(appAccentColor)/\(appAccentColorIndex)")   )

                        }

                    if !kyoPlus_hasPlus{
//                        NavigationLink(destination: {
//                            KyoPlus(color: Color(multicolored ? "\(appAccentColor)/4" : "\(appAccentColor)/\(appAccentColorIndex)"))
//                                .onAppear{
//                                    selectedTabIndex = 4
//                                }
//                        }, label: {
//                            Label("Kyo+", systemImage: "sparkles")
//                        })
//                        .tag(2)
                        Button {
                                                kyoPlus_showPurchaseScreen.toggle()
                                            } label: {
                                                                            Label("Kyo+", systemImage: "sparkles")
                                            }
                    }
//                    NavigationLink(destination: {
//                            TaskView()
//                        }, label: {
//                            Label("Grades", systemImage: "a.book.closed")
//                        })
//                    .tag("View 4")
                    NavigationLink(destination: {
//                        WeekSlider(color: Color(multicolored ? "\(appAccentColor)/\(selectedTabIndex)" : "\(appAccentColor)/\(appAccentColorIndex)"))
                        ScheduleOverviewiPad(color: Color(multicolored ? "\(appAccentColor)/\(selectedTabIndex)" : "\(appAccentColor)/\(appAccentColorIndex)"))
                            .navigationDestination(for: GroupItem.self) { item in
                                                                                    item.destinationView
                                                                                }

//                        AutomaticWeeks(color: Color(multicolored ? "\(appAccentColor)/\(selectedTabIndex)" : "\(appAccentColor)/\(appAccentColorIndex)"), navType: .regular)
                        }, label: {
                            Label("Schedule & Rotation", systemImage: "rectangle.stack")
                        })
                        .tag(3)


                    ClassSection(showCreate: $showCreate, editClass: $editClass)

                   TeachersSidebarSection()

                    ClubsSidebarSection()

//                    NavigationLink(destination: {
//
//
//                            ClassesSettings(color: Color(multicolored ? "\(appAccentColor)/\(selectedTabIndex)" : "\(appAccentColor)/\(appAccentColorIndex)"))
//
//
//
//                        }, label: {
//                            Label(VariableDataNames().classesAndSplitsName(), systemImage: "doc.append")
//                        })
//                        .tag(4)



                    Section("More"){
                        NavigationLink(destination: {
                                             About(color: Color(multicolored ? "\(appAccentColor)/\(selectedTabIndex)" : "\(appAccentColor)/\(appAccentColorIndex)"), back: false)
                                             }, label: {
                                                 Label("About", systemImage: "info.circle")
                                             })
                                             .tag(5)

                     #if !os(macOS)

                                         Button {
                                             showSettings.toggle()
                                         } label: {
                                             Label("Settings", systemImage: "gearshape")
                                         }
                     #endif


                                         if kyoPlus_hasPlus{
                                             Button {
                                                                     Task {
                                                                         do {
                                                                             // FIX: The archive has no paid membership to manage; preserve the original action below.
                                                                             guard !KyoArchive.unlocksPlus else { return }
                                                                             try await Purchases.shared.showManageSubscriptions()
                                                                         } catch {
                                                                             print("Error showing manage subscriptions: \(error)")
                                                                             // Handle the error appropriately, possibly with an alert to the user.
                                                                         }
                                                                     }
                                                                 } label: {
                                                                     Label(KyoArchive.unlocksPlus ? "Kyo+ Included" : "Manage Membership", systemImage: "ticket")
                                                                 }
                                         }
                    }

                }

//          
                .navigationDestination(for: ClassEntity.self) { item in
                    ClassComposer(entity: item)
                                        }
                .listStyle(SidebarListStyle())
//                .navigationTitle("Kyo")

#if !os(macOS)
                    .navigationViewStyle(StackNavigationViewStyle())
                #endif
                .accentColor(Color(multicolored ? "\(appAccentColor)/\(1)" : "\(appAccentColor)/\(appAccentColorIndex)"))
                .frame(minWidth: 180)
#if !os(macOS)
                .fullScreenCover(isPresented: $showSettings, content: {
                    NavigationStack{
                        SettingsView(color: Color(multicolored ? "\(appAccentColor)/\(selectedTabIndex)" : "\(appAccentColor)/\(appAccentColorIndex)")){
                            Button(action: {

                                showSettings.toggle()
                            }, label: {
                                Text("Done")
                                    .scaledFrame(width: 60, height: 40, relativeTo: .body)
                            })
                            .buttonStyle(NavigationButton(color: .accentColor, scrolled: .constant(false)))
                        }
                    }
                })
                .toolbar(content: {
                    ToolbarItem(placement: .automatic, content: {
                        EditButton()
                    })
                })
                #endif
                .sheet(isPresented: $kyoPlus_showPurchaseScreen, content: {
                    NavigationStack{
                        KyoPlus()
                    }
                    .presentationCornerRadius(25)
                })


                .onChange(of: show) { change in
                    if change{
                        state = .automatic
                    }
                    else{
                        state = .detailOnly
                    }
                }

//                .onChange(of: selectedItem) { change in
//                    if change == 0{
//
//#if canImport(RiveRuntime)
//                        try? icon1.setInput("press", value: true)
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                            try? icon1.setInput("press", value: false)
//                        }
//                        #endif
//                    }
//                }
            } 

//        content: {
//                todayView(color: Color(multicolored ? "\(appAccentColor)/1" : "\(appAccentColor)/\(appAccentColorIndex)"))
//                    .environmentObject(columnVisibilitySettings)
//                    .onAppear{
//                        selectedTabIndex = 1
//                    }
//            } 

        detail: {
            NavigationStack{
                PlannerView(color: Color(multicolored ? "\(appAccentColor)/1" : "\(appAccentColor)/\(appAccentColorIndex)"))

#if !os(macOS)
                    .navigationViewStyle(StackNavigationViewStyle())
                #endif
            }


#if !os(macOS)
                .navigationViewStyle(StackNavigationViewStyle())
            #endif
            } .sheet(isPresented: $showCreate) {
                NavigationStack{
                    ClassComposer(color1:  Color(multicolored ? "\(appAccentColor)/1" : "\(appAccentColor)/\(appAccentColorIndex)"), color2: Color(multicolored ? "\(appAccentColor)/1" : "\(appAccentColor)/\(appAccentColorIndex)"))
                }.presentationCornerRadius(25)
            }
            .sheet(item: $editClass) { item in
                NavigationStack{
                    ClassComposer(entity: item)
                }.presentationCornerRadius(25)
            }
            .sheet(isPresented: $showEntryCreate) {
                NavigationStack{
                    TimeSlotWorkshop(color1: Color(multicolored ? "\(appAccentColor)/1" : "\(appAccentColor)/\(appAccentColorIndex)"), color2: Color(multicolored ? "\(appAccentColor)/1" : "\(appAccentColor)/\(appAccentColorIndex)"))
                }
            }
            .sheet(isPresented: $showTaskCreate) {
                NavigationStack{
                    TaskWorkshop(color: Color(multicolored ? "\(appAccentColor)/1" : "\(appAccentColor)/\(appAccentColorIndex)"))
                }
            }

        }
}


enum Tab: String, Codable, Hashable {
    case today
    case planner
    case tasks
    case settings
}
