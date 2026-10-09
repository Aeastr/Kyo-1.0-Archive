// FIX: Use archive identifiers to keep this build and its data separate from the original app.
//
//  WeekSlider.swift
//  KyoNeo
//
//  Created by Aether on 20/07/2023.
//

import SwiftUI
import AmethystUI
import CoreData


class WeeksViewModel: ObservableObject {
    var context: NSManagedObjectContext {
                PersistenceController.shared.container.viewContext
        }

    @Published var weeks: [Week]
    @ObservedObject var weekWizard = WeekWizard(customMessage: "from weeksviewmodel")
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "number", ascending: true)],
                          predicate: NSPredicate(format: "singleDayWeek == nil OR singleDayWeek == %@", NSNumber(value: false))
            ) var weeksFetch: FetchedResults<Week>

    init(weeksFetched: FetchedResults<Week>) {
        self.weeks = Array(weeksFetched)
    }

    func update(weeksFetched: FetchedResults<Week>){
        self.weeks = Array(weeksFetched)
    }

    func moveWeeks(from source: IndexSet, to destination: Int) {
        // Get the 'Week' object that is being moved
        guard let sourceIndex = source.first else { return }
        let weekBeingMoved = weeks[sourceIndex]

        // Check if the moved week was the current week
        let currentWeek = weekWizard.getCurrentWeek()
        let wasCurrentWeekMoved = currentWeek != nil && currentWeek == Int(weekBeingMoved.number)

        // Perform the array move
        weeks.move(fromOffsets: source, toOffset: destination)

        // Renumber the weeks based on their order in the array
        for (index, week) in weeks.enumerated() {
            week.number = Int64(index + 1)
        }

        // If the moved week was the current week, update the current week in WeekWizard
        if wasCurrentWeekMoved {
            weekWizard.schedule_SelectedWeekNumber = Int(weekBeingMoved.number)
        }

    }

    func deleteWeeks(at offsets: IndexSet) {
        // Determine if the current week is being deleted
        let currentWeekNumber = weekWizard.getCurrentWeek()
        let isCurrentWeekDeleted = offsets.contains { index in
            currentWeekNumber == Int(weeks[index].number)
        }

        // Delete from the CoreData context
        for index in offsets {
            let weekToDelete = weeks[index]
            context.delete(weekToDelete)
        }

//        // Save the context after deleting the weeks
//        do {
//            try context.save()
//        } catch {
//            // Handle the CoreData save error, perhaps by showing an alert
//            print("Error saving context after deleting weeks: \(error)")
//        }

        // Delete from the array
        weeks.remove(atOffsets: offsets)

        // Renumber the weeks after deletion
        for (index, week) in weeks.enumerated() {
            week.number = Int64(index + 1)
        }

        // If the current week was deleted, set the current week to 1 if it exists
        if isCurrentWeekDeleted || currentWeekNumber == nil {
            if !weeks.isEmpty {
                weekWizard.schedule_SelectedWeekNumber = 1
            } else {
                // Handle the case where all weeks are deleted, if necessary
                weekWizard.schedule_SelectedWeekNumber = nil
            }
        }

//        // Save the renumbered weeks to CoreData
//        do {
//            try context.save()
//        } catch {
//            // Handle the CoreData save error, perhaps by showing an alert
//            print("Error saving context after renumbering weeks: \(error)")
//        }


    }
}

struct WeekSlider: View {
    var color: Color = Color.accentColor
    @Environment(\.managedObjectContext) var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "number", ascending: true)],
                      predicate: NSPredicate(format: "singleDayWeek == nil OR singleDayWeek == %@", NSNumber(value: false))
        ) var weeks: FetchedResults<Week>

    var body: some View {
        WeekSliderReal(color: color, weeksViewModel: WeeksViewModel(weeksFetched: weeks))
    }
}

struct WeekSliderReal: View {
    @State var isProcessing = false
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "number", ascending: true)],
                  predicate: NSPredicate(format: "singleDayWeek == nil OR singleDayWeek == %@", NSNumber(value: false))
    ) var weeks: FetchedResults<Week>

    var weeksArray: [Week] {
        Array(weeks)
    }

    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "number", ascending: true),
                                    // Add more sort descriptors if needed
                                   ],
                  predicate: NSPredicate(format: "singleDayWeek == %@", NSNumber(value: true))
    ) var singleDayweeks: FetchedResults<Week>

    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "number", ascending: true)]) var days: FetchedResults<Day>
    var color: Color = Color.accentColor
    @State var edit: Bool = false
    @State var addWeek: Bool = false
    @State var scrolled: Bool = false
    @State var progress: Double = 0.0
    @State var angle: Double = 0.0
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("weekCreationIncludeWeekends") var weekCreationIncludeWeekends: Bool = false
    @AppStorage("schedule_SingleDayMode", store: UserDefaults(suiteName: "group.com.example.kyoarchive")) var schedule_SingleDayMode: Bool = false
    @State var alertUser: Bool = false
    @State var alertUserWeekend: Bool = false
    @Environment(\.dismiss) var dismiss
    @State var showAddMore: Bool = false
    @State var isMondayFirstDay: Bool = true


    @StateObject var weeksViewModel: WeeksViewModel

    @State var showTemplates: Bool = false
    var totalCount = 8

    func countTimeSlots(in week: Week) -> Int {
        // Convert 'days' from NSSet to an Array of 'Day'
        guard let daySet = week.days as? Set<Day> else { return 0 }
        let daysArray = Array(daySet)

        // Now 'daysArray' is an Array of 'Day', which you can iterate over to count 'timeSlots'
        let totalCount = daysArray.compactMap { $0.timeSlots?.count }.reduce(0, +)

        return totalCount
    }


    var body: some View {
//        NavigationStack{
        TrackableListView(scrolled: $scrolled, content: {


            if !schedule_SingleDayMode{
                Section{
                    donutSlider(totalCount: totalCount, color: color, bgColor: color.darken(by: 0.2).opacity(0.7) ,progress: $progress, angle: $angle, onDragEnd: {



                                            let count = (Int(Double(totalCount) * progress) % 60)

                        let weeksToCheck = weeks.filter { Week in
                            Week.number > count
                        }
                        
                        for week in weeksToCheck {
                            if let daysArray = (Array(week.days ?? []) as? [Day]){
                                for day in daysArray{
                                    if day.timeSlots?.count != 0 {
                                        if let timeSlotArray = (Array(day.timeSlots ?? []) as? [TimeSlot]){
                                            if !timeSlotArray.isEmpty{
                                                alertUser = true
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        if !alertUser{
                            withAnimation(.smoothCard){
                                                                        createWeeks()
                                                                    }
                        }

//                                            if count != weeks.count && !( count > weeks.count){
//                                                if weeks.count != 0{
//                                                    for week in weeks{
//                                                        print("checker: for week \(week.number)")
//                                                        if let daysArray = (Array(week.days ?? []) as? [Day])?.sorted(by: { $0.number < $1.number }).filter({ day in
//                                                            day.week?.number ?? 0 == count
//                                                        }) {
//
//                                                            for day in daysArray{
//
//                                                                if let timeSlotArray = (Array(day.timeSlots ?? []) as? [TimeSlot])?.sorted(by: { $0.timestamp ?? Date() < $1.timestamp ?? Date() }) {
//                                                                    if timeSlotArray.count != 0 {
//
//                                                                        print("checker: warn \(week.number)")
//                                                                        alertUser = true
//
//                                                                        withAnimation(.bouncy){
//                                                                            angle = ((Double(weeks.count) / Double(totalCount)) * 360)
//                                                                            progress = Double(weeks.count) / Double(totalCount)
//                                                                        }
//                                                                    }
//                                                                    else{
//                                                                        print("checker: nope \(week.number)")
//                                                                    }
//                                                                }
//                                                            }
//                                                        }
//                                                    }
//                                                    //                                    if !alertUser{
//                                                    //                                        viewContext.delete(weeks[weeks.count - 1])
//                                                    //                                    }
//                                                }
//                                            }
//                                            else{
//                                                print("requirement not met")
//                                            }









                                    })
                                    .transition(.blur.animation(.smooth))

                                    .coordinateSpace(name: "circularSlider")


                                    .padding(.vertical, 30)
                                    .background{


                                                                                      GeometryReader { geometry in
                                                                                                                                                                                      Color.clear.preference(key: ScrollOffsetPreferenceKey2.self, value: geometry.frame(in: .named("ListView")).origin)
                                                                                                                                                                                  }


                                                                                                                              }
//                                    .listRowBackground(Color.clear)
                                    .frame(maxWidth: .infinity, alignment: .center)
                }
#if os(macOS)
        .padding(.top, 20)
                #else


#endif


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
//                .onChange(of: progress) { newValue in
//
//                    let count = (Int(Double(totalCount) * newValue) % 60)
//                    // Define the boolean flag
//
//                    if count != weeks.count && !( count > weeks.count){
//                        if weeks.count != 0{
//                            for week in weeks{
//                                print("checker: for week \(week.number)")
//                                if let daysArray = (Array(week.days ?? []) as? [Day])?.sorted(by: { $0.number < $1.number }).filter({ day in
//                                    day.week?.number ?? 0 == count
//                                }) {
//
//                                    for day in daysArray{
//
//                                        if let timeSlotArray = (Array(day.timeSlots ?? []) as? [TimeSlot])?.sorted(by: { $0.timestamp ?? Date() < $1.timestamp ?? Date() }) {
//                                            if timeSlotArray.count != 0 {
//
//                                                print("checker: warn \(week.number)")
//                                                alertUser = true
//
//                                                withAnimation(.bouncy){
//                                                    angle = ((Double(weeks.count) / Double(totalCount)) * 360)
//                                                    progress = Double(weeks.count) / Double(totalCount)
//                                                }
//                                            }
//                                            else{
//                                                print("checker: nope \(week.number)")
//                                            }
//                                        }
//                                    }
//                                }
//                            }
//                            //                                    if !alertUser{
//                            //                                        viewContext.delete(weeks[weeks.count - 1])
//                            //                                    }
//                        }
//                    }
//                    else{
//                        print("requirement not met")
//                    }
//                }
                .onAppear{
                    angle = ((Double(weeks.count) / Double(totalCount)) * 360)
                    progress = Double(weeks.count) / Double(totalCount)

                }
                .onChange(of: weeks.count) { change in
                    withAnimation(.bouncy){
                        angle = ((Double(change) / Double(totalCount)) * 360)
                        progress = Double(change) / Double(totalCount)
                    }

//                    weeksViewModel.update(weeksFetched: weeks)
                }
                .alert(isPresented: $alertUser) {
                    Alert(
                        title: Text("Warning"),
                        message: Text("You are about to delete a week that you've added entries to, and you'll lose this data."),
                        primaryButton: .destructive(Text("Ok")) {
                            withAnimation(.smoothCard){
                                                                                                    createWeeks()
                                                                                                }
                        },
                        secondaryButton: .cancel({
                            withAnimation(.bouncy){
                                                                                                        angle = ((Double(weeks.count) / Double(totalCount)) * 360)
                                                                                                        progress = Double(weeks.count) / Double(totalCount)
                                                                                                    }
                        })
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
                ForEach($weeksViewModel.weeks, id: \.self) { $w in

                                           let count = (Int(Double(totalCount) * progress) % 60)
                                           if (w.number <= count){
                                               NavigationLink {
                                                   WeekWorkship(entity: w, color: color)
//                                                   testviewagain()
                                                   #if !os(iOS)
                                                       .id(w.id)
                                                   #endif
                                               } label: {
                                                   HStack(alignment: .center, spacing: 10) {
                                                                       if #available(iOS 16.0, *) {
                                                                           Image(systemName: "calendar")

                                                                               .fontWeight(.bold)
                                                                               .foregroundColor(color)
//                                                                               .padding(.trailing, 6)
                                                                       } else {

                                                                           Image(systemName: "calendar")


                                                                               .foregroundColor(color)
//                                                                               .padding(.trailing, 6)
                                                                       }
                                                       VStack(alignment: .leading){
                                                           HStack(spacing: 1){
                                                                                                                      if let name = w.name{
                                                                                                                                                                                                 Text(name.capitalized(with: .autoupdatingCurrent) + " - ")
                                                                                                                                                                                                     .foregroundColor(.primary)
                                                                                                                                                                         #if os(iOS) || os(visionOS)
                                                                                                                                                                                                     .autocapitalization(.none)
                                                                                                                                                                                                     .textContentType(.name)
                                                                                                                                                                                                     .transition(.blur)
                                                                                                                                                                                                     .animation(.smooth, value: w.name)

                                                                                                                                                                         #endif
                                                                                                                                                                                             }

                                                                                                                                                                                                 Text("Week \(w.number)")
                                                                                                                                                                                                     .foregroundColor(.primary)
                                                                                                                                                                                                     .opacity(w.name != nil ? 0.6 : 1)
                                                                                                                                                                         #if os(iOS) || os(visionOS)
                                                                                                                                                                                                     .autocapitalization(.none)
                                                                                                                                                                                                     .textContentType(.name)
                                                                                                                                                                                                     .animation(.smooth, value: w.name)
#endif
                                                                                                                  }
                                                           Group{
                                                               Text("^[\(countTimeSlots(in: w)) Entry](inflect: true)")

                                                           }          .font(.caption)
                                                               .opacity(0.7)
                                                       }




                                                                       Spacer()

                                                                       Text(WeekWizard(customMessage: "from week Item (manage weeks likely)").getCurrentWeek() ?? 0 == w.number ? "Current Week" : "")
                                                                           .font(.caption)
                                                                           .fontWeight(.bold)
                                                                           .padding(.trailing, 2)
                                                                           .foregroundStyle(color)



                                                                   }.frame(minHeight:  36)
                                               }
                                               .buttonStyle(.plain)
                                               .id(w.id)
                                               .transition(.asymmetric(insertion: .identity, removal: .blur.animation(.smooth)))
                                               .listRowBackground(
                                                                              Color(.clear)

                                                                              .clipped()

                                                                              .cornerRadius(10)
                                                                              .padding(
                                                                                                              EdgeInsets(
                                                                                                                  top: 5,
                                                                                                                  leading: 0,
                                                                                                                  bottom: 5,
                                                                                                                  trailing: 0
                                                                                                              )
                                                                                                          )
                                                                              .regularOutline(mode: count > 1 ?
                                                                                              w.id == weeksViewModel.weeks.first?.id ?
                                                                                              .top :
                                                                                              w.id == weeksViewModel.weeks.last?.id ?
                                                                                              .bottom :
                                                                                    .sides : .all
                                                                                             )
                                                               )
                                           }

                                       }

                .onMove { (indexSet, destination) in
                    weeksViewModel.moveWeeks(from: indexSet, to: destination)
                }
                .onDelete { IndexSet in
                    weeksViewModel.deleteWeeks(at: IndexSet)
                    do {
                                                                       try viewContext.save()
                   print("save!!")
                                                                   } catch {
                                                                       let nsError = error as NSError
                                                                       fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                                                                   }
//#if !os(macOS)
//                    UIApplication.shared.inAppNotification(tint: .red) { Bool in
//                                DeletedWeekNotification(viewContext: viewContext, timeout: 7, color: .red) {
//                                    weeksViewModel.update(weeksFetched: weeks)
//                                }
//                            }
//                    #endif
                }
                
//                .listRowSeparator(.hidden)
                .listRowSpacing(10)



                                       let count = (Int(Double(totalCount) * progress) % 60)
                                       if weeks.count != count && count > weeks.count{
                                           let placeHolderCount = count - weeks.count
                                           ForEach(0...max(placeHolderCount - 1,0), id: \.self) { i in

                                               HStack(alignment: .center, spacing: 0) {
                                                                                                                      if #available(iOS 16.0, *) {
                                                                                                                          Image(systemName: "calendar")

                                                                                                                              .fontWeight(.bold)
                                                                                                                              .foregroundColor(color)
                                                                                                                              .padding(.trailing, 6)
                                                                                                                      } else {

                                                                                                                          Image(systemName: "calendar")


                                                                                                                              .foregroundColor(color)
                                                                                                                              .padding(.trailing, 6)
                                                                                                                      }



                                                   Text("Week \(i + weeks.count + 1)")
                                                       .foregroundColor(.primary)



                                                                                                                      Spacer()




                                                                                                                  }

                                               .frame(minHeight:  36)

                                               .transition(.asymmetric(insertion: .blur.animation(.smooth), removal: .identity))
                                           }
                                       }
//                .transition(.blur.animation(.smooth))


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
                        week.number = -1
                        week.singleDayWeek = true
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
                    Color("NeoButton").opacity(0.2)
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

        })
        .scrollContentBackground(.hidden)
//        .background(.indigo)
#if os(iOS)
                   .navigationBarBackButtonHidden(true)
               #endif

                .frame(maxWidth: 700)
        .animation(.smooth, value: showAddMore)
#if os(iOS)
        .coordinateSpace(name: "scroll")

        .safeAreaInset(edge: .top, content: {
            AdjustableInset(compactSize: schedule_SingleDayMode ? 95 : 90)
        })


#elseif !os(visionOS)

            .background(Color(NSColor.windowBackgroundColor).edgesIgnoringSafeArea(.all))

#endif


        //                .safeAreaInset(edge: .top) {
        //                    VStack{
        //                        Color.clear.frame(height: 10)
        //                        if #available(iOS 16.0, *) {
        //                            Text("Let's add some weeks")
        //                                .frame(maxWidth: .infinity, alignment: .leading)
        //                                .font(.title3)
        //                                .fontWidth(.expanded)
        //                                .fontWeight(.semibold)
        //                        }
        //                        else{
        //                            Text("Let's add some weeks")
        //                                .frame(maxWidth: .infinity, alignment: .leading)
        //                                .font(.title3)
        //                        }
        //                        Text("You'll need to add some weeks to get started")
        //                            .frame(maxWidth: .infinity, alignment: .leading)
        //                            .padding(.top, 10)
        //                            .font(.body.weight(.regular))
        //
        //                        HStack(spacing: 15){
        //                            Button {
        //                                withAnimation(.smoothCard){
        //                                    edit.toggle()
        //                                }
        //                            } label: {
        //                                Text(edit ? "Done" : "Edit")
        //                                    .padding(.horizontal)
        //                                    .padding(.vertical, 10)
        //                            }
        //                            .fullScreenCover(isPresented: $addWeek) {
        //                                WeekWorkship(color: Color("Default/2"))
        //                                    .interactiveDismissDisabled()
        //                            }
        //                            if !edit{
        //                                Button {
        //                                    addWeek.toggle()
        //                                } label: {
        //                                    Text("Add")
        //                                        .padding(.horizontal)
        //                                        .padding(.vertical, 10)
        //                                }
        //                            }
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




//#if os(iOS)
//        .onDisappear{
//            for item in weeks{
//                SharedDataManager.shared.sendWeekDataToWatch(entity: item)
//
//            }
//
//
//            for item in days{
//                SharedDataManager.shared.sendDayDataToWatch(entity: item)
//            }
//        }
//#endif

        .sheet(isPresented: $showTemplates, content: {
            CustomTemplates(color: color)
                .presentationCornerRadius(25)
        })

        .animation(.smooth, value: schedule_SingleDayMode)
        //            .modify{
        //                if #available(iOS 17.0, *) {
        //                    $0.sensoryFeedback(.increase, trigger: progress)
        //                } else {
        //                    $0
        //                }
        //            }

        .alert(isPresented: $alertUserWeekend) {
            Alert(
                title: Text("Warning"),
                message: Text("Removing Weekends will remove any entries within them"),
                primaryButton: .destructive(Text("Ok")) {

                    createWeeks()
                },
                secondaryButton: .cancel({
                    weekCreationIncludeWeekends = true
                })
            )

        }
//        }
//    detail: {
//
//        }

        .amethystNavigationBar(title: schedule_SingleDayMode ? "Single Day" : "Weeks", titleColor: .primary,   tintColor: color, scrolled: $scrolled, inSheet: true, content: {
            //                        HStack(spacing: 15){


//            if isProcessing{
//                ProgressView()
//
//            }

            HStack{
                if !schedule_SingleDayMode{
                                Menu(content: {


                                    if schedule_SingleDayMode{

                                        Button(action: {
                                            schedule_SingleDayMode.toggle()
                                        }) {

                                            Label("Use Weeks", systemImage: "calendar.day.timeline.left")
                                            Text("Use unique weeks in your schedule")

                                        }
                                    }
                                    else{
                                        Button(action: {
                                            schedule_SingleDayMode.toggle()
                                        }) {

                                            Label("Use Single Day", systemImage: "repeat.1")
                                            Text("Use just one day in your schedule")

                                        }
                                    }
                                    if !schedule_SingleDayMode{
                                        Toggle(isOn: $weekCreationIncludeWeekends) {
                                            Image(systemName: "plus.square.fill.on.square.fill")

                                            Text("Include Weekends")
                                            Text("Applies to all current weeks, and any new ones")

                                        }

                                        //                                Section("Advanced"){
                                        //                                    Button(action: {
                                        //                                        showTemplates.toggle()
                                        //                                    }) {
                                        //
                                        //                                        Label("Custom Template", systemImage: "square.on.square")
                                        //                                        Text("Set a template for current and new weeks")
                                        //
                                        //                                    }
                                        //
                                        //
                                        //                                        Button(action: {
                                        //
                                        //                                        }) {
                                        //
                                        //                                            Label("Create Bulk", systemImage: "figure.run")
                                        //                                            Text("Create weeks with configurations and names in bulk")
                                        //
                                        //                                        }
                                        //                                }
                                    }

                                }, label: {
                                    Text("Options")
#if os(iOS)
                                        .padding(.horizontal)
                                        .padding(.vertical, 10)
#endif
                                })
#if os(iOS)
                                .buttonStyle(NavigationButton(color: color, scrolled: $scrolled))
                                .transition(.blur.animation(.smooth))
                    #else
                                .menuStyle(.button)
#endif

#if !os(macOS)

#if os(iOS)
                    EditButton()

                                    .buttonStyle(NavigationButton(color: color, scrolled: $scrolled, width: 58, height: 40))
                                    .transition(.blur.animation(.smooth))
                    #endif
                    #endif

                            }
            }

            //                if weekWizard.schedule_SelectedWeekNumber == nil{
            //
            //
            //
            //                    NavigationLink {
            //                        SetupAutomaticWeeks( color: color, navType: .regular, weekWizard: weekWizard, index: .constant(0))
            //                            .onDisappear{
            //                                weekWizard.totalWeeks = weeks.count
            //                                weekWizard.schedule_SelectedWeekNumber = weekWizard.schedule_SelectedWeekNumber
            //                                print("setting total weeks to \(weeks.count) set \(weekWizard.totalWeeks ?? -1)")
            //
            //                                do {
            //
            //                                    try viewContext.save()
            //                                } catch {
            //                                    let nsError = error as NSError
            //                                    fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            //                                }
            //
            //                                dismiss()
            //                            }
            //                    } label: {
            //                        Text("Done")
            //                            .padding(.horizontal)
            //                            .padding(.vertical, 10)
            //                    }
            //                    .buttonStyle(NavigationButton(color: color, scrolled: $scrolled))
            //
            //                }
            //                else{
            //
            //                    Button {
            //                        weekWizard.totalWeeks = weeks.count
            //                        weekWizard.schedule_SelectedWeekNumber = weekWizard.schedule_SelectedWeekNumber
            //                        print("setting total weeks to \(weeks.count) set \(weekWizard.totalWeeks ?? -1)")
            //                        do {
            //                            try viewContext.save()
            //                        } catch {
            //                            let nsError = error as NSError
            //                            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            //                        }
            //
            //                        dismiss()
            //                    } label: {
            //                        Text("Done" )
            //                            .padding(.horizontal)
            //                            .padding(.vertical, 10)
            //                    }
            //                    .buttonStyle(NavigationButton(color: color, scrolled: $scrolled))
            //
            //                }
            //                                                    .fullScreenCover(isPresented: $addWeek) {
            //                                                        WeekWorkship(onboardingMode: true ,color: Color("Default/2"))
            //                                                            .interactiveDismissDisabled()
            //                                                    }
            //                                                    if !edit{
            //                                                        Button {
            //                                                            addWeek.toggle()
            //                                                        } label: {
            //                                                            Text("Add")
            //                                                                .padding(.horizontal)
            //                                                                .padding(.vertical, 10)
            //                                                        }
            //                                                    }
            //                                                }
            //                                                .frame(maxWidth: .infinity, alignment: .trailing)
            //                                                .padding(.top, 10)
            //                                                .buttonStyle(NavigationButton(color: .purple, scrolled: $scrolled))
        }, toolbar: {
            #if !os(visionOS)
            if !schedule_SingleDayMode{
                            Text("^[\(weeks.count) Week](inflect: true)")
                                .contentTransition(.numericText())

                        }
            #endif
        })
#if os(visionOS)
        .toolbar {
            ToolbarItem(placement: .bottomOrnament) {
                if !schedule_SingleDayMode{
                                Text("^[\(weeks.count) Week](inflect: true)")
                                    .contentTransition(.numericText())

                            }
            }
        }
#endif
    }

    func createWeeks() {
        isProcessing = true
        var weekWizard = WeekWizard()

        DispatchQueue.main.async {
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
                weeksViewModel.update(weeksFetched: weeks)
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
            weekWizard.reset()
            weekWizard.schedule_SelectedWeekNumber = 1
            weekWizard.anchorWeekDate = Date()
//            weekWizard.totalWeeks = 1
            print("set wizard stuff")
        }

        // Handle weekWizard related code...


        let count = (Int(Double(totalCount) * progress) % 60)

        if let tW = weekWizard.schedule_SelectedWeekNumber {
            print("AAAAAA")
            if count > tW {
//                weekWizard.totalWeeks = count
            } else if count < tW {
                if count > 0 {
                    weekWizard.schedule_SelectedWeekNumber = 1
                }
                else{
                    weekWizard.reset()
                }
            }
        }
    }

}


struct TrackableListView<Content: View>: View {
    @Binding var scrolled: Bool
    let content: Content

    init(scrolled: Binding<Bool>, @ViewBuilder content: () -> Content) {
        self._scrolled = scrolled
        self.content = content()
    }


    var body: some View {
        List{
            content

        }
//        .environment(\.defaultMinListRowHeight, -160)

        .coordinateSpace(name: "ListView")
        .onPreferenceChange(ScrollOffsetPreferenceKey2.self) { offset in
            // Handle the offset if it's non-nil
            withAnimation(.spring(response: 0.1, dampingFraction: 3)) {
                if let offset = offset {
                                if offset.y < 180{
                                                scrolled = true
                                            }
                                            else{
                                                scrolled = false
                                            }
                            }
            }
        }
    }
}


private struct ScrollOffsetPreferenceKey2: PreferenceKey {
    static var defaultValue: CGPoint? = nil

    static func reduce(value: inout CGPoint?, nextValue: () -> CGPoint?) {
        if let next = nextValue() {
            value = next
        }
    }
}

