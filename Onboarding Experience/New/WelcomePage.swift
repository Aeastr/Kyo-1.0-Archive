//
//  WelcomePage.swift
//  KyoNeo
//
//  Created by Aether on 04/04/2023.
//

import SwiftUI
import CoreData

struct Welcome: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var isPresentingImportView = false

    @State private var hueRotationAngle = 0.0
    let maxHueRotationAngle = 360.0

    @AppStorage("showOnboardNeo") var showOnboardNeo = true
    @AppStorage("buildNum") var buildNum = 0

    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "number", ascending: true)],
                  predicate: NSPredicate(format: "singleDayWeek == nil OR singleDayWeek == %@", NSNumber(value: false))
    ) var weeks: FetchedResults<Week>


    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "number", ascending: true),
                                    // Add more sort descriptors if needed
                                   ],
                  predicate: NSPredicate(format: "singleDayWeek == %@", NSNumber(value: true))
    ) var singleDayweeks: FetchedResults<Week>
    var offsetAmount: CGFloat = 0
    @Binding var index: Int
    var body: some View {
  //      ScrollView {
        GeometryReader { geo in
            VStack(alignment: .leading){

                    VStack(alignment: .leading, spacing: 4){
//
//                        if #available(iOS 16.0, *) {
//                            Text("Welcome to ")
//                                .font(.title)
//                                .fontWidth(.expanded)
//                                .fontWeight(.semibold)
//                        } else {
//
//                                Text("Welcome to ")
//                                    .font(Font.title.weight(.semibold))
//                        }
//                        VStack{
//                            if #available(iOS 16.0, *) {
//                                Text("Kyo")
//                                    .font(.system(size: 70))
//                                    .fontWidth(.expanded)
//                                    .fontWeight(.black)
//                                    .foregroundStyle(LinearGradient(gradient: Gradient(colors: [Color("Purples/2"), Color("Purples/1")]), startPoint: /*@START_MENU_TOKEN@*/.leading/*@END_MENU_TOKEN@*/, endPoint: /*@START_MENU_TOKEN@*/.trailing/*@END_MENU_TOKEN@*/))
//
//                            } else {
//                                Text("Kyo")
//                                    .font(Font.title.weight(.black))
//                                    .foregroundStyle(LinearGradient(gradient: Gradient(colors: [Color("Purples/2"), Color("Purples/1")]), startPoint: /*@START_MENU_TOKEN@*/.leading/*@END_MENU_TOKEN@*/, endPoint: /*@START_MENU_TOKEN@*/.trailing/*@END_MENU_TOKEN@*/))
//                            }
//                        }

//                        Text("Please note that Kyo is still in its beta stages, bugs may occur and data may be lost")
//                            .font(.caption)
//                            .padding(.top, 5)
//                            .padding(.trailing, 30)
                    }
                    .padding(.horizontal, 30)
                    .zIndex(1)

                Spacer()

//                VStack(spacing: 20){
//                    HStack(spacing: 30){
//                        EntryTemplate(title: "Physics", room: "5", start: "09:30", end:  "10:00", color1: "b8afea", color2: "d3ddfe")
//                            .frame(width:  geo.size.width)
//                        EntryTemplate(title: "Maths", room: "5", start: "09:30", end:  "10:00", color1: "50aec9", color2: "2f8098")
//                            .frame(width:  geo.size.width)
//                    }
//                    .offset(x: -geo.size.width / 4)
//
//                    HStack(spacing: 30){
//                        EntryTemplate(title: "Free Slot", room: "5", start: "09:30", end:  "10:30", color1: "ffc57c", color2: "f8b0e0")
//                            .frame(width:  geo.size.width)
//                        EntryTemplate(title: "Physics", room: "5", start: "09:30", end:  "10:00", color1: "b8afea", color2: "d3ddfe")
//                            .frame(width:  geo.size.width)
//                    }
//                    .offset(x: geo.size.width / 7)
//
//                    HStack(spacing: 30){
//                        EntryTemplate(title: "Buisness", room: "5", start: "18:30", end:  "20:00", color1: "#ffc67c", color2: "#ffc882")
//                            .frame(width:  geo.size.width)
//                        EntryTemplate(title: "Philosophy", room: "5", start: "09:30", end:  "10:00", color1: "#ffa19c", color2: "#ffe3d2")
//                            .frame(width:  geo.size.width)
//                    }
//                    .offset(x: -geo.size.width / 10)
//
//                    HStack(spacing: 30){
//                        EntryTemplate(title: "Deisgn Technology", room: "5", start: "13:30", end:  "14:00", color1: "#aaebdc", color2: "#aaebdc")
//                            .frame(width:  geo.size.width)
//                        EntryTemplate(title: "Sport", room: "5", start: "09:30", end:  "10:00", color1: "#b0ccee", color2: "#b0ccee")
//                            .frame(width:  geo.size.width)
//                    }
//                    .offset(x: geo.size.width / 3)
//
//                    HStack(spacing: 30){
//                        EntryTemplate(title: "Geography", room: "5", start: "09:30", end:  "10:00", color1: "b8afea", color2: "d3ddfe")
//                            .frame(width:  geo.size.width)
//                        EntryTemplate(title: "Computer Science", room: "5", start: "07:30", end:  "08:30", color1: "#fc97a8", color2: "#fc97a8")
//                            .frame(width:  geo.size.width)
//                    }
//                    .offset(x: -geo.size.width / 3)
//                }
//                .frame(width: geo.size.width, height: geo.size.height / 1.8)
//                .rotationEffect(.degrees(-10))
//
//                .zIndex(0)
//                .offset(x: index == 0 ? 0 : offsetAmount )
                Spacer()

                }


            .safeAreaInset(edge: .top, content: {
                Color.clear.frame(height: 40)
            })
            .safeAreaInset(edge: .bottom) {
                VStack{

                    HStack{


                        Button("Import Data") {
                            isPresentingImportView = true
                        }
                        .padding(.horizontal, 4)
                        .padding(.leading, 4)
                        .buttonStyle(PolishedButton(color: Color("Default/2"), background: false ))
                        .shadow(color: Color("Default/2").opacity(0.15), radius: 10, y: 5)
#if os(iOS) || os(visionOS)
                        .sheet(isPresented: $isPresentingImportView, onDismiss: {
                            
                        }) {
                            ImportViewOnboard(isPresented: $isPresentingImportView)
                                .tint(Color("Default/2"))

                                .presentationCornerRadius(25)
                        }
                        #endif


//                        Button("Skip") {
//                            showOnboardNeo = false
//                        }
//                        .padding(.horizontal, 4)
//                        .padding(.leading, 4)
//                        .buttonStyle(PolishedButton(color: Color("Default/2"), background: false ))
//                        .shadow(color: Color("Default/2").opacity(0.15), radius: 10, y: 5)
//
//                        .sheet(isPresented: $isPresentingImportView, onDismiss: {
//
//                        }) {
//                            ImportViewOnboard(isPresented: $isPresentingImportView)
//                                .tint(Color("Default/2"))
//                        }

                        Button(action: {

                            withAnimation(.smoothCard){
                                index = index + 1
                            }
                        }, label: {
                            Text(weeks.count == 0 ? "Get Started" : "Next")
                                .frame(maxWidth: .infinity, alignment: .center)
                        })
                        .padding(.horizontal, 10)
                        .buttonStyle(PolishedButton(color: Color("Default/2"), background: true))
                        .shadow(color: Color("Default/2").opacity(0.15), radius: 10, y: 5)
                        
                    }.padding(.horizontal, 15)
                    Color.clear.frame(height: 10)
                }
                .offset(x: index == 0 ? 0 : -100)
            }

            .frame(maxWidth: geo.size.width, alignment: .leading)
        }.background(.clear)
 //       }
    }

}

#if os(iOS) || os(visionOS)
struct ImportViewOnboard: UIViewControllerRepresentable {
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
struct HueRotationModifier: AnimatableModifier {
    var angle: Double

    var animatableData: Double {
        get { angle }
        set { angle = newValue }
    }

    func body(content: Content) -> some View {
        content.colorMultiply(Color(hue: angle/360.0, saturation: 1.0, brightness: 1.0))
    }
}
#endif
