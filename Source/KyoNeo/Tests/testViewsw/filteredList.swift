//
//  filteredList.swift
//  KyoNeo
//
//  Created by Aether on 05/12/2022.
//

import SwiftUI

// Define a struct named filteredList that conforms to the View protocol
struct filteredList: View {
    // Declare a FetchRequest property wrapper to fetch TimeSlot objects from Core Data
    @FetchRequest var fetchRequest: FetchedResults<TimeSlot>

    // Define the body of the filteredList view
    var body: some View {
        // Use a List view to display fetched TimeSlot objects
        List(fetchRequest, id: \.self) { t in
            // For each TimeSlot object, display the name of the associated classEntity, or "oops" if the name is not available
            Text(t.classEntity?.name ?? "oops")
        }
    }

    // Define the initializer for the filteredList view, accepting a filter parameter of type String
    init(filter: String) {
        // Initialize the _fetchRequest property with a FetchRequest
        _fetchRequest = FetchRequest<TimeSlot>(
            // Use an empty array for sort descriptors, meaning the fetched results will not be sorted
            sortDescriptors: [],
            // Use an NSPredicate to filter the fetched results based on the day.name property and the filter parameter value
            predicate: NSPredicate(format: "day.name == %@", filter)
        )
    }
}

