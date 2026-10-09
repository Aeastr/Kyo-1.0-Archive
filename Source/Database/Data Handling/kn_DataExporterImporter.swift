//
//   kn_DataExporterImporter.swift
//  KyoNeo
//
//  Created by Aether on 08/04/2023.
//

import SwiftUI
import CoreData

struct kn_DataExporterImporter{
    var context: NSManagedObjectContext {
            PersistenceController.shared.container.viewContext
    }
    var debug = false

    var fetchedWeeks: [Week] {
        let request: NSFetchRequest<Week> = Week.fetchRequest()
        let sort = NSSortDescriptor(key: "number", ascending: true)
        request.sortDescriptors = [sort]
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching weeks: \(error.localizedDescription)")
            return []
        }
    }

    var fetchedDays: [Day] {
        let request: NSFetchRequest<Day> = Day.fetchRequest()

        // Create a predicate to filter out days with a nil 'week' property
        let predicate = NSPredicate(format: "week != nil")
        request.predicate = predicate

        let sort = NSSortDescriptor(key: "number", ascending: true)
        request.sortDescriptors = [sort]

        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching days: \(error.localizedDescription)")
            return []
        }
    }


    var fetchedSplitters: [SplitterEntity] {
        let request: NSFetchRequest<SplitterEntity> = SplitterEntity.fetchRequest()
        let sort = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [sort]
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching SplitterEntities: \(error.localizedDescription)")
            return []
        }
    }

    var fetchedClasses: [ClassEntity] {
        let request: NSFetchRequest<ClassEntity> = ClassEntity.fetchRequest()
        let sort = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [sort]
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching ClassEntities: \(error.localizedDescription)")
            return []
        }
    }


    /**
     Exports all the data in the Core Data store to a JSON file.

     - Precondition: There must be at least one entry in the Core Data store.

     This method fetches all the data from the Core Data store and encodes it as JSON data. The resulting JSON data is saved to the app's document directory with the name `coreDataExport.json`.
     */
    func exportCoreDataToJSON(fileName: String, fileExtension: String, exportSettings: Set<exportSettingsTypes> = [.classes, .splits, .plannerEntries, .tasksEntries, .customisationSettings, .weeksDays]) throws -> URL {
        log("[kn_DEI, ExportData] Starting export...", debug: debug)

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        let dataHelper = kn_DataHelper()
        
        
        let timeSlots = exportSettings.contains(.tasksEntries) ? try dataHelper.fetchAllTimeSlots() : []
//        log("[kn_DEI, ExportData] Fetched timeSlots", debug: debug)
        let days = exportSettings.contains(.weeksDays) ? try dataHelper.fetchAllDays() : []
//        log("[kn_DEI, ExportData] Fetched days", debug: debug)
        let weeks = exportSettings.contains(.weeksDays) ? try dataHelper.fetchAllWeeks() : []
        log("[kn_DEI, ExportData] Fetched weeks", debug: debug)
        let splitterEntities = exportSettings.contains(.splits) ? try dataHelper.fetchAllSplitterEntities() : []
//        log("[kn_DEI, ExportData] Fetched splitters", debug: debug)
        let classEntities = exportSettings.contains(.classes) ? try dataHelper.fetchAllClassEntities() : []
//        log("[kn_DEI, ExportData] Fetched classes", debug: debug)
        let taskEntites = exportSettings.contains(.tasksEntries) ? try dataHelper.fetchAllTasks() : []
//        log("[kn_DEI, ExportData] Fetched tasks", debug: debug)
        
        // Create arrays of codable objects
        let codableTSArray = timeSlots.compactMap { try? TimeSlotCodable(from: $0) }
//        log("[kn_DEI, ExportData] Mapped timeSlots", debug: debug)
        let codableDaysArray = days.compactMap { try? DayCodable(from: $0) }
//        log("[kn_DEI, ExportData] Mapped days", debug: debug)
        let codableWeeksArray = weeks.compactMap { try? WeekCodable(from: $0) }
        log("[kn_DEI, ExportData] Mapped weeks", debug: debug)
        let codableSplitterEntitiesArray = splitterEntities.compactMap { try? SplitterEntityCodable(from: $0) }
//        log("[kn_DEI, ExportData] Mapped splitters", debug: debug)
        let codableClassEntitiesArray = classEntities.compactMap { try? ClassEntityCodable(from: $0) }
//        log("[kn_DEI, ExportData] Mapped classes", debug: debug)
        let codableTaskEntitiesArray = taskEntites.compactMap { try? TaskEntityCodable(from: $0)}

        // Combine arrays of codable objects
        let timeSlotObjects: [Encodable] = codableTSArray
        let dayObjects: [Encodable] = codableDaysArray
        let weekObjects: [Encodable] = codableWeeksArray
        let splitterEntitiesObjects: [Encodable] = codableSplitterEntitiesArray
        let classEntitiesObjects: [Encodable] = codableClassEntitiesArray
        let taskEntitiesObjects: [Encodable] = codableTaskEntitiesArray

        let allCodableObjects = timeSlotObjects + dayObjects + weekObjects + splitterEntitiesObjects + classEntitiesObjects + taskEntitiesObjects


        // Ensure there is at least one entry in the Core Data store
        precondition(allCodableObjects.count > 0, "There must be at least one entry in the Core Data store.")
//        log("[kn_DEI, ExportData] Checked precondition", debug: debug)

        // Encode as JSON and save to file

        struct EncodableWrapper: Encodable {
            let timeSlots: [TimeSlotCodable]
            let days: [DayCodable]
            let weeks: [WeekCodable]
            let splitterEntities: [SplitterEntityCodable]
            let classEntities: [ClassEntityCodable]
            let taskEntities: [TaskEntityCodable]
        }

        // ...

        let wrapper = EncodableWrapper(
            timeSlots: codableTSArray,
            days: codableDaysArray,
            weeks: codableWeeksArray,
            splitterEntities: codableSplitterEntitiesArray,
            classEntities: codableClassEntitiesArray,
            taskEntities: codableTaskEntitiesArray

        )

        log("[kn_DEI, ExportData] Created wrapper \(wrapper)", debug: debug)
        let jsonData = try encoder.encode(wrapper)

            let documentDirectoryURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let fileURL = documentDirectoryURL.appendingPathComponent(fileName).appendingPathExtension(fileExtension)
            try jsonData.write(to: fileURL)

//        log("[kn_DEI, ExportData] Returning \(fileURL)", debug: debug)
            return fileURL
    }

    /**
         Imports data from a JSON file into the Core Data store.

         - Parameters:
            - fileURL: The file URL of the JSON file to import.
         */
    func importJSON(from url: URL) throws {
        log("[kn_DEI, ImportData] Inporting \(url)", debug: debug)
        try kn_DataHelper().deleteAllObjects()

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let jsonData = try Data(contentsOf: url)
        let wrapper = try decoder.decode(EncodableWrapper.self, from: jsonData)


        // Import splitter and class entities
        if let splitterEntities = wrapper.splitterEntities{
            for splitterEntity in splitterEntities {
                let splitter = SplitterEntity(context: context)
                splitter.id = splitterEntity.id
                splitter.name = splitterEntity.name
                splitter.color1 = splitterEntity.color1
                splitter.color2 = splitterEntity.color2

//                log("[kn_DEI, ImportData] Created splitter \(splitter.name ?? "(err: no name found)")", debug: debug)
            }
        }

  let classEntities = wrapper.classEntities
            for classEntity in classEntities {
                let `class` = ClassEntity(context: context)
                `class`.id = classEntity.id
                `class`.shortName = ""
                `class`.name = classEntity.name
                `class`.icon = classEntity.icon != "" ? classEntity.icon ?? getIconForClassName(classEntity.name) : getIconForClassName(classEntity.name)
                `class`.color1 = classEntity.color1
                `class`.color2 = classEntity.color2
//                log("[kn_DEI, ImportData] Created class \(`class`.name ?? "(err: no name found)") with ID \(`class`.id)", debug: debug)
            }

        try context.save()




        // Import splitter and class entities
        if let taskEntities = wrapper.taskEntities{
            for taskData in taskEntities {
                let task = TaskEntity(context: context)
                task.archived = taskData.archived
                task.completed = taskData.completed
                task.doNotArchive = taskData.doNotArchive
                task.due = taskData.due
                task.label = taskData.label
                task.link = taskData.link
                task.muted = taskData.muted
                task.notes = taskData.notes

                if taskData.classEntityId != nil{
                    for classEn in fetchedClasses {
//                        print("\(classEn.id), \(taskData.classEntityId)")
                        if classEn.id == taskData.classEntityId{
                            task.classEntity = classEn
//                            log("[kn_DEI, ImportData] Assigned class \(classEn.name ?? "(err: no name found)") to task \(task.id)", debug: debug)
                        }
                    }
                }
                else{
//                    print("cannot assign!")
                }
            }
        }

        // Import weeks
        var weekIDToWeekMap = [Int64: Week]()
        if let wrapperWeeks = wrapper.weeks{
            for week in wrapperWeeks {
                let newWeek = Week(context: context)
                newWeek.id = week.id
                newWeek.number = Int64(week.number)
                if let bool = week.singleDayWeek{
                    newWeek.singleDayWeek = bool
                }
                log("[kn_DEI, ImportData] Created week \(newWeek.number)", debug: debug)
            }
        }
        else{
            print("fail")
        }

        // Import days and link to weeks
        if let wrapperDays = wrapper.days{
            for day in wrapperDays {
                let newDay = Day(context: context)
                newDay.id = day.id
                newDay.name = day.name
                newDay.number = day.number
                newDay.timestamp = day.timestamp

                for week in fetchedWeeks{
                    if week.id == day.weekId{
                        newDay.week = week
                        week.addToDays(newDay)
                    }
                }
                if newDay.week == nil{
//                    log("[kn_DEI, ImportData] Discared day since week was nil", debug: debug)
                    context.delete(newDay)
                }
                else{
//                    log("[kn_DEI, ImportData] Created day \(newDay.name ?? "(err: no name found)") with week \(newDay.week?.number ?? 0)", debug: debug)
                }

            }
        }

        // Import time slots and link to days, classes and splitters
        if let wrapperTimeSlots = wrapper.timeSlots{
        for timeSlot in wrapperTimeSlots {
            let newTimeSlot = TimeSlot(context: context)
            newTimeSlot.id = timeSlot.id
            newTimeSlot.title = timeSlot.title

            newTimeSlot.startTime = ensureCorrectFormat(input: timeSlot.startTime)
            newTimeSlot.timestamp = TimeFormatter.toDate(ensureCorrectFormat(input: timeSlot.startTime), mode: .time)
            newTimeSlot.endTime = ensureCorrectFormat(input: timeSlot.endTime)
            newTimeSlot.room = timeSlot.room
            newTimeSlot.notes = timeSlot.notes
            //   newTimeSlot.teacher = timeSlot.teacher

            for day in fetchedDays {
                if day.id == timeSlot.dayId{
                    newTimeSlot.day = day

                }
            }

            if timeSlot.classEntityId != nil{
                for classEn in fetchedClasses {
                    if classEn.id == timeSlot.classEntityId{
                        newTimeSlot.classEntity = classEn
//                        log("[kn_DEI, ImportData] Assigned class \(classEn.name ?? "(err: no name found)") to timeSlot \(newTimeSlot.id)", debug: debug)
                    }

                }
            }
            else{
//                log("[kn_DEI, ImportData] Tried to assign class but was nil \(timeSlot.id)", debug: debug)
            }

            if timeSlot.splitterEntityId != nil{
                for splitter in fetchedSplitters {
                    if splitter.id == timeSlot.splitterEntityId{
                        newTimeSlot.splitterEntity = splitter
//                        log("[kn_DEI, ImportData] Assigned splitter \(splitter.name ?? "(err: no name found)") to timeSlot \(newTimeSlot.id)", debug: debug)
                    }
                }
            }
            else{
//                log("[kn_DEI, ImportData] Tried to assign splitter but was nil \(timeSlot.id)", debug: debug)
            }

            if newTimeSlot.classEntity == nil && newTimeSlot.splitterEntity == nil{
                context.delete(newTimeSlot)
//                log("[kn_DEI, ImportData] Discared TimeSlot since it had no class or split", debug: debug)
            }
            else{
//                log("[kn_DEI, ImportData] Created timeSlot \(newTimeSlot.id) with day \(newTimeSlot.day?.name ?? "(err: no name found)") in class/splitter \(newTimeSlot.classEntity?.name ?? "(err: no name found)") \(newTimeSlot.splitterEntity?.name ?? "(err: no name found)")", debug: debug)
            }

        }
    }

            // Save changes to Core Data
            try context.save()
//        log("[kn_DEI, ImportData] Saved", debug: debug)
        }

}

struct EncodableWrapper: Codable {
    let timeSlots: [TimeSlotCodable]?
    let days: [DayCodable]?
    let weeks: [WeekCodable]?
    let splitterEntities: [SplitterEntityCodable]?
    let classEntities: [ClassEntityCodable]
    let taskEntities: [TaskEntityCodable]?
}
