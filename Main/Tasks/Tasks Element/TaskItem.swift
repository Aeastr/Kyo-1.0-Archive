//
//  TaskItem.swift
//  KyoNeo
//
//  Created by Aether on 01/04/2023.
//

import SwiftUI
import ConfettiSwiftUI

struct TaskItem: View {
    @State private var isDoNotArchiveEnabled = false // State for the toggle
    @Environment(\.openURL) private var openURL
    @Environment(\.managedObjectContext) private var viewContext
    @State var currentState: timeState = .upcoming
    @State var currentlyActive: Bool = false
    @State var past: Bool = false
    @State var showNeoItemEdit = false
    @State var showArchiveWarning: Bool = false
    @State var showDeleteWarning: Bool = false
    @State var expandedMode: Bool = false
    @ObservedObject var data: TaskEntity
    @AppStorage("countdownOnlyCurrent") var countdownOnlyCurrent = true

    @AppStorage("alwaysShowButtons") var alwaysShowButtons = false

    @AppStorage("global_Compact") var global_Compact  = false
    @State var showCheck = false

    @Environment(\.colorScheme) var colorScheme

    @State var confetti: Int = 0
    @State var showDetail: Bool = false

    @AppStorage("appAccentColor") var appAccentColor = "Default"
    @AppStorage("multicolored") var multicolored = true
    
    @AppStorage("appAccentColorIndex") var appAccentColorIndex = 1
    @State var useemojis: [String] = ["🌟", "✨", "🎉"]

    var showFullNote = false
    init(data: TaskEntity, showFullNote: Bool = false){
        self.data = data
        self.showFullNote = showFullNote
    }

    func formatDueDate(_ date: Date) -> String {
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US")

            // Get the current year and the due date's year
            let calendar = Calendar.current
            let currentYear = calendar.component(.year, from: Date())
            let dueYear = calendar.component(.year, from: date)

            // Adjust format based on whether the due date's year matches the current year
            if currentYear == dueYear {
                dateFormatter.dateFormat = "MMMM d"
            } else {
                dateFormatter.dateFormat = "MMMM d, yyyy"
            }

            return dateFormatter.string(from: date)
        }

    var body: some View {
        VStack {

                let brightness1 =  data.classEntity != nil ? Color(hex: (data.classEntity?.color1!)! ).getBrightness() : Color(multicolored ? "\(appAccentColor)/1" : "\(appAccentColor)/\(appAccentColorIndex)").getBrightness()
                let color1 = data.classEntity != nil ? Color(hex: (data.classEntity?.color1!)! ) : Color(multicolored ? "\(appAccentColor)/3" : "\(appAccentColor)/\(appAccentColorIndex)")
                let c2 = data.classEntity != nil ? Color(hex: (data.classEntity?.color2!)! ) : Color(multicolored ? "\(appAccentColor)/3" : "\(appAccentColor)/\(appAccentColorIndex)")

                HStack(spacing: 11) {
                    HStack(spacing: 11) {

                        VStack(alignment: .leading, spacing: 3){
                            //  .matchedGeometryEffect(id: "\(data.id)-title", in: namespace)
                            if let taskTitle = data.taskType?.title {

                                Text(taskTitle)
                                //                                        .contentTransition(.opacity)
                                    .font(.caption)
                                    .lineLimit(2)
                                    .foregroundColor(brightness1 > 0.82 ? color1.darken(by: 0.5) : Color.white)
                                    .lineSpacing(2)


                            }
                            else{
                            }

                            Text("\((data.label ?? "Untitled"))")
                                .contentTransition(.opacity)

                                .frame(maxWidth: .infinity, alignment: .leading)
                                .fixedSize(horizontal: false, vertical: true)
                                .lineLimit(2)
                                .font(.headline)
                                .minimumScaleFactor(0.5)
                                .foregroundColor(brightness1 > 0.82 ? color1.darken(by: 0.5) : Color.white)
                                .lineSpacing(2)

                            HStack(spacing: 2){
                                if let due = data.due{
                                    Text(formatDueDate(due))
                                    .fixedSize(horizontal: false, vertical: true)
                                    .lineLimit(1)
                                    .font(.footnote.weight(.regular))
                                    .foregroundColor(brightness1 > 0.82 ? color1.darken(by: 0.5) : Color.white)
                                    .lineSpacing(1)
                            }

                                if let due = data.due, TimeHelper.getTaskTimeState(task: data) == .today && due > Date(){
                                    Text(" - \(data.due ?? Date(), style: .timer)")
                                        .monospacedDigit()
                                        .fixedSize(horizontal: false, vertical: true)
                                        .lineLimit(1)
                                        .font(.footnote.weight(.regular))
                                        .foregroundColor(brightness1 > 0.82 ? color1.darken(by: 0.5) : Color.white)
                                        .lineSpacing(1)
                                        .contentTransition(.numericText())
                                        .animation(.smooth)
                                }
                                else if let due = data.due, !(due < Date()) {
                                    Text(" - \(due, style: .relative)")
                                                                            .monospacedDigit()
                                                                            .fixedSize(horizontal: false, vertical: true)
                                                                            .lineLimit(1)
                                                                            .font(.footnote.weight(.regular))
                                                                            .foregroundColor(brightness1 > 0.82 ? color1.darken(by: 0.5) : Color.white)
                                                                            .lineSpacing(1)
                                                                            .contentTransition(.numericText())
                                                                            .animation(.smooth)
                                }


                            }




                            if let note = data.notes, note != ""{
                                Divider()
                                    .tint(brightness1 > 0.82 ? color1.darken(by: 0.5) : Color.white)
                                    .padding(.vertical, 2)

                                Text(note)                        .contentTransition(.opacity)
                                    .font(.caption)
                                    .lineLimit(showFullNote ? nil : 2)
                                    .padding(.top, 2)
                                    .foregroundColor(brightness1 > 0.82 ? color1.darken(by: 0.5) : Color.white)
                                    .lineSpacing(2)
                            }

                        }



                        Color.clear
                            .layoutPriority(0)
                            .frame(maxWidth: 1, maxHeight: 40)

                        if !alwaysShowButtons {

                            Button {
                                withAnimation(.smooth){
                                    if data.completed == false{
                                        if TaskArchiver().getArchivingAction(for: data) == .none{

                                            if data.completed == false{
                                                confetti = confetti + 1
                                                print("increase confetti")
                                            }

                                                withAnimation(.smooth){
                                                    data.completed.toggle()
                                                    do {
                                                        try viewContext.save()
                                                    } catch {
                                                        let nsError = error as NSError
                                                        fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                                                    }
                                                }

                                        }
                                        else{
                                            print("show warning")
                                            showArchiveWarning.toggle()
                                        }
                                    }
                                    else{
                                        data.archived = false
                                        

                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                            // Action to be executed after the random delay


                                            withAnimation(.smooth){
                                                data.completed.toggle()
                                                do {
                                                    try viewContext.save()
                                                } catch {
                                                    let nsError = error as NSError
                                                    fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                                                }
                                            }
                                        }
                                    }
                                }

                            } label: {
                                Image(systemName: "checkmark")
                                    .symbolRenderingMode(.hierarchical)
                                    .opacity((data.completed) ? 1 : 0)
                                #if !os(visionOS)
                                    .font(.system(size: 19).weight((data.completed) ? .bold : .regular))
                                    .padding(7)

                                    .frame(width: 40, height: 40)
                                    .shadow(color: Color(hex: data.classEntity?.color1 ?? "98C6D1").opacity(0.2), radius: 3, y: 3)
                                    .background(color1.opacity(0.2))
                                    .background(.white.opacity(0.7))
                                    .clipShape(RoundedRectangle(cornerRadius: 12,style: .continuous))
                                    .foregroundColor(brightness1 > 0.82 ? color1.darken(by: 0.4) : color1)
                                    .saturation(brightness1 > 0.82 ?  1.5 : 1.05)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12,style: .continuous)
                                            .stroke(brightness1 > 0.82 ? color1.darken(by: 0.5) : color1, lineWidth: 1.5)
                                    )
                                #endif

                            }


                        }
                    }
                    .padding(.leading, 15)
                    .padding(.vertical, 15)
                                    .sheet(isPresented: $showDetail, content: {
                                        TaskDetail(task: data)
                                            .presentationCornerRadius(25)
                                            .presentationDragIndicator(.visible)
                                    })
                                    .sheet(isPresented: $showNeoItemEdit, content: {
                                        NavigationStack{
                                            TaskWorkshop(entity: data)
                                                .frame(idealWidth: 570, idealHeight:  640)
                                        }
                                                    .interactiveDismissDisabled()
                                        .presentationCornerRadius(25)
                                    })

                }
                    .padding(.trailing, 15)

//            .padding(.bottom, expandedMode ? 40 : 0)
            //   .shadow(color: Color(hex: data.classEntity?.color1 ?? "98C6D1").opacity(currentState == .current ? 0.6 : 0.3), radius: currentState == .current ? 10 : 4, x:0, y: currentState == .current ? 8 : 4)

            .background{
                LinearGradient(gradient: Gradient(colors: [color1, c2]), startPoint: .topLeading, endPoint: .bottomTrailing).opacity(data.muted ? 0.5 : 1)
                #if os(visionOS)
                    .opacity(0.5)
                #endif

            }
            .mask(
                RoundedRectangle(cornerRadius:global_Compact ? 0 : showFullNote ? 0 : 25, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius:global_Compact ? 0 : 30, style: .continuous)
                    .stroke(style: StrokeStyle(lineWidth: 2, dash: [alwaysShowButtons  ? 8 : 4])) // Set the dash pattern here
                    .foregroundStyle(LinearGradient(gradient: Gradient(colors: [Color(hex: data.classEntity?.color1 ?? "98C6D1"), Color(hex: data.classEntity?.color2 ?? "98C6D1")]), startPoint: .topLeading, endPoint: .bottomTrailing)) // Set the color to fill the stroke
                    .opacity(data.muted ? 1 : 0)
            )



        }
        .animation(.bouncy, value: alwaysShowButtons)
        .onAppear{
            isDoNotArchiveEnabled = data.doNotArchive
        }
        .onTapGesture(perform: {
            showDetail.toggle()
        })
        #if !os(macOS)
        .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius:global_Compact ? 0 : 25, style: .continuous))
        #endif
        .contextMenu(menuItems: {


            Button {
                withAnimation(.bouncy){
                    showNeoItemEdit.toggle()
                }
            } label: {
                Label("Edit", systemImage: "pencil")
            }

            Button {
                withAnimation(.bouncy(duration: 0.35)) {
                    data.muted.toggle()

                    do {
                        try viewContext.save()
                    } catch {
                        let nsError = error as NSError
                        fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                    }

                    // Cancel or schedule notifications based on the data.muted state
                    if data.muted {
                        // If data is muted, cancel the notifications

//                        NotificationHelper(context: viewContext).cancelTaskNotifications(for: data)
                    } else {
                        // If data is unmuted, schedule the notifications

//                        NotificationHelper(context: viewContext).makeTaskNotification(for: data) { result in
//                            switch result {
//                            case .success(let success):
//                                print("Notification(s) created successfully: \(success)")
//                            case .failure(let error):
//                                let errorMessage = error.reason
//                                print("Error: \(errorMessage)")
//                                // Present an alert or show the error message to the user
//                            }
//                        }
                    }
                }
            } label: {
                Label(data.muted ?  "Unmute" : "Mute", systemImage: data.muted ? "bell" : "bell.slash")
            }


            Button {
                withAnimation(.bouncy){
                    duplicateTask()
                }
            } label: {
                Label("Duplicate", systemImage: "square.on.square")
            }


        Button {
            if data.archived == true{
                if TaskArchiver().getArchivingAction(for: data) != .none{
                    print("dna")
                    data.doNotArchive = true
                }
                else{
                    print("no action")
                }
            }
            else{

                data.doNotArchive = false
            }

            data.archived.toggle()


            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        } label: {
            Label(data.archived ? "Unarchive" : "Archive", systemImage: "archivebox")
        }


        Toggle(isOn: $isDoNotArchiveEnabled) {
            Label("Do not Archive", systemImage: "rectangle.portrait.slash")
                    }

                    .onChange(of: isDoNotArchiveEnabled) { newValue in
                        data.doNotArchive = newValue // Update the task's doNotArchive property
                        data.archived = false

                        if data.completed{
                            TaskArchiver().performArchivingAction(for: data)
                        }

                        do {
                            try viewContext.save()
                        } catch {
                            let nsError = error as NSError
                            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                        }
                    }

        if let link = data.link, let urlString = findURL(in: link){
            Button(action: {
                #if !os(macOS)
                UIPasteboard.general.string = link
                #else
//                NSPasteboard.general.string(forType: .string) = link
                #endif
            }) {
                Text("Copy link")
                Image(systemName: "doc.on.doc")
            }
        }


            Button(role: .destructive) {

                withAnimation(.bouncy){

                    viewContext.delete(data)
//                    NotificationHelper(context: viewContext).cancelTaskNotifications(for: data)
                    do {
                        try viewContext.save()
                        print("deleted week entry")
                    } catch {
                        let nsError = error as NSError
                        fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                    }
                }
            } label: {
                Label("Delete", systemImage: "trash")
            }


        }
//                     , preview: {
//            TaskDetail(task: data)
//        }
        )
       //.animation(.bouncy, value: alwaysShowButtons)
        .transition(.blur.animation(.bouncy(duration: 0.35)))
        .alert("Warning", isPresented: $showArchiveWarning, actions: {
            Button(role: .destructive) {


                if data.completed == false{
                    confetti = confetti + 1
                }

                    withAnimation(.smooth){
                        data.completed.toggle()
                        do {
                            try viewContext.save()
                        } catch {
                            let nsError = error as NSError
                            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                        }
                    }


                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    let taskArchiver = TaskArchiver()
                    taskArchiver.performArchivingAction(for: data)
                }
            } label: {
                Text("Complete and Archive")
            }
            Button() {
                data.doNotArchive = true

                if data.completed == false{
                    confetti = confetti + 1
                }

                    // Action to be executed after the random delay


                    withAnimation(.smooth){
                        data.completed.toggle()
                        do {
                            try viewContext.save()
                        } catch {
                            let nsError = error as NSError
                            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                        }
                    }



            } label: {
                Text("Complete & Keep")
            }

        }, message: {
            let taskArchiver = TaskArchiver()
            let archivingAction = taskArchiver.getArchivingAction(for: data)

            VStack(alignment: .leading) {


                if archivingAction != .none {
                    Text("\(archivingAction.warning)")
                        .foregroundColor(.red)
                } else {
                    Text("No action needed.")
                        .foregroundColor(.green)
                }
            }
        })
        #if os(iOS)
        .overlay(
                    Color.clear
                        .frame(width: alwaysShowButtons ? 145 : 70, height: 70)
                        .confettiCannon(counter: $confetti, num: 10, confettis: randomEmojis().map { .text($0) }, confettiSize: 30, rainHeight: 200, openingAngle: Angle(degrees: 90), closingAngle: Angle(degrees: 180), radius: 100)


                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: alwaysShowButtons ? .bottomLeading : .trailing)
                )
        #endif

//        .contextMenu {
//
//
//            Menu {
//                Section("Are you Sure?"){
//                    Button(role: .destructive) { // 👈 This argument
//                        viewContext.delete(data)
//                        do {
//                            try viewContext.save()
//                            print("deleted task entry")
//                        } catch {
//                            let nsError = error as NSError
//                            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//                        }
//
//                    } label: {
//                        Label("Delete", systemImage: "trash")
//                    }
//                    Button(role: .cancel){
//
//                    } label: {
//                        Text("Cancel")
//                    }
//                }
//            } label: {
//                Label("Delete", systemImage: "trash")
//            }
//
//
//            Button {
//                showNeoItemEdit = true
//            } label: {
//                Label("Edit", systemImage: "pencil")
//            }
//
//
//
//            Button {
//                //     showNeoItemEdit = true
//            } label: {
//                Label("Select", systemImage: "checkmark.circle")
//            }
//
//            Button {
//                //  duplicateTimesSlot()
//            } label: {
//                Label("Duplicate", systemImage: "square.on.square")
//            }
//            Menu {
//                Text("ID: \(data.objectID)")
//            } label: {
//                Label("Debug", systemImage: "ladybug")
//            }
//        }


        .shadow(color: (data.classEntity != nil ? Color(hex: (data.classEntity?.color1!)! ) : Color(multicolored ? "\(appAccentColor)/3" : "\(appAccentColor)/\(appAccentColorIndex)")).opacity(0.15), radius: 5, x:0, y: 6)
        .animation(.smooth, value: global_Compact)


    }

    let emojis = ["✨", "💯", "🎉", "🔥", "🌟", "🎊", "📘", "📗", "📕", "📙", "📓"]
    let specialEmojis = ["🍞", "🥖", "🥯", "🥐"]

    func randomEmojis() -> [String] {
        var randomEmojis: [String] = []
        if let label = data.label?.lowercased(), label.contains("bread") {
            return specialEmojis
        }
        // Add the special emojis with a 1/100 chance
        let chance = Int.random(in: 1...100)

        if chance == 1 {
            return specialEmojis
        } else {
            let shuffledEmojis = emojis.shuffled()
            randomEmojis = Array(shuffledEmojis.prefix(3))
        }

        return randomEmojis
    }

    private func duplicateTask(){

        let task = TaskEntity(context: viewContext)
        task.classEntity = data.classEntity
        task.taskType = data.taskType
        if data.link != ""{
            task.link = data.link
        }
        task.due = data.due
        task.notes = data.notes
        task.label = data.label


        do {
            try viewContext.save()




        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        print("fjsdil")
        NotificationHelper().makeTaskNotification(for: task) { result in
            print(result)
            switch result {
            case .success(let success):
                print("Notification(s) created successfully: \(success)")
            case .failure(let error):
                let errorMessage = error.reason
                print("Error: \(errorMessage)")
                // Present an alert or show the error message to the user
            }
        }

    }

}

//{
//
//        let brightness1 =  data.classEntity != nil ? Color(hex: (data.classEntity?.color1!)! ).getBrightness() : Color(multicolored ? "\(appAccentColor)/1" : "\(appAccentColor)/\(appAccentColorIndex)").getBrightness()
//        let color1 = data.classEntity != nil ? Color(hex: (data.classEntity?.color1!)! ) : Color(multicolored ? "\(appAccentColor)/3" : "\(appAccentColor)/\(appAccentColorIndex)")
//        let c2 = data.classEntity != nil ? Color(hex: (data.classEntity?.color2!)! ) : Color(multicolored ? "\(appAccentColor)/3" : "\(appAccentColor)/\(appAccentColorIndex)")
//    VStack(alignment: .leading, spacing: 4) {
//
//        HStack(spacing: 11) {
//            HStack(spacing: 11) {
//
////                                                HStack(spacing: 3){
////                        //                                        Image(systemName: data.classEntity == nil ? data.icon ?? "square" :data.classEntity?.icon ?? "square")
////                        //                                            .symbolRenderingMode(.hierarchical)
////                        //                                            .font(.system(size: 15))
////                        //                                            .rotationEffect(Angle(degrees: -45))
////                                                            Image(systemName: data.taskType?.icon ?? "")
////                                                                .symbolRenderingMode(.hierarchical)
////                                                                .font(.system(size: 25))
////                        //                                            .rotationEffect(Angle(degrees: -45))
////                                                        }
////                                                        .padding(7)
////                        //                                    .rotationEffect(Angle(degrees: 45))
////                                                        .foregroundColor(brightness1 > 0.82 ? color1.darken(by: 0.5) : color1)
////                                                        .frame(width: 45, height: 45)
////
////                                                .background(Color.white)
////                                                .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
////                                                .padding(1)
////                        //
//
//                VStack(alignment: .leading, spacing: 3){
//                    Text("\((data.label ?? "Untitled"))")
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                        .contentTransition(.opacity)
////                                .textCase(.uppercase)
//                        .fixedSize(horizontal: false, vertical: true)
//                        .lineLimit(2)
//                        .font(.headline)
//                        .minimumScaleFactor(0.5)
//                        .foregroundColor(brightness1 > 0.82 ? color1.darken(by: 0.5) : Color.white)
//                        .lineSpacing(2)
//
//                    HStack{
//                        let calendar = Calendar.current
//
//                        Group{
//                            Text("\(TimeHelper.getTaskTimeState(task: data).rawValue) \(data.taskType?.title != nil ? "\(data.taskType?.title ?? "Error"), " : "")\(calendar.isDateInToday(data.due ?? Date()) ? "" : calendar.isDateInTomorrow(data.due ?? Date()) ? "Tomorrow " : "")\(data.due ?? Date(), style: .time)")
//
//                                .monospacedDigit()
////                                    + Text((" in \(data.due ?? Date(), style: .timer)"))
//                        }
//                        .fixedSize(horizontal: false, vertical: true)
//                        .lineLimit(1)
//                        .font(.footnote.weight(.regular))
//                        .foregroundColor(brightness1 > 0.82 ? color1.darken(by: 0.5) : Color.white)
//                        .lineSpacing(1)
//                        .contentTransition(.numericText())
//
//
//
//
//                    }
//                    .padding(.vertical, 1.5)
//
//
//
//                    //  .matchedGeometryEffect(id: "\(data.id)-title", in: namespace)
//                    if alwaysShowButtons, let notes = data.notes, notes != "" {
//                        Divider()
//                            .tint(brightness1 > 0.82 ? color1.darken(by: 0.5) : Color.white)
//                            .padding(.vertical, 2)
//
//                        Text(notes)
//                        //                                        .contentTransition(.opacity)
//
//                            .font(.caption)
//                            .lineLimit(2)
//                            .padding(.top, 2)
//                            .foregroundColor(brightness1 > 0.82 ? color1.darken(by: 0.5) : Color.white)
//                            .lineSpacing(2)
//                            .contentTransition(.identity)
//                            .transition(.blur.animation(.smooth))
//
//
//                        if let link = data.link{
//                            HStack(spacing: 3){
//                                Image(systemName: getIconForURL(link))
//                                Text(link)
//                            }
//                            //                                        .contentTransition(.opacity)
//
//                                .font(.caption)
//                                .lineLimit(2)
//
//                                .foregroundColor(brightness1 > 0.82 ? color1.darken(by: 0.5) : Color.white)
//                                .lineSpacing(2)
//                                .opacity(0.8)
//                                .padding(.top, 4)
//                                .transition(.blur.animation(.smooth))
//                        }
//
//
//                    }
//
//                }
//
//
//
//
//
//
//
//            }
//            .padding(.leading, 15)
//            .padding(.vertical, 15)
////                                    .sheet(isPresented: $showDetail, content: {
////                                        TaskDetail(task: data)
////                                            .presentationCornerRadius(25)
////                                    })
////                                    .sheet(isPresented: $showNeoItemEdit, content: {
////                                        TaskWorkshop(entity: data)
////                                            .presentationCornerRadius(25)
////                                            .interactiveDismissDisabled()
////                                    })
//            Button {
//                                           withAnimation(.smooth){
//                                               if showCheck == false{
//                                                   if TaskArchiver().getArchivingAction(for: data) == .none{
//                                                       showCheck = true
//                                                       if data.completed == false{
//                                                           confetti = confetti + 1
//                                                           print("increase confetti")
//                                                       }
//
//
//                                                       DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//                                                           // Action to be executed after the random delay
//
//
//                                                           withAnimation(.smooth){
//                                                               data.completed.toggle()
//
//                                                               do {
//                                                                   try viewContext.save()
//                                                               } catch {
//                                                                   let nsError = error as NSError
//                                                                   fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//                                                               }
//                                                           }
//                                                       }
//                                                   }
//                                                   else{
//                                                       print("show warning")
//                                                       showArchiveWarning.toggle()
//                                                   }
//                                               }
//                                               else{
//                                                   showCheck = false
//                                                   data.archived = false
//
//
//                                                   DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//                                                       // Action to be executed after the random delay
//
//
//                                                       withAnimation(.smooth){
//                                                           data.completed.toggle()
//                                                           do {
//                                                               try viewContext.save()
//                                                           } catch {
//                                                               let nsError = error as NSError
//                                                               fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//                                                           }
//                                                       }
//                                                   }
//                                               }
//                                           }
//
//                                       } label: {
//                                           Image(systemName: "checkmark")
//                                               .symbolRenderingMode(.hierarchical)
//                                               .opacity((data.completed || showCheck) ? 1 : 0.05)
//                                               .font(.system(size: 19).weight((data.completed || showCheck) ? .bold : .regular))
//                                               .padding(7)
//
//                                               .frame(width: 35, height: 35)
//                                               .background(.white)
//                                               .clipShape(RoundedRectangle(cornerRadius: 14,style: .continuous))
//                                               .foregroundColor(color1.darken(by: 0.15))
//                                               .overlay(
//                                                   RoundedRectangle(cornerRadius: 14,style: .continuous)
//                                                       .stroke(color1.darken(by: 0.15), lineWidth: 1.5)
//                                               )
//
//                                       }
//        }
//        .padding(.trailing, 15)
//
//
//    }

////            .padding(.bottom, expandedMode ? 40 : 0)
//    //   .shadow(color: Color(hex: data.classEntity?.color1 ?? "98C6D1").opacity(currentState == .current ? 0.6 : 0.3), radius: currentState == .current ? 10 : 4, x:0, y: currentState == .current ? 8 : 4)
//    .background{
//        LinearGradient(gradient: Gradient(colors: [color1, c2]), startPoint: .topLeading, endPoint: .bottomTrailing).opacity(data.muted ? 0.5 : 1)
//
//
//    }
//    .mask(
//        RoundedRectangle(cornerRadius:global_Compact ? 0 : 25, style: .continuous)
//    )
//    .overlay(
//        RoundedRectangle(cornerRadius:global_Compact ? 0 : 30, style: .continuous)
//            .stroke(style: StrokeStyle(lineWidth: 2, dash: [alwaysShowButtons  ? 8 : 4])) // Set the dash pattern here
//            .foregroundStyle(LinearGradient(gradient: Gradient(colors: [Color(hex: data.classEntity?.color1 ?? "98C6D1"), Color(hex: data.classEntity?.color2 ?? "98C6D1")]), startPoint: .topLeading, endPoint: .bottomTrailing)) // Set the color to fill the stroke
//            .opacity(data.muted ? 1 : 0)
//    )
//
//}
