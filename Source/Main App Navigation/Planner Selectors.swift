// FIX: Use archive identifiers to keep this build and its data separate from the original app.
//
//  NavigationBar.swift
//  KyoNeo
//
//  Created by Aether on 20/11/2022.
//

import SwiftUI

struct weekDaySelector: View{
    var color: Color = .red
    @Environment(\.colorScheme) var colorScheme
    @Binding var scrolled: Bool
    @AppStorage("schedule_SelectedDayID") var schedule_SelectedDayID: String?
    @AppStorage("schedule_SelectedWeekID") var schedule_SelectedWeekID: String?
#if os(iOS)
    @AppStorage("planner_View") var planner_View: plannerViewMode = .pages
#else
    @AppStorage("planner_View") var planner_View: plannerViewMode = .week
#endif

    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "number", ascending: true)],
                  predicate: NSPredicate(format: "singleDayWeek == nil OR singleDayWeek == %@", NSNumber(value: false))
    ) var weeks: FetchedResults<Week>


    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "number", ascending: true),
                                    // Add more sort descriptors if needed
                                   ],
                  predicate: NSPredicate(format: "singleDayWeek == %@", NSNumber(value: true))
    ) var singleDayweeks: FetchedResults<Week>
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "number", ascending: true)]) var days: FetchedResults<Day>

    @AppStorage("askToSetUpAutoSwitch") var askToSetUpAutoSwitch : Bool = true


    @AppStorage("schedule_SingleDayMode", store: UserDefaults(suiteName: "group.com.example.kyoarchive")) var schedule_SingleDayMode: Bool = false
    @State var weekEdit = false
    @State var weeksEdit = false
    @State var weekEntity: Week?

    @ObservedObject var weekWizard = WeekWizard(customMessage: "from weekdaySelector")
    @AppStorage("skipEmpty") var skipEmpty = true
    @AppStorage("skipPast") var skipPast = true

    func getCurrentDayOfWeek() -> String {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE" // "EEEE" gives the full day name like "Monday"
            return formatter.string(from: Date())
        }
    
    var body: some View{

        HStack{
            if !schedule_SingleDayMode && weeks.count != 0 {
                if planner_View == .week{


                    Menu {


                        ForEach(weeks, id:\.self) { w in
                            Button(action: {
                                schedule_SelectedWeekID = w.id?.uuidString
                            }){
                                let localizedString = String(format: NSLocalizedString("week-number %lld", comment: ""), w.number)
                                if let name = w.name{
                                    Label("\(name) - \(localizedString)", systemImage: "calendar")
                                }
                                else{
                                    Label("\(localizedString)", systemImage: "calendar")
                                }
                                Text("^[\(w.days?.count ?? 7) Day](inflect: true)")

                            }
                        }

                        Divider()

                    } label: {

                        HStack{
                            Image(systemName: "calendar")

                            ZStack {
                                let day = days.first { day in
                                    day.id?.uuidString == schedule_SelectedDayID
                                }
                                let week = weeks.first { $0.id?.uuidString == schedule_SelectedWeekID }
                                let dayComponent = planner_View == .pages ? ", \(day?.name ?? "Untitled")" : ""
                                
                                if let weekName = week?.name {
                                    Text(weekName + dayComponent)
                                } else if let weekNumber = week?.number{
                                    Text(LocalizedStringKey("week-string")) + Text(" \(weekNumber)") + Text("\(dayComponent)")
                                }
                            }
                        }
                    }
                    .menuStyle(.button)
#if os(iOS)
                    .foregroundColor(color)
                    .brightness(scrolled ? colorScheme == .dark ? 1 : -1     : 0)
#endif

                }
                else if weeks.count > 1{
                    HStack{

                    Menu {


                        ForEach(weeks, id:\.self) { w in
                            Menu {

                                Text(weekEntity?.id?.uuidString ?? "empty")
                                    .hidden()
                                NavigationBarSelectorDays(filter: w.number)
                                Divider()



                                Button {
                                    weekWizard.schedule_SelectedWeekNumber = Int(w.number)
                                    let x = timeSlotChecks()
                                    let scheduleManager = ScheduleManager( debug: true, findOnlyNonEmptyDays: x.empty() ? false : skipEmpty,  findNextWithUpcomingCurrentSlots: x.empty() ? false :  skipPast, fromCode: "weekDaySelector")
                                    let currentDay = scheduleManager.getCurrentDay(Int(w.number))
                                    let newAnchorWeekDate = Date() // Replace with the desired anchor week date
                                    weekWizard.anchorWeekDate = newAnchorWeekDate
                                    askToSetUpAutoSwitch = false


                                    schedule_SelectedDayID = currentDay?.day.id?.uuidString
                                    schedule_SelectedWeekID = currentDay?.day.week?.id?.uuidString
                                } label: {
                                    let condition = weekWizard.getCurrentWeek() == Int(w.number)
                                    Label(condition ? "Current Week" : "Set as current week", systemImage: condition ? "star.fill" : "star")
                                }

                            } label: {
                                HStack {
                                    Image(systemName: "calendar")

                                    ZStack {

                                        if let name = w.name {
                                            let localizedString = String(format: NSLocalizedString("week-number %lld", comment: ""), w.number)

                                            Text(name + " - " + localizedString)
                                        }
                                        else{
                                            let localizedString = String(format: NSLocalizedString("week-number %lld", comment: ""), w.number)
                                            Text(localizedString)
                                        }


                                    }
                                    .font(.system(size: 16))


                                }
                            }

                        }

                        Divider()

                    } label: {

                        HStack{
                            Image(systemName: "calendar")

                            ZStack {
                                let day = days.first { day in
                                    day.id?.uuidString == schedule_SelectedDayID
                                }
                                let week = weeks.first { $0.id?.uuidString == schedule_SelectedWeekID }
                                let dayComponent = planner_View == .pages ? ", \(day?.name ?? "Untitled")" : ""
#if os(visionOS)
                                if let weekName = week?.name {
                                    Text(weekName)
                                } else if let weekNumber = week?.number{
                                    Text(LocalizedStringKey("week-string")) + Text(" \(weekNumber)")
                                }
                                #else
                                if let weekName = week?.name {
                                    Text(weekName + dayComponent)
                                } else if let weekNumber = week?.number{
                                    Text(LocalizedStringKey("week-string")) + Text(" \(weekNumber)") + Text("\(dayComponent)")
                                }
                                #endif
                            }

                        }
                    }
                    .menuStyle(.button)
                    .menuOrder(.fixed)
#if os(iOS)
                    .foregroundColor(color)
                    .brightness(scrolled ? colorScheme == .dark ? 1 : -1     : 0)
#endif

                }

#if os(visionOS)
                    Divider()

if let currentWeek = weeks.first { week in
    return week.id?.uuidString == schedule_SelectedWeekID
} {
    NavigationBarSelectorDays(filter: currentWeek.number)
}


#endif

                }
                else{
                    #if os(iOS)
                    Menu {

                        ForEach(weeks, id: \.self){ w in
                            Text(weekEntity?.id?.uuidString ?? "empty")
                                .hidden()
                            NavigationBarSelectorDays(filter: w.number)
                        }} label: {
                            if planner_View == .pages{
                                HStack {
                                    Image(systemName: "calendar")


                                .font(.system(size: 18))

                                    let dayName = days.first { day in
                                        return day.id?.uuidString == schedule_SelectedDayID
                                    }?.name
                                    Text((dayName ?? "Untitled") + " ")
                                        .font(.system(size: 16))
                                }

                            }
                            else{
                                HStack {
                                    Image(systemName: "calendar")

                                .font(.system(size: 18))

                                    Text("Days")
                                        .font(.system(size: 16))
                                }

                            }
                        }
#if os(iOS)
                        .foregroundColor(color)
                        .brightness(scrolled ? colorScheme == .dark ? 1 : -1 : 0)
#endif
                        .fixedSize(horizontal: true, vertical: false )
                        .frame(maxWidth: .infinity, alignment: .leading)

                    #else
                    ForEach(weeks, id: \.self){ w in
                        NavigationBarSelectorDays(filter: w.number)
                    }
                    #endif
                    }

                


                }
            else if schedule_SingleDayMode{
                Button {
                            // Action when the button is tapped
                        } label: {
                            Text(getCurrentDayOfWeek())
                        }

            }
            }



                .sheet(isPresented: $weeksEdit, onDismiss: {
                    weekEntity = nil
                }) {
                    WeekSlider(color: color)

                        .presentationCornerRadius(25)
                        .interactiveDismissDisabled()
                }

        }

    }
    struct WidthPreferenceKey: PreferenceKey {
        static var defaultValue: CGFloat = 0

        static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
            value = nextValue()
        }
    }


    /**
     Enum representing different types of navigation bars.
     - regular: A standard navigation bar.
     - today: A navigation bar with a 'Today' button.
     - hiddenButton: A navigation bar with a hidden button.
     - backButton: A navigation bar with a back button.
     - blank: A blank navigation bar.
     - hiddenSelector: A navigation bar with a hidden selector.
     */


    enum navigationFont: String, CaseIterable, Codable {
        case expanded = "Expanded"
            case condensed = "Condensed"
            case compressed = "Compressed"
        case regular = "Regular"
        case rounded = "Rounded"
        case serif = "Serif"
        case monospaced = "Monospace"
        case OpenDyslexic = "OpenDyslexic"
        //    case Dyslexie

        static var allCases: [navigationFont] {
            var cases: [navigationFont] = [
                .regular, .rounded, .serif, .monospaced, .OpenDyslexic
            ]

            if #available(iOS 16.0, *) {
                cases.insert(contentsOf: [
                    .expanded, .condensed, .compressed
                ], at: 0)
            }

            return cases
        }



        var design: Font.Design {
            switch self {
            case .regular :
                return Font.Design.default
            case .expanded:
                return Font.Design.default
                        case .compressed:
                return Font.Design.default
            case .rounded:
                return Font.Design.rounded
            case.serif:
                return Font.Design.serif
            case.monospaced:
                return Font.Design.monospaced
                        case.condensed:
                            return Font.Design.default
            case .OpenDyslexic:
                return Font.Design.default
            }
        }

#if !os(macOS)
        var systemDesign: UIFontDescriptor.SystemDesign{
            switch self {
                        case .regular :
                return UIFontDescriptor.SystemDesign.default
                        case .expanded:
                            return UIFontDescriptor.SystemDesign.default
                                    case .compressed:
                                        return UIFontDescriptor.SystemDesign.default
                        case .rounded:
                            return UIFontDescriptor.SystemDesign.rounded
                        case.serif:
                            return UIFontDescriptor.SystemDesign.serif
                        case.monospaced:
                            return UIFontDescriptor.SystemDesign.monospaced
                                    case.condensed:
                                        return UIFontDescriptor.SystemDesign.default
                        case .OpenDyslexic:
                            return UIFontDescriptor.SystemDesign.default
                        }
        }
        #else

        var systemDesign: NSFontDescriptor.SystemDesign{
            switch self {
                        case .regular :
                return NSFontDescriptor.SystemDesign.default
                        case .expanded:
                            return NSFontDescriptor.SystemDesign.default
                            //        case .compressed:
                            //            return Font.Design.default
                        case .rounded:
                            return NSFontDescriptor.SystemDesign.rounded
                        case.serif:
                            return NSFontDescriptor.SystemDesign.serif
                        case.monospaced:
                            return NSFontDescriptor.SystemDesign.monospaced
                            //        case.condensed:
                            //            return Font.Design.default
                        case .OpenDyslexic:
                            return NSFontDescriptor.SystemDesign.default
                        }
        }
        #endif


        @available(iOS 16.0, *)
        var wdith: Font.Width {
            switch self {
            case .regular :
                return Font.Width.standard
            case .expanded:
                return Font.Width.expanded
                        case .compressed:
                            return Font.Width.compressed
            case .rounded:
                return Font.Width.standard
            case.serif:
                return Font.Width.standard
            case.monospaced:
                return Font.Width.standard
                        case.condensed:
                            return Font.Width.condensed
            case .OpenDyslexic:
                return Font.Width.standard
            }
        }
    }

    struct NavigationBarSelectorDays: View {
        @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "number", ascending: true)]) var days: FetchedResults<Day>

        @AppStorage("schedule_SelectedDayID") var schedule_SelectedDayID: String?
        @AppStorage("schedule_SelectedWeekID") var schedule_SelectedWeekID: String?

        var selectedCombined: String {
            "\(schedule_SelectedDayID ?? "Mon")_\(schedule_SelectedWeekID ?? "")"
        }

        var body: some View {
            #if !os(visionOS)
            Picker(selection: Binding(get: { selectedCombined }, set: updateSelectedCombined), label: Text("Select a day")) {
                ForEach(days, id: \.self) { t in
                    Button {
                        updateSelectedCombined("\(t.id?.uuidString ?? "Mon")_\(t.week?.id?.uuidString ?? "")")
                        print("set")
                    } label: {
                        HStack {
                            if let name = t.name{
                                Text(getFullDayName(from: name) ?? name)
                            }
                        }
                    }
                    .tag("\(t.id?.uuidString ?? "Mon")_\(t.week?.id?.uuidString ?? "")")
                }
            }
            .pickerStyle(.inline)
            #else
            ForEach(days, id: \.self) { t in
                if "\(t.id?.uuidString ?? "Mon")_\(t.week?.id?.uuidString ?? "")" == selectedCombined{
                    Button {
                        withAnimation(.smooth){
                            updateSelectedCombined("\(t.id?.uuidString ?? "Mon")_\(t.week?.id?.uuidString ?? "")")
                        }
                    } label: {
                        HStack {
                            if let name = t.name{
                                Text(getFullDayName(from: name) ?? name)
                            }
                        }
                    }
                    .tag("\(t.id?.uuidString ?? "Mon")_\(t.week?.id?.uuidString ?? "")")
                    .buttonStyle(.bordered)
                    .transition(.blur.animation(.smooth))
                }
                else{
                    Button {
                        withAnimation(.smooth){
                            updateSelectedCombined("\(t.id?.uuidString ?? "Mon")_\(t.week?.id?.uuidString ?? "")")
                        }
                    } label: {
                        HStack {
                            if let name = t.name{
                                Text(getFullDayName(from: name) ?? name)
                            }
                        }
                    }
                    .tag("\(t.id?.uuidString ?? "Mon")_\(t.week?.id?.uuidString ?? "")")
                    .buttonStyle(.borderless)
                    .transition(.blur.animation(.smooth))
                }

            }
            .animation(.smooth, value: selectedCombined)
            #endif
        }

        private func updateSelectedCombined(_ combined: String) {
            let components = combined.split(separator: "_")
            if components.count == 2, let day = components.first, let week = components.last {
                if let foundDay = days.first(where: { $0.id?.uuidString == String(day) && $0.week?.id?.uuidString == String(week)}) {
                    self.schedule_SelectedDayID = foundDay.id?.uuidString
                    self.schedule_SelectedWeekID = foundDay.week?.id?.uuidString
                }
            }
        }

        init(filter: Int64) {
            _days = FetchRequest<Day>(sortDescriptors: [NSSortDescriptor(key: "number", ascending: true)], predicate: NSPredicate(format: "week.number == %i", filter))
        }

    }







