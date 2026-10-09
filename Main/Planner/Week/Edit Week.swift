//
//  Create Week.swift
//  KyoNeo
//
//  Created by Aether on 23/01/2023.
//

import SwiftUI

struct EditWeek: View {

    var week: Week
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "number", ascending: true)],
                  predicate: NSPredicate(format: "singleDayWeek == nil OR singleDayWeek == %@", NSNumber(value: false))
    ) var weeks: FetchedResults<Week>


    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "number", ascending: true),
                                    // Add more sort descriptors if needed
                                   ],
                  predicate: NSPredicate(format: "singleDayWeek == %@", NSNumber(value: true))
    ) var singleDayweeks: FetchedResults<Week>

    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "timestamp", ascending: true)]) var timeSlots: FetchedResults<TimeSlot>

    @Environment(\.managedObjectContext) private var viewContext

    enum FocusField: Hashable {
        case field
    }

    @State var scrolled: Bool = false

    @FocusState private var focusedField: FocusField?
    @State var originalNumber = 0
    @State var alert = false
    @State var alert2 = false
    @State var highlightBox = false
    @State var highlightSelector = false

    @State var deleteWeek: Week = Week()

    @State var selectedDays: [dayItemModel] = [
        dayItemModel(name: "Mon", active: true),
        dayItemModel(name: "Tue", active: true),
        dayItemModel(name: "Wed", active: true),
        dayItemModel(name: "Thu", active: true),
        dayItemModel(name: "Fri", active: true),
        dayItemModel(name: "Sat", active: true),
        dayItemModel(name: "Sun", active: true),
    ]

    @State var number: Int?

    @Environment(\.dismiss) var dismiss

    var color: Color = Color("1")

    var body: some View {
        ZStack{


            pageTopHue()

            ScrollView{
                ScrollDetector(scrolled: $scrolled)
                VStack{
                    Text("Number")
                        .textCase(.uppercase)
                        .sectionTitle()


                    HStack(spacing: 0) {
                        if #available(iOS 16.0, *) {
                            Image(systemName: "character.cursor.ibeam")
                                .fontWeight(.bold)
                                .foregroundColor(color)
                                .padding(.leading, 13)
                                .padding(.trailing, 5)
                        } else {

                            Image(systemName: "character.cursor.ibeam")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(color)
                                .padding(.leading, 13)
                                .padding(.trailing, 5)
                        }
                        TextField("Enter week number", value: $number, format: .number)
                            .focused($focusedField, equals: .field)
                            .onAppear {
                                self.focusedField = .field
                            }
#if os(iOS) || os(visionOS)
                            .autocapitalization(.none)
                            .textContentType(.none)
                            .keyboardType(.numberPad)
                            .submitLabel(.done)
#endif

                            .autocorrectionDisabled(true)

                    }
                    .onAppear{
                        number = Int(week.number)
                        originalNumber = Int(week.number)
                    }
                    .onChange(of: number, perform: { newValue in
                        if !checkForOverlap(){
                            withAnimation(.smoothCard){
                                highlightBox = false
                            }

                        }
                        else{
                            if newValue != originalNumber{
                                withAnimation(.smoothCard){
                                    highlightBox = true
                                }
                            }
                        }
                    })
                    .neoFieldCard()
                    if highlightBox{
                        Text("Week already exists")
                            .sectionTitle()
                            .foregroundColor(.red)
                    }
                }
                .padding(.horizontal, 20)
                VStack{
                    Text("Days")
                        .textCase(.uppercase)
                        .sectionTitle(bottomPadding: 2)

                    filteredDays_WeekEdit(week: week, color: color)

                }.padding(.horizontal, 20)

                //toggle
            }
            .coordinateSpace(name: "scroll")

            .safeAreaInset(edge: .top, content: {
                Color.clear.frame(height: 85)
            })
            .overlay(
                EditNavigationBar(type: .blank, title: "Edit Week", color: color, scrolled: $scrolled){
                    navBarContent
                }

            )
#if os(iOS) || os(visionOS)
            .navigationBarTitle("")
            .navigationBarHidden(true)
#endif


        }
    }
    
  

    func checkForOverlap() -> Bool {
        for week in weeks {
            if week.number == number ?? 999{
                deleteWeek = week
                return true
            }
        }
        return false
    }

    func update(){
        viewContext.perform {
            week.number = Int64(number ?? 0)
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    var navBarContent: some View{
        HStack(spacing: 13){
            Button {
                if !highlightBox{
                    update()
                    dismiss()
                }

            } label: {
                Text("Done")
                    .font(.body.weight(.regular))
                    .padding(11)
                    .opacity(highlightBox ? 0.7 : 1)
                    .disabled(highlightBox ? true : false)
            }
            .buttonStyle(neoNavigationButton(color: color, scrolled: $scrolled))

        }


    }

    var toggle: some View {
        Toggle(isOn: .constant(false)) {
            Text("Remember Selection")
        }
        .disabled(true)
        .frame(minHeight: 50)
        .padding(.horizontal, 10)
        .background(Color("textField"))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(LinearGradient(gradient: Gradient(colors: [Color.white, Color(red: 0, green: 0, blue: 0, opacity: 0)]), startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1.17))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

        .padding(.vertical, 3)
        .padding(.horizontal, 20)
        .shadow(color: .primary.opacity(0.05), radius: 13, x: 0, y: 5)
    }



}



struct dayRowList: View {
    var day: Day
    var color: Color
    @State var dragX: Double = 0.0
    @State var dragXOffset: Double = 0.0
    @State var hideItem = false
    var week: Week
    @State var confirmDelete: Bool = false
    @State var haptic = false

    @State var dragged = false

    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "number", ascending: true)],
                  predicate: NSPredicate(format: "singleDayWeek == nil OR singleDayWeek == %@", NSNumber(value: false))
    ) var weeks: FetchedResults<Week>


    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "number", ascending: true),
                                    // Add more sort descriptors if needed
                                   ],
                  predicate: NSPredicate(format: "singleDayWeek == %@", NSNumber(value: true))
    ) var singleDayweeks: FetchedResults<Week>
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "number", ascending: true)]) var days: FetchedResults<Day>
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "timestamp", ascending: true)]) var timeSlots: FetchedResults<TimeSlot>

    @Environment(\.managedObjectContext) private var viewContext


    var body: some View {
        if !hideItem{
            ZStack{
                HStack(spacing: 0) {
                    if #available(iOS 16.0, *) {
                        Image(systemName: "calendar")
                            .fontWeight(.bold)
                            .foregroundColor(color)
                            .padding(.leading, 13)
                            .padding(.trailing, 6)
                    } else {

                        Image(systemName: "calendar")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(color)
                            .padding(.leading, 13)
                            .padding(.trailing, 6)

                    }
                    Text(day.name ?? "No name found")

                        .foregroundColor(.primary)
#if os(iOS) || os(visionOS)
                        .autocapitalization(.none)
                        .textContentType(.name)
#endif
                    Spacer()


                    if #available(iOS 16.0, *) {
                        Image(systemName: "chevron.forward")

                            .fontWeight(.bold)
                            .foregroundColor(color)
                            .padding(.leading, 6)
                            .padding(.trailing, 13)
                    } else {
                        Image(systemName: "chevron.forward")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(color)
                            .padding(.leading, 6)
                            .padding(.trailing, 13)

                    }
                }

                .background(Color("textField").frame(minHeight: 50).opacity(0.7))
                .offset(x: dragX + dragXOffset)
                .background(
                    HStack{
                        Spacer()
                        ZStack(alignment: .leading) {
                            Color.red
                        }.frame(width: dragged ? abs(dragX + dragXOffset) : 0)

                            .frame(minHeight: 50)
                            .onTapGesture {
                                confirmDelete = true
                            }
                            .overlay{
                                HStack{
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundColor(.white)
                                    Spacer()
                                }
                                .padding(.horizontal)
                            }
                    }

                )
                .gesture(
                    DragGesture(minimumDistance: 30)
                        .onChanged({ drag in
                            print(drag.translation.width)
                            if drag.translation.width > -250 - dragXOffset{
                                withAnimation(.linear){
                                    dragged = true
                                    dragX = drag.translation.width / 1.7
                                    haptic = false
                                }
                            }
                            if drag.translation.width < -250 - dragXOffset{
                                withAnimation(.linear){
                                    dragX = drag.translation.width * 1.3
                                    haptic = true
                                }
                            }
                            withAnimation(.smoothCard){



                            }
                        })
                        .onEnded({ drag in

                            haptic = false
                            if drag.translation.width < -70 && drag.translation.width > -250 - dragXOffset{
                                withAnimation(.smoothCard){
                                    dragX = 0.0
                                    dragXOffset = -100

                                }
                            }
                            else if drag.translation.width > -250 - dragXOffset {
                                withAnimation(.closeCard){
                                    dragX = 0.0
                                    dragXOffset = 0.0
                                }
                            }

                            else if drag.translation.width < -250 - dragXOffset {
                                withAnimation(.smoothCard){

                                    // dragX = -500.0

                                    confirmDelete = true
                                }
                            }







                        })
                )

            }
            .frame(minHeight:  50)
            #if os(iOS) || os(visionOS)
            .actionSheet(isPresented: $confirmDelete) {
                ActionSheet(
                    title: Text("Are you sure you want to delete " + (day.name ?? "Untitled")),
                    buttons: [
                        .destructive(Text("Delete")) {
                            withAnimation(.closeCard){
                                hideItem = true
                                deleteDay(week: week)
                            }

                        },

                            .cancel(){
                                withAnimation(.closeCard){
                                    dragX = 0.0
                                    dragXOffset = 0.0
                                }
                            }
                    ]
                )
            }
            #endif
            .onChange(of: haptic) { newValue in
#if os(iOS)
                let impactMed = UIImpactFeedbackGenerator(style: .soft)
                impactMed.impactOccurred()
#endif
            }

        }

    }

    


    private func deleteDay(week: Week){

        print("delete timeslots in days")
        for timeSlot in timeSlots {
            let timeSlotDay = timeSlot.day ?? Day()

            if timeSlotDay == day{
                let timeSlotDayWeek = timeSlotDay.week

                if timeSlotDayWeek == week{
                    print("deleted timeslot \(timeSlot)")
                    viewContext.delete(timeSlot)

                }
            }
        }

        print("deleting day")
        viewContext.delete(day)


        do {
            try viewContext.save()
            print("deleted day entrys")
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }

}

struct filteredDays_WeekEdit: View{
    var week: Week
    var color: Color
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "number", ascending: true)]) var days: FetchedResults<Day>
    @Environment(\.managedObjectContext) private var viewContext

    

    @State var edit = false

    var body: some View{
        VStack(spacing: 0) {
            if !edit{
                ForEach(days) { day in
                    NavigationLink {
                    } label: {
                        dayRowList(day: day, color: color, week: day.week ?? Week())
                    }

                }
            }

            Divider()
            Button {

                edit.toggle()
            } label: {
                ZStack{
                    HStack(spacing: 0) {
                        if #available(iOS 16.0, *) {
                            Image(systemName: edit ? "checkmark.circle.fill" : "pencil.circle")
                                .fontWeight(.bold)
                                .foregroundColor(color)
                                .padding(.leading, 13)
                                .padding(.trailing, 6)
                        } else {
                            Image(systemName: edit ? "checkmark.circle.fill" : "pencil.circle")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(color)
                                .padding(.leading, 13)
                                .padding(.trailing, 6)

                        }
                        Text(edit ? "Done" : "Edit")

                            .foregroundColor(.primary)
#if os(iOS) || os(visionOS)
                            .autocapitalization(.none)
                            .textContentType(.name)
#endif
                        Spacer()

                    }

                    .background(Color("textField").frame(minHeight: 50).opacity(0.7))

                }
                .frame(minHeight:  50)
            }
        }
        .background(Color("textField"))
        .neoOutline(cornerRadius: 18)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))


        .shadow(color: .primary.opacity(0.05), radius: 13, x: 0, y: 5)
        .animation(.smoothCard, value: edit)
    }

    init(week: Week, color: Color) {
        self.week = week
        self.color = color
        _days = FetchRequest<Day>(sortDescriptors: [NSSortDescriptor(key: "number", ascending: true)], predicate: NSPredicate(format:"week.number = %i",  week.number))
    }


}



