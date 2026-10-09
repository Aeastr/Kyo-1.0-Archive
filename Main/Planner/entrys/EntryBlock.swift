//
//  EntryBlock.swift
//  KyoNeo
//
//  Created by Aether on 30/08/2023.
//

import SwiftUI
import CoreData

struct EntryBlock: View {
    @Environment(\.managedObjectContext) private var viewContext

    @AppStorage("schedule_SingleDayMode", store: UserDefaults(suiteName: "group.com.example.kyoarchive")) var schedule_SingleDayMode: Bool = false
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "due", ascending: true)]) var tasks: FetchedResults<TaskEntity>
    @AppStorage("global_Compact") var global_Compact  = false

    @AppStorage("lastClassDuration") var lastClassDuration: Double = 1.0

@AppStorage("planner_viewSettings_twoColumn") var planner_viewSettings_twoColumn : Bool = false

    @AppStorage("debug") var debug: Bool = false
    @ObservedObject var timeSlot: TimeSlot
    var index: Int = 0
    @State var confirmDelete: Bool = false
    @State var showEditScreen: Bool = false
    @Binding var shownTimeSlot: TimeSlot?
    @Binding var classForTask: ClassEntity?
    @Binding var viewTimeSlot: TimeSlot?
    @ObservedObject var timeSlotClass: ClassEntity
    @ObservedObject var timeSlotSplit: SplitterEntity
    @Binding var editMode: Bool
    @Binding var shareTimeSlot: TimeSlot?
    var imageMode = false
    var previewMode = false
    @AppStorage("scaleMode") var scaleMode:  plannerScaleMode = .regular
    @AppStorage("scaleWithDuration") var scaleWithDuration: Bool = true
    @AppStorage("planner_selectedTimeSlotDetailID") var planner_selectedTimeSlotDetailID: String?
    init(timeSlot: TimeSlot,
         index: Int = 0,
         context: NSManagedObjectContext = PersistenceController.shared.container.viewContext,
         shownTimeSlot: Binding<TimeSlot?>,
         viewTimeSlot: Binding<TimeSlot?>,
         classForTask: Binding<ClassEntity?>,
         shareTimeSlot: Binding<TimeSlot?>,
         editMode: Binding<Bool>,
         imageMode: Bool = false,
         previewMode: Bool = false) {
        self.timeSlot = timeSlot
        self.index = index
        self.imageMode = imageMode
        _shownTimeSlot = shownTimeSlot
        _classForTask = classForTask
        _viewTimeSlot = viewTimeSlot
        _shareTimeSlot = shareTimeSlot
        _editMode = editMode
        self.previewMode = previewMode
        if let classEntity = timeSlot.classEntity{
            self.timeSlotClass = classEntity
        }
        else{
            self.timeSlotClass = ClassEntity()
        }
        if let splitterEntity = timeSlot.splitterEntity{
            self.timeSlotSplit = splitterEntity
        }
        else{
            self.timeSlotSplit = SplitterEntity()
        }
    }


    @State var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State var currentState: timeState = .upcoming
    @AppStorage("countdownOnlyCurrent") var countdownOnlyCurrent = true

    @AppStorage("showLength") var showLength = true
    @AppStorage("planner_CountDown") var planner_CountDown : Bool = true
    @AppStorage("showDetails") var showDetails = true

    var body: some View {

        let color1 = Color(hex: timeSlot.classEntity?.color1 ?? timeSlot.splitterEntity?.color1 ?? "")
        let color2 = Color(hex: timeSlot.classEntity?.color2 ?? timeSlot.splitterEntity?.color2 ?? "")


        let brightness1 = color1.getBrightness()

        ZStack{
            if timeSlot.classEntity != nil{
                HStack{
                    Image(systemName: timeSlot.classEntity?.icon ?? "book.closed")
                        .frame(width: 40, height: 40)
                        .font(.system(size: 23))

                VStack(alignment: .leading, spacing: 4){
                    HStack{
                        Text(timeSlot.classEntity?.name ?? "A")
//                            .textCase(.uppercase)
                            .font(.body.weight(.semibold))
                            .lineLimit(1)

                            .italic(timeSlot.muted)
                        Spacer()
                        if timeSlot.muted{
                            Image(systemName: "bell.slash")
                                .transition(.blur.animation(.smooth))
                        }
                    }
                    switch currentState {
                    case .error:
                        Group{
                            Text("State Error")
                                .font(.footnote.weight(.regular))
                        }
                    case .upcoming:
                        HStack{
                            Group{
                                Text(timeSlot.startTime ?? "")
                                    .font(.footnote.weight(.regular))
                                +
                                Text(" - ")
                                    .font(.footnote.weight(.regular))
                                +
                                Text(timeSlot.endTime ?? "")
                                    .font(.footnote.weight(.regular))
                            }
                            if imageMode{
                                Group{

                                    Text("Week \(timeSlot.day?.week?.number ?? -1)")
                                        .font(.footnote.weight(.regular))
                                    +
                                    Text(", \(getFullDayName(from: timeSlot.day?.name ?? "Untilted Day") ?? "Untilted Day")")
                                                                   .font(.footnote.weight(.regular))


                                                           }
                            }
                            Spacer()

                            if showLength || imageMode{
                                let number = differenceBetween((timeSlot.startTime ?? ""), (timeSlot.endTime ?? ""))
                                let roundedNumber = decimalToFraction(number)
                                Text(roundedNumber + "\(differenceBetween((timeSlot.startTime ?? ""), (timeSlot.endTime ?? "")) > 1 ? " hrs" : " hr")")
//                                    .textCase(.uppercase)
                                    .font(Font.footnote.weight(.semibold))
                                    .fixedSize(horizontal: true, vertical: false)
                                    .opacity(0.7)
                                    .transition(.blur)
                            }
                        }
                    case .upcomingOnOtherDay:
                        Group{
                            Text("State Error")
                                .font(.footnote.weight(.regular))
                        }
                    case .past:

                            Group{
                                Text("Ended ")
                                    .font(.footnote.weight(.regular))
                                +
                                Text(timeSlot.endTime ?? "")
                                    .font(.footnote.weight(.regular))
                            }
                    case .current:
                        HStack{
                            if planner_CountDown{
                                Text("\("Remaining") \(TimeFormatter.toDate((timeSlot.endTime ?? "")) ?? Date(), style: .timer)")
                                    .monospacedDigit()
                                    .font(.footnote.weight(.regular))
                                    .transition(.blur)
                            }
                            else{
                                Text("Now")
                                    .monospacedDigit()
                                    .font(.footnote.weight(.regular))
                                    .transition(.blur)
                            }



                            Spacer()
                            Text(Image(systemName: "arrow.right"))
                                .font(.footnote.weight(.light))
                            +
                            Text(" " + (timeSlot.endTime ?? ""))
                                .font(.footnote.weight(.regular))
                        }
//                        .textCase(.uppercase)
                            .animation(.smooth)
                    case .today:
                        Group{
                            Text("State Error")
                                .font(.footnote.weight(.regular))
                        }
                    default:
                        EmptyView()
                    }



                    if (((timeSlot.room != "" || timeSlot.taughtBy != nil) &&  showDetails) || imageMode) && !previewMode{
                        Divider()
                            .padding(.vertical, 2)
                            .tint(color1.darken(by: 0.5))

                        HStack(spacing: 3){
                            if let room = timeSlot.room, timeSlot.room != "" && findURL(in: room) == nil{
                                Group{
                                    Text(Image(systemName: "square.split.bottomrightquarter"))
                                        .font(.caption.weight(.regular))
                                    + Text(" ")
                                        .font(.caption2)
                                    + Text((room) + (timeSlot.taughtBy != nil ? "," : ""))
                                        .font(.caption.weight(.regular))
                                }
                            }
                            else if let room = timeSlot.room, findURL(in: room) != nil{
                                Group{
                                    Text(Image(systemName: getIconForURL(room)))
                                        .font(.caption.weight(.regular))
                                    + Text(" ")
                                        .font(.caption2)
                                    + Text((cleanUpURLForDisplay(room).shortenedClassName(maxLength: 23)) + (timeSlot.taughtBy != nil ? "," : ""))
                                        .font(.caption.weight(.regular))
                                }
                            }
                            if timeSlot.taughtBy != nil, let teacher = timeSlot.taughtBy?.name {
                                Group{
                                    Text(Image(systemName: "person"))
                                        .font(.caption.weight(.regular))
                                    + Text(" ")
                                        .font(.caption2)
                                    + Text((teacher))
                                        .font(.caption.weight(.regular))
                                }
                            }
                        }
                        .transition(.blur)

                    }
                    if debug{
                        Text("Timestamp: \(timeSlot.timestamp ?? Date())")
                            .font(.caption.weight(.regular))
                        Text("ID: \(timeSlot.id)")
                            .font(.caption.weight(.regular))
                    }
                }
                .frame(minHeight: (scaleWithDuration && !imageMode) ? ((differenceBetween(timeSlot.startTime ?? "", timeSlot.endTime ?? "") * ((global_Compact || previewMode) ? 65 : 70)) * getTimeSlotHeightMultiplier(start: timeSlot.startTime ?? "" , end: timeSlot.endTime ?? "", mode: scaleMode)): 92)
            }
                .padding(.vertical , (scaleWithDuration && !imageMode) ? differenceBetween(timeSlot.startTime ?? "", timeSlot.endTime ?? "") * 11.2 : 5)


                #if os(visionOS)
                .padding(.horizontal, 20)
                .background{
                    LinearGradient(gradient: Gradient(colors: [color1, color2]), startPoint: .topLeading, endPoint: .bottomTrailing).blendMode(.overlay)
                        .animation(.smooth) { body in
                            body
                                .opacity(planner_selectedTimeSlotDetailID == timeSlot.id?.uuidString ? !planner_viewSettings_twoColumn ? 0.4 : 0.7 : 0.7)
                        }
                }

                #else
                .padding(.horizontal, 15)
                .background(LinearGradient(gradient: Gradient(colors: [color1, color2]), startPoint: .topLeading, endPoint: .bottomTrailing))
                .foregroundStyle(brightness1 > 0.73 ? color1.darken(by: 0.5) : Color.white)
                #endif
                .clipShape(RoundedRectangle(cornerRadius: (global_Compact || previewMode) ? 0 : 28, style: .continuous))
                #if os(iOS) || os(visionOS)
                .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: (global_Compact || previewMode) ? 0 : 28, style: .continuous))
                #endif


#if os(visionOS)
                .animation(.smooth) { body in
                    body
                        .frame(depth: (planner_selectedTimeSlotDetailID == timeSlot.id?.uuidString ? !planner_viewSettings_twoColumn ? 0 : 20 : 0))
                }
#endif
            }


            else if let splitter = timeSlot.splitterEntity, splitter.type == SplitterType.divider.rawValue{
                HStack{
                    Text(timeSlot.splitterEntity?.name ?? "A")

//                        .textCase(.uppercase)
                        .font(.footnote.weight(.semibold))
                        .lineLimit(1)

                    Group{
                        Text(timeSlot.startTime ?? "")
                            .font(.caption.weight(.regular))
                        +
                        Text(" - ")
                            .font(.caption.weight(.regular))
                        +
                        Text(timeSlot.endTime ?? "")
                            .font(.caption.weight(.regular))
                    }
                }
                .frame(maxHeight: .infinity, alignment: .center)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding((global_Compact || previewMode) ? 12 : 8)



#if os(visionOS)
                .background(Color("bw").opacity(0.3))
                .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: (global_Compact || previewMode) ? 0 : 28, style: .continuous))
                #elseif !os(macOS)
                .background(Color("bw"))
                .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: (global_Compact || previewMode) ? 0 : 28, style: .continuous))
                #endif
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .regularOutline(cornerRadius: (global_Compact || previewMode) ? 0 : 12)
                .padding(.horizontal, (global_Compact || imageMode) ? 0 : 16)
                .padding(.vertical, (global_Compact || previewMode) ? 0 : 2)

            }
            else if let splitter = timeSlot.splitterEntity, splitter.type == SplitterType.free.rawValue{
                HStack{

                    Image(systemName: "line.3.horizontal")
                        .frame(width: 40, height: 40)
                        .font(.system(size: 23))

                VStack(alignment: .leading, spacing: 4){
                    HStack{
                        Text(splitter.name ?? "A")
//                            .textCase(.uppercase)
                            .font(.body.weight(.semibold))
                            .lineLimit(1)

                            .italic(timeSlot.muted)
                        Spacer()
                        if timeSlot.muted{
                            Image(systemName: "bell.slash")
                                .transition(.blur.animation(.smooth))
                        }
                    }
                    switch currentState {
                    case .error:
                        Group{
                            Text("State Error")
                                .font(.footnote.weight(.regular))
                        }
                    case .upcoming:
                        Group{
                            Text(timeSlot.startTime ?? "")
                                .font(.footnote.weight(.regular))
                            +
                            Text(" - ")
                                .font(.footnote.weight(.regular))
                            +
                            Text(timeSlot.endTime ?? "")
                                .font(.footnote.weight(.regular))
                        }
                    case .upcomingOnOtherDay:
                        Group{
                            Text("State Error")
                                .font(.footnote.weight(.regular))
                        }
                    case .past:

                            Group{
                                Text("Ended ")
                                    .font(.footnote.weight(.regular))
                                +
                                Text(timeSlot.endTime ?? "")
                                    .font(.footnote.weight(.regular))
                            }
                    case .current:
                        HStack{
                            Text("\("Remaining") \(TimeFormatter.toDate((timeSlot.endTime ?? "")) ?? Date(), style: .timer)")
                                .monospacedDigit()
                                .font(.footnote.weight(.regular))



                            Spacer()
                            Text(Image(systemName: "arrow.right"))
                                .font(.footnote.weight(.light))
                            +
                            Text(" " + (timeSlot.endTime ?? ""))
                                .font(.footnote.weight(.regular))
                        }
//                        .textCase(.uppercase)
                            .animation(.smooth)
                    case .today:
                        Group{
                            Text("State Error")
                                .font(.footnote.weight(.regular))
                        }
                    default:
                        EmptyView()
                    }




                    if (timeSlot.room != "" || timeSlot.taughtBy != nil) {
                        Divider()
                            .padding(.vertical, 2)
                            .tint(color1.darken(by: 0.5))

                        HStack(spacing: 3){
                            if let room = timeSlot.room, timeSlot.room != "" && findURL(in: room) == nil{
                                Group{
                                    Text(Image(systemName: "square.split.bottomrightquarter"))
                                        .font(.caption.weight(.regular))
                                    + Text(" ")
                                        .font(.caption2)
                                    + Text((room) + (timeSlot.taughtBy != nil ? "," : ""))
                                        .font(.caption.weight(.regular))
                                }
                            }
                            else if let room = timeSlot.room, findURL(in: room) != nil{
                                Group{
                                    Text(Image(systemName: getIconForURL(room)))
                                        .font(.caption.weight(.regular))
                                    + Text(" ")
                                        .font(.caption2)
                                    + Text((cleanUpURLForDisplay(room).shortenedClassName(maxLength: 23)) + (timeSlot.taughtBy != nil ? "," : ""))
                                        .font(.caption.weight(.regular))
                                }
                            }
                            if timeSlot.taughtBy != nil, let teacher = timeSlot.taughtBy?.name {
                                Group{
                                    Text(Image(systemName: "person"))
                                        .font(.caption.weight(.regular))
                                    + Text(" ")
                                        .font(.caption2)
                                    + Text((teacher))
                                        .font(.caption.weight(.regular))
                                }
                            }
                        }
                    }
                }
                .frame(minHeight: ((differenceBetween(timeSlot.startTime ?? "", timeSlot.endTime ?? "") * ((global_Compact || previewMode) ? 70 : 75)) * (0.8) * 1.1 * getTimeSlotHeightMultiplier(start: timeSlot.startTime ?? "" , end: timeSlot.endTime ?? "")))
                }
                .padding(.vertical , differenceBetween(timeSlot.startTime ?? "", timeSlot.endTime ?? "") * 11.2)
                .padding(.horizontal, 15)
                .background(LinearGradient(gradient: Gradient(colors: [color1, color2]), startPoint: .topLeading, endPoint: .bottomTrailing))
                .foregroundStyle(brightness1 > 0.73 ? color1.darken(by: 0.5) : Color.white)
                .clipShape(RoundedRectangle(cornerRadius: (global_Compact || previewMode) ? 0 : 28, style: .continuous))
#if os(iOS) || os(visionOS)
                .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: (global_Compact || previewMode) ? 0 : 28, style: .continuous))
                #endif
            }
        }


        .frame(maxWidth: .infinity, alignment: .leading)


        .contextMenu {

            if let room = timeSlot.room, findURL(in: room) != nil{
                //                Group{
                //                    Text(Image(systemName: getIconForURL(room)))
                //                        .font(.footnote.weight(.regular))
                //                    + Text(" ")
                //                        .font(.caption2)
                //                    + Text((cleanUpURLForDisplay(room).shortenedClassName(maxLength: 23)) + (timeSlot.taughtBy != nil ? "," : ""))
                //                        .font(.footnote.weight(.regular))
                //                }
                //                .foregroundStyle(color1.darken(by: 0.5))
                Button(action: {

                }) {
                    Label("Open Link", systemImage: getIconForURL(room))
                    Text(cleanUpURLForDisplay(room))
                }
                Divider()
            }



            if let classEntity = timeSlot.classEntity{
                Button(action: {
                    classForTask = classEntity
                }) {
                    Label("Task", systemImage: "plus")
                    let totalTasks = tasks.filter{ item in
                        return item.classEntity == timeSlot.classEntity
                    }


                }
            }

            Button {
                shownTimeSlot = timeSlot
            } label: {
                Label("Edit", systemImage: "pencil")
            }

//            Button {
//                withAnimation(.bouncy){
//                    timeSlot.muted.toggle()
//                }
//                do {
//                    try viewContext.save()
//                } catch {
//                    let nsError = error as NSError
//                    fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//                }
//            } label: {
//                Label(timeSlot.muted ? "Unmute" : "Mute", systemImage: timeSlot.muted ? "bell" : "bell.slash")
//            }

                Button {
                    let dataFactory = knDataFactory()
                    dataFactory.duplicateTimeSlot(timeSlot: timeSlot, startTime: TimeFormatter.toDate(timeSlot.endTime!, mode: .fullDate) ?? Date(), endTime: Calendar.current.date(byAdding: .minute, value: Int(lastClassDuration * 60) , to: (TimeFormatter.toDate(timeSlot.endTime!, mode: .fullDate) ?? Date())) ?? Date())
                } label: {
                    Label("Duplicate", systemImage: "square.on.square")
                }

//                Button {
//                    shareTimeSlot = timeSlot
//                } label: {
//                    Label("Share", systemImage: "square.and.arrow.up")
//                }

                Button(role: .destructive) {
                    confirmDelete.toggle()
                } label: {
                    Label("Delete", systemImage: "trash")
                }

        }

        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation{
                planner_selectedTimeSlotDetailID = timeSlot.id?.uuidString
                viewTimeSlot = timeSlot
            }
        }
        .padding(.horizontal, editMode ? 0 : (global_Compact || imageMode) ? 0 : 20)

        .onAppear{
            getState()
            if currentState == .past{
                   self.timer.upstream.connect().cancel()
            }
        }
                .onReceive(timer) { input in
                    getState()
                    if currentState == .past{
                        self.timer.upstream.connect().cancel()
                    }
                }

                .alert("Are you sure you want to delete this entry?", isPresented: $confirmDelete) {
                    Button("Delete", role: .destructive, action: {
                        //    viewContext.delete(timeSlot)
                        // remove from classes!!

                        if let classEntity = timeSlot.classEntity{
                            classEntity.removeFromTimeSlot(timeSlot)
                            print("remove from classes")
                        }
                        if let splitterEntity = timeSlot.splitterEntity{
                            splitterEntity.removeFromTimeSlot(timeSlot)
                            print("remove from splitters")
                        }
                        if let day = timeSlot.day{
                            day.removeFromTimeSlots(timeSlot)
                            print("remove from day")
                        }

                        withAnimation(.smooth){
                            viewContext.delete(timeSlot)
//                            do {
//                                try viewContext.save()
//                                print("deleted week entry")
//                            } catch {
//                                let nsError = error as NSError
//                                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//                            }
#if !os(macOS)
                            UIApplication.shared.inAppNotification(adaptForDynamicIsland: true, timeout: 5, swipeToClose: true, tint: .red) { Bool in
                                DeletedEntryNotification(viewContext: viewContext, timeout: 5, color: .red)
                            }
                            #endif
                        }
                                })
                    Button("Cancel", role: .cancel) { }

                            }
    }

    func getState() {
        let remMinutes = TimeHelper.getRemainingMinutes(for: timeSlot.endTime ?? "01:00")

        if !(remMinutes < 0.0){
            if timeSlot.day?.name == TimeFormatter.getDayCode(date: Date()) || schedule_SingleDayMode {
                withAnimation(.smoothCard) {
                    self.currentState = TimeHelper.getTimeState(startTime: timeSlot.startTime ?? "00:00", endTime: timeSlot.endTime ?? "00:01")
                }
                if remMinutes > 8.0{
                    print("Adjusting state timer refresh to longer interval \(remMinutes)")
                    changeTimerInterval(to: 300) // Change interval to 5 minutes
                } else{
                    if timer.upstream.interval != 1 {
                        print("Adjusting timer refresh to shorter interval")
                        changeTimerInterval(to: 1) // Change interval back to 1 second if not already
                    }
                }
            }
        }
    }

    func changeTimerInterval(to interval: TimeInterval) {
        timer.upstream.connect().cancel() // Cancel the existing timer
        timer = Timer.publish(every: interval, on: .main, in: .common).autoconnect() // Create a new timer with the specified interval
    }

}
