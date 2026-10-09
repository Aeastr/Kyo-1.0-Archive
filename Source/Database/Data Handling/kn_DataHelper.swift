//
//  kn_DataHelper.swift
//  KyoNeo
//
//  Created by Aether on 08/04/2023.
//

import SwiftUI
import CoreData

struct kn_DataHelper {
    var context: NSManagedObjectContext {
            PersistenceController.shared.container.viewContext
    }

    func fetchAllTimeSlots() throws -> [TimeSlot] {
        let fetchRequest: NSFetchRequest<TimeSlot> = TimeSlot.fetchRequest()
        // Create a predicate to filter out time slots with nil .day
        fetchRequest.predicate = NSPredicate(format: "day != nil")

        return try context.fetch(fetchRequest)
    }


    func fetchAllDays() throws -> [Day] {
        let fetchRequest: NSFetchRequest<Day> = Day.fetchRequest()
        // Create a predicate to filter out days with nil .week
        fetchRequest.predicate = NSPredicate(format: "week != nil")

        return try context.fetch(fetchRequest)
    }


    func fetchAllWeeks() throws -> [Week] {
        let fetchRequest: NSFetchRequest<Week> = Week.fetchRequest()
        return try context.fetch(fetchRequest)
    }


    func fetchAllTasks() throws -> [TaskEntity] {
        let fetchRequest: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        return try context.fetch(fetchRequest)
    }

    func fetchAllSplitterEntities() throws -> [SplitterEntity] {
        let fetchRequest: NSFetchRequest<SplitterEntity> = SplitterEntity.fetchRequest()
        return try context.fetch(fetchRequest)
    }

    func fetchAllClassEntities() throws -> [ClassEntity] {
        let fetchRequest: NSFetchRequest<ClassEntity> = ClassEntity.fetchRequest()
        return try context.fetch(fetchRequest)
    }

    func deleteAllObjects() throws {
            try deleteAllTimeSlots()
            try deleteAllDays()
            try deleteAllWeeks()
            try deleteAllSplitterEntities()
            try deleteAllClassEntities()
            try deleteAllTasks()
        }

        // ...

        private func deleteAllTimeSlots() throws {
            let request = TimeSlot.fetchRequest()
            let allObjects = try context.fetch(request) as [NSManagedObject]
            for object in allObjects {
                context.delete(object)
            }
        }


        private func deleteAllTasks() throws {
            let request = TaskEntity.fetchRequest()
            let allObjects = try context.fetch(request) as [NSManagedObject]
            for object in allObjects {
                context.delete(object)
            }
        }

        private func deleteAllDays() throws {
            let request = Day.fetchRequest()
            let allObjects = try context.fetch(request) as! [NSManagedObject]
            for object in allObjects {
                context.delete(object)
            }
        }

        private func deleteAllWeeks() throws {
            let request = Week.fetchRequest()
            let allObjects = try context.fetch(request) as! [NSManagedObject]
            for object in allObjects {
                context.delete(object)
            }
        }

        private func deleteAllSplitterEntities() throws {
            let request = SplitterEntity.fetchRequest()
            let allObjects = try context.fetch(request) as! [NSManagedObject]
            for object in allObjects {
                context.delete(object)
            }
        }

        private func deleteAllClassEntities() throws {
            let request = ClassEntity.fetchRequest()
            let allObjects = try context.fetch(request) as! [NSManagedObject]
            for object in allObjects {
                context.delete(object)
            }
        }
}

