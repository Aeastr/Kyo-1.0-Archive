//
//  AdvancedData.swift
//  KyoNeo
//
//  Created by Aether on 04/04/2024.
//

import SwiftUI
import AmethystUI

struct AdvancedData: View {
    var color: Color

    @Environment(\.managedObjectContext) private var viewContext
    @State var startTime = Date()
    @State var endTime = Date()

    @Environment(\.colorScheme) private var colorScheme
    @State var scrolled: Bool = false

    @State private var isPresentingImportView = false
    @State var load = true
    @State var showExportView = false
    @State var showImportWarning = false

    @AppStorage("Contrast") var contrast = false
    @AppStorage("tintPages") var tintPages = false
    @AppStorage("global_Compact") var global_Compact  = false
    var tintBinding: Binding<Bool> {
            Binding(
                get: { contrast ? true : tintPages },
                set: { tintPages = $0 }
            )
        }

    @FetchRequest(sortDescriptors: []) var days: FetchedResults<Day> // Fetches weeks from Core Data

    @FetchRequest(sortDescriptors: []) var timeSlots: FetchedResults<TimeSlot> // Fetches weeks from Core Data
    @FetchRequest(sortDescriptors: []) var classes: FetchedResults<ClassEntity> // Fetches weeks from Core Data
    @FetchRequest(sortDescriptors: []) var splits: FetchedResults<SplitterEntity> // Fetches weeks from Core Data

    @FetchRequest(sortDescriptors: []) var tasks: FetchedResults<TaskEntity> // Fetches weeks from Core Data

    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "number", ascending: true)],
                      predicate: NSPredicate(format: "singleDayWeek == nil OR singleDayWeek == %@", NSNumber(value: false))
        ) var weeks: FetchedResults<Week>

    #if os(macOS)
    func showDocumentPicker() {
        let openPanel = NSOpenPanel()
        openPanel.allowedFileTypes = ["json"]
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseFiles = true
        openPanel.canChooseDirectories = false

        openPanel.begin { response in
            if response == .OK, let url = openPanel.urls.first {
                importJSON(from: url)
            }
        }
    }

    func importJSON(from url: URL) {
        do {
            let importer = kn_DataExporterImporter(debug: true)
            try importer.importJSON(from: url)
        } catch {
            print("Error importing data: \(error.localizedDescription)")
        }
    }
    #endif

    var body: some View {
        ZStack {

            ScrollView {
                #if os(iOS)
                ScrollDetector(scrolled: $scrolled)
                #endif
                VStack{
                    Group{
                        Text("^[\(weeks.count) Weeks](inflect: true), ")
                        +
                        Text("^[\(days.count) Days](inflect: true), ")
                        +
                        Text("^[\(classes.count) Classes](inflect: true), ")
                        +
                        Text("^[\(splits.count) Splits](inflect: true), ")
                        +
                        Text("^[\(timeSlots.count) Entries](inflect: true), and ")
                        +
                        Text("^[\(tasks.count) Tasks](inflect: true)")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.caption)
                    .opacity(0.7)
                    .padding(.horizontal, 25)
                    .padding(.bottom, 10)
                }
                .padding(.top, 15)

                Text("Kyo automatically checks for any data issues, but you can apply data fixes manually here")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.caption)
                    .padding(.horizontal, 25)
                    .padding(.bottom, 10)

                Button {
                    for slot in timeSlots{
                        if let startTime = slot.startTime{
                            slot.timestamp = TimeFormatter.toDate(startTime, mode: .time)
                        }
                    }
                    do {
                        try viewContext.save()
                        print("save!!")
                    } catch {
                        let nsError = error as NSError
                        fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                    }
                } label: {
                        Label("Reset Timestamps", systemImage: "arrow.circlepath")
                            .frame(maxWidth: .infinity, alignment: .center)
                }
                .buttonStyle(PolishedButton(color: color, background: false))
                .padding(.horizontal, 25)


                Button {
                    for (index, week) in weeks.enumerated() {
                               week.number = Int64(index + 1)
                           }
                    do {
                                                                       try viewContext.save()
                   print("save!!")
                                                                   } catch {
                                                                       let nsError = error as NSError
                                                                       fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                                                                   }
                } label: {
                        Label("Reorder Weeks", systemImage: "arrow.circlepath")
                            .frame(maxWidth: .infinity, alignment: .center)
                }
                .buttonStyle(PolishedButton(color: color, background: false))
                .padding(.horizontal, 25)
            }
            .animation(.smoothCard, value: load)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(maxWidth: 700)
            .shadow(color: .primary.opacity(0.05), radius: 13, x: 0, y: 5)
            .coordinateSpace(name: "scroll")

            .frame(maxWidth: 700)
#if os(iOS)
            .safeAreaInset(edge: .top, content: {
                Color.clear.frame(height: 60)
            })
            #endif

            .amethystNavigationBar(title: "Advanced", titleColor: .primary,   tintColor: color, compactMode: true, overrideType: .back, scrolled: $scrolled, content: {

            }, toolbar: {

            })
        }
        .tint(color)
    }


}
