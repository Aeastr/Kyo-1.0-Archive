//
//  kn_DataFactory .swift
//  KyoNeo
//
//  Created by Aether on 07/04/2023.
//

import SwiftUI
import CoreData

struct knDataFactory{
    var context: NSManagedObjectContext {
            PersistenceController.shared.container.viewContext
    }
    @Binding var selectedID: UUID?

    init(selectedID: Binding<UUID?> = .constant(nil)) {
        self._selectedID = selectedID
    }

    var timeslots: [TimeSlot] {
            let request: NSFetchRequest<TimeSlot> = TimeSlot.fetchRequest()
            let sort = NSSortDescriptor(key: "timestamp", ascending: true)
            request.sortDescriptors = [sort]
            do {
                return try context.fetch(request)
            } catch {
                print("Error fetching timeslots: \(error.localizedDescription)")
                return []
            }
        }

        var classes: [ClassEntity] {
            let request: NSFetchRequest<ClassEntity> = ClassEntity.fetchRequest()
            let sort = NSSortDescriptor(key: "name", ascending: true)
            request.sortDescriptors = [sort]
            do {
                return try context.fetch(request)
            } catch {
                print("Error fetching classes: \(error.localizedDescription)")
                return []
            }
        }

        var splitters: [SplitterEntity] {
            let request: NSFetchRequest<SplitterEntity> = SplitterEntity.fetchRequest()
            let sort = NSSortDescriptor(key: "name", ascending: true)
            request.sortDescriptors = [sort]
            do {
                return try context.fetch(request)
            } catch {
                print("Error fetching splitters: \(error.localizedDescription)")
                return []
            }
        }

    var teachers: [TeacherEntity] {
        let request: NSFetchRequest<TeacherEntity> = TeacherEntity.fetchRequest()
        let sort = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [sort]
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching splitters: \(error.localizedDescription)")
            return []
        }
    }


    /**
     Adds a new time slot to the schedule with the specified attributes.

     - Parameters:
     - dayEntity: The `Day` object for the day on which the time slot occurs.
     - classEntity: The `ClassEntity` object for the class associated with the time slot, if any.
     - splitterEntity: The `SplitterEntity` object for the splitter associated with the time slot, if any.
     - room: The room number or location of the time slot.
     - startTime: The start time of the time slot.
     - endTime: The end time of the time slot.
     - debug: If `true`, print debug information to the console.

     If `debug` is `true`, debug logs will be printed to the console to help with debugging. If `debug` is `false` (the default), no debug logs will be printed.

     - Note: Only one of `classEntity` and `splitterEntity` should be non-nil. If both are non-nil or both are nil, a precondition failure will occur.
     */

    func testdel(obj: NSManagedObject){
        context.delete(obj)
    }
    func addTimeSlot(
        dayEntity: Day,
        classEntity: ClassEntity?,
        splitterEntity: SplitterEntity?,
        room: String,
        teacher: TeacherEntity? = nil,
        startTime: Date,
        endTime: Date,
        notes: String? = nil,
        debug: Bool = false) {

            log("[[knDF, CreateTS]]: dayEntity.week.id = \(dayEntity.week?.id?.uuidString ?? "nil")", debug: debug)


        log("[[knDF, CreateTS]]: Adding new TimeSlot entity", debug: debug)

        // Check that only one of classEntity and splitterEntity is non-nil
        precondition((classEntity == nil && splitterEntity != nil) || (classEntity != nil && splitterEntity == nil), "Class entity and splitter entity cannot both be nil or both be non-nil")
        log("[[knDF, CreateTS]]: Checked that only one of classEntity and splitterEntity is non-nil", debug: debug)
        
        // Create a new TimeSlot object and set its attributes
        let item = TimeSlot(context: context)
        log("[knDF, CreateTS]: Created new TimeSlot object", debug: debug)
        item.id = UUID()
        log("[knDF, CreateTS]: Set TimeSlot ID", debug: debug)
        item.day = dayEntity
        log("[knDF, CreateTS]: Set TimeSlot day to \(dayEntity)", debug: debug)
            if let teacher = teacher{
                item.taughtBy = teacher
                log("[knDF, CreateTS]: Set teacher to \(teacher.name ?? "No Name")", debug: debug)
            }
            else{
                item.taughtBy = nil
            }

//            if let teacher = teacher{
//                if teacher != ""{
//                    item.teacher = teacher
//                    log("[knDF, CreateTS]: Set teacher to \(teacher)", debug: debug)
//                }
//                else{
//                    item.teacher = nil
//                }
//            }

        item.room = room
        log("[knDF, CreateTS]: Set TimeSlot room to \(room)", debug: debug)
            if let notes = notes{
                item.notes = notes
                log("[knDF, CreateTS]: Set TimeSlot notes to \(notes)", debug: debug)
            }
        item.startTime = TimeFormatter.getTimeString(startTime)
        log("[knDF, CreateTS]: Set TimeSlot start time to \(TimeFormatter.getTimeString(startTime))", debug: debug)
        item.endTime = TimeFormatter.getTimeString(endTime)
        log("[knDF, CreateTS]: Set TimeSlot end time to \(TimeFormatter.getTimeString(endTime))", debug: debug)
        item.timestamp = TimeFormatter.toDate(TimeFormatter.getTimeString(startTime), mode: .time)
        log("[knDF, CreateTS]: Set TimeSlot timestamp to \(TimeFormatter.toDate(TimeFormatter.getTimeString(startTime), mode: .time))", debug: debug)

        // Set the classEntity or splitterEntity, if applicable
        if let classEntity = classEntity {
            item.classEntity = classEntity
            log("[knDF, CreateTS]: Added and Assigned TimeSlot to ClassEntity \(classEntity)", debug: debug)
            classEntity.addToTimeSlot(item)
        }

        if let splitterEntity = splitterEntity {
            item.splitterEntity = splitterEntity
            log("[knDF, CreateTS]: Added TimeSlot to SplitterEntity", debug: debug)
            splitterEntity.addToTimeSlot(item)
        }
        log("[knDF, CreateTS]: Set TimeSlot classEntity and splitterEntity, if applicable", debug: debug)

        dayEntity.addToTimeSlots(item)
        log("[knDF, CreateTS]: Added TimeSlot to Day", debug: debug)
            if let teacher = teacher{
                teacher.addToTeachingTimeSlots(item)
                log("[knDF, CreateTS]: Added TimeSlot to Teacher", debug: debug)
            }

        log("[knDF, CreateTS]: New TimeSlot entity created with attributes: \(item)", debug: debug)
           
      

            log("[[knDF, CreateTS]]: Updated dayEntity.week.id = \(dayEntity.week?.id?.uuidString ?? "nil")", debug: debug)

    }

    /**
    Updates the provided timeSlot object in Core Data, setting its attributes to the given values. If a classEntity or splitterEntity is provided, the timeSlot is added to it and vice versa. If the provided timeSlot is not nil, it is updated; otherwise, a new TimeSlot is created.
    - Parameters:
        - timeSlot: The TimeSlot object to be updated. If nil, a new TimeSlot is created instead.
        - dayEntity: The Day object to which the TimeSlot belongs.
        - classEntity: The ClassEntity object to which the TimeSlot belongs, if applicable.
        - splitterEntity: The SplitterEntity object to which the TimeSlot belongs, if applicable.
        - room: The room where the class takes place.
        - startTime: The start time of the class.
        - endTime: The end time of the class.
        - debug: Whether to print debug logs (default is false).
        - context: The NSManagedObjectContext in which the TimeSlot should be updated or created.
    */

    func updateTimeSlot(
        timeSlot: TimeSlot?,
        dayEntity: Day,
        classEntity: ClassEntity?,
        splitterEntity: SplitterEntity?,
        room: String,
        teacher: TeacherEntity? = nil,
        startTime: Date,
        endTime: Date,
        notes: String? = nil,
        debug: Bool = false,
        dispatchGroup: DispatchGroup? = nil
    ) {
        print("--[knDF]--")
//        guard let item = timeSlot,
//                  let previousDay = item.day,
//                  let previousRoom = item.room,
//                  let previousStartTime = item.startTime,
//                  let previousEndTime = item.endTime,
//              let previousTeacher = item.teacher,
//                  (previousDay == dayEntity || previousRoom == room || previousStartTime == TimeFormatter.getTimeString(startTime) || previousEndTime == TimeFormatter.getTimeString(endTime) || item.classEntity == classEntity || item.splitterEntity == splitterEntity || previousTeacher == teacher)
//            else {
//            log("[knDF, UpdateTS]: No updates needed \(timeSlot?.teacher) \(teacher)", debug: debug)
//                return
//            }
            if let day = timeSlot?.day{
                if let timeSlot = timeSlot{
                    day.removeFromTimeSlots(timeSlot)
                }
            }
            for t in timeslots{
                if t == timeSlot?.splitterEntity{
                    context.delete(t)
                    log("[knDF, UpdateTS]: Removed TimeSlot from SplitterEntity: \(t)", debug: debug)
                }
            }
            print(" ")
            for c in classes{
                if c == timeSlot?.classEntity{
                    if let itemToRemove = timeSlot{
                        c.removeFromTimeSlot(itemToRemove)
                        log("[knDF, UpdateTS]: Removed TimeSlot \(itemToRemove) from ClassEntity with name \(c.name) and ID \(c.id?.uuidString) ", debug: debug)
                    }
                }
            }

        for teacher in teachers{
            if teacher == timeSlot?.taughtBy{
                if let itemToRemove = timeSlot{
                    teacher.removeFromTeachingTimeSlots(itemToRemove)
                    log("[knDF, UpdateTS]: Removed TimeSlot \(itemToRemove) from teacher with name \(teacher.name) and ID \(teacher.id?.uuidString) ", debug: debug)
                }
            }
        }

            for s in splitters{
                if s == timeSlot?.splitterEntity{
                    if let itemToRemove = timeSlot{
                        s.removeFromTimeSlot(itemToRemove)
                        log("[knDF, UpdateTS]: Removed TimeSlot \(itemToRemove) from SplitterEntity: \(s)", debug: debug)
                    }
                }
            }

        log("[knDF, UpdateTS]: Updating existing TimeSlot entity", debug: debug)

        // Check that only one of classEntity and splitterEntity is non-nil
        precondition((classEntity == nil && splitterEntity != nil) || (classEntity != nil && splitterEntity == nil), "Class entity and splitter entity cannot both be nil or both be non-nil")
        log("[knDF, UpdateTS]: Checked that only one of classEntity and splitterEntity is non-nil", debug: debug)

        // Create a new TimeSlot object and set its attributes
        if let item = timeSlot{
            log("[knDF, UpdateTS]: Set TimeSlot object to \(item)", debug: debug)
            log("[knDF, UpdateTS]: Set TimeSlot day to \(dayEntity.id?.uuidString), where day is in \(dayEntity.week?.number ?? 0), old day was \(item.day?.id?.uuidString)", debug: debug)
            item.day = dayEntity
            

            item.room = room
            log("[knDF, UpdateTS]: Set TimeSlot room to \(room)", debug: debug)

            item.notes = notes
            log("[knDF, UpdateTS]: Set TimeSlot note to \(notes)", debug: debug)

            if let teacher = teacher{
                item.taughtBy = teacher
                log("[knDF, CreateTS]: Set teacher to \(teacher.name ?? "No Name")", debug: debug)
            }
            else{
                item.taughtBy = nil
            }

            item.startTime = TimeFormatter.getTimeString(startTime)
            log("[knDF, UpdateTS]: Set TimeSlot start time to \(TimeFormatter.getTimeString(startTime))", debug: debug)
            item.endTime = TimeFormatter.getTimeString(endTime)
            log("[knDF, UpdateTS]: Set TimeSlot end time to \(TimeFormatter.getTimeString(endTime))", debug: debug)
            item.timestamp = TimeFormatter.toDate(TimeFormatter.getTimeString(startTime), mode: .time)
            log("[knDF, UpdateTS]: Set TimeSlot timestamp to \(TimeFormatter.toDate(TimeFormatter.getTimeString(startTime), mode: .time))", debug: debug)

            // Set the classEntity or splitterEntity, if applicable
            if let classEntity = classEntity {
                item.classEntity = classEntity
                log("[knDF, UpdateTS]: Added TimeSlot to ClassEntity with name \(classEntity.name) and id \(classEntity.id?.uuidString)", debug: debug)
                classEntity.addToTimeSlot(item)
            }

            if let splitterEntity = splitterEntity {
                item.splitterEntity = splitterEntity
                log("[knDF, UpdateTS]: Added TimeSlot to SplitterEntity", debug: debug)
                splitterEntity.addToTimeSlot(item)
            }
            log("[knDF, UpdateTS]: Set TimeSlot classEntity and splitterEntity, if applicable", debug: debug)

            dayEntity.addToTimeSlots(item)
            log("[knDF, UpdateTS]: Added TimeSlot to Day", debug: debug)

            if let teacher = teacher{
                teacher.addToTeachingTimeSlots(item)
                log("[knDF, CreateTS]: Added TimeSlot to Teacher", debug: debug)
            }

            log("[knDF, UpdateTS]: New TimeSlot entity created with attributes: \(item)", debug: debug)
        }

        if let dispatchGroup = dispatchGroup{
            dispatchGroup.leave() // Signal that this task is completed
        }
        else{
            do {
                try context.save()
                log("[knDF, CreateTS]: Changes saved to Core Data", debug: debug)
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    func findWeekID(forWeekNumber weekNumber: Int) -> UUID? {
        // Perform a fetch request or query on your data source to find the week with the matching weekNumber
        let fetchRequest: NSFetchRequest<Week> = Week.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "number == %d", weekNumber)
        fetchRequest.fetchLimit = 1 // Assuming there's only one week with the given number

        do {
            let fetchedWeeks = try context.fetch(fetchRequest)
            return fetchedWeeks.first?.id
        } catch {
            print("Error fetching weeks: \(error)")
            return nil
        }
    }

    func duplicateTimeSlot(
        timeSlot: TimeSlot,
        startTime: Date,
        endTime: Date,
        debug: Bool = false) {
            if let dayEntity = timeSlot.day, let room = timeSlot.room{
            log("[[knDF, CreateTS]]: dayEntity.week.id = \(dayEntity.week?.id?.uuidString ?? "nil")", debug: debug)

            log("[[knDF, CreateTS]]: Adding new TimeSlot entity", debug: debug)
            
            // Check that only one of classEntity and splitterEntity is non-nil
                precondition((timeSlot.classEntity == nil && timeSlot.splitterEntity != nil) || (timeSlot.classEntity != nil && timeSlot.splitterEntity == nil), "Class entity and splitter entity cannot both be nil or both be non-nil")
            log("[[knDF, CreateTS]]: Checked that only one of classEntity and splitterEntity is non-nil", debug: debug)
            
            // Create a new TimeSlot object and set its attributes
            let item = TimeSlot(context: context)
            log("[knDF, CreateTS]: Created new TimeSlot object", debug: debug)
            item.id = UUID()
            log("[knDF, CreateTS]: Set TimeSlot ID", debug: debug)
            item.day = dayEntity
            log("[knDF, CreateTS]: Set TimeSlot day to \(dayEntity)", debug: debug)
            if let teacher = timeSlot.taughtBy{
                item.taughtBy = teacher
                log("[knDF, CreateTS]: Set teacher to \(teacher.name ?? "No Name")", debug: debug)
            }
            else{
                item.taughtBy = nil
            }
            
            //            if let teacher = teacher{
            //                if teacher != ""{
            //                    item.teacher = teacher
            //                    log("[knDF, CreateTS]: Set teacher to \(teacher)", debug: debug)
            //                }
            //                else{
            //                    item.teacher = nil
            //                }
            //            }
            
            item.room = room
            log("[knDF, CreateTS]: Set TimeSlot room to \(room)", debug: debug)
            item.startTime = TimeFormatter.getTimeString(startTime)
            log("[knDF, CreateTS]: Set TimeSlot start time to \(TimeFormatter.getTimeString(startTime))", debug: debug)
            item.endTime = TimeFormatter.getTimeString(endTime)
            log("[knDF, CreateTS]: Set TimeSlot end time to \(TimeFormatter.getTimeString(endTime))", debug: debug)
            item.timestamp = TimeFormatter.toDate(TimeFormatter.getTimeString(startTime), mode: .time)
            log("[knDF, CreateTS]: Set TimeSlot timestamp to \(TimeFormatter.toDate(TimeFormatter.getTimeString(startTime), mode: .time))", debug: debug)
            
            // Set the classEntity or splitterEntity, if applicable
                if let classEntity = timeSlot.classEntity {
                item.classEntity = classEntity
                log("[knDF, CreateTS]: Added and Assigned TimeSlot to ClassEntity \(classEntity)", debug: debug)
                classEntity.addToTimeSlot(item)
            }
            
                if let splitterEntity = timeSlot.splitterEntity {
                item.splitterEntity = splitterEntity
                log("[knDF, CreateTS]: Added TimeSlot to SplitterEntity", debug: debug)
                splitterEntity.addToTimeSlot(item)
            }
            log("[knDF, CreateTS]: Set TimeSlot classEntity and splitterEntity, if applicable", debug: debug)
            
            dayEntity.addToTimeSlots(item)
            log("[knDF, CreateTS]: Added TimeSlot to Day", debug: debug)
                if let teacher = timeSlot.taughtBy{
                teacher.addToTeachingTimeSlots(item)
                log("[knDF, CreateTS]: Added TimeSlot to Teacher", debug: debug)
            }
            
            log("[knDF, CreateTS]: New TimeSlot entity created with attributes: \(item)", debug: debug)
            
                do {
                    try context.save()
                    
                    log("[knDF, CreateTS]: Changes saved to Core Data", debug: debug)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {

                    withAnimation(.bouncy(duration: 0.35)){
                        selectedID = item.id
                    }
                }
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
            
            log("[[knDF, CreateTS]]: Updated dayEntity.week.id = \(dayEntity.week?.id?.uuidString ?? "nil")", debug: debug)
        }
    }
}
