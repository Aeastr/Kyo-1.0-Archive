//
//  timeSlotChecks.swift
//  KyoNeo
//
//  Created by Aether on 27/08/2023.
//

import SwiftUI
import CoreData

struct timeSlotChecks {
    var context: NSManagedObjectContext {
            PersistenceController.shared.container.viewContext
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

    func checkForParentlessTimeSlots() -> Bool {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = TimeSlot.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "day == nil || day.week == nil")
        fetchRequest.resultType = .countResultType

        do {
            let result = try context.fetch(fetchRequest) as? [NSNumber]
            if let count = result?.first?.intValue {
                return count > 0
            }
        } catch {
            print("Error checking for parentless time slots: \(error)")
                    NotificationCenter.default.post(name: .coreDataError, object: error)
        }

        return false
    }




    func deleteParentlessTimeSlots() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = TimeSlot.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "day == nil || day.week == nil")

        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try context.execute(batchDeleteRequest)
            try context.save() // Save changes after batch delete
        } catch {
            print("Error deleting parentless time slots: \(error)")
                    NotificationCenter.default.post(name: .coreDataError, object: error)
        }
    }

    func empty() -> Bool {
        return timeslots.isEmpty
    }

}

extension Notification.Name {
    static let coreDataError = Notification.Name("coreDataErrorNotification")
}

class ErrorObserver: ObservableObject {
    @Published var errorMessage: String?

    init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleErrorNotification(_:)),
            name: .coreDataError,
            object: nil
        )
    }

    @objc private func handleErrorNotification(_ notification: Notification) {
        if let error = notification.object as? Error {
            errorMessage = error.localizedDescription
        }
    }
}
