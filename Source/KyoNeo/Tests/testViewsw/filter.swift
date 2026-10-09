//
//  filter.swift
//  KyoNeo
//
//  Created by Aether on 05/12/2022.
//

import SwiftUI
import CoreData

struct filter: View {
    @State private var filter: String = "Mon"
    @State private var timeSlots: [TimeSlot] = []
    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        VStack {
            // Display the filtered data
            List(timeSlots, id: \.id) { timeSlot in
                Text(timeSlot.classEntity?.name ?? "No Name Found")
            }

            // Update the filter parameter when the button is tapped
            Button(action: {
                filter = "Mon"
            }) {
                Text("Change Filter to Mon")
            }
            // Update the filter parameter when the button is tapped
            Button(action: {
                filter = "Tue"
            }) {
                Text("Change Filter to Tue")
            }
        }
        // Reload the data every time the filter parameter changes
        .onChange(of: filter) { newValue in
            timeSlots = fetchData(filter: newValue)
        }
    }

    // Fetch the data from Core Data and apply the filter
    private func fetchData(filter: String) -> [TimeSlot] {
        let fetchRequest: NSFetchRequest<TimeSlot> = TimeSlot.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "day.name == %@", filter)

        do {
            return try viewContext.fetch(fetchRequest)
        } catch {
            print("Error fetching data: \(error.localizedDescription)")
            return []
        }
    }
}


struct filter_Previews: PreviewProvider {
    static var previews: some View {
        filter()
    }
}
