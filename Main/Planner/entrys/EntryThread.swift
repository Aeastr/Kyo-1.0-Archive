//
//  EntryThread.swift
//  KyoNeo
//
//  Created by Aether on 30/08/2023.
//

import SwiftUI

struct EntryThread: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "due", ascending: true)]) var tasks: FetchedResults<TaskEntity>

    @Environment(\.colorScheme) var colorScheme

    @AppStorage("planner_Suggestions") var planner_Suggestions: Bool = true

    @AppStorage("schedule_SingleDayMode", store: UserDefaults(suiteName: "group.com.example.kyoarchive")) var schedule_SingleDayMode: Bool = false
    @AppStorage("planner_TimelineBubbles") var planner_TimelineBubbles:  Bool = true

    @AppStorage("lastClassDuration") var lastClassDuration: Double = 1.0
    @ObservedObject var timeSlot: TimeSlot
    @ObservedObject var timeSlotPrev: TimeSlot
    @ObservedObject var timeSlotNext: TimeSlot
    var index: Int = 0
    var widthBubble: CGFloat = 75

    @State var confirmDelete: Bool = false
    @State var showEditScreen: Bool = false
    @Binding var shownTimeSlot: TimeSlot?
    @Binding var classForTask: ClassEntity?
    @Binding var viewTimeSlot: TimeSlot?
    @ObservedObject var timeSlotClass: ClassEntity
    @ObservedObject var timeSlotSplit: SplitterEntity
    @Binding var editMode: Bool
    

    init(timeSlot: TimeSlot,
         timeSlotPrev: TimeSlot,
         timeSlotNext: TimeSlot,
         index: Int = 0,
         widthBubble: CGFloat = 75,
         shownTimeSlot: Binding<TimeSlot?>,
         viewTimeSlot: Binding<TimeSlot?>,
         classForTask: Binding<ClassEntity?>,
         editMode: Binding<Bool>) {
        self.timeSlot = timeSlot
        self.timeSlotPrev = timeSlotPrev
        self.timeSlotNext = timeSlotNext
        self.index = index
        self.widthBubble = widthBubble
        _shownTimeSlot = shownTimeSlot
        _classForTask = classForTask
        _viewTimeSlot = viewTimeSlot
        _editMode = editMode
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
        HStack{

            let color1 = Color(hex: timeSlot.classEntity?.color1 ?? timeSlot.splitterEntity?.color1 ?? "a5bbc9")
            let color2 = Color(hex: timeSlot.classEntity?.color2 ?? timeSlot.splitterEntity?.color2 ?? "95b4c9")
            let color1Next = Color(hex: timeSlotNext.classEntity?.color1 ??  timeSlotNext.splitterEntity?.color1 ?? "a5bbc9")
            let color1Prev = Color(hex: timeSlotPrev.classEntity?.color1 ??  timeSlotPrev.splitterEntity?.color1 ?? "a5bbc9")

            let icon = timeSlot.classEntity?.icon ?? "book.closed"
            let brightness1 = color1.getBrightness()
            if timeSlot.classEntity != nil{


                if index == 0 && planner_TimelineBubbles{
                    if timeSlot != timeSlotNext{
                        Image(!isNextSlotLoop() ?  "timelineViewAssets/start-circle-normalLine" : "timelineViewAssets/start-cirlce-loopLine")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: widthBubble)


                            .foregroundStyle(LinearGradient(gradient: Gradient(stops: [.init(color: color1.opacity(timeSlot.muted ? 0.4 : 1), location: 0.81), .init(color: timeSlot.endTime != timeSlotNext.startTime || !planner_Suggestions ? color1.opacity(timeSlotNext.muted ? 0.4 : 1) : color1Next.opacity(timeSlotNext.muted ? 0.4 : 1), location: 1.00)]), startPoint: .top, endPoint: .bottom))

                            .overlay{
                                Image(systemName: icon)
                                    .font(.system(size: widthBubble / 3.3))
                                    .foregroundColor(brightness1 > 0.73 ? color1.darken(by: 0.5).opacity(timeSlot.muted ? 0.3 : 1) : timeSlot.muted ? color1.darken(by: 0.5).opacity(0.3) : Color.white)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .aspectRatio(CGSize(width: 1, height: 1), contentMode: .fit)
                                    .padding(.trailing, 5)
                                    .frame(maxHeight: .infinity, alignment: .topLeading)
                            }
                            .scaleEffect(1)
                            .transition(.blurWithoutScale)
                    }
                    else{
                        Circle()
                            .frame(width: 70 - 5, alignment: .leading)
                            .padding(.trailing, 5)
                            .foregroundStyle(LinearGradient(gradient: Gradient(stops: [.init(color: color1.opacity(timeSlot.muted ? 0.4 : 1), location: 0.81), .init(color: color1Next.opacity(timeSlotNext.muted ? 0.4 : 1), location: 1.00)]), startPoint: .top, endPoint: .bottom))
                            .overlay{
                                Image(systemName: icon)
                                    .font(.system(size: widthBubble / 3.3))
                                    .foregroundColor(brightness1 > 0.73 ? color1.darken(by: 0.5).opacity(timeSlot.muted ? 0.3 : 1) : timeSlot.muted ? color1.darken(by: 0.5).opacity(0.3) : Color.white)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .aspectRatio(CGSize(width: 1, height: 1), contentMode: .fit)
                                    .padding(.trailing, 5)
                                    .frame(maxHeight: .infinity, alignment: .topLeading)
                            }
                            .scaleEffect(1)
                            .transition(.blurWithoutScale)
                    }
                }
                else if timeSlot == timeSlotNext, isPreviousSlotLoop(), planner_TimelineBubbles{
                    Image("timelineViewAssets/end-circle-loopLine")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: widthBubble)
                        .foregroundStyle(LinearGradient(gradient: Gradient(stops: [.init(color: color1Prev.opacity(timeSlotPrev.muted ? 0.4 : 1), location: 0.07),.init(color: color1.opacity(timeSlot.muted ? 0.4 : 1), location: 0.13), .init(color: color1.opacity(timeSlot.muted ? 0.4 : 1), location: 1.00)]), startPoint: .top, endPoint: .bottom))
                        .opacity(timeSlot.muted ? 0.4 : 1)
                        .overlay{
                            Image(systemName: icon)
                                .font(.system(size: widthBubble / 3.3))

                                .foregroundColor(brightness1 > 0.73 ? color1.darken(by: 0.5).opacity(timeSlot.muted ? 0.3 : 1) : timeSlot.muted ? color1.darken(by: 0.5).opacity(0.3) : Color.white)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .aspectRatio(CGSize(width: 1, height: 1), contentMode: .fit)
                                .padding(.trailing, 5)
                                .frame(maxHeight: .infinity, alignment: .bottomLeading)
                        }
                        .transition(.blurWithoutScale)
                }
                else if timeSlot == timeSlotNext, !isPreviousSlotLoop(),  planner_TimelineBubbles{
                    //
                    Image("timelineViewAssets/end-circle-normalLine")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: widthBubble)
                        .foregroundStyle(color1)
                        .opacity(timeSlot.muted ? 0.4 : 1)
                        .overlay{
                            Image(systemName: icon)
                                .font(.system(size: widthBubble / 3.3))

                                .foregroundColor(brightness1 > 0.73 ? color1.darken(by: 0.5).opacity(timeSlot.muted ? 0.3 : 1) : timeSlot.muted ? color1.darken(by: 0.5).opacity(0.3) : Color.white)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .aspectRatio(CGSize(width: 1, height: 1), contentMode: .fit)
                                .padding(.trailing, 5)
                                .frame(maxHeight: .infinity, alignment: .bottomLeading)
                        }
                        .transition(.blurWithoutScale)
                }
                else if planner_TimelineBubbles{

                    if !isPreviousSlotLoop() && !isNextSlotLoop(){

                        Image(isNextSlotLoop() ?  "timelineViewAssets/circle-normalLine-to-loopLine" : "timelineViewAssets/circle-normalLine-to-normalLine")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: widthBubble)
                            .foregroundStyle(LinearGradient(gradient: Gradient(stops: [.init(color: color1.opacity(timeSlot.muted ? 0.4 : 1), location: 0.81), .init(color: color1Next, location: 1.00)]), startPoint: .top, endPoint: .bottom))
                            .opacity(timeSlot.muted ? 0.4 : 1)
                            .overlay{
                                Image(systemName: icon)
                                    .font(.system(size: widthBubble / 3.3))

                                    .foregroundColor(brightness1 > 0.73 ? color1.darken(by: 0.5).opacity(timeSlot.muted ? 0.3 : 1) : timeSlot.muted ? color1.darken(by: 0.5).opacity(0.3) : Color.white)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .aspectRatio(CGSize(width: 1, height: 1), contentMode: .fit)

                                    .padding(.trailing, 5)
                                    .padding(.bottom,  isNextSlotLoop() ?  3.4 : 0 )
                                    .frame(maxHeight: .infinity, alignment: .center)
                            }
                            .transition(.blurWithoutScale)
                    }
                    else if isPreviousSlotLoop() && !isNextSlotLoop() {
                        Image("timelineViewAssets/circle-loopLine-to-NormalLine")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: widthBubble)


                            .foregroundStyle(LinearGradient(gradient: Gradient(stops: [.init(color: color1Prev, location: 0.07),.init(color: color1.opacity(timeSlot.muted ? 0.4 : 1), location: 0.13), .init(color: color1.opacity(timeSlot.muted ? 0.4 : 1), location: 0.81), .init(color: timeSlot.endTime != timeSlotNext.startTime || !planner_Suggestions ? color1.opacity(timeSlotNext.muted ? 0.4 : 1) : color1Next.opacity(timeSlotNext.muted ? 0.4 : 1), location: 1.00)]), startPoint: .top, endPoint: .bottom))
//                            .foregroundStyle(LinearGradient(gradient: Gradient(stops: [.init(color: color1.opacity(timeSlot.muted ? 0.4 : 1), location: 0.81), .init(color: timeSlot.endTime != timeSlotNext.startTime || !planner_Suggestions ? color1.opacity(timeSlotNext.muted ? 0.4 : 1) : color1Next.opacity(timeSlotNext.muted ? 0.4 : 1), location: 1.00)]), startPoint: .top, endPoint: .bottom))
                            .opacity(timeSlot.muted ? 0.4 : 1)
                        //                        .frame(height: 78)
                        //                        .clipped()
                            .overlay{
                                Image(systemName: icon)
                                    .font(.system(size: widthBubble / 3.3))

                                    .foregroundColor(brightness1 > 0.73 ? color1.darken(by: 0.5).opacity(timeSlot.muted ? 0.3 : 1) : timeSlot.muted ? color1.darken(by: 0.5).opacity(0.3) : Color.white)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .aspectRatio(CGSize(width: 1, height: 1), contentMode: .fit)
                                    .padding(.trailing, 5)
                                    .padding(.top, 3.4)
                                    .frame(maxHeight: .infinity, alignment: .center)
                            }
                            .transition(.blurWithoutScale)
                    }
                    else if  isNextSlotLoop() && isPreviousSlotLoop(){
                        Image("timelineViewAssets/circle-loopLine-to-loopLine")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: widthBubble)


                            .foregroundStyle(LinearGradient(gradient: Gradient(stops: [.init(color: color1Prev, location: 0.07),.init(color: color1.opacity(timeSlot.muted ? 0.4 : 1), location: 0.13), .init(color: color1.opacity(timeSlot.muted ? 0.4 : 1), location: 0.81), .init(color: color1Next, location: 1.00)]), startPoint: .top, endPoint: .bottom))
                            .opacity(timeSlot.muted ? 0.4 : 1)
                        //                        .frame(height: 78)
                        //                        .clipped()
                            .overlay{
                                Image(systemName: icon)
                                    .font(.system(size: widthBubble / 3.3))

                                    .foregroundColor(brightness1 > 0.73 ? color1.darken(by: 0.5).opacity(timeSlot.muted ? 0.3 : 1) : timeSlot.muted ? color1.darken(by: 0.5).opacity(0.3) : Color.white)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .aspectRatio(CGSize(width: 1, height: 1), contentMode: .fit)
                                    .padding(.trailing, 5)
                                    .padding(.top, 3.4)
                                    .frame(maxHeight: .infinity, alignment: .center)
                            }
                            .transition(.blurWithoutScale)
                    }
                    else{
                        Image("timelineViewAssets/circle-normalLine-to-loopLine")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: widthBubble)


                            .foregroundStyle(LinearGradient(gradient: Gradient(stops: [.init(color: color1.opacity(timeSlot.muted ? 0.4 : 1), location: 0.13), .init(color: color1.opacity(timeSlot.muted ? 0.4 : 1), location: 0.81), .init(color: color1Next, location: 1.00)]), startPoint: .top, endPoint: .bottom))
                            .opacity(timeSlot.muted ? 0.4 : 1)
                        //                        .frame(height: 78)
                        //                        .clipped()
                            .overlay{
                                Image(systemName: icon)
                                    .font(.system(size: widthBubble / 3.3))

                                    .foregroundColor(brightness1 > 0.73 ? color1.darken(by: 0.5).opacity(timeSlot.muted ? 0.3 : 1) : timeSlot.muted ? color1.darken(by: 0.5).opacity(0.3) : Color.white)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .aspectRatio(CGSize(width: 1, height: 1), contentMode: .fit)
                                    .padding(.trailing, 5)
                                    .padding(.bottom, 3.4)
                                    .frame(maxHeight: .infinity, alignment: .center)
                            }

                            .transition(.blurWithoutScale)
                    }
                }
                VStack(alignment: .leading, spacing: 4){
                    HStack{
                        Text(timeSlot.classEntity?.name ?? "A")
                            .textCase(.uppercase)
                            .font(.body.weight(.semibold))
                            .lineLimit(2)

                            .italic(timeSlot.muted)
                        Spacer()
                        if timeSlot.muted{
                            Image(systemName: "bell.slash")
                                .transition(.blur.animation(.smooth))
                        }
                        if let currentSlotStartTime = timeSlot.startTime,
                           let nextSlotStartTime = timeSlotNext.startTime,
                           let nextSlotEndTime = timeSlotNext.endTime,
                           let currentSlotStartDate = TimeFormatter.toDate(currentSlotStartTime, mode: .time),
                           let nextSlotStartDate = TimeFormatter.toDate(nextSlotStartTime, mode: .time),
                           let nextSlotEndDate = TimeFormatter.toDate(nextSlotEndTime, mode: .time),
                           currentSlotStartDate == nextSlotStartDate /*|| currentSlotStartDate < nextSlotEndDate */, timeSlot != timeSlotNext {

                            Image(systemName: "exclamationmark.triangle")
                                .transition(.blur.animation(.smooth))
                        }
                        else if let currentSlotStartTime = timeSlot.startTime,
                                let prevSlotStartTime = timeSlotPrev.startTime,
                                let prevSlotEndTime = timeSlotPrev.endTime,
                                let currentSlotStartDate = TimeFormatter.toDate(currentSlotStartTime, mode: .time),
                                let prevSlotStartDate = TimeFormatter.toDate(prevSlotStartTime, mode: .time),
                                let prevSlotEndDate = TimeFormatter.toDate(prevSlotEndTime, mode: .time),
                                ((currentSlotStartDate == prevSlotStartDate || currentSlotStartDate < prevSlotEndDate) && index != 0 ) {

                            Image(systemName: "exclamationmark.triangle")
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
                            Spacer()

                            if showLength{
                                let number = differenceBetween((timeSlot.startTime ?? ""), (timeSlot.endTime ?? ""))
                                let roundedNumber = decimalToFraction(number)
                                Text(roundedNumber + "\(differenceBetween((timeSlot.startTime ?? ""), (timeSlot.endTime ?? "")) > 1 ? " hrs" : " hr")")
                                    .textCase(.uppercase)
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
                        }.textCase(.uppercase)
                            .animation(.smooth)

                    case .today:
                        Group{
                            Text("State Error")
                                .font(.footnote.weight(.regular))
                        }
                    default:
                        EmptyView()
                    }




                    if (timeSlot.room != "" || timeSlot.taughtBy != nil) && !editMode && showDetails{
                        Divider()
                            .padding(.vertical, 2)
                            .tint(colorScheme == .dark ? color1.darken(by: -0.5) : color1.darken(by: 0.5))

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
                                .textCase(.uppercase)
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
                #if os(visionOS)

                .foregroundStyle(color1.lighten(by: 0.9))
                #else
                .foregroundStyle(colorScheme == .dark ? color1.darken(by: -0.5) : color1.darken(by: 0.5))
                #endif
                .frame(maxHeight: planner_TimelineBubbles ? widthBubble * 0.97 : .infinity)
                .frame(maxHeight: .infinity, alignment: index == 0 ? .top : timeSlot == timeSlotNext ? .bottom : .center)
            }
            else if let splitter = timeSlot.splitterEntity, isCurrentSlotLoop(){
                VStack(alignment: .leading,spacing: 0){
                    if index == 0{
                        HStack{
                            Image("timelineViewAssets/start-cirlce-loopLine")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: widthBubble)


                                .foregroundStyle(color1)


                            Text("Start of Day")
                                .textCase(.uppercase)
                                .font(.body.weight(.semibold))
                                .lineLimit(1)
                                .italic()
                                .foregroundStyle(color1.darken(by: 0.5).opacity(0.7))
                                .frame(height: widthBubble * 0.97)
                                .frame(maxHeight: .infinity, alignment: index == 0 ? .top : .center)

                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    HStack{
                        if planner_TimelineBubbles{
                            Image("timelineViewAssets/loop")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: widthBubble)


                                .foregroundStyle(color1)
                                .transition(.blur.animation(.smooth))
                        }

                            VStack(alignment: .leading){
                                Text(timeSlot.splitterEntity?.name ?? "A")

                                    .textCase(.uppercase)
                                    .font(.footnote.weight(.semibold))
                                    .lineLimit(1)
                                    .foregroundStyle(colorScheme == .dark ? color1.darken(by: -0.5) : color1.darken(by: 0.5))

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
                                .foregroundStyle(colorScheme == .dark ? color1.darken(by: -0.5) : color1.darken(by: 0.5))
                            }
                            .padding(.leading, planner_TimelineBubbles ? 4 : 0)
                            .frame(maxHeight: planner_TimelineBubbles ? 0: .infinity)

                    }
                }
            }
            else if let splitter = timeSlot.splitterEntity, splitter.type == SplitterType.free.rawValue{



                if index == 0{
                    Image(timeSlotNext.classEntity != nil ?  "timelineViewAssets/start-circle-normalLine" : "timelineViewAssets/start-cirlce-loopLine")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: widthBubble)


                        .foregroundStyle(LinearGradient(gradient: Gradient(stops: [.init(color: color1.opacity(timeSlot.muted ? 0.4 : 1), location: 0.81), .init(color: color1Next, location: 1.00)]), startPoint: .top, endPoint: .bottom))
                        .overlay{
                            Image(systemName: icon)
                                .font(.system(size: widthBubble / 3.3))

                                .foregroundColor(brightness1 > 0.73 ? color1.darken(by: 0.5).opacity(timeSlot.muted ? 0.3 : 1) : timeSlot.muted ? color1.darken(by: 0.5).opacity(0.3) : Color.white)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .aspectRatio(CGSize(width: 1, height: 1), contentMode: .fit)
                                .padding(.trailing, 5)
                                .frame(maxHeight: .infinity, alignment: .topLeading)
                        }
                }
                else if timeSlot == timeSlotNext, isPreviousSlotLoop(){
                    Image("timelineViewAssets/end-circle-loopLine")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: widthBubble)
                        .foregroundStyle(LinearGradient(gradient: Gradient(stops: [.init(color: color1Prev, location: 0.07),.init(color: color1.opacity(timeSlot.muted ? 0.4 : 1), location: 0.13), .init(color: color1.opacity(timeSlot.muted ? 0.4 : 1), location: 1.00)]), startPoint: .top, endPoint: .bottom))
                        .overlay{
                            Image(systemName: icon)
                                .font(.system(size: widthBubble / 3.3))

                                .foregroundColor(brightness1 > 0.73 ? color1.darken(by: 0.5).opacity(timeSlot.muted ? 0.3 : 1) : timeSlot.muted ? color1.darken(by: 0.5).opacity(0.3) : Color.white)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .aspectRatio(CGSize(width: 1, height: 1), contentMode: .fit)
                                .padding(.trailing, 5)
                                .frame(maxHeight: .infinity, alignment: .bottomLeading)
                        }
                }
                else if timeSlot == timeSlotNext, !isPreviousSlotLoop(){
                    //
                    Image("timelineViewAssets/end-circle-normalLine")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: widthBubble)
                        .foregroundStyle(color1)
                        .overlay{
                            Image(systemName: icon)
                                .font(.system(size: widthBubble / 3.3))

                                .foregroundColor(brightness1 > 0.73 ? color1.darken(by: 0.5).opacity(timeSlot.muted ? 0.3 : 1) : timeSlot.muted ? color1.darken(by: 0.5).opacity(0.3) : Color.white)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .aspectRatio(CGSize(width: 1, height: 1), contentMode: .fit)
                                .padding(.trailing, 5)
                                .frame(maxHeight: .infinity, alignment: .bottomLeading)
                        }
                }
                else{

                    if !isPreviousSlotLoop() && !isNextSlotLoop(){

                        Image(timeSlotNext.classEntity != nil ? timeSlotNext.splitterEntity != nil ?  "timelineViewAssets/circle-normalLine-to-loopLine" : "timelineViewAssets/circle-normalLine-to-normalLine" : "timelineViewAssets/circle-normalLine-to-loopLine")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: widthBubble)
                            .foregroundStyle(LinearGradient(gradient: Gradient(stops: [.init(color: color1.opacity(timeSlot.muted ? 0.4 : 1), location: 0.81), .init(color: color1Next, location: 1.00)]), startPoint: .top, endPoint: .bottom))
                            .overlay{
                                Image(systemName: icon)
                                    .font(.system(size: widthBubble / 3.3))

                                    .foregroundColor(brightness1 > 0.73 ? color1.darken(by: 0.5).opacity(timeSlot.muted ? 0.3 : 1) : timeSlot.muted ? color1.darken(by: 0.5).opacity(0.3) : Color.white)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .aspectRatio(CGSize(width: 1, height: 1), contentMode: .fit)

                                    .padding(.trailing, 5)
                                    .padding(.bottom, timeSlotNext.classEntity != nil ? timeSlotNext.splitterEntity != nil ?  3.4 : 0 : 3.4)
                                    .frame(maxHeight: .infinity, alignment: .center)
                            }
                    }
                    else if isPreviousSlotLoop() && !isNextSlotLoop() {
                        Image("timelineViewAssets/circle-loopLine-to-NormalLine")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: widthBubble)


                            .foregroundStyle(LinearGradient(gradient: Gradient(stops: [.init(color: color1Prev, location: 0.07),.init(color: color1.opacity(timeSlot.muted ? 0.4 : 1), location: 0.13), .init(color: color1.opacity(timeSlot.muted ? 0.4 : 1), location: 0.81), .init(color: color1Next, location: 1.00)]), startPoint: .top, endPoint: .bottom))
                        //                        .frame(height: 78)
                        //                        .clipped()
                            .overlay{
                                Image(systemName: icon)
                                    .font(.system(size: widthBubble / 3.3))

                                    .foregroundColor(brightness1 > 0.73 ? color1.darken(by: 0.5).opacity(timeSlot.muted ? 0.3 : 1) : timeSlot.muted ? color1.darken(by: 0.5).opacity(0.3) : Color.white)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .aspectRatio(CGSize(width: 1, height: 1), contentMode: .fit)
                                    .padding(.trailing, 5)
                                    .padding(.top, 3.4)
                                    .frame(maxHeight: .infinity, alignment: .center)
                            }
                    }
                    else if  isNextSlotLoop() && isPreviousSlotLoop(){
                        Image("timelineViewAssets/circle-loopLine-to-loopLine")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: widthBubble)


                            .foregroundStyle(LinearGradient(gradient: Gradient(stops: [.init(color: color1Prev, location: 0.07),.init(color: color1.opacity(timeSlot.muted ? 0.4 : 1), location: 0.13), .init(color: color1.opacity(timeSlot.muted ? 0.4 : 1), location: 0.81), .init(color: color1Next, location: 1.00)]), startPoint: .top, endPoint: .bottom))
                        //                        .frame(height: 78)
                        //                        .clipped()
                            .overlay{
                                Image(systemName: icon)
                                    .font(.system(size: widthBubble / 3.3))

                                    .foregroundColor(brightness1 > 0.73 ? color1.darken(by: 0.5).opacity(timeSlot.muted ? 0.3 : 1) : timeSlot.muted ? color1.darken(by: 0.5).opacity(0.3) : Color.white)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .aspectRatio(CGSize(width: 1, height: 1), contentMode: .fit)
                                    .padding(.trailing, 5)
                                    .padding(.top, 3.4)
                                    .frame(maxHeight: .infinity, alignment: .center)
                            }
                    }
                    else{
                        Image("timelineViewAssets/circle-normalLine-to-loopLine")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: widthBubble)


                            .foregroundStyle(LinearGradient(gradient: Gradient(stops: [.init(color: color1.opacity(timeSlot.muted ? 0.4 : 1), location: 0.13), .init(color: color1.opacity(timeSlot.muted ? 0.4 : 1), location: 0.81), .init(color: color1Next, location: 1.00)]), startPoint: .top, endPoint: .bottom))
                        //                        .frame(height: 78)
                        //                        .clipped()
                            .overlay{
                                Image(systemName: icon)
                                    .font(.system(size: widthBubble / 3.3))

                                    .foregroundColor(brightness1 > 0.73 ? color1.darken(by: 0.5).opacity(timeSlot.muted ? 0.3 : 1) : timeSlot.muted ? color1.darken(by: 0.5).opacity(0.3) : Color.white)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .aspectRatio(CGSize(width: 1, height: 1), contentMode: .fit)
                                    .padding(.trailing, 5)
                                    .padding(.bottom, 3.4)
                                    .frame(maxHeight: .infinity, alignment: .center)
                            }
                    }
                }

                VStack(alignment: .leading, spacing: 4){
                    Text(timeSlot.splitterEntity?.name ?? "A")
                        .textCase(.uppercase)
                        .font(.body.weight(.semibold))
                        .lineLimit(1)

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

                    if timeSlot.room != "" || timeSlot.taughtBy != nil{

                            Divider()
                                .padding(.vertical, 2)
                                .tint(colorScheme == .dark ? color1.darken(by: -0.5) : color1.darken(by: 0.5))

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
                                    + Text((cleanUpURLForDisplay(room).shortened(maxLength: 23)) + (timeSlot.taughtBy != nil ? "," : ""))
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
                .foregroundStyle(colorScheme == .dark ? color1.darken(by: -0.5) : color1.darken(by: 0.5))
                .frame(height: widthBubble * 0.97)
                .frame(maxHeight: .infinity, alignment: index == 0 ? .top : .center)
            }
            else{
                if index == 0 && planner_TimelineBubbles{
                    if timeSlot != timeSlotNext{
                        Image(!isNextSlotLoop() ?  "timelineViewAssets/start-circle-normalLine" : "timelineViewAssets/start-cirlce-loopLine")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: widthBubble)


                            .foregroundStyle(LinearGradient(gradient: Gradient(stops: [.init(color: color1.opacity(timeSlot.muted ? 0.4 : 1), location: 0.81), .init(color: color1Next.opacity(timeSlotNext.muted ? 0.4 : 1), location: 1.00)]), startPoint: .top, endPoint: .bottom))

                            .overlay{
                                Image(systemName: "circle")
                                    .font(.system(size: widthBubble / 3.3))
                                    .foregroundColor(brightness1 > 0.73 ? color1.darken(by: 0.5).opacity(timeSlot.muted ? 0.3 : 1) : timeSlot.muted ? color1.darken(by: 0.5).opacity(0.3) : Color.white)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .aspectRatio(CGSize(width: 1, height: 1), contentMode: .fit)
                                    .padding(.trailing, 5)
                                    .frame(maxHeight: .infinity, alignment: .topLeading)
                            }
                            .scaleEffect(1)
                            .transition(.blurWithoutScale)
                    }
                    else{
                        Circle()
                            .frame(width: 70 - 5, alignment: .leading)
                            .padding(.trailing, 5)
                            .foregroundStyle(LinearGradient(gradient: Gradient(stops: [.init(color: color1.opacity(timeSlot.muted ? 0.4 : 1), location: 0.81), .init(color: color1Next.opacity(timeSlotNext.muted ? 0.4 : 1), location: 1.00)]), startPoint: .top, endPoint: .bottom))
                            .overlay{
                                Image(systemName: "circle")
                                    .font(.system(size: widthBubble / 3.3))
                                    .foregroundColor(brightness1 > 0.73 ? color1.darken(by: 0.5).opacity(timeSlot.muted ? 0.3 : 1) : timeSlot.muted ? color1.darken(by: 0.5).opacity(0.3) : Color.white)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .aspectRatio(CGSize(width: 1, height: 1), contentMode: .fit)
                                    .padding(.trailing, 5)
                                    .frame(maxHeight: .infinity, alignment: .topLeading)
                            }
                            .scaleEffect(1)
                            .transition(.blurWithoutScale)
                    }
                }
                else if timeSlot == timeSlotNext, isPreviousSlotLoop(), planner_TimelineBubbles{
                    Image("timelineViewAssets/end-circle-loopLine")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: widthBubble)
                        .foregroundStyle(LinearGradient(gradient: Gradient(stops: [.init(color: color1Prev.opacity(timeSlotPrev.muted ? 0.4 : 1), location: 0.07),.init(color: color1.opacity(timeSlot.muted ? 0.4 : 1), location: 0.13), .init(color: color1.opacity(timeSlot.muted ? 0.4 : 1), location: 1.00)]), startPoint: .top, endPoint: .bottom))
                        .opacity(timeSlot.muted ? 0.4 : 1)
                        .overlay{
                            Image(systemName: "circle")
                                .font(.system(size: widthBubble / 3.3))

                                .foregroundColor(brightness1 > 0.73 ? color1.darken(by: 0.5).opacity(timeSlot.muted ? 0.3 : 1) : timeSlot.muted ? color1.darken(by: 0.5).opacity(0.3) : Color.white)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .aspectRatio(CGSize(width: 1, height: 1), contentMode: .fit)
                                .padding(.trailing, 5)
                                .frame(maxHeight: .infinity, alignment: .bottomLeading)
                        }
                        .transition(.blurWithoutScale)
                }
                else if timeSlot == timeSlotNext, !isPreviousSlotLoop(),  planner_TimelineBubbles{
                    //
                    Image("timelineViewAssets/end-circle-normalLine")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: widthBubble)
                        .foregroundStyle(color1)
                        .opacity(timeSlot.muted ? 0.4 : 1)
                        .overlay{
                            Image(systemName: "circle")
                                .font(.system(size: widthBubble / 3.3))

                                .foregroundColor(brightness1 > 0.73 ? color1.darken(by: 0.5).opacity(timeSlot.muted ? 0.3 : 1) : timeSlot.muted ? color1.darken(by: 0.5).opacity(0.3) : Color.white)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .aspectRatio(CGSize(width: 1, height: 1), contentMode: .fit)
                                .padding(.trailing, 5)
                                .frame(maxHeight: .infinity, alignment: .bottomLeading)
                        }
                        .transition(.blurWithoutScale)
                }
                else if planner_TimelineBubbles{

                    if !isPreviousSlotLoop() && !isNextSlotLoop(){

                        Image(isNextSlotLoop() ?  "timelineViewAssets/circle-normalLine-to-loopLine" : "timelineViewAssets/circle-normalLine-to-normalLine")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: widthBubble)
                            .foregroundStyle(LinearGradient(gradient: Gradient(stops: [.init(color: color1.opacity(timeSlot.muted ? 0.4 : 1), location: 0.81), .init(color: color1Next, location: 1.00)]), startPoint: .top, endPoint: .bottom))
                            .opacity(timeSlot.muted ? 0.4 : 1)
                            .overlay{
                                Image(systemName: "circle")
                                    .font(.system(size: widthBubble / 3.3))

                                    .foregroundColor(brightness1 > 0.73 ? color1.darken(by: 0.5).opacity(timeSlot.muted ? 0.3 : 1) : timeSlot.muted ? color1.darken(by: 0.5).opacity(0.3) : Color.white)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .aspectRatio(CGSize(width: 1, height: 1), contentMode: .fit)

                                    .padding(.trailing, 5)
                                    .padding(.bottom,  isNextSlotLoop() ?  3.4 : 0 )
                                    .frame(maxHeight: .infinity, alignment: .center)
                            }
                            .transition(.blurWithoutScale)
                    }
                    else if isPreviousSlotLoop() && !isNextSlotLoop() {
                        Image("timelineViewAssets/circle-loopLine-to-NormalLine")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: widthBubble)


                            .foregroundStyle(LinearGradient(gradient: Gradient(stops: [.init(color: color1Prev, location: 0.07),.init(color: color1.opacity(timeSlot.muted ? 0.4 : 1), location: 0.13), .init(color: color1.opacity(timeSlot.muted ? 0.4 : 1), location: 0.81), .init(color: color1Next, location: 1.00)]), startPoint: .top, endPoint: .bottom))
                            .opacity(timeSlot.muted ? 0.4 : 1)
                        //                        .frame(height: 78)
                        //                        .clipped()
                            .overlay{
                                Image(systemName: "circle")
                                    .font(.system(size: widthBubble / 3.3))

                                    .foregroundColor(brightness1 > 0.73 ? color1.darken(by: 0.5).opacity(timeSlot.muted ? 0.3 : 1) : timeSlot.muted ? color1.darken(by: 0.5).opacity(0.3) : Color.white)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .aspectRatio(CGSize(width: 1, height: 1), contentMode: .fit)
                                    .padding(.trailing, 5)
                                    .padding(.top, 3.4)
                                    .frame(maxHeight: .infinity, alignment: .center)
                            }
                            .transition(.blurWithoutScale)
                    }
                    else if  isNextSlotLoop() && isPreviousSlotLoop(){
                        Image("timelineViewAssets/circle-loopLine-to-loopLine")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: widthBubble)


                            .foregroundStyle(LinearGradient(gradient: Gradient(stops: [.init(color: color1Prev, location: 0.07),.init(color: color1.opacity(timeSlot.muted ? 0.4 : 1), location: 0.13), .init(color: color1.opacity(timeSlot.muted ? 0.4 : 1), location: 0.81), .init(color: color1Next, location: 1.00)]), startPoint: .top, endPoint: .bottom))
                            .opacity(timeSlot.muted ? 0.4 : 1)
                        //                        .frame(height: 78)
                        //                        .clipped()
                            .overlay{
                                Image(systemName: "circle")
                                    .font(.system(size: widthBubble / 3.3))

                                    .foregroundColor(brightness1 > 0.73 ? color1.darken(by: 0.5).opacity(timeSlot.muted ? 0.3 : 1) : timeSlot.muted ? color1.darken(by: 0.5).opacity(0.3) : Color.white)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .aspectRatio(CGSize(width: 1, height: 1), contentMode: .fit)
                                    .padding(.trailing, 5)
                                    .padding(.top, 3.4)
                                    .frame(maxHeight: .infinity, alignment: .center)
                            }
                            .transition(.blurWithoutScale)
                    }
                    else{
                        Image("timelineViewAssets/circle-normalLine-to-loopLine")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: widthBubble)


                            .foregroundStyle(LinearGradient(gradient: Gradient(stops: [.init(color: color1.opacity(timeSlot.muted ? 0.4 : 1), location: 0.13), .init(color: color1.opacity(timeSlot.muted ? 0.4 : 1), location: 0.81), .init(color: color1Next, location: 1.00)]), startPoint: .top, endPoint: .bottom))
                            .opacity(timeSlot.muted ? 0.4 : 1)
                        //                        .frame(height: 78)
                        //                        .clipped()
                            .overlay{
                                Image(systemName: "circle")
                                    .font(.system(size: widthBubble / 3.3))

                                    .foregroundColor(brightness1 > 0.73 ? color1.darken(by: 0.5).opacity(timeSlot.muted ? 0.3 : 1) : timeSlot.muted ? color1.darken(by: 0.5).opacity(0.3) : Color.white)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .aspectRatio(CGSize(width: 1, height: 1), contentMode: .fit)
                                    .padding(.trailing, 5)
                                    .padding(.bottom, 3.4)
                                    .frame(maxHeight: .infinity, alignment: .center)
                            }

                            .transition(.blurWithoutScale)
                    }
                }
                VStack(alignment: .leading, spacing: 4){
                    HStack{
                        Text("Empty Entry")
                            .textCase(.uppercase)
                            .font(.body.weight(.semibold))
                            .lineLimit(1)

                        Spacer()

                        if let currentSlotStartTime = timeSlot.startTime,
                           let nextSlotStartTime = timeSlotNext.startTime,
                           let nextSlotEndTime = timeSlotNext.endTime,
                           let currentSlotStartDate = TimeFormatter.toDate(currentSlotStartTime, mode: .time),
                           let nextSlotStartDate = TimeFormatter.toDate(nextSlotStartTime, mode: .time),
                           let nextSlotEndDate = TimeFormatter.toDate(nextSlotEndTime, mode: .time),
                           currentSlotStartDate == nextSlotStartDate /*|| currentSlotStartDate < nextSlotEndDate */, timeSlot != timeSlotNext {

                            Image(systemName: "exclamationmark.triangle")
                                .transition(.blur.animation(.smooth))
                        }
                        else if let currentSlotStartTime = timeSlot.startTime,
                                let prevSlotStartTime = timeSlotPrev.startTime,
                                let prevSlotEndTime = timeSlotPrev.endTime,
                                let currentSlotStartDate = TimeFormatter.toDate(currentSlotStartTime, mode: .time),
                                let prevSlotStartDate = TimeFormatter.toDate(prevSlotStartTime, mode: .time),
                                let prevSlotEndDate = TimeFormatter.toDate(prevSlotEndTime, mode: .time),
                                ((currentSlotStartDate == prevSlotStartDate || currentSlotStartDate < prevSlotEndDate) && index != 0 ) {

                            Image(systemName: "exclamationmark.triangle")
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
                            Spacer()

                            if showLength{
                                let number = differenceBetween((timeSlot.startTime ?? ""), (timeSlot.endTime ?? ""))
                                let roundedNumber = decimalToFraction(number)
                                Text(roundedNumber + "\(differenceBetween((timeSlot.startTime ?? ""), (timeSlot.endTime ?? "")) > 1 ? " hrs" : " hr")")
                                    .textCase(.uppercase)
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
                        }.textCase(.uppercase)
                            .animation(.smooth)

                    case .today:
                        Group{
                            Text("State Error")
                                .font(.footnote.weight(.regular))
                        }

                    default:
                        EmptyView()
                    }




                    if (timeSlot.room != "" || timeSlot.taughtBy != nil) && !editMode && showDetails{
                        Divider()
                            .padding(.vertical, 2)
                            .tint(colorScheme == .dark ? color1.darken(by: -0.5) : color1.darken(by: 0.5))

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
                                .textCase(.uppercase)
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
                .foregroundStyle(colorScheme == .dark ? color1.darken(by: -0.5) : color1.darken(by: 0.5))
                .frame(maxHeight: planner_TimelineBubbles ? widthBubble * 0.97 : .infinity)
                .frame(maxHeight: .infinity, alignment: index == 0 ? .top : timeSlot == timeSlotNext ? .bottom : .center)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 28)
        .padding(.top, index == 0 ? 16 : 0)
        .padding(.bottom, timeSlot == timeSlotNext ? 12 : 0)
        .padding(.vertical, isCurrentSlotLoop() ? 10 : 0)
        .contentShape(Rectangle())

        .contextMenu {
            if timeSlot.classEntity != nil || timeSlot.splitterEntity != nil {

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
                        Group{
                            Text("^[\(totalTasks.count) Task](inflect: true)")
                            + Text(", for \(timeSlot.classEntity?.name ?? "Untitled Class")")

                        }
                    }
                }

                Button {
                    shownTimeSlot = timeSlot
                } label: {
                    Label("Edit", systemImage: "pencil")
                }
//
//                Button {
//                    withAnimation(.bouncy){
//                        timeSlot.muted.toggle()
//                    }
//                    do {
//                        try viewContext.save()
//                    } catch {
//                        let nsError = error as NSError
//                        fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//                    }
//                } label: {
//                    Label(timeSlot.muted ? "Unmute" : "Mute", systemImage: timeSlot.muted ? "bell" : "bell.slash")
//                }

                    Button {
                        let dataFactory = knDataFactory()
                        dataFactory.duplicateTimeSlot(timeSlot: timeSlot, startTime: TimeFormatter.toDate(timeSlot.endTime!, mode: .fullDate) ?? Date(), endTime: Calendar.current.date(byAdding: .minute, value: Int(lastClassDuration * 60) , to: (TimeFormatter.toDate(timeSlot.endTime!, mode: .fullDate) ?? Date())) ?? Date())
                    } label: {
                        Label("Duplicate", systemImage: "square.on.square")
                    }

//                    Button {
//
//                    } label: {
//                        Label("Share", systemImage: "square.and.arrow.up")
//                    }

                    Button(role: .destructive) {
                        confirmDelete.toggle()
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }

            }
            else{
                    Button {
                        shownTimeSlot = timeSlot
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }


                     Button(role: .destructive) {
                         confirmDelete.toggle()
                     } label: {
                         Label("Delete", systemImage: "trash")
                     }

            }
        }
        .padding(.top, index == 0 ? -16 : 0)
        .padding(.bottom, timeSlot == timeSlotNext ? -12 : 0)
        .padding(.vertical, isCurrentSlotLoop() ? -10 : 0)
        .zIndex(isCurrentSlotLoop() ? 0 : 1)
        .contentShape(Rectangle())
        .onTapGesture {
            
//            withAnimation{
//                viewTimeSlot = timeSlot
//            }
        }

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
        .onChange(of: timeSlot.startTime){ changed in
            getState()
            if currentState == .past{
                self.timer.upstream.connect().cancel()
            }
        }
        .onChange(of: timeSlot.endTime){ changed in
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
                    do {
                        try viewContext.save()
                        print("deleted week entry")
                    } catch {
                        let nsError = error as NSError
                        fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                    }
                }
                        })
            Button("Cancel", role: .cancel) { }

                    }
    }
    private func isPreviousSlotLoop() -> Bool{
        return timeSlotPrev.splitterEntity?.type == SplitterType.divider.rawValue
    }

    private func isCurrentSlotLoop() -> Bool{
        return timeSlot.splitterEntity?.type == SplitterType.divider.rawValue
    }

    private func isNextSlotLoop() -> Bool{
        return timeSlotNext.splitterEntity?.type == SplitterType.divider.rawValue
    }

    func getState() {
        if timeSlot.day?.name == TimeFormatter.getDayCode(date: Date()) || schedule_SingleDayMode {
            withAnimation(.smoothCard) {
                self.currentState = TimeHelper.getTimeState(startTime: timeSlot.startTime ?? "00:00", endTime: timeSlot.endTime ?? "00:01")
            }

            if TimeHelper.getRemainingMinutes(for: timeSlot.endTime ?? "01:00") > 8.0 {
                print("Adjusting state timer refresh to longer interval")
                changeTimerInterval(to: 300) // Change interval to 5 minutes
            } else {
                if timer.upstream.interval != 1 {
                    print("Adjusting timer refresh to shorter interval")
                    changeTimerInterval(to: 1) // Change interval back to 1 second if not already
                }
            }
        }
    }

    func changeTimerInterval(to interval: TimeInterval) {
        timer.upstream.connect().cancel() // Cancel the existing timer
        timer = Timer.publish(every: interval, on: .main, in: .common).autoconnect() // Create a new timer with the specified interval
    }
}
