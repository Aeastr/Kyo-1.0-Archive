//
//  SharedDataManager.swift
//  KyoNeo
//
//  Created by Aether on 04/08/2023.
//

import Foundation
import CoreData
#if canImport(WatchConnectivity)
import WatchConnectivity



//class SharedDataManager: NSObject, ObservableObject, WCSessionDelegate {
//    static let shared = SharedDataManager()
//
//    private var watchSession: WCSession?
//
//    override init() {
//        super.init()
//        if WCSession.isSupported() {
//            watchSession = WCSession.default
//            watchSession?.delegate = self
//            watchSession?.activate()
//        }
//    }
//
//    // Function to send 'ClassEntity' data to the watch
//    func sendClassDataToWatch(entity: ClassEntity) {
//        watchSession?.activate()
//        print("attemping to send data now")
////        print(watchSession!.isWatchAppInstalled)
////        print(watchSession!.isPaired)
////        print(watchSession!.isReachable ? "session reached" : "session is not reachable!")
//        guard let watchSession = watchSession, watchSession.isReachable else {
//            return
//        }
//        print("sending data now")
//        let data: [String: Any] = [
//            "sharedDataType": sharedDataType.classData.rawValue,
//            "color1": entity.color1,
//            "color2": entity.color2,
//            "icon": entity.icon,
//            "id": entity.id?.uuidString,
//            "name": entity.name,
//            "shortName": entity.shortName
//        ]
//
//        watchSession.sendMessage(data, replyHandler: nil, errorHandler: nil)
//    }
//
//    func sendSplitDataToWatch(entity: SplitterEntity) {
//        watchSession?.activate()
//        print("attemping to send data now")
//        print(watchSession!.isWatchAppInstalled)
//        print(watchSession!.isPaired)
//        print(watchSession!.isReachable ? "session reached" : "session is not reachable!")
//        guard let watchSession = watchSession, watchSession.isReachable else {
//            return
//        }
//        print("sending data now")
//        let data: [String: Any] = [
//            "sharedDataType": sharedDataType.splitData.rawValue,
//            "color1": entity.color1,
//            "color2": entity.color2,
//            "id": entity.id?.uuidString,
//            "name": entity.name,
//            "splitType": entity.type
//        ]
//
//        watchSession.sendMessage(data, replyHandler: nil, errorHandler: nil)
//    }
//    
//    func sendWeekDataToWatch(entity: Week) {
//        watchSession?.activate()
//        print("attemping to send data now")
//
//        guard let watchSession = watchSession, watchSession.isReachable else {
//            return
//        }
//        let data: [String: Any] = [
//            "sharedDataType": sharedDataType.week.rawValue,
//            "id": entity.id?.uuidString,
//            "name": entity.name ?? "",
//            "number": entity.number,
//            "singleDayWeek": entity.singleDayWeek
//        ]
//
//        print("sending data now \(data)")
//        watchSession.sendMessage(data, replyHandler: nil, errorHandler: nil)
//    }
//
//
//    func sendDayDataToWatch(entity: Day) {
//        watchSession?.activate()
//        print("attemping to send data now")
//       
//        guard let watchSession = watchSession, watchSession.isReachable else {
//            return
//        }
//        if let id = entity.id?.uuidString, let linkedID = entity.week?.id?.uuidString{
//            let data: [String: Any] = [
//                "sharedDataType": sharedDataType.day.rawValue,
//                "id": id,
//                "name": entity.name ?? "",
//                "number": entity.number,
//                "linkedWeekID": linkedID
//            ]
//
//            print("sending data now \(data)")
//            watchSession.sendMessage(data, replyHandler: nil, errorHandler: nil)
//        }
//        else{
//            print("missing data!")
//        }
//    }
//
//    func sendTimeSlotDataToWatch(entity: TimeSlot) {
//        watchSession?.activate()
//        print("attemping to send data now")
//        print(watchSession!.isWatchAppInstalled)
//        print(watchSession!.isPaired)
//        print(watchSession!.isReachable ? "session reached" : "session is not reachable!")
//        guard let watchSession = watchSession, watchSession.isReachable else {
//            return
//        }
//        print("sending data now")
//        if let cSLinkedID = entity.classEntity?.id?.uuidString{
//            let data: [String: Any] = [
//                "idString": entity.id!.uuidString,
//                "sharedDataType": sharedDataType.timeSlot.rawValue,
//                "linkedClassID": cSLinkedID,
//                "room": entity.room ?? "",
//                "startTime": entity.startTime!,
//                "endTime": entity.endTime!,
//                "linkedDayIDString": entity.day!.id!.uuidString,
//                "timestamp": entity.timestamp
//            ]
//
//            print("sending data now \(data)")
//            watchSession.sendMessage(data, replyHandler: nil, errorHandler: nil)
//        }
//        else if let cSLinkedID = entity.splitterEntity?.id?.uuidString{
//            let data: [String: Any] = [
//                "idString": entity.id!.uuidString,
//                "sharedDataType": sharedDataType.timeSlot.rawValue,
//                "linkedSplitterID": cSLinkedID,
//                "room": entity.room ?? "",
//                "startTime": entity.startTime!,
//                "endTime": entity.endTime!,
//                "linkedDayIDString": entity.day!.id!.uuidString,
//                "timestamp": entity.timestamp
//
//            ]
//
//            print("sending data now \(data)")
//            watchSession.sendMessage(data, replyHandler: nil, errorHandler: nil)
//        }
//
//    }
//
////    func sendDataToWatch(entity: TimeSlot) {
////        watchSession?.activate()
////        print("attemping to send data now")
////        print(watchSession!.isWatchAppInstalled)
////        print(watchSession!.isPaired)
////        print(watchSession!.isReachable ? "session reached" : "session is not reachable!")
////        guard let watchSession = watchSession, watchSession.isReachable else {
////            return
////        }
////        print("sending data now")
////        let data: [String: Any] = [
////            "type": sharedDataType.timeSlot
////            ""
////        ]
////
////        watchSession.sendMessage(data, replyHandler: nil, errorHandler: nil)
////    }
//
//    // MARK: - WCSessionDelegate methods
//
//    // Required method to handle activation of the session on the watch
//    func sessionDidBecomeInactive(_ session: WCSession) {
//        print("session inactive!")
//        // This method is called when the session is no longer active but could be reactivated later.
//    }
//
//    // Required method to handle session deactivation on the watch
//    func sessionDidDeactivate(_ session: WCSession) {
//        print("session deactivate!")
//        // This method is called when the session is deactivated, typically when the paired device becomes unreachable.
//        // The watchOS app needs to call 'activate()' on the session again to reestablish communication.
//        watchSession?.activate()
//    }
//
//    // Required method to handle activation of the session on the watch with a new paired iOS device
//    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
//
//            print("session active fr, \(session.description)")
//        // This method is called when the session activation completes, providing the activation state and any potential errors.
//    }
//
//    // Optional method to handle receiving a message from the watch
//    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
//        // Handle the received 'ClassEntity' data from iOS app
//        if let idString = message["id"] as? String,
//           let name = message["name"] as? String,
//           let color1 = message["color1"] as? String,
//           let color2 = message["color2"] as? String,
//           let icon = message["icon"] as? String,
//           let shortName = message["shortName"] as? String,
//           let id = UUID(uuidString: idString) {
//            // Fetch the managed object context for the watchOS app
//            let context = PersistenceController.shared.container.viewContext
//
//            // Check if the entity already exists in the watchOS app's Core Data store
//            var entityToUpdate: ClassEntity?
//
//            let fetchRequest: NSFetchRequest<ClassEntity> = ClassEntity.fetchRequest()
//            fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
//
//            do {
//                let fetchedEntities = try context.fetch(fetchRequest)
//                entityToUpdate = fetchedEntities.first
//            } catch {
//                print("Error fetching entity: \(error)")
//            }
//
//            // Create or update the 'ClassEntity' in watchOS app's Core Data store
//            if let entityToUpdate = entityToUpdate {
//                // Update the existing entity with the new data
//                entityToUpdate.name = name
//                entityToUpdate.color1 = color1
//                entityToUpdate.color2 = color2
//                entityToUpdate.icon = icon
//                entityToUpdate.shortName = shortName
//            } else {
//                // Create a new entity since it doesn't exist in the watchOS app's Core Data store
//                let newEntity = ClassEntity(context: context)
//                newEntity.id = id
//                newEntity.name = name
//                newEntity.color1 = color1
//                newEntity.color2 = color2
//                newEntity.icon = icon
//                newEntity.shortName = shortName
//            }
//
//            // Save the changes to Core Data
//            do {
//                try context.save()
//            } catch {
//                print("Error saving context: \(error)")
//            }
//
//            // Optionally, refresh the UI to reflect the new data
//            // In SwiftUI, the @FetchRequest property wrapper will automatically update the view when Core Data changes.
//        }
//    }
//}

#endif
