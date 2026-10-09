//
//  Task Widgets.swift
//  KyoNeo
//
//  Created by Aether on 07/08/2023.
//


#if canImport(WidgetKit)
import SwiftUI
import CoreData
import WidgetKit

struct taskProvider: TimelineProvider {
    let debug = true
    let viewContext = PersistenceController.shared.container.viewContext

    func fetchTasks(context: NSManagedObjectContext) -> NSFetchRequest<TaskEntity> {
        let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        request.sortDescriptors = [
            //            NSSortDescriptor(keyPath: \TimeSlot.day?.week?.number, ascending: true),
            //            NSSortDescriptor(keyPath: \TimeSlot.day?.number, ascending: true),
            NSSortDescriptor(keyPath: \TaskEntity.due, ascending: true)
        ]
        //
        //        // Filter based on the day name
        //        let dayPredicate = NSPredicate(format: "day.name == %@", dayName)
        //
        //        // Filter based on the week number
        //        let weekPredicate = NSPredicate(format: "day.week.number == %d", weekNumber)
        //
        //        // Combine the day and week predicates using AND
        //        let compoundPredicate = NSCompoundPredicate(type: .and, subpredicates: [dayPredicate, weekPredicate])
        //
        //        request.predicate = compoundPredicate
        print("fetched tasks!")
        //
        return request
    }

    func placeholder(in context: Context) -> TaskEntry {
        return TaskEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (TaskEntry) -> ()) {


        do {
            let tasks = try viewContext.fetch(fetchTasks(context: viewContext))
            let newEntry = TaskEntry(date: Date(), tasks: tasks)

            completion(newEntry)
        }
        catch{

        }





    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TaskEntry>) -> ()) {
        var entries: [TaskEntry] = []

        do {
            let tasks = try viewContext.fetch(fetchTasks(context: viewContext))
            let newEntry = TaskEntry(date: Date(), tasks: tasks)
            entries.append(newEntry)
        }
        catch{

        }

        let timeline = Timeline(entries: entries, policy: .never)

        completion(timeline)


    }
}


struct TasksWidget : View {
    var entry: taskProvider.Entry
    @Environment(\.widgetFamily) var family

    @AppStorage("global_breakMode", store: UserDefaults(suiteName: "group.com.example.kyoarchive")) var global_breakMode: Bool = false

    var body: some View {
        if !global_breakMode{
        VStack(alignment: .leading, spacing: 0){

            if family == .systemSmall || family == .systemMedium || family == .systemLarge{
                HStack{
                    Text("Tasks")
                        .font((family == .systemMedium ? Font.headline : Font.body).weight(.semibold))
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(1)
                    Spacer()
                    Text(entry.tasks.count, format: .number)
                        .font((family == .systemMedium ? Font.headline : Font.headline).weight(.semibold))
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(1)
                }
                .padding(.bottom,4.8)
            }
            if family == .systemSmall || family == .systemMedium || family == .systemLarge && !entry.tasks.isEmpty{
                ViewThatFits(in: .vertical, content: {
                    VStack(spacing: 0){
                        let filteredTasks = entry.tasks.prefix(7)
                        ForEach(filteredTasks, id: \.id){ task in
                            VStack{
                                HStack(spacing: 7){
                                    Text(Image(systemName: "circle"))
                                        .font(.system(size: 22))
                                        .opacity(0.6)

                                    VStack(alignment: .leading){
                                        Text(task.label ?? "Untitled task")
                                            .font(.footnote)
                                            .lineLimit(1)
                                            .frame(maxWidth: .infinity, alignment: .leading)

                                    }
                                }
                            }
                            .frame(maxHeight: .infinity, alignment: .center)
                            if task != filteredTasks.last{
                                Divider()
                                    .padding(.leading, 35)
                                    .padding(.vertical, 3)
                            }

                        }
                        //                    ForEach(0...abs((filteredTasks.count - 8)), id: \.self){ taskTemp in
                        //                        VStack{
                        //                        }
                        //
                        //                        .frame(maxHeight: .infinity, alignment: .center)
                        //                    }
                    }
                    VStack(spacing: 0){
                        let filteredTasks = entry.tasks.prefix(8)
                        ForEach(filteredTasks, id: \.id){ task in
                            VStack{
                                HStack(spacing: 7){
                                    Text(Image(systemName: "circle"))
                                        .font(.system(size: 22))
                                        .opacity(0.6)

                                    VStack(alignment: .leading){
                                        Text(task.label ?? "Untitled task")
                                            .font(.footnote)
                                            .lineLimit(1)
                                            .frame(maxWidth: .infinity, alignment: .leading)

                                    }
                                }
                            }
                            .frame(maxHeight: .infinity, alignment: .center)
                            if task != filteredTasks.last{
                                Divider()
                                    .padding(.leading, 35)
                                    .padding(.vertical, 3)
                            }

                        }

                    }
                    VStack(spacing: 0){
                        let filteredTasks = entry.tasks.prefix(6)
                        ForEach(filteredTasks, id: \.id){ task in
                            VStack{
                                HStack(spacing: 7){
                                    Text(Image(systemName: "circle"))
                                        .font(.system(size: 22))
                                        .opacity(0.6)

                                    VStack(alignment: .leading){
                                        Text(task.label ?? "Untitled task")
                                            .font(.footnote)
                                            .lineLimit(1)
                                            .frame(maxWidth: .infinity, alignment: .leading)

                                    }
                                }
                            }
                            .frame(maxHeight: .infinity, alignment: .center)
                            if task != filteredTasks.last{
                                Divider()
                                    .padding(.leading, 35)
                                    .padding(.vertical, 3)
                            }

                        }

                    }
                    VStack(spacing: 0){
                        let filteredTasks = entry.tasks.prefix(4)
                        ForEach(filteredTasks, id: \.id){ task in
                            VStack{
                                HStack(spacing: 7){
                                    Text(Image(systemName: "circle"))
                                        .font(.system(size: 22))
                                        .opacity(0.6)

                                    VStack(alignment: .leading){
                                        Text(task.label ?? "Untitled task")
                                            .font(.footnote)
                                            .lineLimit(1)
                                            .frame(maxWidth: .infinity, alignment: .leading)

                                    }
                                }
                            }
                            .frame(maxHeight: .infinity, alignment: .center)
                            if task != filteredTasks.last{
                                Divider()
                                    .padding(.leading, 35)
                                    .padding(.vertical, 3)
                            }

                        }

                    }

                    VStack(spacing: 0){
                        let filteredTasks = entry.tasks.prefix(3)
                        ForEach(filteredTasks, id: \.id){ task in
                            VStack{
                                HStack(spacing: 7){
                                    Text(Image(systemName: "circle"))
                                        .font(.system(size: 22))
                                        .opacity(0.6)

                                    VStack(alignment: .leading){
                                        Text(task.label ?? "Untitled task")
                                            .font(.footnote)
                                            .lineLimit(1)
                                            .frame(maxWidth: .infinity, alignment: .leading)

                                    }
                                }
                            }
                            .frame(maxHeight: .infinity, alignment: .center)
                            if task != filteredTasks.last{
                                Divider()
                                    .padding(.leading, 35)
                                    .padding(.vertical, 3)
                            }

                        }



                    }
                })
                .padding(.bottom,1)
            }
            else if entry.tasks.isEmpty{
                VStack(alignment: .leading){
                    Text("No Tasks")
                        .font(.body)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)

                }
                .frame(maxHeight: .infinity, alignment: .center)
            }
#if os(iOS) || os(visionOS)
            if family == .accessoryRectangular{
                let filteredTasks = entry.tasks.prefix(2)
                ForEach(filteredTasks, id: \.id){ task in
                    VStack{
                        HStack(spacing: family == .accessoryRectangular ? 10 : 7){
                            Text(Image(systemName: "circle"))
                                .font(.system(size: 17))
                                .opacity(0.6)

                            VStack(alignment: .leading){
                                Text(task.label ?? "Untitled task")
                                    .font(.body)
                                    .lineLimit(1)
                                    .frame(maxWidth: .infinity, alignment: .leading)

                            }
                        }
                    }
                    .frame(maxHeight: .infinity, alignment: .center)

                }
            }
#endif




        }
#if os(iOS) || os(visionOS)
        .padding(.vertical , family == .accessoryRectangular ? 1.5 : family == .systemSmall ? 8: 11)
        .padding(.top , family == .accessoryRectangular ? 0 : 3)
        .padding(.horizontal, family == .accessoryRectangular ? 2 : family == .systemSmall ? 13 : 16)
#endif
        .frame(maxWidth: .infinity, alignment: .leading)
    }
        else{
            GeometryReader { GeometryProxy in
                                         VStack{
                                             HStack{
                                                 // Umbrella Icon from SF Symbols
                                                 Image(systemName: "sun.max.fill")
                                                 // Umbrella Icon from SF Symbols
                                                 Image(systemName: "beach.umbrella")
                                                 // Umbrella Icon from SF Symbols
                                                 Image(systemName: "snowflake")
                                                 // Umbrella Icon from SF Symbols
                                                 Image(systemName: "car.side")
                                             }
                                             .font(.system(size: 35))
                                             .frame(width: GeometryProxy.size.width, height: 30)

                                             // Description
                                             Text("Widgets are disabled\nin break mode.")
                                                 .padding(.horizontal, -10)
                                                 .font(.caption)
                                                 .padding(.top, 20)
                                                 .bold()
                                         }
                                         .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)

                                     }
        }
    }

}

struct TaskWidget: Widget {
    let kind: String = "TaskListWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: taskProvider()) { entry in
            if #available(macOS 14.0, iOS 17.0, *) {
                TasksWidget(entry: entry)
                    .containerBackground(Color(hex: "F2AC9B").gradient, for: .widget)

            } else {
                TasksWidget(entry: entry)
            }
        }
       
        .configurationDisplayName("Upcoming Tasks")
        .description("Displays current or upcoming tasks")
        #if !os(macOS)
        .supportedFamilies(
            [
                .systemSmall,
                .systemMedium,
                    .systemLarge,
                .accessoryRectangular,
                .accessoryInline])
        #else

        .supportedFamilies(
            [
                .systemSmall,
                .systemMedium,
                    .systemLarge,
            ])
        #endif
    }
}


struct TaskEntry: TimelineEntry {
    let date: Date
    var tasks: [TaskEntity] = []
}


struct taskCountsProvider: TimelineProvider {
    let debug = true
    let viewContext = PersistenceController.shared.container.viewContext

    func fetchTasks(context: NSManagedObjectContext) -> NSFetchRequest<TaskEntity> {
        let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        request.sortDescriptors = [
            //            NSSortDescriptor(keyPath: \TimeSlot.day?.week?.number, ascending: true),
            //            NSSortDescriptor(keyPath: \TimeSlot.day?.number, ascending: true),
            NSSortDescriptor(keyPath: \TaskEntity.due, ascending: true)
        ]
        //
        //        // Filter based on the day name
        //        let dayPredicate = NSPredicate(format: "day.name == %@", dayName)
        //
        //        // Filter based on the week number
        //        let weekPredicate = NSPredicate(format: "day.week.number == %d", weekNumber)
        //
        //        // Combine the day and week predicates using AND
        //        let compoundPredicate = NSCompoundPredicate(type: .and, subpredicates: [dayPredicate, weekPredicate])
        //
        //        request.predicate = compoundPredicate
        print("fetched tasks!")
        //
        return request
    }

    func placeholder(in context: Context) -> TaskCountEntry {
        return TaskCountEntry(date: Date(), overdueCount: 2, todayCount: 0, upcomingCount: 10, completedCount: 4)
    }

    func getSnapshot(in context: Context, completion: @escaping (TaskCountEntry) -> ()) {

        var overdueCount: Int = 0
        var todayCount: Int = 0
        var upcomingCount: Int = 0
        var completedCount: Int = 0

        do {
            let tasks = try viewContext.fetch(fetchTasks(context: viewContext))
            for task in tasks{
                let state = TimeHelper.getTaskTimeState(task: task)
                switch state {
                case .completed:
                    completedCount+=1
                case .overdue:
                    overdueCount+=1
                case .today:
                    todayCount+=1
                case .upcoming:
                    upcomingCount+=1
//                case .all:
//                    print("x")
                }
            }

        }
        catch{

        }

        let finalEntry = TaskCountEntry(date: Date(), overdueCount: overdueCount, todayCount: todayCount, upcomingCount: upcomingCount, completedCount: completedCount)
        completion(finalEntry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TaskCountEntry>) -> ()) {
        var entries: [TaskCountEntry] = []

        var overdueCount: Int = 0
        var todayCount: Int = 0
        var upcomingCount: Int = 0
        var completedCount: Int = 0

        do {
            let tasks = try viewContext.fetch(fetchTasks(context: viewContext))
            for task in tasks{
                let state = TimeHelper.getTaskTimeState(task: task)
                switch state {
                case .completed:
                    completedCount+=1
                case .overdue:
                    overdueCount+=1
                case .today:
                    todayCount+=1
                case .upcoming:
                    upcomingCount+=1
//                case .all:
//                    print("x")
                }
            }

        }
        catch{

        }

        let finalEntry = TaskCountEntry(date: Date(), overdueCount: overdueCount, todayCount: todayCount, upcomingCount: upcomingCount, completedCount: completedCount)
        entries.append(finalEntry)
        let timeline = Timeline(entries: entries, policy: .never)

        completion(timeline)
    }
}

struct TaskCountEntry: TimelineEntry {
    let date: Date
    var overdueCount: Int
    var todayCount: Int
    var upcomingCount: Int
    var completedCount: Int
}
#if !os(macOS)
struct TaskCountWidget: Widget {
    let kind: String = "TaskCountWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: taskCountsProvider()) { entry in
            if #available(macOS 14.0, iOS 17.0, *) {
                TaskCountWidgetView(entry: entry)
                    .containerBackground(Color(hex: "F2AC9B").gradient, for: .widget)

            } else {
                TaskCountWidgetView(entry: entry)
            }
        }
        .contentMarginsDisabled()
        .configurationDisplayName("Task Count")
        .description("Displays a summary of tasks, including overdue, upcoming, today and completed ones, with customizable options.")
        .supportedFamilies([.accessoryRectangular, .accessoryInline])
    }
}
#endif

struct TaskCountWidgetView : View {
    var entry: taskCountsProvider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View{
        switch family {
        case .accessoryRectangular:
            VStack(spacing: 4){
                HStack{
                    Image(systemName: taskTimeState.overdue.symbol)
                        .scaledFrame(width: 11, height: nil, relativeTo: .caption2, alignment: .center)
                    Text("OVR")
                        .lineLimit(1)
                        .scaledFrame(width: 33, height: nil, relativeTo: .body, alignment: .leading)
                    Text(entry.overdueCount, format: .number)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                HStack{
                    Image(systemName: taskTimeState.upcoming.symbol)
                        .scaledFrame(width: 11, height: nil, relativeTo: .caption2, alignment: .center)
                    Text("UPC")
                        .lineLimit(1)
                        .scaledFrame(width: 33, height: nil, relativeTo: .body, alignment: .leading)
                    Text(entry.upcomingCount, format: .number)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                HStack{
                    Image(systemName: taskTimeState.completed.symbol)
                        .scaledFrame(width: 11, height: nil, relativeTo: .caption2, alignment: .center)
                    Text("CMP")
                        .lineLimit(1)
                        .scaledFrame(width: 33, height: nil, relativeTo: .body, alignment: .leading)

                    Text(entry.completedCount, format: .number)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            .font(.callout)
            .padding(1.3)

        case .accessoryInline:
            Group{
                Text(Image(systemName: taskTimeState.overdue.symbol))
                +
                Text(entry.overdueCount, format: .number)
                +
                Text(" ")
                +
                Text(Image(systemName: taskTimeState.upcoming.symbol))
                +
                Text(entry.upcomingCount, format: .number)
                +
                Text(" ")
                +
                Text(Image(systemName: taskTimeState.completed.symbol))
                +
                Text(entry.completedCount, format: .number)
            }
        default:
            Text("Not Supported")
        }
    }
}
#endif
