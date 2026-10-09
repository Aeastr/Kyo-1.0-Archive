//
//  ScheduleOverview.swift
//  KyoNeo
//
//  Created by Aether on 26/12/2023.
//

import SwiftUI
import AmethystUI

struct ScheduleOverview: View {
    var color: Color

    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "number", ascending: true)],
                  predicate: NSPredicate(format: "singleDayWeek == nil OR singleDayWeek == %@", NSNumber(value: false))
    ) var weeks: FetchedResults<Week>

    @Environment(\.colorScheme) private var colorScheme


#if os(macOS)
    @AppStorage("Contrast") var contrast = false
    @AppStorage("tintPages") var tintPages = false

    @AppStorage("skipEmpty") var skipEmpty = true
    @AppStorage("skipPast") var skipPast = true

    @AppStorage("automaticWeek") var automaticWeek = true
    @AppStorage("askToSetUpAutoSwitch") var askToSetUpAutoSwitch : Bool = true

    @ObservedObject var weekWizard = WeekWizard(customMessage: "schedule overview")

    @AppStorage("debug") var debug: Bool = false
    @State private var show_WeekSlider: Bool = false
#endif
    @State var showMore: Bool = false
    var setupMode = false
    var body: some View {
#if !os(macOS)
            Group{
                GroupSection(label: "Schedule") {

                    if !setupMode{
                        SettingsGroup(color: ColorEngine().getXColor(1, colorScheme: colorScheme),
                                      [GroupItem(label: "Rotation", icon: "repeat", destinationView: AnyView(AutomaticWeeks(color: ColorEngine().getXColor(1, colorScheme: colorScheme)))),
                                       GroupItem(label: "Edit", icon: "calendar",  destinationView: AnyView(WeekSlider(color: ColorEngine().getXColor(1, colorScheme: colorScheme))))
                                      ]
                        )
                    }
                }



        #if !os(visionOS)
                if weeks.count > 5{
                    HStack{
                        Text("Weeks")
                            .sectionTitle()
                        Spacer()
                        Button {
                            withAnimation(.smooth){
                                showMore.toggle()
                            }
                        } label: {
                            Text(showMore ? "Show Less" : "Show More")
                                .framelessSectionTitle()
                                .foregroundStyle(color)
                        }
                        
                        
                    }
                }
            VStack{
                let weeksPrefixed = Array(weeks.prefix(showMore ? 99 : 5))
                ForEach(weeksPrefixed, id: \.self) { week in
                    if let daysArray = (Array(week.days ?? []) as? [Day])?.sorted(by: { $0.number < $1.number }) {
                        HStack{
                            ForEach(daysArray, id: \.self) { day in
                                VStack{
                                    Text(day.name ?? "-")
                                        .font(.caption)
                                        .frame(maxWidth: .infinity, alignment: .center)

                                    if let timeSlotsArrayCount = (Array(day.timeSlots ?? []) as? [TimeSlot])?.sorted(by: { $0.timestamp ?? Date() < $1.timestamp ?? Date() }).count {
                                        Text("\(timeSlotsArrayCount) \(daysArray.count > 5 ? "Ent" : "Entries")")
                                            .font(.caption2)
                                            .opacity(0.8)
                                            .minimumScaleFactor(0.5)
                                            .scaleEffect(0.9)
                                            .padding(.top, 1)
                                            .lineLimit(1)

                                    }

                                }
                            }
                        }
                        .transition(.blur.animation(.smooth))
                        if week != weeksPrefixed.last {
                            Divider()
                                .padding(.vertical, 8)
                        }
                    }
                }
            }
            .padding(10)
            .padding(.vertical, 6)
            .background {
                Color("NeoButton").opacity(0.6)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
            .regularOutline()
            #endif
        }
        .padding(.horizontal, 20)

#else
        NavigationStack{
            ScrollView{
            Group{
                Text("My Schedule")
                    .sectionTitle()

                VStack{
                    ForEach(weeks, id: \.self){  week in
                        if let daysArray = (Array(week.days ?? []) as? [Day])?.sorted(by: { $0.number < $1.number }) {
                            HStack{
                                ForEach(daysArray, id: \.self) { day in
                                    VStack{
                                        Text(day.name ?? "-")
                                            .font(.caption)
                                            .frame(maxWidth: .infinity, alignment: .center)

                                        if let timeSlotsArrayCount = (Array(day.timeSlots ?? []) as? [TimeSlot])?.sorted(by: { $0.timestamp ?? Date() < $1.timestamp ?? Date() }).count {
                                            Text("\(timeSlotsArrayCount) \(daysArray.count > 5 ? "Ent" : "Entries")")
                                                .font(.caption2)
                                                .opacity(0.8)
                                                .minimumScaleFactor(0.5)
                                                .scaleEffect(0.9)
                                                .padding(.top, 1)
                                                .lineLimit(1)

                                        }

                                    }
                                }
                            }
                            if week != weeks.last {
                                Divider()
                                    .padding(.vertical, 8)
                            }
                        }
                    }
                }
                .padding(10)
                .padding(.vertical, 6)
                .background {
                    Color("NeoButton").opacity(0.6)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
                .regularOutline()


                SettingsGroup(color: color,
                              [
                                //                               GroupItem(label: "Edit", icon: "calendar", action: {
                                //                                   show_WeekSlider.toggle()
                                //                               })
                                GroupItem(label: "Edit", icon: "calendar", destinationView: AnyView(WeekSlider(color: color)), useOldLink: true)

                              ]


                )
                .sheet(isPresented: $show_WeekSlider) {

                    WeekSlider(color: color)

                        .frame(minWidth: 600, minHeight: 800)
                        .presentationCornerRadius(25)

                }


            }

            .navigationTitle("Schedule & Rotation")
            .padding(.horizontal, 20)

            Group {
                Text("Automatic Rotation")
                    .sectionTitle()
                    .padding(.horizontal, 20)

                VStack{
                    Group{

                        Toggle(isOn: $skipEmpty) {
                            HStack{

                                Image(systemName: "calendar.badge.clock")
                                    .frame(width: 20, alignment: .center)
                                    .symbolRenderingMode(.hierarchical)
                                    .foregroundColor(color)

                                VStack(alignment: .leading, spacing: 3){
                                    Text("Skip Empty Days")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    Text("Skip past any days without entries ")
                                        .font(.caption).opacity(0.5)

                                        .padding(.trailing, 1)
                                }
                            }
                        }

                        .toggleStyle(.switch)

                        Divider()
                            .padding(.leading, 25)
                            .opacity(0.7)

                        Toggle(isOn: $skipPast) {
                            HStack{

                                Image(systemName: "arrowshape.zigzag.right")
                                    .frame(width: 20, alignment: .center)
                                    .symbolRenderingMode(.hierarchical)
                                    .foregroundColor(color)

                                VStack(alignment: .leading, spacing: 3){
                                    Text("Skip Completed Days")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    Text("Skip past days without any current or upcoming entries")
                                        .font(.caption).opacity(0.5)

                                        .padding(.trailing, 1)
                                }
                            }
                        }
                        .toggleStyle(.switch)
                    }
                    .padding(.horizontal, 2)
                    .padding(.vertical, 3)
                    .padding(.bottom, 1)
                }
                .neoSettingsCard()
                .padding(.horizontal, 20)

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
//                                weekWizard.totalWeeks = weeks.count
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

                Divider()
                    .padding(.vertical, 8)
                    .padding(.horizontal, 20)


                if let schedule_SelectedWeek = weekWizard.schedule_SelectedWeekNumber {
                    Group{
                        Text("It's week \(weekWizard.getCurrentWeek() ?? -1) now")
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
        }
        }
#endif
    }
}
#Preview {
    ScheduleOverview(color: Color.accentColor)
}

struct ScheduleOverviewiPad: View {
    var color: Color

    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "number", ascending: true)],
                  predicate: NSPredicate(format: "singleDayWeek == nil OR singleDayWeek == %@", NSNumber(value: false))
    ) var weeks: FetchedResults<Week>

    @Environment(\.colorScheme) private var colorScheme

    @State var scrolled: Bool = false
    @AppStorage("Contrast") var contrast = false
    @AppStorage("tintPages") var tintPages = false

    @AppStorage("skipEmpty") var skipEmpty = true
    @AppStorage("skipPast") var skipPast = true

    @AppStorage("automaticWeek") var automaticWeek = true
    @AppStorage("askToSetUpAutoSwitch") var askToSetUpAutoSwitch : Bool = true

    @ObservedObject var weekWizard = WeekWizard(customMessage: "schedule overview")

    @AppStorage("debug") var debug: Bool = false
    @State private var show_WeekSlider: Bool = false


    // FIX: These screens use local state, so enable Kyo+ here as well as in shared AppStorage.
    @State var kyoPlus_hasPlus: Bool = KyoArchive.unlocksPlus
    @State var kyoPlus_showPurchaseScreen: Bool = false
    var body: some View {
        NavigationStack{
            ScrollView{
                #if os(iOS)
                ScrollDetector(scrolled: $scrolled)
                #endif
            Group{
                Text("My Schedule")
                    .sectionTitle()

                VStack{
                    ForEach(weeks, id: \.self){  week in
                        if let daysArray = (Array(week.days ?? []) as? [Day])?.sorted(by: { $0.number < $1.number }) {
                            HStack{
                                ForEach(daysArray, id: \.self) { day in
                                    VStack{
                                        Text(day.name ?? "-")
                                            .font(.caption)
                                            .frame(maxWidth: .infinity, alignment: .center)

                                        if let timeSlotsArrayCount = (Array(day.timeSlots ?? []) as? [TimeSlot])?.sorted(by: { $0.timestamp ?? Date() < $1.timestamp ?? Date() }).count {
                                            Text("\(timeSlotsArrayCount) \(daysArray.count > 5 ? "Ent" : "Entries")")
                                                .font(.caption2)
                                                .opacity(0.8)
                                                .minimumScaleFactor(0.5)
                                                .scaleEffect(0.9)
                                                .padding(.top, 1)
                                                .lineLimit(1)

                                        }

                                    }
                                }
                            }
                            if week != weeks.last {
                                Divider()
                                    .padding(.vertical, 8)
                            }
                        }
                    }
                }
                .padding(10)
                .padding(.vertical, 6)
                .background {
                    Color("NeoButton").opacity(0.6)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
                .regularOutline()


                SettingsGroup(color: color,
                              [
                                //                               GroupItem(label: "Edit", icon: "calendar", action: {
                                //                                   show_WeekSlider.toggle()
                                //                               })
                                GroupItem(label: "Edit", icon: "calendar", destinationView: AnyView(WeekSlider(color: color)), useOldLink: true)

                              ]


                )
                .sheet(isPresented: $show_WeekSlider) {

                    WeekSlider(color: color)

                        .frame(minWidth: 600, minHeight: 800)
                        .presentationCornerRadius(25)

                }


            }
            .padding(.horizontal, 20)
            .frame(maxWidth: 700)
            Group {
                Text("Automatic Rotation")
                    .sectionTitle()
                    .padding(.horizontal, 20)

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
//                                weekWizard.totalWeeks = weeks.count
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

                Divider()
                    .padding(.vertical, 8)
                    .padding(.horizontal, 20)


                if let schedule_SelectedWeek = weekWizard.schedule_SelectedWeekNumber {
                    Group{
                        Text("It's week \(weekWizard.getCurrentWeek() ?? -1) now")
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
            .frame(maxWidth: 700)
        }
            .coordinateSpace(name: "scroll")
            #if os(iOS)
            .safeAreaInset(edge: .top, content: {
                Color.clear.frame(height: 50)
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
        .amethystNavigationBar(title: "Schedule and Rotation", tintColor: color, overrideType: .regular, scrolled: $scrolled) {

        } toolbar: {

        }

    }
}
