// FIX: Use archive identifiers to keep this build and its data separate from the original app.
//
//  EntriesIntro.swift
//  KyoNeo
//
//  Created by Aether on 04/04/2023.
//

import SwiftUI
import AVKit
#if canImport(RiveRuntime)
import RiveRuntime
#endif
import AmethystUI

#if canImport(RiveRuntime)
let anim = RiveViewModel(fileName: "onboardingexamples", stateMachineName: "press_plus_StateMachine", artboardName: "PressPlus")
#endif

struct EntriesTut: View {
    @Binding var index: Int

    init(index: Binding<Int>) {
        self._index = index


    }

    @State var addEntryShow = false
    @State var showReplay = false

    var body: some View {
        GeometryReader { geo in

            ScrollView{
                GeometryReader { vStackGeo in
                    VStack{
                        ZStack{
                            Spacer()
                        }

#if canImport(RiveRuntime)
                        anim.view()
                            .aspectRatio(contentMode: .fit)
                        #endif
                    }
                    .frame(height: geo.size.height / 2)
                    .background(Color("Default/2"))
                    .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                    .padding([.leading, .trailing, .bottom],25)
                    .padding([.top],5)
                    .rotation3DEffect(
                        Angle(degrees: Double(vStackGeo.frame(in: .global).minY / 59) - 1),
                        axis: (x: 1.0, y: 0.0, z: 0.0)
                    )
                }
                .frame(height: geo.size.height / 1.9)

                .shadow(color: Color("Default/2").opacity(0.3), radius: 10)

                .overlay(alignment: .bottomTrailing){
                    if showReplay{
                        Button {
                            playAnim()
                        } label: {

                            HStack{
                                Text(Image(systemName: "arrow.clockwise"))
                            }

                        }
                        .buttonStyle(PolishedButton(color: Color("Default/2")))
                        .shadow(color: Color("Default/2").opacity(0.3), radius: 10)
                        .offset(x: -15, y: -5)
                    }
                }
                .onChange(of: index) { newValue in
                    print(newValue)
                    if newValue == 6 {

                        playAnim()

                    }
                }
                if #available(iOS 16.0, *) {
                    Text("Adding entries to your planner")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        .font(.title3)
                        .fontWidth(.expanded)
                        .fontWeight(.semibold)

                }
                else{
                    Text("Adding entries to your planner")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        .font(.title3)
                }
                Text("Now that you've added some weeks, classes, and splits, you can create some entries in your planner. ")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 10)
                    .padding(.horizontal, 20)
                    .font(.body.weight(.regular))

                Button {
                    playAnim()
                } label: {
                    Text("Just tap the ")
                        .font(.body.weight(.semibold))
                    +
                    Text(Image(systemName: "plus"))
                        .font(.body.weight(.black))
                        .foregroundColor(Color("Default/2"))
                    +
                    Text(" in the upper right corner to get started.")
                        .font(.body.weight(.semibold))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 10)
                .padding(.horizontal, 20)
                .buttonStyle(bounceButton())




                Text("You can also hold on **+** to create a new class or week")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 10)
                    .padding(.horizontal, 20)
                    .font(.body.weight(.regular))
                Spacer()

            }
            .coordinateSpace(name: "scroll")
            .safeAreaInset(edge: .bottom) {
                VStack{

                    HStack{
                        Button(action: {

                            withAnimation(.smoothCard){
                                index = index - 1
                            }
                        }, label: {
                            Image(systemName: "arrow.left")
                        })
                        .padding([.vertical, .leading])
                        .buttonStyle(PolishedButton(color: Color("Default/2"), background: false))
                        .shadow(color: Color("Default/2").opacity(0.15), radius: 10, y: 5)
                        .padding(.leading, 10)
                        .padding(.trailing, 5)

                        Button(action: {

                            withAnimation(.smoothCard){
                                index = index + 1
                            }

                        }, label: {
                            Text("Next")
                                .frame(maxWidth: .infinity, alignment: .center)
                        })
                        .padding()
                        .buttonStyle(PolishedButton(color: Color("Default/2"), background: true))
                        .shadow(color: Color("Default/2").opacity(0.15), radius: 10, y: 5)
                        .padding(.horizontal, 10)
                    }
                    Color.clear.frame(height: 10)
                }
            }
            .background(Color("Background3"))
        }.ignoresSafeArea(edges: [.bottom, .leading, .trailing])
    }

    func playAnim(){

        withAnimation(.smoothCard){
            showReplay = false
        }

#if canImport(RiveRuntime)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5){
            anim.triggerInput("Trigger 1")
            withAnimation(.smoothCard){
                addEntryShow = true
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.5){
            withAnimation(.smoothCard){
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 5){
            withAnimation(.smoothCard){
                addEntryShow = false
                showReplay = true
            }
        }
        #endif
    }
}

struct WeeksOnboarding: View {
    var color: Color = Color.purple
    var totalCount = 8
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "number", ascending: true)],
                  predicate: NSPredicate(format: "singleDayWeek == nil OR singleDayWeek == %@", NSNumber(value: false))
    ) var weeks: FetchedResults<Week>


    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "number", ascending: true),
                                    // Add more sort descriptors if needed
                                   ],
                  predicate: NSPredicate(format: "singleDayWeek == %@", NSNumber(value: true))
    ) var singleDayweeks: FetchedResults<Week>
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "number", ascending: true)]) var days: FetchedResults<Day>
    @State var edit: Bool = false
    @State var addWeek: Bool = false
    @State var scrolled: Bool = false
    @Binding var index: Int
    @State var progress: Double = 0.0
    @State var angle: Double = 0.0
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("weekCreationIncludeWeekends") var weekCreationIncludeWeekends: Bool = false
    
    @AppStorage("schedule_SingleDayMode", store: UserDefaults(suiteName: "group.com.example.kyoarchive")) var schedule_SingleDayMode: Bool = false
    @State var alertUser: Bool = false
    @State var alertUserWeekend: Bool = false
    @State var showManageWeeks: Bool = false

    @ObservedObject var weekWizard = WeekWizard()

    @State var isProcessing = false

    var body: some View {
        NavigationStack{
            ScrollView{
                ScrollDetector(scrolled: $scrolled)

                                    if !schedule_SingleDayMode{



                donutSlider(totalCount: totalCount, color: color, bgColor: color.darken(by: 0.2).opacity(0.7) ,progress: $progress, angle: $angle, onDragEnd: {
                    withAnimation(.smoothCard){
                        createWeeks()
                    }
                })
                .transition(.blur.animation(.smooth))

                .coordinateSpace(name: "circularSlider")


                .padding(.vertical, 40)

                                            Spacer()

                                        VStack{

                                            Toggle(isOn: $weekCreationIncludeWeekends) {

                                                Text("Weekends")
                                            }
                                            .tint(color)
                                            .neoSettingsToggle()
                                        }

                                        .padding(.horizontal, 20)

                .onChange(of: weekCreationIncludeWeekends) { change in
                    if !change{
                        for week in weeks{
                            if let daysArray = (Array(week.days ?? []) as? [Day])?.sorted(by: { $0.number < $1.number }).filter({ day in
                                day.number == 5 || day.number == 6
                            }) {

                                for day in daysArray{

                                    if let timeSlotArray = (Array(day.timeSlots ?? []) as? [TimeSlot])?.sorted(by: { $0.timestamp ?? Date() < $1.timestamp ?? Date() }) {
                                        if timeSlotArray.count != 0 {

                                            alertUserWeekend = true

                                            withAnimation(.bouncy){
                                                angle = ((Double(weeks.count) / Double(totalCount)) * 360)
                                                progress = Double(weeks.count) / Double(totalCount)
                                            }
                                        }
                                    }
                                }

                                if !alertUserWeekend{
                                    createWeeks()
                                }
                            }
                        }
                    }
                    else{
                        createWeeks()
                    }

                }
                .onChange(of: progress) { newValue in

                    let count = (Int(Double(totalCount) * newValue) % 60)
                    // Define the boolean flag

                    if count != weeks.count && !( count > weeks.count){
                        if weeks.count != 0{
                            for week in weeks{
                                if let daysArray = (Array(week.days ?? []) as? [Day])?.sorted(by: { $0.number < $1.number }).filter({ day in
                                    day.week?.number ?? 0 == weeks.count
                                }) {

                                    for day in daysArray{

                                        if let timeSlotArray = (Array(day.timeSlots ?? []) as? [TimeSlot])?.sorted(by: { $0.timestamp ?? Date() < $1.timestamp ?? Date() }) {
                                            if timeSlotArray.count != 0 {

                                                alertUser = true

                                                withAnimation(.bouncy){
                                                    angle = ((Double(weeks.count) / Double(totalCount)) * 360)
                                                    progress = Double(weeks.count) / Double(totalCount)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            //                                    if !alertUser{
                            //                                        viewContext.delete(weeks[weeks.count - 1])
                            //                                    }
                        }
                    }
                }
                .onAppear{
                    angle = ((Double(weeks.count) / Double(totalCount)) * 360)
                    progress = Double(weeks.count) / Double(totalCount)

                }
                .onChange(of: weeks.count) { change in
                    withAnimation(.bouncy){
                        angle = ((Double(change) / Double(totalCount)) * 360)
                        progress = Double(change) / Double(totalCount)
                    }
                }
                .alert(isPresented: $alertUser) {
                    Alert(
                        title: Text("Warning"),
                        message: Text("You are about to delete a week that you've added entries to, and you'll lose this data."),
                        primaryButton: .destructive(Text("Ok")) {
                            //                                            viewContext.delete(weeks[weeks.count - 1])
                        },
                        secondaryButton: .cancel()
                    )
                }

                //                    if showAddMore{
                //                        Button {
                //
                //                        } label: {
                //                            Text("Need to add more?")
                //
                //                            .frame(maxWidth: .infinity)
                //                            .toggleStyle(.switch)
                //                            .neoSettingsToggle()
                //                            .padding(.horizontal, 20)
                //                            .tint(color)
                //                        }
                //                        .buttonStyle(bounceButton())
                //                        .padding(.bottom, 5)
                //
                //                    }
                //
                //
                //                    Toggle(isOn: $weekCreationIncludeWeekends) {
                //                        HStack{
                //                            Image(systemName: "plus.square.fill.on.square.fill")
                //                                .frame(width: 20, alignment: .center)
                //                                .symbolRenderingMode(.hierarchical)
                //                                .foregroundColor(color)
                //
                //                            VStack(alignment: .leading, spacing: 3){
                //                                Text("Include Weekends?")
                //                                    .frame(maxWidth: .infinity, alignment: .leading)
                //                                    .foregroundStyle(Color("splitter"))
                ////                                Text("Show the class icons in the planner")
                ////                                    .font(.caption2).opacity(0.5)
                //                            }
                //                        }
                //
                //                    }
                //                    .frame(maxWidth: .infinity)
                //                    .toggleStyle(.switch)
                //                    .neoSettingsToggle()
                //                    .padding(.horizontal, 20)
                //                    .tint(color)
                //
                //                        .padding(.bottom, 5)
                                        VStack(spacing: 0) {
                                            VStack(spacing: 0) {

                                                ForEach(weeks) { w in

                                                    let count = (Int(Double(totalCount) * progress) % 60)
                                                    if (w.number <= count){
                                                        NavigationLink {
                                                            WeekWorkship(entity: w, color: color)
#if !os(iOS)
                                                      .id(w.id)
                                                  #endif
                                                        } label: {
                                                            weekItem(entity: w, color: color,  edit: $edit)
                                                        }
                                                        .transition(.asymmetric(insertion: .identity, removal: .blur.animation(.smooth)))

                                                    }

                                                }


                                                let count = (Int(Double(totalCount) * progress) % 60)
                                                if weeks.count != count && count > weeks.count{
                                                    let placeHolderCount = count - weeks.count
                                                    ForEach(0...max(placeHolderCount - 1,0), id: \.self) { i in

                                                        HStack(alignment: .center, spacing: 0) {
                                                            if #available(iOS 16.0, *) {
                                                                Image(systemName: "calendar")

                                                                    .fontWeight(.bold)
                                                                    .foregroundColor(color)
                                                                    .padding(.leading, 13)
                                                                    .padding(.trailing, 6)
                                                            } else {

                                                                Image(systemName: "calendar")


                                                                    .foregroundColor(color)
                                                                    .padding(.leading, 13)
                                                                    .padding(.trailing, 6)
                                                            }
                                                            Text("Week \(i + weeks.count + 1)")
                                                                .foregroundColor(.primary)



                                                            Spacer()


                                                            Image(systemName: "chevron.forward")

                                                                .font(Font.body.bold())
                                                                .foregroundColor(color)
                                                                .padding(.leading, 6)
                                                                .padding(.trailing, 13)

                                                        }

                                                        .frame(minHeight:  50)

                                                        .background(Color("NeoButton"))

                                                        .transition(.asymmetric(insertion: .blur.animation(.smooth), removal: .identity))
                                                    }
                                                }
                                            }
                                            .frame(maxWidth: .infinity, alignment: .center)
                                            .background(Color("NeoButton"))
                                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                                            .regularOutline()

                                            .padding(.horizontal, 20)
                                            .safeAreaInset(edge: .bottom) {
                                                Color.clear.frame(height: 30)
                                            }
                                        }
                                        .transition(.blur.animation(.smooth))


                                            Spacer()
            }
                else{
                    VStack{

                        Text("Single Day Mode gives you just singular day for your entries, in case you always have the same schedule, you can switch back at any time, any of your weeks you made have been saved")
                            .font(.caption)
                            .foregroundStyle(Color.primary.opacity(0.6))

                            .lineLimit(nil)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)



                            .padding(.horizontal, 2)
                            .padding(13)
                            .background {
                                Color("NeoButton").opacity(0.6)
                                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                                    .regularOutline(cornerRadius: 18)

                            }
                    }
                    .padding(.horizontal, 30)
                    .transition(.blur.animation(.smooth))
                    .onAppear{
                        if singleDayweeks.contains(where: { week in
                            week.singleDayWeek
                        }){
                            print("already is setup")
                        }
                        else{
                            print("need to setup!")
                            let day = Day(context: viewContext)
                            day.id = UUID()
                            day.number = 0
                            day.name = "Single0"
                            let week = Week(context: viewContext)
                            week.id = UUID()
                            week.singleDayWeek = true
                            week.number = -1
                            week.addToDays(day)
                            day.week = week
                        }

                        do {

                                                                                          try viewContext.save()
                                                                                      } catch {
                                                                                          let nsError = error as NSError
                                                                                          fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                                                                                      }
                    }

                    Button {
                        withAnimation(.smooth){
                            schedule_SingleDayMode.toggle()
                        }
                    } label: {
                            Text("Use Weeks Instead")
                                .frame(maxWidth: .infinity)

                    }
                    .padding(.horizontal, 2)
                    .padding(13)
                    .background {
                        Color("NeoButton").opacity(0.6)
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                            .regularOutline(cornerRadius: 18)

                    }
                    .padding(.horizontal, 30)
                    .transition(.blur.animation(.smooth))


//
//                        Button {
//                            withAnimation(.smooth){
//                                schedule_SingleDayMode.toggle()
//                            }
//                        } label: {
//                                Text("Move Data to Weeks")
//                                    .frame(maxWidth: .infinity)
//
//                        }
//                        .padding(.horizontal, 2)
//                        .padding(13)
//                        .background {
//                            Color("NeoButton").opacity(0.6)
//                                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
//                                .regularOutline(cornerRadius: 18)
//
//                        }
//                        .padding(.horizontal, 30)
//                        .transition(.blur.animation(.smooth))

                }
                Spacer()
            }

            #if os(iOS) || os(visionOS)
            .coordinateSpace(name: "scroll")
            .safeAreaInset(edge: .top, content: {
                Color.clear.frame(height: 75)
            })
            .overlay(alignment: .top) {
                FluidNavigationBar(title: "How many weeks are in your schedule?", titleColor: .primary,   tintColor: .purple,type: .back, scrolled: $scrolled, linelimit: 2, method: .custom, content: {

                }, toolbar: {
                    Text(" ")
                }, overrideBackAction: {
                    withAnimation(.smoothCard){
                        index = index - 1
                    }
                })

            }
            #else
            .navigationTitle("Weeks")
            #endif
            .safeAreaInset(edge: .bottom) {
                #if os(iOS)
                VStack{
                    HStack(spacing: 5){
                        Button(action: {
                            if !isProcessing{
                                if weeks.count == 1{
                                    weekWizard.anchorWeekDate = Date()
//                                    weekWizard.totalWeeks = 1
                                    weekWizard.schedule_SelectedWeekNumber = 1
                                }
                                withAnimation(.smoothCard){
                                    index = index + 1
                                }
                            }
                        }, label: {
                            HStack(spacing: 10){
                                if isProcessing{
                                    ProgressView()
                                        .tint(Color.white)
                                        .transition(.blur.animation(.smooth))
                                }
                                else{
                                    Text(weeks.isEmpty ? "Skip Planner Setup" : "Next")
                                        .transition(.blur.animation(.smooth))
                                }

                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                        })
                        .padding()
                        .buttonStyle(PolishedButton(color: color, background: true))
                        .shadow(color: color    .opacity(0.15), radius: 10, y: 5)
                        .padding(.horizontal, 10)
                        .disabled(isProcessing)
                        .opacity(isProcessing ? 0.7 : 1)
                    }


                    Color.clear.frame(height: 20)
                }.background(LinearGradient(gradient: Gradient(colors: [Color.clear, Color("bw").opacity(0.5)]), startPoint: .top, endPoint: .bottom))
                    .background(VariableBlurView().rotationEffect(Angle(degrees: 180)).ignoresSafeArea())
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
    .buttonStyle(PolishedButton(color: color, background: false))
    Spacer()
    Button {
        withAnimation(.smoothCard){
            index = index + 1
        }
    } label: {
        Text("Next")
            .frame(maxWidth: .infinity)
    }
    .buttonStyle(PolishedButton(color: color, background: true))
    .disabled(isProcessing)
    .opacity(isProcessing ? 0.7 : 1)
}
.padding(.bottom, 17)
.padding(.horizontal, 20)

                #endif
            }
            .ignoresSafeArea(edges: .bottom)
            #if os(iOS) || os(visionOS)
            .navigationTitle("")
            .navigationBarHidden(true)
            #endif
        }
        .animation(.smooth, value: schedule_SingleDayMode)
        .alert(isPresented: $alertUser) {
            Alert(
                title: Text("Warning"),
                message: Text("You are about to delete a week that you've added entries to, and you'll lose this data."),
                primaryButton: .destructive(Text("Delete")) {
                    viewContext.delete(weeks[weeks.count - 1])
                },
                secondaryButton: .cancel()
            )
        }
        .tint(.purple)
        .ignoresSafeArea()
//        .modify{
//            if #available(iOS 17.0, *) {
//                $0.sensoryFeedback(.increase, trigger: progress)
//            } else {
//                $0
//            }
//        }





    }

    func createWeeks() {
        var weekWizard = WeekWizard(customMessage: "from create weeks function")

        isProcessing = true

        DispatchQueue.global().async {
            do {

                let count = (Int(Double(totalCount) * progress) % 60)
                print("count is \(count)")

                viewContext.performAndWait {
                    let weeksToDelete = weeks.filter { $0.number > count }
                    for week in weeksToDelete {
                        if let days = week.days?.allObjects as? [Day] {
                            for day in days {
                                if let timeSlots = day.timeSlots?.allObjects as? [TimeSlot] {
                                    for timeSlot in timeSlots {
                                        viewContext.delete(timeSlot)
                                    }
                                }
                                viewContext.delete(day)
                            }
                        }
                        viewContext.delete(week)
                    }

                    for i in 0...max(0,count - 1) {
                        if !(weeks.contains { $0.number == (i + 1) }) {


                            let isMondayFirstDay = true
                            let newWeek = Week(context: viewContext)
                            print("weekcount \(weeks.count)")
                            newWeek.id = UUID()
                            newWeek.number = Int64(i + 1)

                            let dateFormatter = DateFormatter()
                            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                            if let daySymbols = dateFormatter.shortWeekdaySymbols {
                                var selectedDays: [dayItemModel] = []
                                var indexNumber = 0

                                if isMondayFirstDay {
                                    let weekdays = Array(daySymbols[1...5])
                                    for (index, daySymbol) in weekdays.enumerated() {
                                        let day = dayItemModel(name: daySymbol, number: index)
                                        selectedDays.append(day)
                                    }
                                    // Add Sunday as the last day if required
                                    if weekCreationIncludeWeekends {
                                        if let saturday = daySymbols.last {
                                            let day = dayItemModel(name: saturday, number: 5)
                                            selectedDays.append(day)
                                        }
                                        if let sunday = daySymbols.first {
                                            let day = dayItemModel(name: sunday, number: 6)
                                            selectedDays.append(day)
                                        }
                                    }

                                } else {
                                    if weekCreationIncludeWeekends {
                                        let daySymbolsArray = Array(daySymbols)
                                        for (index, daySymbol) in daySymbolsArray.enumerated() {
                                            let day = dayItemModel(name: daySymbol, number: index)
                                            selectedDays.append(day)
                                        }
                                    } else {
                                        let weekdays = Array(daySymbols[0..<6])
                                        for (index, daySymbol) in weekdays.enumerated() {
                                            let day = dayItemModel(name: daySymbol, number: index)
                                            selectedDays.append(day)
                                        }
                                    }
                                }

                                for day in selectedDays {
                                    let newDay = Day(context: viewContext)
                                    newDay.id = UUID()
                                    newDay.name = day.name
                                    newDay.number = Int16(indexNumber)
                                    newDay.week = newWeek
                                    print("Create Week: Added Day, name: \(day.name)")
                                    newWeek.addToDays(newDay)
                                    indexNumber += 1
                                }

                            }

                        } else {
                            print("did not create as it aleady exists! \(i + 1)")
                            print("check weekends")
                            if weekCreationIncludeWeekends{
                                if let week = weeks.first(where: { week in
                                    week.number == (i + 1)
                                }) {
                                    if let dayArray = (Array(week.days ?? []) as? [Day])?.sorted(by: { $0.number < $1.number}) {
                                        if dayArray.contains(where: { Day in
                                            Day.number == 5
                                        }){
                                            print("already contains saturday")
                                        }
                                        else{
                                            print("does not contain saturday! add!")
                                            let newDay = Day(context: viewContext)
                                            newDay.id = UUID()
                                            newDay.name = "Sat"
                                            newDay.number = 5
                                            newDay.week = week
                                            print("Create Week: Added Day, name: \(newDay.name)")
                                            week.addToDays(newDay)

                                            do {
                                                try viewContext.save()  // Save the changes made to the managed object context
                                                // go here
                                            } catch {
                                                /**
                                                 * If an error occurs while saving the changes to the managed object context,
                                                 * handle the error by printing an error message with the relevant information.
                                                 */
                                                let nsError = error as NSError
                                                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                                            }
                                        }

                                        if dayArray.contains(where: { Day in
                                            Day.number == 6
                                        }){
                                            print("already contains sunday")
                                        }
                                        else{
                                            print("does not contain sunday! add!")
                                            let newDay = Day(context: viewContext)
                                            newDay.id = UUID()
                                            newDay.name = "Sun"
                                            newDay.number = 6
                                            newDay.week = week
                                            print("Create Week: Added Day, name: \(newDay.name)")
                                            week.addToDays(newDay)

                                            do {
                                                try viewContext.save()  // Save the changes made to the managed object context
                                                // go here
                                            } catch {
                                                /**
                                                 * If an error occurs while saving the changes to the managed object context,
                                                 * handle the error by printing an error message with the relevant information.
                                                 */
                                                let nsError = error as NSError
                                                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                                            }
                                        }
                                    }


                                }
                            }
                            else{
                                if let week = weeks.first(where: { week in
                                    week.number == (i + 1)
                                }) {
                                    if let dayArray = (Array(week.days ?? []) as? [Day])?.sorted(by: { $0.number < $1.number}) {
                                        if dayArray.contains(where: { Day in
                                            Day.number == 5
                                        }){
                                            if let dayToRemove = dayArray.first { Day in
                                                Day.number == 5
                                            }{
                                                print("already contains saturday, remove!")
                                                week.removeFromDays(dayToRemove)
                                            }
                                            do {
                                                try viewContext.save()  // Save the changes made to the managed object context
                                                // go here
                                            } catch {
                                                /**
                                                 * If an error occurs while saving the changes to the managed object context,
                                                 * handle the error by printing an error message with the relevant information.
                                                 */
                                                let nsError = error as NSError
                                                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                                            }
                                        }
                                        else{
                                            print("does not contain saturday")

                                        }

                                        if dayArray.contains(where: { Day in
                                            Day.number == 6
                                        }){
                                            if let dayToRemove = dayArray.first { Day in
                                                Day.number == 6
                                            }{
                                                print("already contains saturday, remove!")
                                                week.removeFromDays(dayToRemove)
                                            }
                                            do {
                                                try viewContext.save()  // Save the changes made to the managed object context
                                                // go here
                                            } catch {
                                                /**
                                                 * If an error occurs while saving the changes to the managed object context,
                                                 * handle the error by printing an error message with the relevant information.
                                                 */
                                                let nsError = error as NSError
                                                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                                            }
                                        }
                                        else{
                                            print("does not contain saturday")

                                        }
                                    }


                                }
                            }
                        }
                    }

                    do {
                        try viewContext.save()
                    } catch {
                        let nsError = error as NSError
                        print("Unresolved error \(nsError), \(nsError.userInfo)")
                    }
                }

                let randomDelay = Double.random(in: 0.2899942...1.23423)
                DispatchQueue.main.asyncAfter(deadline: .now() + randomDelay) {
                    withAnimation(.smoothCard) {
                        isProcessing = false
                    }
                }
            } catch {
                let nsError = error as NSError
                print("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }

        if weeks.count == 1 {
            var weekWiz = WeekWizard(customMessage: "create weeks function pt2")
            weekWiz.reset()
            weekWiz.schedule_SelectedWeekNumber = 1
            weekWiz.anchorWeekDate = Date()
//            weekWiz.totalWeeks = 1
            print("set wizard stuff")
        }

        // Handle weekWizard related code...


        let count = (Int(Double(totalCount) * progress) % 60)

        if let tW = weekWizard.schedule_SelectedWeekNumber {
            if count > tW {
//                weekWizard.totalWeeks = count
            } else if count < tW {
                weekWizard.reset()
            }
        }
    }



}



struct WeeksClassesTut: View {
    @Binding var index: Int
    var body: some View {
        GeometryReader { geo in

            VStack(spacing: 0){
                ZStack{
                    Text("Images haven't been added yet").opacity(0.2)
                }
                .frame(width: geo.size.width, height: geo.size.height / 2)
                .background(Color("Default/2"))

                .mask{
                    Rectangle().frame(height: geo.size.height / 2)
                }
                .shadow(color: Color("Default/2").opacity(0.6), radius: 10)

                ScrollView{

                    if #available(iOS 16.0, *) {
                        Text("Weeks, \(VariableDataNames().classesName()), & Splits")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 20)
                            .font(.title3)
                            .fontWidth(.expanded)
                            .fontWeight(.semibold)
                            .padding(.top, 25)
                    }
                    else{
                        Text("Weeks, \(VariableDataNames().classesName()), & Splits")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 20)
                            .font(.title3)
                            .padding(.top, 25)
                    }
                    HStack{
                        Text("You can add weeks and (VariableDataNames().classesName()) by tapping and holding ")
                            .font(.body.weight(.regular))
                        +
                        Text(Image(systemName: "plus"))
                            .font(.body.weight(.black))
                            .foregroundColor(Color("Default/2"))
                        //   .baselineOffset(3.0)
                        +
                        Text("  in the upper-right corner")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 10)
                    .padding(.horizontal, 20)
                    HStack{
                        Text("You can also edit, delete (and add) weeks, classes, ***and splits*** in the manage menu under the  ")
                            .font(.body.weight(.regular))
                        +
                        Text(Image(systemName: "ellipsis"))
                            .font(.body.weight(.black))
                            .foregroundColor(Color("Default/2"))

                        +
                        Text("  menu")

                    }

                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 10)
                    .padding(.horizontal, 20)


                    Spacer()
                }
            }
            .safeAreaInset(edge: .bottom) {
                VStack{

                    HStack{
                        Button(action: {

                            withAnimation(.smoothCard){
                                index = index - 1
                            }
                        }, label: {
                            Image(systemName: "arrow.left")
                        })
                        .padding([.vertical, .leading])
                        .buttonStyle(PolishedButton(color: Color("Default/2"), background: false))
                        .shadow(color: Color("Default/2").opacity(0.15), radius: 10, y: 5)
                        .padding(.leading, 10)
                        .padding(.trailing, 5)
                        Button(action: {
                            withAnimation(.smoothCard){
                                index = index + 1
                            }
                        }, label: {
                            Text("Next")
                                .frame(maxWidth: .infinity, alignment: .center)
                        })
                        .padding()
                        .buttonStyle(PolishedButton(color: Color("Default/2"), background: true))
                        .shadow(color: Color("Default/2").opacity(0.15), radius: 10, y: 5)
                        .padding(.horizontal, 10)
                    }
                    Color.clear.frame(height: 20)
                }
            }
            .background(Color("Background3"))
        }.ignoresSafeArea()
    }
}

struct TaskTut: View {
    @Binding var index: Int
    var body: some View {
        GeometryReader { geo in

            VStack(spacing: 0){
                ZStack{
                    Text("Images haven't been added yet").opacity(0.2)
                }
                .frame(width: geo.size.width, height: geo.size.height / 2)
                //    .background(Color("Default/3"))

                .mask{
                    Rectangle().frame(height: geo.size.height / 2)
                }
                .shadow(color: Color("Default/3").opacity(0.6), radius: 10)

                ScrollView{

                    if #available(iOS 16.0, *) {
                        Text("Tasks & Categories")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 20)
                            .font(.title3)
                            .fontWidth(.expanded)
                            .fontWeight(.semibold)
                            .padding(.top, 25)
                    }
                    else{
                        Text("Weeks, Classes, & Splits")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 20)
                            .font(.title3)
                            .padding(.top, 25)
                    }
                    HStack{
                        Text("You can add tasks by tapping  ")
                            .font(.body.weight(.regular))
                        +
                        Text(Image(systemName: "plus"))
                            .font(.body.weight(.black))
                            .foregroundColor(Color("Default/3"))
                        //   .baselineOffset(3.0)
                        +
                        Text("  in the upper-right corner")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 10)
                    .padding(.horizontal, 20)
                    HStack{
                        Text("You can also add task categories by tapping and holding on  ")
                            .font(.body.weight(.regular))
                        +
                        Text(Image(systemName: "plus"))
                            .font(.body.weight(.black))
                            .foregroundColor(Color("Default/3"))


                    }

                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 10)
                    .padding(.horizontal, 20)
                    HStack{
                        Text("Finally you can edit tasks and manage categories by tapping  ")
                            .font(.body.weight(.regular))
                        +
                        Text(Image(systemName: "ellipsis"))
                            .font(.body.weight(.black))
                            .foregroundColor(Color("Default/3"))


                    }

                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 10)
                    .padding(.horizontal, 20)


                    Spacer()
                }
            }
            .safeAreaInset(edge: .bottom) {
                VStack{
                    HStack{
                        Button(action: {

                            withAnimation(.smoothCard){
                                index = index - 1
                            }
                        }, label: {
                            Image(systemName: "arrow.left")
                        })
                        .padding([.vertical, .leading])
                        .buttonStyle(PolishedButton(color: Color("Default/2"), background: false))
                        .shadow(color: Color("Default/2").opacity(0.15), radius: 10, y: 5)
                        .padding(.leading, 10)
                        .padding(.trailing, 5)

                        Button(action: {

                            withAnimation(.smoothCard){
                                index = index + 1
                            }
                        }, label: {
                            Text("Next")
                                .frame(maxWidth: .infinity, alignment: .center)
                        })
                        .padding()
                        .buttonStyle(PolishedButton(color: Color("Default/3"), background: true))
                        .shadow(color: Color("Default/3").opacity(0.15), radius: 10, y: 5)
                        .padding(.horizontal, 10)
                    }
                    Color.clear.frame(height: 20)
                }
            }
            .background(Color("Background3"))
        }.ignoresSafeArea()
    }
}

struct ClassesOnboarding: View {
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)]) var classEntities: FetchedResults<ClassEntity>
    @State var edit: Bool = false
    @State var addClass: Bool = false
    @State var scrolled: Bool = false
    @Binding var index: Int
    @Environment(\.colorScheme) var colorScheme
    var color: Color
    var body: some View {
        NavigationStack{
            ScrollView{
                ScrollDetector(scrolled: $scrolled)

                VStack{

                    VStack(spacing: 10) {
                        ForEach(classEntities) { entity in
                            NavigationLink {
                                ClassComposer(entity: entity)
                            } label: {
                                ClassPeelItem(entity: entity, progressOffset: edit ? 0.2 : 0, edit: $edit)

                            }

                            .buttonStyle(BouncyButton())


                        }

                        if classEntities.isEmpty{
                            Text("Add some classes, you'll need them for you planner and tasks")
                                .font(.caption)
                                .foregroundStyle(Color.primary.opacity(0.6))

                                .lineLimit(nil)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)



                                .padding(.horizontal, 2)
                                .padding(13)
                                .background {
                                    Color("NeoButton").opacity(0.6)
                                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                                        .regularOutline(cornerRadius: 18)

                                }
                        }
                    }.ignoresSafeArea()
                    Spacer()
                }

                .padding(.horizontal, 20)
            }
            .coordinateSpace(name: "scroll")
#if os(iOS)
            .safeAreaInset(edge: .top, content: {
                Color.clear.frame(height: 95)
            })

            .overlay(alignment: .top) {
                FluidNavigationBar(title: VariableDataNames().classesName(), titleColor: .primary,   tintColor: color, compactMode: true, type: .back, scrolled: $scrolled, linelimit: 1, method: .custom, content: {
                    HStack(spacing: 15){
                        Button {
                            withAnimation(.smoothCard){
                                edit.toggle()
                            }
                        } label: {
                            Text(edit ? "Done" : "Edit")
                                .padding(.horizontal)
                                .padding(.vertical, 10)
                        }
#if os(iOS) || os(visionOS)
                        .fullScreenCover(isPresented: $addClass) {
                            NavigationStack{
                                ClassComposer()
//                                                               .interactiveDismissDisabled()
                            }
                        }
                        #else
                        .sheet(isPresented: $addClass) {
                            ClassComposer()
                                .interactiveDismissDisabled()

                                .presentationCornerRadius(25)
                        }
                        #endif
                        if !edit{
                            Button {
                                addClass.toggle()
                            } label: {
                                Text("Add")
                                    .padding(.horizontal)
                                    .padding(.vertical, 10)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.top, 10)
                    .buttonStyle(NavigationButton(color: color , scrolled: $scrolled))
                }, toolbar: {
                    Text(" ")
                }, overrideBackAction: {
                    withAnimation(.smoothCard){
                        index = index - 1
                    }
                })
                }
            #else
            .navigationTitle(VariableDataNames().classesName())
            
            #endif
            //                .safeAreaInset(edge: .top) {
            //                    VStack{
            //                        Color.clear.frame(height: 10)
            //                        if #available(iOS 16.0, *) {
            //                            Text("Add your classes")
            //                                .frame(maxWidth: .infinity, alignment: .leading)
            //                                .font(.title3)
            //                                .fontWidth(.expanded)
            //                                .fontWeight(.semibold)
            //                        }
            //                        else{
            //                            Text("Add your classes")
            //                                .frame(maxWidth: .infinity, alignment: .leading)
            //                                .font(.title3)
            //                        }
            //                        Text("You'll need to add classes to get started too")
            //                            .frame(maxWidth: .infinity, alignment: .leading)
            //                            .padding(.top, 10)
            //                            .font(.body.weight(.regular))
            //
            //                        HStack(spacing: 15){
            //
            //                        }
            //                        .frame(maxWidth: .infinity, alignment: .trailing)
            //                        .padding(.top, 10)
            //                        .buttonStyle(NavigationButton(color: Color("Default/2"), scrolled: $scrolled))
            //                    }.padding(.horizontal, 20)
            //
            //                        .background(
            //                            Color.clear
            //                                .frame(height: 350)
            //                                .background(.ultraThinMaterial)
            //                                .offset(y:-50)
            //                                .blur(radius: 10)
            //                                .opacity(scrolled ? 1 : 0)
            //                                .animation(.linear(duration: 0.1), value: scrolled)
            //                                .transition(.opacity.animation(.linear(duration: 0.1)))
            //                                .contrast(colorScheme == .dark ? 1.3 : 1)
            //                        )
            //
            //                }
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
                        .buttonStyle(PolishedButton(color: color.opacity(classEntities.count == 0 ? 0.2 : 1), background: true))

                        .padding(.horizontal, 10)
                        .disabled(classEntities.count == 0 ? true : false)
                    }


                    Color.clear.frame(height: 20)
                }.background(LinearGradient(gradient: Gradient(colors: [Color.clear, Color("bw").opacity(0.5)]), startPoint: .top, endPoint: .bottom))

                    .background(VariableBlurView().rotationEffect(Angle(degrees: 180)).ignoresSafeArea())
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
                    .buttonStyle(PolishedButton(color: color, background: false))
                    .background {
                        BackdropBlurView(radius: 10)
                    }
                    Spacer()
                    Button {
                        withAnimation(.smoothCard){
                            index = index + 1
                        }
                    } label: {
                        Text("Next")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(PolishedButton(color: color.opacity(classEntities.count == 0 ? 0.2 : 1), background: true))
                    .disabled(classEntities.count == 0 ? true : false)

                    Button {
                        withAnimation(.smoothCard){
                            edit.toggle()
                        }
                    } label: {
                        Text(edit ? "Done" : "Edit")
                            .padding(.horizontal)
                            .padding(.vertical, 10)
                    }
                    .sheet(isPresented: $addClass) {
                        NavigationStack{
                            ClassComposer()

                        }.frame(idealWidth: 570, idealHeight:  640)
                            .interactiveDismissDisabled()

                            .presentationCornerRadius(25)
                    }
                    if !edit{
                        Button {
                            addClass.toggle()
                        } label: {
                            Text("Add")
                                .padding(.horizontal)
                                .padding(.vertical, 10)
                        }
                    }

                }
                .padding(.bottom, 17)
                .padding(.horizontal, 20)
#endif
            }
            .ignoresSafeArea(edges: .bottom)
            .background{
                ZStack{
                    pageTopHue(color: .teal)
                }.ignoresSafeArea()
            }
#if os(iOS)
            .navigationTitle("")
            .navigationBarHidden(true)
#endif
        }
        .ignoresSafeArea()





    }

    
}
