//
//  AutomaticWeeks.swift
//  KyoNeo
//
//  Created by Aether on 14/07/2023.
//

import SwiftUI
import AmethystUI



struct AutomaticWeeks: View {
    var color: Color
    var navType: AmethystUI.NavigationBarType = .back
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    @State var scrolled: Bool = false
    @AppStorage("Contrast") var contrast = false
    @AppStorage("tintPages") var tintPages = false

    @AppStorage("skipEmpty") var skipEmpty = true
    @AppStorage("skipPast") var skipPast = true

    @AppStorage("automaticWeek") var automaticWeek = true
    @AppStorage("askToSetUpAutoSwitch") var askToSetUpAutoSwitch : Bool = true

    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "number", ascending: true)],
                  predicate: NSPredicate(format: "singleDayWeek == nil OR singleDayWeek == %@", NSNumber(value: false))
    ) var weeks: FetchedResults<Week>


    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "number", ascending: true),
                                    // Add more sort descriptors if needed
                                   ],
                  predicate: NSPredicate(format: "singleDayWeek == %@", NSNumber(value: true))
    ) var singleDayweeks: FetchedResults<Week>

    @ObservedObject var weekWizard = WeekWizard()

    @State private var schedule_SelectedWeekIndex = 0

    @State private var currentWeek = 1

    @State var load = false

    @AppStorage("debug") var debug: Bool = false
    var tintBinding: Binding<Bool> {
            Binding(
                get: { contrast ? true : tintPages },
                set: { tintPages = $0 }
            )
        }

    var body: some View {
        ZStack {
            ScrollView {
                ScrollDetector(scrolled: $scrolled)
#if os(macOS)
                Text("Automatic Rotation")
                    .sectionTitle()
                    .padding(.horizontal, 20)
                #else

                #endif
                content
                    .frame(maxWidth: 700)
                #if os(iOS)
                    .navigationBarBackButtonHidden(true)
                #endif

            }
            .frame(maxWidth: .infinity, alignment: .leading)

            .coordinateSpace(name: "scroll")
#if os(iOS)
            .safeAreaInset(edge: .top, content: {
                Color.clear.frame(height: 75)
            })
            
            #endif
            .safeAreaInset(edge: .bottom, content: {

                KyoPlusButtonBinding(color: color, kyoPlus_hasPlus: $kyoPlus_hasPlus, kyoPlus_showPurchaseScreen: $kyoPlus_showPurchaseScreen, text: "Upgrade to Kyo+ for advanced rotation features", emoji: "📅", rotation: -10, position: CGPoint(x: -3 ,y: 8), actionIfNot: {
                    skipEmpty = false
                    skipPast = false
                })
                               .padding(.bottom, 10)
                       })

        }
        .tint(color)
        .amethystNavigationBar(title: "Auto Rotation", titleColor: .primary,   tintColor: color, compactMode: true, overrideType: navType, scrolled: $scrolled, content: {

                   }, toolbar: {

                   })
    }

    // FIX: These screens use local state, so enable Kyo+ here as well as in shared AppStorage.
    @State var kyoPlus_hasPlus: Bool = KyoArchive.unlocksPlus
    @State var kyoPlus_showPurchaseScreen: Bool = false

    var content: some View {

        Group {


            GroupSection {
                SettingsGroup(
                    [
                        GroupItem(label: "Skip Empty Days", description: "Skip past any days without entries ", icon: "calendar.badge.clock", color: color, linkedBoolBinding: { Binding<Bool>(get: { self.skipEmpty }, set: { self.skipEmpty = $0 }) }),
                        GroupItem(label: "Skip Completed Days", description: "Skip past days without any current or upcoming entries", icon: "arrowshape.zigzag.right", color: color, linkedBoolBinding: { Binding<Bool>(get: { self.skipPast }, set: { self.skipPast = $0 }) })
                    ], background: true, dividers: true)
            }
            .padding(.horizontal, 20)
            .disabled(!kyoPlus_hasPlus)
                        .opacity(!kyoPlus_hasPlus ? 0.5 : 1.0)
                        .onTapGesture {
                                    if !kyoPlus_hasPlus{
                                        kyoPlus_showPurchaseScreen.toggle()
                                        
                                    }
                                }


            Text("Auto rotation automatically selects the current week and day for you, you can set any week as the 'current week' and we'll take it from here - no further setup needed! When you add or remove weeks, we'll try to adjust this for you, but you may need to manually set this up again for it to be correct")
                .font(.caption)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 10)
                .padding(.horizontal, 20)

                VStack {
                    Menu {
                        Text("Select")
                        ForEach(weeks) { week in
                            Button(action: {
                                weekWizard.schedule_SelectedWeekNumber = Int(week.number)
                                
                                let newAnchorWeekDate = Date() // Replace with the desired anchor week date
                                weekWizard.anchorWeekDate = newAnchorWeekDate
                                askToSetUpAutoSwitch = false
                                automaticWeek = true
                            }) {
                                Text("Week \(week.number)")

                            }
                        }

                    } label: {
                        Group{
                            if let schedule_SelectedWeek = weekWizard.schedule_SelectedWeekNumber {
                                Text("Selected Week: \(schedule_SelectedWeek)")
                            }

                            else{
                                Text("Select Current Week")
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                    }

                    .neoSettingsCard()
                    .padding(.horizontal, 20)

                    
                }
                .padding(.bottom, 10)



            Divider()
                .padding(.vertical, 8)
                .padding(.horizontal, 20)
            
            if debug{
                Text("Warning: This may mess up your schedule, either select a new week after or restart Kyo to avoid issues")
                    .sectionTitle()
                    .opacity(0.6)
                    .italic()
                    .padding(.horizontal, 20)
                Button {
                    weekWizard.reset()
                } label: {
                    Text("kyo_debug_label_resetWeekSystem")
                }
            }


            if load{
                if let schedule_SelectedWeek = weekWizard.schedule_SelectedWeekNumber {
                    Group{
                        Text("It's week \(weekWizard.getCurrentWeek() ?? -1), for this week")
                            .font(.caption)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 1)
                            .padding(.horizontal, 20)
                        ForEach(0...weeks.count, id:\.self){ i in
                            let nextWeekDate = Calendar.current.date(byAdding: .weekOfYear, value: (i + 1) , to: Date())
                            Text("\(i > 0 ? "then the week after it's" : "then, next week it's") \(weekWizard.getCurrentWeek(nextWeekDate!) ?? -1)")
                                .font(.caption)
                                .frame(maxWidth: .infinity, alignment: .leading).padding(.vertical, 1)
                                .padding(.horizontal, 20)
                        }

                    }
                    .opacity(weeks.count < 2 ? 0.3 : 0.7)
                }
            }
            else{
                ProgressView().tint(color)
                    .onAppear{
                        // Generate a random delay between 0 and 7 seconds
                        let randomDelay: TimeInterval = Double.random(in: 1..<1.6654)

                        // Schedule the action to be performed after the random delay
                        DispatchQueue.main.asyncAfter(deadline: .now() + randomDelay) {
                            // Action to be executed after the random delay
                            withAnimation(.bouncy){
                                load = true
                            }
                        }
                    }
            }

        }

    }

}


struct SetupAutomaticWeeks: View {
    var color: Color
    var navType: AmethystUI.NavigationBarType = .back
    @Environment(\.colorScheme) private var colorScheme
    @State var scrolled: Bool = false
    @AppStorage("Contrast") var contrast = false
    @AppStorage("tintPages") var tintPages = false

    @AppStorage("automaticDay") var automaticDay = true
    @AppStorage("automaticWeek") var automaticWeek = true
    @AppStorage("askToSetUpAutoSwitch") var askToSetUpAutoSwitch : Bool = true

    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "number", ascending: true)],
                  predicate: NSPredicate(format: "singleDayWeek == nil OR singleDayWeek == %@", NSNumber(value: false))
    ) var weeks: FetchedResults<Week>


    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "number", ascending: true),
                                    // Add more sort descriptors if needed
                                   ],
                  predicate: NSPredicate(format: "singleDayWeek == %@", NSNumber(value: true))
    ) var singleDayweeks: FetchedResults<Week>

    @ObservedObject var weekWizard = WeekWizard()

    @State private var schedule_SelectedWeekIndex = 0

    @State private var currentWeek = 1

    @State var load = false

    @Environment(\.dismiss) var dismiss


    @AppStorage("skipEmpty") var skipEmpty = true
    @AppStorage("skipPast") var skipPast = true

    @Binding var index: Int

    var tintBinding: Binding<Bool> {
            Binding(
                get: { contrast ? true : tintPages },
                set: { tintPages = $0 }
            )
        }

    var body: some View {
        ZStack {
            pageTopHue(color: color)

            ScrollView {
                ScrollDetector(scrolled: $scrolled)
                content
             

            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            .coordinateSpace(name: "scroll")
            #if os(iOS) || os(visionOS)
            .safeAreaInset(edge: .top, content: {
                Color.clear.frame(height: 75)
            })
            .navigationTitle("")
            .navigationBarHidden(true)

            .overlay(alignment: .top) {
                FluidNavigationBar(title: "What week is it\ncurrently?", titleColor: .primary,   tintColor: color, compactMode: true, type: navType, scrolled: $scrolled, linelimit: 3, method: .custom, content: {

                }, toolbar: {
                    Text(" ")
                }, overrideBackAction: {
                    withAnimation(.smoothCard){
                                                index = index - 1
                                            }
                })

                //                Image(systemName: "paintpalette")
                //                    .foregroundStyle(color)
                //                    .padding(.trailing, 15)
                //                    .font(.headline)
            }
            #endif
        }
        .tint(color)
    }

    var content: some View {

        Group {
//            VStack{
//                Group{
//
//                    Toggle(isOn: $skipEmpty) {
//                        HStack{
//
//                                            Image(systemName: "calendar.badge.clock")
//                                                .frame(width: 20, alignment: .center)
//                                                .symbolRenderingMode(.hierarchical)
//                                                .foregroundColor(color)
//
//                                            VStack(alignment: .leading, spacing: 3){
//                                                Text("Skip Empty Days")
//                                                    .frame(maxWidth: .infinity, alignment: .leading)
//                                                Text("Skip past any days without entries ")
//                                                    .font(.caption).opacity(0.5)
//
//                                                .padding(.trailing, 1)
//                                            }
//                                        }
//                    }
//
//
//                    Divider()
//                        .padding(.leading, 25)
//                        .opacity(0.7)
//
//                    Toggle(isOn: $skipPast) {
//                        HStack{
//
//                                            Image(systemName: "arrowshape.zigzag.right")
//                                                .frame(width: 20, alignment: .center)
//                                                .symbolRenderingMode(.hierarchical)
//                                                .foregroundColor(color)
//
//                                            VStack(alignment: .leading, spacing: 3){
//                                                Text("Skip Completed Days")
//                                                    .frame(maxWidth: .infinity, alignment: .leading)
//                                                Text("Skip past days without any current or upcoming entries")
//                                                    .font(.caption).opacity(0.5)
//
//                                                .padding(.trailing, 1)
//                                            }
//                                        }
//                    }
//                }
//                .padding(.horizontal, 2)
//                .padding(.vertical, 3)
//                .padding(.bottom, 1)
//            }
//            .neoSettingsCard()
//            .padding(.horizontal, 20)
//
//            Divider()
//                .padding(.vertical, 8)
//                .padding(.horizontal, 20)

            Text("Auto rotation automatically selects the current week and day for you, you can set any week as the 'current week' and we'll take it from here - no further setup needed! When you add or remove weeks, we'll try to adjust this for you, but you may need to manually set this up again for it to be correct")
                            .font(.caption)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 20)

                            VStack {
                                Menu {
                                    Text("Select")
                                    ForEach(weeks) { week in
                                        Button(action: {
                                            weekWizard.schedule_SelectedWeekNumber = Int(week.number)

                                            let newAnchorWeekDate = Date() // Replace with the desired anchor week date
                                            weekWizard.anchorWeekDate = newAnchorWeekDate
                                            askToSetUpAutoSwitch = false
                                            automaticWeek = true
                                        }) {
                                            Text("Week \(week.number)")

                                        }
                                    }

                                } label: {
                                    Group{
                                        if let schedule_SelectedWeek = weekWizard.schedule_SelectedWeekNumber {
                                            Text("Selected Week: \(schedule_SelectedWeek)")
                                        }

                                        else{
                                            Text("Select Current Week")
                                        }
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                }

                                .neoSettingsCard()
                                .padding(.horizontal, 20)


                            }
                            .padding(.bottom, 10)


//            Text("When you add or remove weeks, we'll try to adjust this for you, but you may need to set this up again for it to be correct")
//                .font(.caption)
//                .frame(maxWidth: .infinity, alignment: .leading)
//                .padding(.vertical, 10)
//                .padding(.horizontal, 20)
            Divider()
                .padding(.vertical, 8)
                .padding(.horizontal, 20)

            if load{
                if let schedule_SelectedWeek = weekWizard.schedule_SelectedWeekNumber {
                    Group{
                        Text("It's week \(weekWizard.getCurrentWeek() ?? -1), for this week")
                            .font(.caption)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 1)
                            .padding(.horizontal, 20)
                        ForEach(0...weeks.count, id:\.self){ i in
                            let nextWeekDate = Calendar.current.date(byAdding: .weekOfYear, value: (i + 1) , to: Date())
                            Text("\(i > 0 ? "then the week after it's" : "then, next week it's") \(weekWizard.getCurrentWeek(nextWeekDate!) ?? -1)")
                                .font(.caption)
                                .frame(maxWidth: .infinity, alignment: .leading).padding(.vertical, 1)
                                .padding(.horizontal, 20)
                        }

                    }
                    .opacity(weeks.count < 2 ? 0.3 : 0.7)
                }
            }
            else{
                ProgressView().tint(color)
                    .onAppear{
                        // Generate a random delay between 0 and 7 seconds
                        let randomDelay: TimeInterval = Double.random(in: 1..<1.6654)

                        // Schedule the action to be performed after the random delay
                        DispatchQueue.main.asyncAfter(deadline: .now() + randomDelay) {
                            // Action to be executed after the random delay
                            withAnimation(.bouncy){
                                load = true
                            }
                        }
                    }
            }

        }

    }

}
