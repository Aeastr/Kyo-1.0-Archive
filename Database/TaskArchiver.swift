//
//  TaskArchiver.swift
//  KyoNeo
//
//  Created by Aether on 24/08/2023.
//

import SwiftUI
import CoreData

struct TaskArchiver{
    var context: NSManagedObjectContext {
            PersistenceController.shared.container.viewContext
    }

    var debug: Bool = true
    let currentDate = Date()
        let calendar = Calendar.current

    var tasks: [TaskEntity] {
        let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        let sort = NSSortDescriptor(key: "due", ascending: false)
        request.sortDescriptors = [sort]

        // Get the date that is 30 days ago
        if let daysAgo = Calendar.current.date(byAdding: .day, value: -1, to: Date()) {
            // Create a predicate to filter tasks that are due before or on thirtyDaysAgo,
            // have completed set to true, doNotArchive set to false, and archive set to false
            let predicate = NSPredicate(format: "due <= %@ AND completed == %d AND doNotArchive == %d", argumentArray: [daysAgo as NSDate, NSNumber(value: true), NSNumber(value: false)])
            request.predicate = predicate
        }

        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching tasks: \(error.localizedDescription)")
            return []
        }
    }


    func isDateOlderThan30Days(date: Date) -> Bool {
            if let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: Date()) {
                return date < thirtyDaysAgo
            }
            return false
        }

    func isDateOlderThan15Days(date: Date) -> Bool {
            if let thirtyDaysAgo = calendar.date(byAdding: .day, value: -15, to: Date()) {
                return date < thirtyDaysAgo
            }
            return false
        }

    func isDateOlderThan20Days(date: Date) -> Bool {
        if let twentyDaysAgo = calendar.date(byAdding: .day, value: -20, to: Date()) {
            return date < twentyDaysAgo
        }
        return false
    }
    func isDateOlderThan1Days(date: Date) -> Bool {
        if let twentyDaysAgo = calendar.date(byAdding: .day, value: -1, to: Date()) {
            return date < twentyDaysAgo
        }
        return false
    }

    func archiveTasks(){
        log("[TaskArchiver - archiveTasks] Begin", debug: debug)
//
        let tasksToDelete = tasks.filter { task in
                return isDateOlderThan15Days(date: task.due ?? currentDate)
            }
        for task in tasksToDelete {
                log("[TaskArchiver - archiveTasks] Deleting task with title: \(task.label ?? "No Title")", debug: debug)
                context.delete(task)
            }

        for task in tasks {
            log("[TaskArchiver - archiveTasks] Archiving task with title: \(task.label ?? "No Title")", debug: debug)
            task.archived = true
        }
        if tasks.isEmpty{
            log("[TaskArchiver - archiveTasks] No Tasks to be archived :)", debug: debug)
        }
        else{
            do {
                try context.save()
                log("[TaskArchiver] Task changes saved successfully", debug: debug)

            } catch {
                print("Error saving changes: \(error.localizedDescription)")

            }
        }

        

    }




    func getArchivingAction(for task: TaskEntity) -> ArchivingAction {
        if !task.doNotArchive {
            if isDateOlderThan1Days(date: task.due ?? currentDate) {
                let warning = "Task '\(task.label ?? "No Title")' will be archived upon completion."
                return .archive(warning)
            } else {
                return .none
            }
        } else {
            return .none
        }
    }

    func performArchivingAction(for task: TaskEntity) {
        if !task.doNotArchive {
            if isDateOlderThan1Days(date: task.due ?? currentDate) {
                log("[TaskArchiver] Archiving task with title: \(task.label ?? "No Title")", debug: debug)
                task.archived = true

                do {
                    try context.save()
                    log("[TaskArchiver] Task archived and changes saved successfully", debug: debug)
                } catch {
                    print("Error saving changes: \(error.localizedDescription)")
                }
            }
        }
    }



}

enum ArchivingAction: Equatable {
    case archive(String), delete(String), none

    var warning: String {
        switch self {
        case .archive(let warning), .delete(let warning):
            return warning
        case .none:
            return ""
        }
    }
}
