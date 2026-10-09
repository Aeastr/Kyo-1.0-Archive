//
//  ManageTeachers.swift
//  KyoNeo
//
//  Created by Aether on 21/07/2023.
//

import SwiftUI
import AmethystUI

#if !os(visionOS)
struct ManageTeachers: View {
    // Fetch request properties to retrieve weeks, days, and timeSlots
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)]) var teachers: FetchedResults<TeacherEntity>
    @State private var selectedTeacher: TeacherEntity?

    // Environment properties for managing the view context and dismissing the view
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss

    // State properties for managing the week creation process and scrolling
    @State var weekCreate = false
    @State var scrollValue = 0.0
    @State var scrolled: Bool = false

    @State var teacherName: String = ""
    @State var teacherNameAdd: String = ""
    @State var confirmDelete: Bool = false

    @State private var isOptionsAlertPresented = false
    @State private var isRenameAlertPresented = false
    @State private var showCreateAlert = false

    // State property for managing the edit mode
    var back = true
    var color: Color = Color("1")

    // FIX: Read the local Pro preview setting, defaulting to on; no purchase checks are used.

    @AppStorage("archivePlusEnabled") private var kyoPlus_hasPlus = true
    @State var kyoPlus_showPurchaseScreen: Bool = false

    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    // Main body of the view
    var body: some View {

                // ScrollView to display the list of weeks
                ScrollView {
                    // Scroll detection view to handle scroll events
                    ScrollDetector(scrolled: $scrolled)

                    // VStack to display the list of weeks
                    VStack(spacing: 0) {
                        // Loop through the fetched weeks
                        ForEach(teachers) { teacher in
                            teacherItem(entity: teacher, color: color)
                                .onTapGesture {
                                    teacherName = teacher.name ?? ""
                                                        selectedTeacher = teacher
                                                        isOptionsAlertPresented = true

                                                    }
                        }
                        .alert("Are you sure?", isPresented: $confirmDelete) {
                            Button("Delete", role: .destructive, action: {
                                            if let selectedTeacher = selectedTeacher{
                                                viewContext.delete(selectedTeacher)
                                            }

                                            do {
                                                try viewContext.save()
                                            } catch {
                                                let nsError = error as NSError
                                                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                                            }
                                        })
                            Button("Cancel", role: .cancel) { }

                                    }
                    }
                    // Style the VStack with a neo-field card appearance
                    .buttonStyle(.plain)
                    .padding(.horizontal, 2)
                    .padding(5)
                #if !os(visionOS)
                    .background {
                        Color("NeoButton").opacity(0.6)
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                            .regularOutline(cornerRadius: 18)

                    }
                #else
                    .background(.regularMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .regularOutline(cornerRadius: 18)
                #endif


                    .padding(.horizontal, 20)
                    .frame(maxWidth: 700)
                    .alert("\(selectedTeacher?.name ?? "No Name")", isPresented: $isOptionsAlertPresented) {
                        Button("Rename", action: {isRenameAlertPresented.toggle()})
                        Button("Delete", role: .destructive, action: {
                            confirmDelete.toggle()

                        })
                        Button("Cancel", role: .cancel, action: {})
                    }
                }
                .safeAreaInset(edge: .bottom, content: {

                               KyoPlusButtonBinding(color: color, kyoPlus_hasPlus: $kyoPlus_hasPlus, kyoPlus_showPurchaseScreen: $kyoPlus_showPurchaseScreen, text: "Upgrade to Kyo+ to attach teachers to entries", emoji: "🍎", rotation: -10, position: CGPoint(x: 10 ,y: 8), actionIfNot: {

                               })
                                              .padding(.bottom, 10)
                                      })
                .alert("Teacher", isPresented: $isRenameAlertPresented) {
                                TextField("Enter Teacher name", text: $teacherName)
                                Button("Update",action: {
                                    selectedTeacher?.name = teacherName

                                    do {
                                        try viewContext.save()
                                    } catch {
                                        let nsError = error as NSError
                                        fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                                    }
                                })
                    Button("Cancel", role: .cancel) { }

                            }
                .alert("Teacher", isPresented: $showCreateAlert) {
                                TextField("Enter Teacher name", text: $teacherNameAdd)
                                Button("Add",action: {
                                    let newTeacher = TeacherEntity(context: viewContext)
                                    newTeacher.id = UUID()
                                    newTeacher.name = teacherNameAdd

                                    do {
                                        try viewContext.save()
                                    } catch {
                                        let nsError = error as NSError
                                        fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                                    }
                                })
                    Button("Cancel", role: .cancel) { }

                            }

                .coordinateSpace(name: "scroll")
        #if os(iOS)
                .safeAreaInset(edge: .top, content: {
                    AdjustableInset(compactSize: 80)
                })
        #endif
                .amethystNavigationBar(title: "Teachers", titleColor: .primary, scrolled: $scrolled) {

                    if horizontalSizeClass == .compact{
                        Button {
                            showCreateAlert = true
                        } label: {

                            Image(systemName: "plus")
#if os(iOS)
                                .scaledFrame(width: 42, height: 42, relativeTo: .body)
#endif
                        }

#if os(iOS)
                        .buttonStyle(NavigationButton(color: color, scrolled: $scrolled))
#endif
                    }
                    else{
                        Button {
                                                  showCreateAlert = true
                                              } label: {

                                                  Image(systemName: "plus")
                                              }

                                          
                    }

                        if !back{

                            Button {
                                dismiss()
                            } label: {
                                Text("Done")
                                    .scaledFrame(width: nil, height: 42, relativeTo: .body, alignment: .leading)
                                    .padding(.horizontal, 15)
                                    .contentShape(Rectangle())

                            }
                            .buttonStyle(NavigationButton(color: color, scrolled: $scrolled))
                            .transition(.blur)

                            //                                    .padding(.horizontal, -15)
                        }



                }toolbar: {
                    #if !os(visionOS)
                    ViewThatFits{
                        Text("^[\(teachers.count) Teacher](inflect: true)")
                            .transition(.blur.animation(.smooth))
                    }
                    .transition(.blur.animation(.smooth))
                    .scaledFrame(width: nil, height: 42, relativeTo: .body, alignment: .leading)
                    #endif

                }
#if os(visionOS)
                .toolbar {
                    ToolbarItem(placement: .bottomOrnament) {
                            Text("^[\(teachers.count) Teacher](inflect: true)")
                    }
                }
#endif
#if os(iOS)
                .tint(color)
#endif
    }
}
#else
struct ManageTeachers: View {
    // Fetch request properties to retrieve weeks, days, and timeSlots
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)]) var teachers: FetchedResults<TeacherEntity>
    @State private var selectedTeacher: TeacherEntity?

    // Environment properties for managing the view context and dismissing the view
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss

    // State properties for managing the week creation process and scrolling
    @State var weekCreate = false
    @State var scrollValue = 0.0
    @State var scrolled: Bool = false

    @State var teacherName: String = ""
    @State var teacherNameAdd: String = ""
    @State var confirmDelete: Bool = false

    @State private var isOptionsAlertPresented = false
    @State private var isRenameAlertPresented = false
    @State private var showCreateAlert = false

    // State property for managing the edit mode
    var back = true
    var color: Color = Color("1")

    // FIX: Read the local Pro preview setting, defaulting to on; no purchase checks are used.

    @AppStorage("archivePlusEnabled") private var kyoPlus_hasPlus = true
    @State var kyoPlus_showPurchaseScreen: Bool = false

    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    // Main body of the view
    var body: some View {

                // ScrollView to display the list of weeks
        List(content: {
            ForEach(teachers) { teacher in
                Button {
                    teacherName = teacher.name ?? ""
                                                                                       selectedTeacher = teacher
                                                                                       isOptionsAlertPresented = true

                } label: {
                    Label(teacher.name ?? "Untitled", systemImage: "person")
                }



                                    }
                                    .alert("Are you sure?", isPresented: $confirmDelete) {
                                        Button("Delete", role: .destructive, action: {
                                                        if let selectedTeacher = selectedTeacher{
                                                            viewContext.delete(selectedTeacher)
                                                        }

                                                        do {
                                                            try viewContext.save()
                                                        } catch {
                                                            let nsError = error as NSError
                                                            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                                                        }
                                                    })
                                        Button("Cancel", role: .cancel) { }

                                                }
        })
        .alert("\(selectedTeacher?.name ?? "No Name")", isPresented: $isOptionsAlertPresented) {
                               Button("Rename", action: {isRenameAlertPresented.toggle()})
                               Button("Delete", role: .destructive, action: {
                                   confirmDelete.toggle()

                               })
                               Button("Cancel", role: .cancel, action: {})
                           }
                .safeAreaInset(edge: .bottom, content: {

                               KyoPlusButtonBinding(color: color, kyoPlus_hasPlus: $kyoPlus_hasPlus, kyoPlus_showPurchaseScreen: $kyoPlus_showPurchaseScreen, text: "Upgrade to Kyo+ to attach teachers to entries", emoji: "🍎", rotation: -10, position: CGPoint(x: 10 ,y: 8), actionIfNot: {

                               })
                                              .padding(.bottom, 10)
                                      })
                .alert("Teacher", isPresented: $isRenameAlertPresented) {
                                TextField("Enter Teacher name", text: $teacherName)
                                Button("Update",action: {
                                    selectedTeacher?.name = teacherName

                                    do {
                                        try viewContext.save()
                                    } catch {
                                        let nsError = error as NSError
                                        fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                                    }
                                })
                    Button("Cancel", role: .cancel) { }

                            }
                .alert("Teacher", isPresented: $showCreateAlert) {
                                TextField("Enter Teacher name", text: $teacherNameAdd)
                                Button("Add",action: {
                                    let newTeacher = TeacherEntity(context: viewContext)
                                    newTeacher.id = UUID()
                                    newTeacher.name = teacherNameAdd

                                    do {
                                        try viewContext.save()
                                    } catch {
                                        let nsError = error as NSError
                                        fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                                    }
                                })
                    Button("Cancel", role: .cancel) { }

                            }

                .coordinateSpace(name: "scroll")
        #if os(iOS)
                .safeAreaInset(edge: .top, content: {
                    Color.clear.frame(height: 80)
                })
        #endif
                .amethystNavigationBar(title: "Teachers", titleColor: .primary, overrideType: back ? .back : .regular, scrolled: $scrolled) {

                    if horizontalSizeClass == .compact{
                        Button {
                            showCreateAlert = true
                        } label: {

                            Image(systemName: "plus")
#if os(iOS)
                                .scaledFrame(width: 42, height: 42, relativeTo: .body)
#endif
                        }

#if os(iOS)
                        .buttonStyle(NavigationButton(color: color, scrolled: $scrolled))
#endif
                    }
                    else{
                        Button {
                                                  showCreateAlert = true
                                              } label: {

                                                  Image(systemName: "plus")
                                              }


                    }

                        if !back{

                            Button {
                                dismiss()
                            } label: {
                                Text("Done")
                                    .scaledFrame(width: nil, height: 42, relativeTo: .body, alignment: .leading)
                                    .padding(.horizontal, 15)
                                    .contentShape(Rectangle())

                            }
                            .buttonStyle(NavigationButton(color: color, scrolled: $scrolled))
                            .transition(.blur)

                            //                                    .padding(.horizontal, -15)
                        }



                }toolbar: {
                    #if !os(visionOS)
                    ViewThatFits{
                        Text("^[\(teachers.count) Teacher](inflect: true)")
                            .transition(.blur.animation(.smooth))
                    }
                    .transition(.blur.animation(.smooth))
                    .scaledFrame(width: nil, height: 42, relativeTo: .body, alignment: .leading)
                    #endif

                }
#if os(visionOS)
                .toolbar {
                    ToolbarItem(placement: .bottomOrnament) {
                            Text("^[\(teachers.count) Teacher](inflect: true)")
                    }
                }
#endif
#if os(iOS)
                .tint(color)
#endif
    }
}
#endif

//#Preview {
//    ManageTeachers()
//}

struct teacherItem: View {
    var entity: TeacherEntity
    var color: Color
    @State var dragX: Double = 0.0
    @State var dragXOffset: Double = 0.0
    @State var mid = false
    @State var hideItem = false
    @State var confirmDelete: Bool = false
    @State var haptic = false
    @State var width = 0.0
    @State var dragged = false
    @State var enableShadow = true
    @Environment(\.colorScheme) var colorScheme

    @AppStorage("automaticWeek") var automaticWeek = true
    @AppStorage("askToSetUpAutoSwitch") var askToSetUpAutoSwitch : Bool = true

    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "number", ascending: true)],
                  predicate: NSPredicate(format: "singleDayWeek == nil OR singleDayWeek == %@", NSNumber(value: false))
    ) var weeks: FetchedResults<Week>


    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "number", ascending: true),
                                    // Add more sort descriptors if needed
                                   ],
                  predicate: NSPredicate(format: "singleDayWeek == %@", NSNumber(value: true))
    ) var singleDayweeks: FetchedResults<Week>
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "number", ascending: true)]) var days: FetchedResults<Day>
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "timestamp", ascending: true)]) var timeSlots: FetchedResults<TimeSlot>

    @Environment(\.managedObjectContext) private var viewContext


    var body: some View {
        if !hideItem{
            GeometryReader { geo in
                
                
                HStack(alignment: .center, spacing: 0) {

                        Image(systemName: "person")

                            .fontWeight(.bold)
                            .foregroundColor(color)
                            .padding(.leading, 13)
                            .padding(.trailing, 6)

                    if let name = entity.name{
                        Text(name.capitalized(with: .autoupdatingCurrent))
                            .foregroundColor(.primary)

                            
                            .textContentType(.name)
                    }

                        
                        Spacer()
                        
                        
                        
                        Image(systemName: "circle.dotted")

                            .font(Font.body.bold())
                            .foregroundColor(color)
                            .padding(.leading, 6)
                            .padding(.trailing, 13)
                        
                    }
                    
                        .frame(minHeight:  50)
                        .contentShape(Rectangle())
                        .background(Color("bw"))
                        .offset(x:  dragX + dragXOffset)
                        .background(
                            
                            
                            HStack{
                                Spacer()
                                ZStack(alignment: .leading) {
                                    Color.red
                                }
                                
                                .frame(width:
                                        

                                        dragged ?
                                       (-(dragX + dragXOffset)) < 80 ?
                                       80:
                                        (-(dragX + dragXOffset)) > geo.size.width ?
                                       geo.size.width
                                       :
                                        -(dragX + dragXOffset)
                                       
                                       :
                                        
                                        80
                                )
                                
                                
                                //  .frame(height: 70 )
                                
                                
                                //    .frame(minHeight: 50)
                                .onTapGesture {
                                    withAnimation(.smoothCard){
                                        
                                        // dragX = -500.0
                                        
                                        confirmDelete = true
                                        dragX = -(geo.size.width)
                                        dragXOffset = 0
                                    }
                                }
                                .overlay{
                                    HStack{
                                        Image(systemName: "minus.circle.fill")
                                            .foregroundColor(.white)
                                        Spacer()
                                    }
                                    .padding(.horizontal)

                                }
                                
                            }
                            
                            
                        )
                                .gesture(
                
                                    DragGesture(minimumDistance: 30)
                
                                        .onChanged({ drag in
                                            print(drag.translation.width)
                                            if drag.translation.width > -250 - dragXOffset{
                                                withAnimation(.linear){
                                                    dragged = true
                                                    dragX = drag.translation.width / 1.7
                                                    haptic = false
                                                }
                                            }
                                            if drag.translation.width < -250 - dragXOffset{
                                                withAnimation(.linear){
                                                    dragX = drag.translation.width * 1.3
                                                    haptic = true
                                                }
                                            }
                                            withAnimation(.smoothCard){
                
                
                
                                            }
                                        })
                                        .onEnded({ drag in
                
                                            haptic = false
                                            if drag.translation.width < -70 && drag.translation.width > -250 - dragXOffset{
                                                withAnimation(.smoothCard){
                                                    dragX = 0.0
                                                    dragXOffset = -100
                
                                                }
                                            }
                                            else if drag.translation.width > -250 - dragXOffset {
                                                withAnimation(.closeCard){
                                                    dragX = 0.0
                                                    dragXOffset = 0.0
                                                    dragged = false
                                                }
                                            }
                
                                            else if drag.translation.width < -250 - dragXOffset {
                                                withAnimation(.smoothCard){
                
                                                    // dragX = -500.0
                
                                                    confirmDelete = true
                                                    confirmDelete = true
                                                    dragX = -(geo.size.width)
                                                    dragXOffset = 0
                                                }
                                            }
                
                
                                        })
                                )


                    
                    
                }
                .frame(minHeight:  50)
                
#if os(iOS) || os(visionOS)
    .actionSheet(isPresented: $confirmDelete) {
        ActionSheet(
            title: Text("Are you sure you want to remove " + (entity.name ?? "No Name") + "?"),
            buttons: [
                .destructive(Text("Remove " + (entity.name ?? "No Name"))) {
                    withAnimation(.closeCard) {
                        viewContext.delete(entity)
                        dragged = false
                        hideItem = true
                    }

                    do {
                        try viewContext.save()
                    } catch {
                        let nsError = error as NSError
                        fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                    }
                },

                .cancel() {
                    withAnimation(.closeCard) {
                        dragged = false
                        dragX = 0.0
                        dragXOffset = 0.0
                    }
                }
            ]
        )
    }
#else
    .alert(isPresented: $confirmDelete) {
        Alert(
            title: Text("Are you sure you want to remove " + (entity.name ?? "No Name") + "?"),
            primaryButton: .destructive(Text("Remove " + (entity.name ?? "No Name"))) {
                withAnimation(.closeCard) {
                    viewContext.delete(entity)
                    dragged = false
                    hideItem = true
                }

                do {
                    try viewContext.save()
                } catch {
                    let nsError = error as NSError
                    fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                }
            },
            secondaryButton: .cancel() {
                withAnimation(.closeCard) {
                    dragged = false
                    dragX = 0.0
                    dragXOffset = 0.0
                }
            }
        )
    }
#endif

#if os(iOS)
                .onChange(of: haptic) { newValue in
                    
                    let impactMed = UIImpactFeedbackGenerator(style: .soft)
                    impactMed.impactOccurred()
                    
                }
            #endif

                
            }
            
        }
        
        
        

}
