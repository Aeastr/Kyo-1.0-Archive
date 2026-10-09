//
//  Previewing.swift
//  KyoNeo
//
//  Created by Aether on 14/01/2023.
//
import SwiftUI
import CoreData

struct Previewing<Content: View, Model>: View {
    var content: Content
    var persisence: PersistenceController

    var body: some View {
        content
            .environmentObject(\.managedObjectContext, persisence.container.viewContext)
    }
}

struct PreviewingData{
    var items: (NSManagedObjectContext) -> [TimeSlot] {  { context in
        var createdItems = [TimeSlot]
        for _ in 0..<15{
            let newItem = TimeSlot(context: context)
            newItem.id = UUID()
            newItem.name = "Physics"
            newItem.startTime = "08:30 AM"
            newItem.endTime = "10:30 AM"
           // newItem.day = mon
            newItem.color1 = "6B94F2"
            newItem.color2 = "78BDF4"
            newItem.timestamp = TimeFormatter.toDate(newItem.startTime ?? "00:00")
        }
        return createdItems
    }}
}
