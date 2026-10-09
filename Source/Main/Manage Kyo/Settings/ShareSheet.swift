//
//  ShareSheet.swift
//  KyoNeo
//
//  Created by Aether on 08/04/2023.
//

import SwiftUI
import CoreData
import AmethystUI

struct ImportExportNewView: View {
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

    @FetchRequest(sortDescriptors: []) var weeks: FetchedResults<Week> // Fetches weeks from Core Data
    @FetchRequest(sortDescriptors: []) var days: FetchedResults<Day> // Fetches weeks from Core Data

    @FetchRequest(sortDescriptors: []) var timeSlots: FetchedResults<TimeSlot> // Fetches weeks from Core Data
    @FetchRequest(sortDescriptors: []) var classes: FetchedResults<ClassEntity> // Fetches weeks from Core Data
    @FetchRequest(sortDescriptors: []) var splits: FetchedResults<SplitterEntity> // Fetches weeks from Core Data

    @FetchRequest(sortDescriptors: []) var tasks: FetchedResults<TaskEntity> // Fetches weeks from Core Data

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
                        Text("Currently you have ")
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

                Text("You can export this data, or override it with new data.")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.caption)

                    .padding(.horizontal, 25)
                    .padding(.bottom, 10)

                Group{
                    // FIX: Add explicit view content so this empty Group compiles with the current SDK.
                    // Preserve the original commented-out code below; this addition does not change the UI.
                    EmptyView()
//                Text("The import/export feature is currently in beta testing. Although I've made every effort to ensure the accuracy and functionality of the feature, there may be potential issues that could affect the exported or imported data, including planner entries, classes, weeks, and splitters.")
//                    .padding(.horizontal, 20)
//                    .padding(.bottom, 4)
//                    .font(.caption).opacity(0.5)
//
//                Text("If you encounter any problems, please let me know, and I'll do my best to assist you. I appreciate your understanding and patience as I continue to improve Kyo. Thank you for your support!")
//                    .padding(.horizontal, 20)
//                    .padding(.bottom)
//                    .font(.caption).opacity(0.5)
//
//                Divider()
//                    .padding(.horizontal, 20)
//                    .padding(.bottom)







            }
            }
            .animation(.smoothCard, value: load)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(maxWidth: 700)
            .shadow(color: .primary.opacity(0.05), radius: 13, x: 0, y: 5)

            .coordinateSpace(name: "scroll")
            .safeAreaInset(edge: .bottom, content: {
                HStack{
                    Button {
                        showImportWarning.toggle()
                    } label: {
                        HStack{


                            Label("Import", systemImage: "square.and.arrow.down")
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                    .buttonStyle(PolishedButton(color: color, background: true))
                    .alert("Import Data", isPresented: $showImportWarning, actions: {
                        Button(role: .destructive) {
                            #if !os(macOS)
                            isPresentingImportView.toggle()
                            #else
                            showDocumentPicker()
                            #endif
                        } label: {
                            Text("Continue")
                        }
                        Button {
                            showExportView.toggle()
                        } label: {
                            Text("Export Data")
                        }

                    }, message: {
                        Text("Importing Data will override your existing data")
                    })
                   #if !os(macOS)
                    .sheet(isPresented: $isPresentingImportView) {
                        ImportView(isPresented: $isPresentingImportView)


                    }                            .presentationCornerRadius(25)
#endif






                                Button {
                                    showExportView.toggle()
                                } label: {
                                    HStack{

                                        Label("Export", systemImage: "square.and.arrow.up")
                                            .frame(maxWidth: .infinity, alignment: .center)
                                    }

                                    
                                }
                                .buttonStyle(PolishedButton(color: color))
                                .sheet(isPresented: $showExportView) {
                                    exportPage(color: color)
                                        .presentationCornerRadius(25)

                                }
                }

                .padding(.horizontal, 22)
                .padding(.bottom, 20)
            })

            .frame(maxWidth: 700)
#if os(iOS)
            .safeAreaInset(edge: .top, content: {
                Color.clear.frame(height: 60)
            })
            #endif

            .amethystNavigationBar(title: "Data", titleColor: .primary,   tintColor: color, compactMode: true, overrideType: .back, scrolled: $scrolled, content: {

            }, toolbar: {

            })
        }
        .tint(color)
    }


}
//struct ContentViewTest_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentViewTest(color: .teal)
//    }
//}

import SwiftUI

#if !os(macOS)
struct ImportView: UIViewControllerRepresentable {
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var isPresented: Bool

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let documentPicker = UIDocumentPickerViewController(documentTypes: ["public.json"], in: .import)
        documentPicker.allowsMultipleSelection = false
        documentPicker.delegate = context.coordinator
        return documentPicker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {
        // Nothing to update
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(viewContext: viewContext, isPresented: $isPresented)
    }

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let viewContext: NSManagedObjectContext
        @Binding var isPresented: Bool

        init(viewContext: NSManagedObjectContext, isPresented: Binding<Bool>) {
            self.viewContext = viewContext
            self._isPresented = isPresented
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            do {
                let importer = kn_DataExporterImporter(debug: true)
                try importer.importJSON(from: url)
                isPresented = false
            } catch {
                print("Error importing data: \(error.localizedDescription)")
            }
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            isPresented = false
        }
    }
}
#else

#endif


#if !os(macOS)
struct ExportView: UIViewControllerRepresentable {
    var context: NSManagedObjectContext {
            PersistenceController.shared.container.viewContext
    }
    let onDismiss: () -> Void

    func makeCoordinator() -> Coordinator {
        return Coordinator(context: context, onDismiss: onDismiss)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<ExportView>) -> UIDocumentPickerViewController {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileName = "KyoData"
        let fileURL = url.appendingPathComponent(fileName).appendingPathExtension("json")
        let exportVC = UIDocumentPickerViewController(url: fileURL, in: .exportToService)
        exportVC.delegate = context.coordinator
        exportVC.allowsMultipleSelection = false
        exportVC.shouldShowFileExtensions = true
        return exportVC
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: UIViewControllerRepresentableContext<ExportView>) {
        // no need to update anything here
    }

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let context: NSManagedObjectContext
        let onDismiss: () -> Void

        init(context: NSManagedObjectContext, onDismiss: @escaping () -> Void) {
            self.context = context
            self.onDismiss = onDismiss
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            do {
                try kn_DataExporterImporter( debug: true).importJSON(from: url)
                onDismiss()
            } catch {
                print("Error importing data: \(error.localizedDescription)")
            }
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            onDismiss()
        }
    }
}
#else
#endif
