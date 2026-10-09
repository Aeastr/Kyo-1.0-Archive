//
//  kn_DatabaseCodableStructures.swift
//  KyoNeo
//
//  Created by Aether on 08/04/2023.
//

import Foundation
import CoreData

struct TimeSlotCodable: Codable {
    let type: Int32
    let endTime: String
    let notes: String
    let room: String
    let startTime: String
   // let teacher: String
    let title: String
    let timestamp: Date
    let id: UUID
    let splitterEntityId: UUID?
    let dayId: UUID?
    let classEntityId: UUID?


    init(from timeSlot: TimeSlot?) throws {
            guard let slot = timeSlot else {
                throw NSError(domain: "kn_DataExporterImporter", code: 0, userInfo: [NSLocalizedDescriptionKey: "TimeSlot is nil"])
            }

            type = slot.type
            endTime = slot.endTime ?? ""
            notes = slot.notes ?? ""
            room = slot.room ?? ""
            startTime = slot.startTime ?? ""
           // teacher = slot.teacher ?? ""
            title = slot.title ?? ""
            timestamp = slot.timestamp ?? Date()
            id = slot.id ?? UUID()
            splitterEntityId = slot.splitterEntity?.id
            dayId = slot.day?.id
            classEntityId = slot.classEntity?.id
        }
}


struct DayCodable: Codable {
    let number: Int16
    let name: String
    let timestamp: Date
    let id: UUID
    let weekId: UUID
    let timeSlotIds: [UUID]

    init(from day: Day?) throws {
        guard let day = day else {
            throw NSError(domain: "kn_DataExporterImporter", code: 0, userInfo: [NSLocalizedDescriptionKey: "Day is nil"])
        }

        number = day.number
        name = day.name ?? ""
        timestamp = day.timestamp ?? Date()
        id = day.id ?? UUID()
        weekId = day.week?.id ?? UUID()
        timeSlotIds = day.timeSlots?.compactMap { ($0 as? TimeSlot)?.id } ?? []
    }
}

struct WeekCodable: Codable {
    let number: Int16
    let id: UUID
    let dayIds: [UUID]
    let singleDayWeek: Bool?

    init(from week: Week?) throws {

        print("make week")
        guard let week = week else {
            throw NSError(domain: "kn_DataExporterImporter", code: 0, userInfo: [NSLocalizedDescriptionKey: "Week is nil"])
        }

        number = Int16(week.number)
        id = week.id ?? UUID()
        dayIds = week.days?.compactMap { ($0 as? Day)?.id } ?? []
        singleDayWeek = week.singleDayWeek
    }
}


struct SplitterEntityCodable: Codable {
    let id: UUID?
    let type: Int32
    let number: Int64
    let color1: String
    let color2: String
    let name: String
    let timeSlotIds: [UUID]

    init(from splitterEntity: SplitterEntity?) throws {
        guard let splitterEntity = splitterEntity else {
            throw NSError(domain: "kn_DataExporterImporter", code: 0, userInfo: [NSLocalizedDescriptionKey: "SplitterEntity is nil"])
        }
        if let identi = splitterEntity.id{
            id = identi
        }
        else{
            id = nil
        }
        type = splitterEntity.type
        number = splitterEntity.number
        color1 = splitterEntity.color1 ?? ""
        color2 = splitterEntity.color2 ?? ""
        name = splitterEntity.name ?? ""
        timeSlotIds = splitterEntity.timeSlot?.compactMap { ($0 as? TimeSlot)?.id } ?? []
    }


}


struct ClassEntityCodable: Codable {
    let id: UUID?
    let color1: String
    let color2: String
    let name: String
    let icon: String?
    let timeSlotIds: [UUID]

    init(from classEntity: ClassEntity?) throws {
        guard let classEntity = classEntity else {
            throw NSError(domain: "kn_DataExporterImporter", code: 0, userInfo: [NSLocalizedDescriptionKey: "ClassEntity is nil"])
        }

        id = classEntity.id
        color1 = classEntity.color1 ?? ""
        color2 = classEntity.color2 ?? ""
        name = classEntity.name ?? ""
        icon = classEntity.icon ?? getIconForClassName(classEntity.name ?? "")
        timeSlotIds = classEntity.timeSlot?.compactMap { ($0 as? TimeSlot)?.id } ?? []
    }
}

struct TaskEntityCodable: Codable {
    var id: UUID = UUID()
    let archived: Bool
    let completed: Bool
    let doNotArchive: Bool
    let due: Date
    let label: String
    let link: String?
    let muted: Bool
    let notes: String?

    let classEntityId: UUID?

    init(from task: TaskEntity?) throws {
        self.archived = task?.archived ?? false
        self.completed = task?.completed ?? false
        self.doNotArchive = task?.doNotArchive ?? false
        self.due = task?.due ?? Date()
        self.label = task?.label ?? "Untitled Task"
        self.link = task?.link
        self.muted = task?.muted ?? false
        self.notes = task?.notes

        self.classEntityId = task?.classEntity?.id
    }
}

struct TaskTypeEntityCodable: Codable {
    var id: UUID = UUID()
    let archived: Bool
    let completed: Bool
    let doNotArchive: Bool
    let due: Date
    let label: String
    let link: String?
    let muted: Bool
    let notes: String?

    let classEntityId: UUID?

    init(from task: TaskEntity?) throws {
        self.archived = task?.archived ?? false
        self.completed = task?.completed ?? false
        self.doNotArchive = task?.doNotArchive ?? false
        self.due = task?.due ?? Date()
        self.label = task?.label ?? "Untitled Task"
        self.link = task?.link
        self.muted = task?.muted ?? false
        self.notes = task?.notes

        self.classEntityId = task?.classEntity?.id
    }
}


