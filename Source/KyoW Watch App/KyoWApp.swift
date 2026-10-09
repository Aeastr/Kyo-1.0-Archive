//
//  KyoWApp.swift
//  KyoW Watch App
//
//  Created by Aether on 11/02/2024.
//

import SwiftUI

@main
struct KyoW_Watch_AppApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            NavigationStack{
                WatchTodayView()
            }
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
