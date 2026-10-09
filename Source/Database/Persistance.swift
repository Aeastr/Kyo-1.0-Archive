// FIX: Use archive identifiers to keep this build and its data separate from the original app.
//
//  Persistance.swift
//  KyoNeo
//
//  Created by Aether on 19/11/2022.
//

import CoreData


struct PersistenceController {
    static let shared = PersistenceController()
    let container: NSPersistentCloudKitContainer

    init(inMemory: Bool = false) {
        // Change to NSPersistentCloudKitContainer
        container = NSPersistentCloudKitContainer(name: "KyoNeoData")

        // Configuration for the persistent store
        let storeDescription = NSPersistentStoreDescription()
        let url = URL.storeURL(for: "group.com.example.kyoarchive", databaseName: "KyoNeoData")
        storeDescription.url = url

        // Enable CloudKit support
        storeDescription.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: "iCloud.com.example.kyoarchive")

        container.persistentStoreDescriptions = [storeDescription]

        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                PersistenceController.handleLoadPersistentStoresError(error)
            } else {
                print("Store has been loaded \(storeDescription.url!)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true

        // Create an UndoManager and assign it to the viewContext
                let undoManager = UndoManager()
                container.viewContext.undoManager = undoManager
    }

    private static func handleLoadPersistentStoresError(_ error: NSError) {
        let customError = PersistenceError(error: error)
        print("Persistence Error: \(customError.localizedDescription)")
        // Handle the error based on its type or show an error message to the user
    }
}

public extension URL {
    static func storeURL(for appGroup: String, databaseName: String) -> URL {
        
        guard let fileContainer = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup) else {
            fatalError("Unable to create URL for \(appGroup)")
        }
        return fileContainer.appendingPathComponent("\(databaseName).sqlite")
    }
}

enum PersistenceError: LocalizedError {
    case parentDirectoryError
    case storeInaccessible
    case deviceOutOfSpace
    case migrationFailed
    case unknownError(NSError)

    init(error: NSError) {
        switch error.code {
        case NSFileWriteNoPermissionError:
            self = .parentDirectoryError
        case NSFileReadCorruptFileError:
            self = .storeInaccessible
        case NSFileWriteOutOfSpaceError:
            self = .deviceOutOfSpace
        case NSMigrationError:
            self = .migrationFailed
        default:
            self = .unknownError(error)
        }
    }

    var errorDescription: String? {
        switch self {
        case .parentDirectoryError:
            return "The parent directory does not exist, cannot be created, or disallows writing."
        case .storeInaccessible:
            return "The persistent store is not accessible, due to permissions or data protection when the device is locked."
        case .deviceOutOfSpace:
            return "The device is out of space."
        case .migrationFailed:
            return "The store could not be migrated to the current model version."
        case .unknownError(let error):
            return "Unknown error: \(error), \(error.userInfo)"
        }
    }
}
