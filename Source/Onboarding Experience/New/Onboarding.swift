// FIX: Use archive identifiers to keep this build and its data separate from the original app.
//
//  Onboarding.swift
//  KyoNeo
//
//  Created by Aether on 04/04/2023.
//

import SwiftUI

struct neoOnboard: View{
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)]) var splitters: FetchedResults<SplitterEntity>
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "timestamp", ascending: true)]) var timeSlots: FetchedResults<TimeSlot>
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "number", ascending: true)],
                  predicate: NSPredicate(format: "singleDayWeek == nil OR singleDayWeek == %@", NSNumber(value: false))
    ) var weeks: FetchedResults<Week>


    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "number", ascending: true),
                                    // Add more sort descriptors if needed
                                   ],
                  predicate: NSPredicate(format: "singleDayWeek == %@", NSNumber(value: true))
    ) var singleDayweeks: FetchedResults<Week>
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "title", ascending: true)]) var taskTypes: FetchedResults<TaskTypeEntity>

    @ObservedObject var weekWizard = WeekWizard(customMessage: "from onBoarding")

    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    @State var index = 0

    @AppStorage("appAccentColor") var appAccentColor = "Default"
    @AppStorage("multicolored") var multicolored = true
    @AppStorage("appAccentColorIndex") var appAccentColorIndex = 1

    @AppStorage("selectedTabIndex") var selectedTabIndex: Int = 2 // Holds the currently selected tab

    @AppStorage("schedule_SingleDayMode", store: UserDefaults(suiteName: "group.com.example.kyoarchive")) var schedule_SingleDayMode: Bool = false

    var body: some View{
        GeometryReader{ geo in
            HStack(spacing: 0){
                NewWelcomeView(index: $index, color:  Color("\("Default")/\("2")"))
                UserSettings(index: $index, color:  Color("\("Default")/\("2")"))
                if !schedule_SingleDayMode{
                    WeeksOnboarding(color: Color("\("Default")/\("3")"), index: $index)
                }
                if weeks.count > 1 && !schedule_SingleDayMode{
                    NavigationStack{
                        SetupAutomaticWeeks(color: Color("\("Default")/\("3")"), navType: .back, index: $index)
                        #if !os(iOS)
                            .navigationTitle("Current Week")
                        #endif
                    }
                        .safeAreaInset(edge: .bottom) {
                            #if os(iOS)
                            VStack{
                                HStack{


                                    Button(action: {
                                        withAnimation(.smoothCard){
                                            index = index + 1
                                        }
                                    }, label: {
                                        Text("Next")
                                            .frame(maxWidth: .infinity, alignment: .center)
                                    })
                                    .padding()
                                    .buttonStyle(PolishedButton(color: Color("\("Default")/\("3")").opacity(weeks.count == 0 ? 0.2 : 1), background: true))
                                    .padding(.horizontal, 10)
                                    .disabled(weekWizard.schedule_SelectedWeekNumber == nil)
                                    .opacity(weekWizard.schedule_SelectedWeekNumber == nil ? 0.5 : 1)
                                }
                                
                                
                                Color.clear.frame(height: 20)
                            }
                            #else
                            HStack{
                                Button(action: {
                                    withAnimation(.smoothCard){
                                    index = index - 1 > -1 ? index - 1 : index
                                    }
                                }, label: {
                                    Text("Back")
                                        .font(.callout )
                                })
                                .buttonStyle(PolishedButton(color: Color("\("Default")/\("3")").opacity(weeks.count == 0 ? 0.2 : 1), background: false))
                                Spacer()
                                Button {
                                    withAnimation(.smoothCard){
                                        index = index + 1
                                    }
                                } label: {
                                    Text("Next")
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(PolishedButton(color: Color("\("Default")/\("3")").opacity(weeks.count == 0 ? 0.2 : 1), background: true))
                                .disabled(weekWizard.schedule_SelectedWeekNumber == nil)
                                .opacity(weekWizard.schedule_SelectedWeekNumber == nil ? 0.5 : 1)
                            }
                            .padding(.bottom, 17)
                            .padding(.horizontal, 20)
                            #endif
                        }
                        .ignoresSafeArea(edges: .bottom)
                    
                }
                ClassesOnboarding(index: $index, color: Color("\("Default")/\("4")"))
//                NotificationSettings(color: Color("\("Default")/\("5")"), onboardMode: true, index: $index)
//                    .safeAreaInset(edge: .bottom) {
//                        VStack{
//                            HStack{
//                              Button(action: {
//                                    withAnimation(.smoothCard){
//                                        index = index + 1
//                                    }
//                                }, label: {
//                                    Text("Next")
//                                        .frame(maxWidth: .infinity, alignment: .center)
//                                })
//                                .padding()
//                                .buttonStyle(PolishedButton(color: Color("\("Default")/\("5")").opacity(weeks.count == 0 ? 0.2 : 1), background: true))
//                                
//                                .padding(.horizontal, 10)
//                            }
//
//
//                            Color.clear.frame(height: 20)
//                        }
//                    }
//                    .ignoresSafeArea(edges: .bottom)
//                    .ignoresSafeArea(edges: horizontalSizeClass == .compact ? [] : .bottom)


//                WeeksClassesTut(index: $index)
//                EntriesTut(index: $index)
//                TaskTut(index: $index)
//                PlannerSetup(index: $index)
//                KyoPlus(color: Color("\("Default")/\("5")"), onbaord: true)
                welcomeScreen(index: $index, color:  Color("\("Default")/\("2")"))

            }
            .frame(width: geo.size.width * ((weeks.count > 1 ? 6 : 5) - (schedule_SingleDayMode ? weeks.count > 1 ? 2 : 1 : 0)))
            #if !os(visionOS)
            .background(Color("bw"))
            #endif
            .offset(x: -geo.size.width * CGFloat(index))
//            .toolbar(content: {
//
//                    ToolbarItem(placement: .cancellationAction, content: {
//                        Button(action: {
//                            withAnimation(.smoothCard){
//                                index = index - 1 > -1 ? index - 1 : 0
//                            }
//                        }, label: {
//                            Text("Back")
//                        })
//                        .buttonStyle(PolishedButton(color: Color("\("Default")/\(index + 2 != 6 ? index + 2 : 5)").opacity(weeks.count == 0 ? 0.2 : 1), background: false, compact: true))
//                        .padding(.vertical, -10)
//                    })
//
//
//
//                    ToolbarItem(placement: .automatic, content: {
//                        Button(action: {
//
//                        }, label: {
//                            Text("Import Data")
//                        })
//                        .buttonStyle(PolishedButton(color: Color("\("Default")/\(index + 2 != 6 ? index + 2 : 5)").opacity(weeks.count == 0 ? 0.2 : 1), background: false, compact: true))
//                        .padding(.vertical, -10)
//                        .opacity(index == 0 ? 1.0 : 0)
//                    })
//
//
//
//                ToolbarItem(placement: .confirmationAction, content: {
//                    Button(action: {
//                        withAnimation(.smoothCard){
//                            index = index + 1
//                        }
//                    }, label: {
//                        Text("Continue")
//                    })
//                    .buttonStyle(PolishedButton(color: Color("\("Default")/\(index + 2 != 6 ? index + 2 : 5)").opacity(weeks.count == 0 ? 0.2 : 1), background: true, compact: true))
//                    .padding(.vertical, -10)
//                    .frame(maxWidth: .infinity, alignment: .trailing)
//                })
//
//            })

        }
        .onDisappear(){

            if splitters.isEmpty{
                for splitter in defaultSplitters{
                    let newSplitter = SplitterEntity(context: viewContext)
                    newSplitter.id = UUID()
                    newSplitter.name = splitter.text
                    
                    newSplitter.color1 = Color.random().hexString
                    newSplitter.color2 = Color.random().hexString
                    newSplitter.number = Int64(index)
                    
                }

                do {
                    try viewContext.save()
                } catch {
                    let nsError = error as NSError
                    fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                }
            }
            
            
            if taskTypes.isEmpty{

                for type in defaultTaskTypes{
                let newType = TaskTypeEntity(context: viewContext)
                newType.id = UUID()
                newType.title = type.text
                newType.icon = type.icon
            }
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }


                }
        #if os(iOS)
//        .mask{RoundedRectangle(cornerRadius:  horizontalSizeClass == .compact ? 0 : 30, style: .continuous).ignoresSafeArea()}
//        .overlay{
//            if horizontalSizeClass != .compact{
//                Color.clear
//                    .regularOutline(cornerRadius: 30)
//            }
//        }
//        .padding(horizontalSizeClass == .compact ? 0 : 100)
//    
//        .frame(maxWidth: 700)
//        .clipShape(RoundedRectangle(cornerRadius: 25))
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
//
//                                   .background {
//                                       Image("bgPattern")
//                                           .resizable(resizingMode: .tile)
//                                           .frame(maxWidth: .infinity, maxHeight: .infinity)
//                                           .opacity(0.2)
//                                           .ignoresSafeArea()
//                                   }
//                                   .background {
//                                       Color("splitter")
//                                           .opacity(0.2)
//                                           .ignoresSafeArea()
//                                   }
        #endif
    }
}
