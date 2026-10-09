//
//  ClassesSettings.swift
//  KyoNeo
//
//  Created by Aether on 04/05/2023.
//

import SwiftUI
import AmethystUI

struct ClassSplitSelection: Hashable {
    var classEntity: ClassEntity?
    var splitterEntity: SplitterEntity?
}

#if os(iOS)
struct ClassesSettings: View {
    var color: Color = Color.accentColor
    @State var scrolled: Bool = false
    @State var edit: Bool = false
    @State private var numbers = [1,2,3,4,5,6,7,8,9]
    var NavigationBarType: NavigationBarType = .regular

    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)]) var classEntities: FetchedResults<ClassEntity>

    @FetchRequest(sortDescriptors: []) var timeSlots: FetchedResults<TimeSlot>
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)]) var splitters: FetchedResults<SplitterEntity>

    @State private var selectedItems: Set<ClassSplitSelection> = []
    @Environment(\.editMode) var editMode
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showDeleteAlert = false
    @State private var showSingleDeleteAlert = false
    @State private var showSingleDeleteItem: ClassSplitSelection? = nil
    @State var showClassEdit: ClassEntity?
    @State var showClassCreation: Bool = false
    @State var showSplitCreation: Bool = false
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    var allItems: [ClassSplitSelection] {
        classEntities.map { ClassSplitSelection(classEntity: $0) } +
        splitters.map { ClassSplitSelection(splitterEntity: $0) }
    }
    var body: some View {
        ZStack{
            GeometryReader { g in
                ScrollView {
                    ScrollDetector(scrolled: $scrolled)


                    List(selection: $selectedItems) {
                        Section(header: Text("Class Entities")) {
                            ForEach(Array(classEntities.enumerated()), id: \.element) { index, entity in
                                ZStack(alignment: .leading) {
                                    if UIDevice.current.userInterfaceIdiom != .pad{


                                        //                                                    NavigationLink(
                                        //                                                        destination: {
                                        //                                                            ClassComposer(entity: entity)
                                        //                                                                .onAppear{
                                        //
                                        //                                                                        selectedItems = [ClassSplitSelection(classEntity: entity)]
                                        //                                                                }
                                        //                                                                .onDisappear{
                                        //                                                                    selectedItems = []
                                        //                                                                }
                                        //                                                        }
                                        //                                                    ) {
                                        //                                                            EmptyView()
                                        //                                                            .frame(height: 55)
                                        //                                                        }
                                        //
                                        //                                                        .opacity(0)

                                        NavigationLink(value: entity) {
                                            EmptyView()
                                                .frame(height: 55)
                                        }
                                        .opacity(0)

                                        ClassPeelItem(entity: entity, progressOffset: edit ? 0.2 : 0, edit: $edit)

                                            .frame(height: 55)
                                    }
                                    else{
                                        Button {
                                            showClassEdit = entity
                                        } label: {
                                            ClassPeelItem(entity: entity, progressOffset: edit ? 0.2 : 0, edit: $edit)

                                                .frame(height: 55)
                                        }

                                    }




                                }
                                .allowsHitTesting(!(editMode?.wrappedValue.isEditing ?? false))
                                .buttonStyle(BouncyButton())

                                .listRowSeparator(.hidden, edges: [.bottom])
#if os(iOS) || os(visionOS)

                                .listRowSpacing(0)
                                .listRowInsets(EdgeInsets(top: 17, leading: 25, bottom: 17, trailing: 25))
                                .listRowBackground(selectedItems.contains((ClassSplitSelection(classEntity: entity))) && (editMode?.wrappedValue.isEditing ?? false) ? Color.gray.opacity(0.4) : Color.clear)
#else
                                .frame(height: 68)


                                .listRowInsets(EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 15))
                                .listRowBackground(Color(NSColor.windowBackgroundColor).edgesIgnoringSafeArea(.all))
#endif
                                .tag(ClassSplitSelection(classEntity: entity))
                                .swipeActions(edge: .trailing) {
                                    Button() {
                                                                    showSingleDeleteAlert.toggle()
                                                                    showSingleDeleteItem = ClassSplitSelection(classEntity: entity)
                                                                } label: {
                                                                    Label("Delete", systemImage: "trash")
                                                                }
                                                                .tint(.red)

                                                            }
                            }


                        }
                        .listSectionSeparator(.hidden, edges: .top)

                        .alert(isPresented: $showSingleDeleteAlert) {
                                                    Alert(
                                                        title: Text("Are You Sure?"),
                                                        message: Text("Do you want to delete \(showSingleDeleteItem?.classEntity?.name ?? showSingleDeleteItem?.splitterEntity?.name ?? "Untitled")?"),
                                                        primaryButton: .destructive(Text("Delete")) {
                                                            for timeSlot in timeSlots{
                                                                if timeSlot.classEntity == showSingleDeleteItem?.classEntity{
                                                                                                                                              viewContext.delete(timeSlot)
                                                                                                                                          }
                                                                if timeSlot.splitterEntity == showSingleDeleteItem?.splitterEntity{
                                                                    viewContext.delete(timeSlot)
                                                                }
                                                                                                                                      }

                                                            if let item = showSingleDeleteItem?.classEntity ?? showSingleDeleteItem?.splitterEntity  {
                                                                viewContext.delete(item)
                                                            }



                                                                                                                                  do {
                                                                                                                                      try viewContext.save()
                                                                                                                                      print("deleted week entry")
                                                                                                                                  } catch {
                                                                                                                                      let nsError = error as NSError
                                                                                                                                      fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                                                                                                                                  }
                                                        },
                                                        secondaryButton: .cancel({
                                                            showSingleDeleteItem = nil
                                                        })
                                                    )
                                                }

                    }
                    .navigationDestination(for: ClassEntity.self, destination: { classEntity in
                        ClassComposer(entity: classEntity)
                    })
                    .navigationDestination(for: SplitterEntity.self, destination: { splitterEntity in
                        SplitterEdit(entity: splitterEntity)
                    })
                    .listRowSeparator(.hidden, edges: [.bottom])
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .listSectionSeparator(.hidden)
                    .scrollDisabled(!(editMode?.wrappedValue.isEditing ?? false))
                    .frame(maxWidth: 700)
                    .alert(isPresented: $showDeleteAlert) {
                                                Alert(
                                                    title: Text("Are You Sure?"),
                                                    message: Text("Do you want to delete ^[\(selectedItems.count) Item](inflect: true)?"),
                                                    primaryButton: .destructive(Text("Delete")) {
                                                        for item in selectedItems{
                                                            if let itemClass = item.classEntity{
                                                                for timeSlot in timeSlots{
                                                                    if timeSlot.classEntity == itemClass{
                                                                        viewContext.delete(timeSlot)
                                                                    }
                                                                }

                                                                viewContext.delete(itemClass)

                                                            }
                                                            else if let itemSplit = item.splitterEntity{
                                                                for timeSlot in timeSlots{
                                                                    if timeSlot.splitterEntity == itemSplit{
                                                                        viewContext.delete(timeSlot)
                                                                    }
                                                                }

                                                                viewContext.delete(itemSplit)

                                                            }

                                                            do {
                                                                try viewContext.save()
                                                                print("deleted week entry")
                                                            } catch {
                                                                let nsError = error as NSError
                                                                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                                                            }
                                                        }
                                                    },
                                                    secondaryButton: .cancel()
                                                )
                                            }
#if os(iOS) || os(visionOS)
                    .background(Color("bw").edgesIgnoringSafeArea(.all))
#else
                    .background(Color(NSColor.windowBackgroundColor).edgesIgnoringSafeArea(.all))
#endif

                    .frame(width: g.size.width, height: g.size.height + CGFloat((60 * classEntities.count)), alignment: .center)

#if os(iOS) || os(visionOS)
                    .safeAreaInset(edge: .top) {
                        Color.clear.frame(height: horizontalSizeClass == .compact ? 75 : 30)
                    }
#endif
                }
                .animation(.smooth, value: selectedItems)
                .sheet(isPresented: $showClassCreation, content: {
                    ClassComposer(color1: color, color2: color)
                        .presentationCornerRadius(25)
                        .interactiveDismissDisabled()
                })
#if os(iOS) || os(visionOS)

                .coordinateSpace(name: "scroll")
                .amethystNavigationBar(title: VariableDataNames().classesName(), titleColor: .primary,   tintColor: color, scrolled: $scrolled, linelimit: 2, content: {
#if os(iOS) || os(visionOS)
                    if horizontalSizeClass == .compact{
                        EditButton()
                            .buttonStyle(NavigationButton(color: color, scrolled: $scrolled, width: 58, height: 40))
                            .padding(.top, 5)
                            .padding(.bottom, 5)

                            .animation(.smooth, value: (editMode?.wrappedValue.isEditing ?? false))
                            .transition(.blur)
                    }
                    else{
                        EditButton()
                            .tint(color)
                    }
#endif
                    if !(editMode?.wrappedValue.isEditing ?? true){
                        Button {
                            showClassCreation.toggle()
                                                    } label: {
                                                        Image(systemName: "plus")
                                                    }
                        .buttonStyle(NavigationButton(color: color, scrolled: $scrolled, width: 40, height: 40))
                        .padding(.top, 5)
                        .padding(.bottom, 5)
                        .transition(.blur)
                    }

                }, toolbar: {
                    ViewThatFits{
                        Text("\(classEntities.count)")
                    }
                })
                .sheet(item: $showClassEdit, content: { Item in
                    NavigationStack{
                        ClassComposer(entity: Item)

                    }.frame(idealWidth: 570, idealHeight:  640)
                })

#endif

            }


        }
        .toolbar {
            ToolbarItem(placement: .bottomBar) {

                if (editMode?.wrappedValue.isEditing ?? false){
                    HStack{
                        Button {
                            if selectedItems.count == allItems.count {
                                selectedItems.removeAll()
                            } else {
                                selectedItems = Set(allItems)
                            }
                        } label: {
                            Text(selectedItems.count == allItems.count ? "Deselect All" : "Select All")
                        }
                        .buttonStyle(.bordered)
                        Button(role: .destructive) {
                            showDeleteAlert.toggle()
                        } label: {
                            Text("Delete")
                        }
                        #if os(visionOS)
                        .tint(.red.opacity(0.2))
                        #else
                        .tint(.red.opacity(0.8))
                        #endif
                        .buttonStyle(.bordered)
                        .disabled(selectedItems.isEmpty)
                    }

                }

            }
        }


    }

    
}

struct SplitsSettings: View {
    var color: Color = Color.accentColor
    @State var scrolled: Bool = false
    @State var edit: Bool = false
    @State private var numbers = [1,2,3,4,5,6,7,8,9]
    var NavigationBarType: NavigationBarType = .regular

    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)]) var classEntities: FetchedResults<ClassEntity>

    @FetchRequest(sortDescriptors: []) var timeSlots: FetchedResults<TimeSlot>
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)]) var splitters: FetchedResults<SplitterEntity>

    @State private var selectedItems: Set<ClassSplitSelection> = []
    @Environment(\.editMode) var editMode
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showDeleteAlert = false
    @State private var showSingleDeleteAlert = false
    @State private var showSingleDeleteItem: ClassSplitSelection? = nil
    @State var showClassEdit: ClassEntity?
    @State var showClassCreation: Bool = false
    @State var showSplitCreation: Bool = false
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    var allItems: [ClassSplitSelection] {
        classEntities.map { ClassSplitSelection(classEntity: $0) } +
        splitters.map { ClassSplitSelection(splitterEntity: $0) }
    }
    var body: some View {
        ZStack{
            GeometryReader { g in
                ScrollView {
                    ScrollDetector(scrolled: $scrolled)


                    List(selection: $selectedItems) {

                        Section(header: Text("Splitter Entities")) {
                            ForEach(splitters) { entity in
                                NavigationLink(entity.name ?? "Untitled", value: entity)

                                .tag(ClassSplitSelection(splitterEntity: entity))
                                .swipeActions(edge: .trailing) {
                                                                    Button() {
                                                                                                    showSingleDeleteAlert.toggle()
                                                                                                    showSingleDeleteItem = ClassSplitSelection(splitterEntity: entity)
                                                                                                } label: {
                                                                                                    Label("Delete", systemImage: "trash")
                                                                                                }
                                                                                                .tint(.red)

                                                                                            }
                            }
                            .listRowInsets(EdgeInsets(top: 3, leading: 28, bottom: 3, trailing: 25))
                        }.listSectionSeparator(.hidden, edges: .top)
                    }
                    .navigationDestination(for: SplitterEntity.self, destination: { splitterEntity in
                        SplitterEdit(entity: splitterEntity)
                    })
                    .listRowSeparator(.hidden, edges: [.bottom])
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .listSectionSeparator(.hidden)
                    .scrollDisabled(!(editMode?.wrappedValue.isEditing ?? false))
                    .frame(maxWidth: 700)
                    .alert(isPresented: $showDeleteAlert) {
                                                Alert(
                                                    title: Text("Are You Sure?"),
                                                    message: Text("Do you want to delete ^[\(selectedItems.count) Item](inflect: true)?"),
                                                    primaryButton: .destructive(Text("Delete")) {
                                                        for item in selectedItems{
                                                            if let itemClass = item.classEntity{
                                                                for timeSlot in timeSlots{
                                                                    if timeSlot.classEntity == itemClass{
                                                                        viewContext.delete(timeSlot)
                                                                    }
                                                                }

                                                                viewContext.delete(itemClass)

                                                            }
                                                            else if let itemSplit = item.splitterEntity{
                                                                for timeSlot in timeSlots{
                                                                    if timeSlot.splitterEntity == itemSplit{
                                                                        viewContext.delete(timeSlot)
                                                                    }
                                                                }

                                                                viewContext.delete(itemSplit)

                                                            }

                                                            do {
                                                                try viewContext.save()
                                                                print("deleted week entry")
                                                            } catch {
                                                                let nsError = error as NSError
                                                                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                                                            }
                                                        }
                                                    },
                                                    secondaryButton: .cancel()
                                                )
                                            }
#if os(iOS) || os(visionOS)
                    .background(Color("bw").edgesIgnoringSafeArea(.all))
#else
                    .background(Color(NSColor.windowBackgroundColor).edgesIgnoringSafeArea(.all))
#endif

                    .frame(width: g.size.width, height: g.size.height + CGFloat((30 * splitters.count)), alignment: .center)

#if os(iOS) || os(visionOS)
                    .safeAreaInset(edge: .top) {
                        Color.clear.frame(height: horizontalSizeClass == .compact ? 75 : 30)
                    }
#endif
                }
                .animation(.smooth, value: selectedItems)
                .sheet(isPresented: $showSplitCreation, content: {
                    CreateSplitter(color1: color, color2: color)
                        .presentationCornerRadius(25)
                        .interactiveDismissDisabled()
                })
#if os(iOS) || os(visionOS)

                .coordinateSpace(name: "scroll")
                .amethystNavigationBar(title: "Splits", titleColor: .primary,   tintColor: color, scrolled: $scrolled, linelimit: 2, content: {
#if os(iOS) || os(visionOS)
                    if horizontalSizeClass == .compact{
                        EditButton()
                            .buttonStyle(NavigationButton(color: color, scrolled: $scrolled, width: 58, height: 40))
                            .padding(.top, 5)
                            .padding(.bottom, 5)

                            .animation(.smooth, value: (editMode?.wrappedValue.isEditing ?? false))
                            .transition(.blur)
                    }
                    else{
                        EditButton()
                            .tint(color)
                    }
#endif
                    if !(editMode?.wrappedValue.isEditing ?? true){
                        Button {
                            showSplitCreation.toggle()
                                                    } label: {
                                                        Image(systemName: "plus")
                                                    }
                        .buttonStyle(NavigationButton(color: color, scrolled: $scrolled, width: 40, height: 40))
                        .padding(.top, 5)
                        .padding(.bottom, 5)
                        .transition(.blur)
                    }

                }, toolbar: {
                    ViewThatFits{
                        Text("\(splitters.count)")
                    }
                })
                .sheet(item: $showClassEdit, content: { Item in
                    NavigationStack{
                        ClassComposer(entity: Item)

                    }.frame(idealWidth: 570, idealHeight:  640)
                })

#endif

            }


        }
        .toolbar {
            ToolbarItem(placement: .bottomBar) {

                if (editMode?.wrappedValue.isEditing ?? false){
                    HStack{
                        Button {
                            if selectedItems.count == allItems.count {
                                selectedItems.removeAll()
                            } else {
                                selectedItems = Set(allItems)
                            }
                        } label: {
                            Text(selectedItems.count == allItems.count ? "Deselect All" : "Select All")
                        }
                        .buttonStyle(.bordered)
                        Button(role: .destructive) {
                            showDeleteAlert.toggle()
                        } label: {
                            Text("Delete")
                        }
                        #if os(visionOS)
                        .tint(.red.opacity(0.2))
                        #else
                        .tint(.red.opacity(0.8))
                        #endif
                        .buttonStyle(.bordered)
                        .disabled(selectedItems.isEmpty)
                    }

                }

            }
        }


    }

}
#elseif os(visionOS)
struct ClassesSettings: View {
    var color: Color = Color.accentColor
    @State var scrolled: Bool = false
    @State var edit: Bool = false
    @State private var numbers = [1,2,3,4,5,6,7,8,9]
    var NavigationBarType: NavigationBarType = .back


    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)]) var classEntities: FetchedResults<ClassEntity>
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)]) var splitters: FetchedResults<SplitterEntity>

    @FetchRequest(sortDescriptors: []) var timeSlots: FetchedResults<TimeSlot>

    @State private var selectedItems: Set<ClassSplitSelection> = []
    @Environment(\.editMode) var editMode
    @Environment(\.dismiss) var dismiss

    @State var showClassCreation: Bool = false
    @State var showSplitCreation: Bool = false
    @Environment(\.undoManager) var undoManager

    @Environment(\.managedObjectContext) private var viewContext
    @State private var showDeleteAlert = false
    @State var showClassEdit: ClassEntity?
    var allItems: [ClassSplitSelection] {
        classEntities.map { ClassSplitSelection(classEntity: $0) } +
        splitters.map { ClassSplitSelection(splitterEntity: $0) }
    }
    var body: some View {

        List(selection: $selectedItems) {
            Section(header: Text(VariableDataNames().classesName())) {
                //                    Button {
                //                        viewContext.undoManager?.undo()
                //                    } label: {
                //                        Text("undo")
                //                    }
                //                    .onAppear {
                //                         viewContext.undoManager = undoManager
                //                      }

                ForEach(Array(classEntities.enumerated()), id: \.element) { index, entity in
                    Button(action: {
                        showClassEdit = entity
                    }, label: {
                        if let color1String = entity.color1{
                            let color1 = Color(hex: color1String)

                            HStack {
                                Image(systemName: entity.icon ?? "book")
                                    .minimumScaleFactor(0.5)
                                    .frame(width: 35, height: 35, alignment: .center)
                                    .minimumScaleFactor(0.5)
                                    .symbolRenderingMode(.monochrome)
                                    .fontWeight(.regular)
                                    .foregroundColor(color1.getBrightness() > 0.65 ? color1.darken(by: 0.5) : Color.white)
                                    .padding(6)
                                    .background(color1.darken(by: color1.getBrightness() > 0.65 ? -0.2 : 0.2).gradient)
                                    .clipShape(Circle())

                                VStack(alignment: .leading, spacing: 9){
                                    Text(entity.name ?? "Untitled")
                                        .foregroundColor(.primary)
                                    if let array = (Array(entity.tags ?? []) as? [TagItem])?.sorted(by: { $0.name! < $1.name! }), !array.isEmpty {
                                        HStack(spacing: 5){

                                            HStack{
                                                ForEach(array, id: \.self) { tag in
                                                    Text(tag.name ?? "")
                                                        .font(.caption)
                                                        .padding(4)
                                                        .background(color1.darken(by: color1.getBrightness() > 0.65 ? -0.2 : 0.2).gradient)
                                                        .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
                                                        .padding(.vertical, -4)
                                                        .foregroundColor(color1.getBrightness() > 0.65 ? color1.darken(by: 0.5) : Color.white)
                                                }
                                            }

                                        }
                                    }
                                }
                                .padding(.leading, 8)

                            }
                            .padding(.leading, 7)
                            .frame(maxHeight: .infinity, alignment: .center)
                        }
                    })

                    .tag(ClassSplitSelection(classEntity: entity))
                }

            }
            .alert(isPresented: $showDeleteAlert) {
                Alert(
                    title: Text("Are You Sure?"),
                    message: Text("Do you want to delete ^[\(selectedItems.count) Item](inflect: true)?"),
                    primaryButton: .destructive(Text("Delete")) {
                        for item in selectedItems{
                            if let itemClass = item.classEntity{
                                for timeSlot in timeSlots{
                                    if timeSlot.classEntity == itemClass{
                                        viewContext.delete(timeSlot)
                                    }
                                }

                                viewContext.delete(itemClass)

                            }
                            else if let itemSplit = item.splitterEntity{
                                for timeSlot in timeSlots{
                                    if timeSlot.splitterEntity == itemSplit{
                                        viewContext.delete(timeSlot)
                                    }
                                }

                                viewContext.delete(itemSplit)

                            }

                            do {
                                try viewContext.save()
                                print("deleted week entry")
                            } catch {
                                let nsError = error as NSError
                                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                            }
                        }
                    },
                    secondaryButton: .cancel()
                )
            }

            Section(header: Text("Splits")) {
                ForEach(splitters) { entity in
                    NavigationLink(destination: {
                        SplitterEdit(entity: entity)
                            .onAppear{
                                selectedItems = [ClassSplitSelection(splitterEntity: entity)]
                            }
                            .onDisappear{
                                selectedItems = []
                            }
                    }, label: {
                        Text(entity.name ?? "Untitled")
                    })
                    .tag(ClassSplitSelection(splitterEntity: entity))
                }
                .listRowInsets(EdgeInsets(top: 3, leading: 28, bottom: 3, trailing: 25))
            }.listSectionSeparator(.hidden, edges: .top)

        }
        .environment(\.defaultMinListRowHeight, 3)


        .frame(maxWidth: 700)
        .sheet(item: $showClassEdit, content: { Item in
            NavigationStack{
                ClassComposer(entity: Item)

            }.frame(idealWidth: 570, idealHeight:  640)
        })
        .sheet(isPresented: $showClassCreation, content: {
            NavigationStack{
                ClassComposer(color1: color, color2: color)
            }.frame(idealWidth: 570, idealHeight:  640)
        })



        .toolbar(content: {
            ToolbarItem(placement: .destructiveAction) {

                EditButton()
                    .buttonStyle(.bordered)
            }
            ToolbarItem(placement: .primaryAction) {

                if !(editMode?.wrappedValue.isEditing ?? false){
                    Menu(content: {
                        Button {
                            showClassCreation.toggle()
                        } label: {
                            Text("Add Class")
                        }
                        Button {
                            showSplitCreation.toggle()
                        } label: {
                            Text("Add Split")
                        }
                    }, label: {
                        Text("Add")
                    })
                    .menuStyle(.button)
                    .buttonStyle(.bordered)
                }

            }


            ToolbarItem(placement: .bottomBar) {

                if (editMode?.wrappedValue.isEditing ?? false){
                    HStack{
                        Button {
                            if selectedItems.count == allItems.count {
                                selectedItems.removeAll()
                            } else {
                                selectedItems = Set(allItems)
                            }
                        } label: {
                            Text(selectedItems.count == allItems.count ? "Deselect All" : "Select All")
                        }
                        .buttonStyle(.bordered)
                        Button(role: .destructive) {
                            showDeleteAlert.toggle()
                        } label: {
                            Text("Delete")
                        }
                        .tint(.red.opacity(0.2))
                        .buttonStyle(.bordered)
                        .disabled(selectedItems.isEmpty)
                    }

                }

            }



        })
        .amethystNavigationBar(title: "Manage", titleColor: .primary,   tintColor: color, overrideType: (editMode?.wrappedValue.isEditing ?? false) ? .regular : NavigationBarType, scrolled: $scrolled, linelimit: 2, content: {


        }, toolbar: {
//            ViewThatFits{
//                Text("\(classEntities.count) Classes, \(splitters.count) Splits")
//
//                Text("")
//            }
        })
        .toolbar {
            ToolbarItem(placement: .bottomOrnament) {
                            ViewThatFits{
                                Text("\(classEntities.count) Classes, \(splitters.count) Splits")
                            }
            }
        }

    }
}
struct SplitsSettings: View {
    var color: Color
    var body: some View {
        Text("uhm")
    }
}
#elseif os(macOS)
struct ClassesSettings: View {
    var color: Color = Color.accentColor
    @State var scrolled: Bool = false
    @State var edit: Bool = false
    @State private var numbers = [1,2,3,4,5,6,7,8,9]

    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)]) var classEntities: FetchedResults<ClassEntity>
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)]) var splitters: FetchedResults<SplitterEntity>

    @State private var selectedItems: Set<ClassSplitSelection> = []

    var body: some View {
        NavigationSplitView(columnVisibility: .constant(.all)){
            GeometryReader { g in
                ScrollView {
                    ScrollDetector(scrolled: $scrolled)


                    List(selection: $selectedItems) {
                        Section(header: Text("Class Entities")) {
                            ForEach(Array(classEntities.enumerated()), id: \.element) { index, entity in
                                ZStack(alignment: .leading) {



                                    NavigationLink(
                                        destination: {
                                            NavigationStack{
                                                ClassComposer(entity: entity)
                                            }
                                            .id(entity.id!)
                                        }
                                    ) {
                                        EmptyView()
                                            .frame(height: 55)
                                    }

                                    .opacity(0)


                                    ClassPeelItem(entity: entity, progressOffset: edit ? 0.2 : 0, edit: $edit)

                                        .frame(height: 55)





                                }


                                .buttonStyle(BouncyButton())

                                .listRowSeparator(.hidden, edges: [.bottom])

                                .frame(height: 68)


                                .listRowInsets(EdgeInsets(top: index == 0 ? 5 : 0, leading: 10, bottom: 0, trailing: 10))
                                .listRowBackground(Color("bw").edgesIgnoringSafeArea(.all))

                                .tag(ClassSplitSelection(classEntity: entity))
                            }

                        }
                        .listSectionSeparator(.hidden, edges: .top)

                        Section(header: Text("Splitter Entities")) {
                            ForEach(splitters) { entity in
                                NavigationLink(destination: {
                                    SplitterEdit(entity: entity)

                                }, label: {
                                    Text(entity.name ?? "Untitled")
                                })
                                .tag(ClassSplitSelection(splitterEntity: entity))
                            }
                            .listRowInsets(EdgeInsets(top: 3, leading: 28, bottom: 3, trailing: 25))
                        }.listSectionSeparator(.hidden, edges: .top)
                    }

                    .listRowSeparator(.hidden, edges: [.bottom])
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .listSectionSeparator(.hidden)


                    .frame(width: g.size.width, height: g.size.height, alignment: .center)

                }
                .background(Color("bw").ignoresSafeArea())
                .animation(.smooth, value: selectedItems)
#if os(iOS) || os(visionOS)
                .toolbar(.hidden)
                .coordinateSpace(name: "scroll")
                .overlay(alignment: .top){
                    FluidNavigationBar(title: VariableDataNames().classesName(), titleColor: .primary,  type: .back, scrolled: $scrolled, content: {
#if os(iOS) || os(visionOS)
                        EditButton()
                            .buttonStyle(NavigationButton(color: color, scrolled: $scrolled, width: 58, height: 44))
#endif
                        Button {

                        } label: {
                            Text("Add")
                        }
                        .buttonStyle(NavigationButton(color: color, scrolled: $scrolled, width: 55, height: 44))

                    }, toolbar: {

                    })
                }
#endif

            }
            .frame(minWidth: 280)


        } detail: {

            Text("Select a Class/Split, or create a new one below")
                .padding(.bottom, 20)
            HStack(spacing: 15){
                NavigationLink {

                    NavigationStack{
                        ClassComposer()
                    }
                } label: {
                    VStack(alignment: .center, spacing: 10){
                        Image(systemName: "plus.square")
                        Text("New\nClass")
                            .multilineTextAlignment(.center)
                    }
                    .frame(width: 80, height: 80)
                    .aspectRatio(1, contentMode: .fit)
                    .background(Color.gray.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                }
                .buttonStyle(.plain)

                NavigationLink {
                    CreateSplitter()
                } label: {
                    VStack(alignment: .center, spacing: 10){
                        Image(systemName: "plus.square")
                        Text("New\nSplit")
                            .multilineTextAlignment(.center)
                    }
                    .frame(width: 80, height: 80)
                    .aspectRatio(1, contentMode: .fit)
                    .background(Color.gray.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                }
                .buttonStyle(.plain)


            }
        }

#if os(macOS)
        .navigationTitle((VariableDataNames().classesAndSplitsName()))
#else

        .toolbar(.hidden)
#endif

    }

}
#endif

struct ClassesSettings_Previews: PreviewProvider {
    static var previews: some View {
        ClassesSettings(color: .red)
    }
}


struct classListItemPreview: View {
    var title: String
    var title2: String?
    var icon: String
    var color1: String
    var color2: String
    @State var enableShadow = true
    @Environment(\.colorScheme) var colorScheme

    @AppStorage("darkenText") var darkenText = false
    @Environment(\.managedObjectContext) private var viewContext


    var body: some View {
        GeometryReader { geo in


            let c1 = Color(hex: color1)
            let brightness1 = (darkenText ? Color(hex: color1).getBrightness() : 0.0)
            let brightness2 = (darkenText ? Color(hex: color2).getBrightness() : 0.0)

            ZStack {
                if !darkenText && (Color(hex: color1).getBrightness() > 0.85 || Color(hex: color1).getBrightness() > 0.85){
                    LinearGradient(gradient: Gradient(colors: [Color.getAdjustedColor(color: Color(hex: color1), colorScheme: colorScheme, factor: 2).moreSaturated(factor: 4), Color.getAdjustedColor(color: Color(hex: color2), colorScheme: colorScheme, factor: 2).moreSaturated(factor: 4)]), startPoint: .topLeading, endPoint: .bottomTrailing)

                        .mask(
                            RoundedRectangle(cornerRadius: 25, style: .continuous)

                        )
                }
                else{
                    LinearGradient(gradient: Gradient(colors: [Color(hex: color1 ), Color(hex: color2)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                        .mask(
                            RoundedRectangle(cornerRadius: 25, style: .continuous)

                        )
                }
                //  .shadow(color: Color(hex: entity.color1 ?? "98C6D1").opacity(enableShadow ? 0.5 : 0), radius: 4, x:0, y: 4)

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: icon)
                            .symbolRenderingMode(/*@START_MENU_TOKEN@*/.hierarchical/*@END_MENU_TOKEN@*/)
                            .font(.system(size: 23))
                            .padding(10)
                            .frame(width: 50, height: 50)
                            .foregroundColor(brightness1 > 0.85 ? c1.darken(by: 0.5) : Color.white)
                            .padding(.trailing, 3)
                        VStack(alignment: .leading){

                            Text(title)
                            //   .strikethrough(past ? true : false)
                                .textCase(.uppercase)
                                .font(Font.body.weight(.semibold))
                                .lineLimit(2)
                                .minimumScaleFactor(0.5)
                                .foregroundColor(brightness1 > 0.85 ? c1.darken(by: 0.5) : Color.white)
                                .lineSpacing(1)
                                .multilineTextAlignment(.leading)
                            if let title2 = title2{
                                Text(title2)
                                //   .strikethrough(past ? true : false)
                                    .textCase(.uppercase)
                                    .font(Font.caption.weight(.regular))
                                    .lineLimit(2)
                                    .minimumScaleFactor(0.5)
                                    .foregroundColor(brightness1 > 0.85 ? c1.darken(by: 0.5) : Color.white)
                                    .lineSpacing(1)
                                    .multilineTextAlignment(.leading)
                            }

                        }
                        Spacer()

                        //                            Image(systemName: "chevron.forward")
                        //
                        //
                        //                                .font(.body.weight(.regular))
                        //                                .foregroundColor(brightness2 > 0.85 ? Color.black : Color.white)
                        //                            .padding(.leading, 6)

                    }

                }
                .padding(.leading, 11)
                .padding(.trailing, 25)
                .padding(.vertical, 10)

            }

        }
        .frame(height: 70 )

    }



}


//
//  ClassesSettings.swift
//  KyoNeo
//
//  Created by Aether on 04/05/2023.
//

//import SwiftUI
//import AmethystUI
//
//struct ClassSplitSelection: Hashable {
//    var classEntity: ClassEntity?
//    var splitterEntity: SplitterEntity?
//}
//
//
//
//
//#if os(iOS) || os(visionOS)
//struct ClassesSettings: View {
//
//    var color: Color = Color.accentColor
//    @State var edit: Bool = false
//    @State private var numbers = [1,2,3,4,5,6,7,8,9]
//    var NavigationBarType: NavigationBarType = .back
//
//    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)]) var classEntities: FetchedResults<ClassEntity>
//    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)]) var splitters: FetchedResults<SplitterEntity>
//
//    @State private var selectedItems: Set<ClassSplitSelection> = []
//    @Environment(\.editMode) var editMode
//    @Environment(\.dismiss) var dismiss
//
//    @State private var currentPosition: CGFloat = 0
//    @State private var previousPosition: CGFloat = 0
//    @State private var scrolled = false
//    private let coordinateSpaceName = UUID()
//
//    let items = Array(1...100).map { String($0) }
//
//    var body: some View {
//
//            List {
//                Group {
//                    Section(header: Text("Class Entities")) {
//                        ForEach(Array(classEntities.enumerated()), id: \.element) { index, entity in
//                            ZStack(alignment: .leading) {
//
//
//
//                                NavigationLink(
//                                    destination: {
//                                        ClassComposer(entity: entity)
//                                            .onAppear{
//
//                                                    selectedItems = [ClassSplitSelection(classEntity: entity)]
//                                            }
//                                            .onDisappear{
//                                                selectedItems = []
//                                            }
//                                    }
//                                ) {
//                                        EmptyView()
//                                        .frame(height: 55)
//                                    }
//
//                                    .opacity(0)
//
//
//                                ClassPeelItem(entity: entity, progressOffset: edit ? 0.2 : 0, edit: $edit)
//
//                                    .frame(height: 55)
//
//
//
//
//
//                        }
//                            .allowsHitTesting(!(editMode?.wrappedValue.isEditing ?? false))
//                            .buttonStyle(BouncyButton())
//
//                            .listRowSeparator(.hidden, edges: [.bottom])
//                            #if os(iOS) || os(visionOS)
//
//                            .listRowSpacing(0)
//                            .listRowInsets(EdgeInsets(top: 17, leading: 25, bottom: 17, trailing: 25))
//                            .listRowBackground(selectedItems.contains((ClassSplitSelection(classEntity: entity))) && (editMode?.wrappedValue.isEditing ?? false) ? Color.gray.opacity(0.4) : Color.clear)
//                            #else
//                            .frame(height: 68)
//
//
//                            .listRowInsets(EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 15))
//                            .listRowBackground(Color(NSColor.windowBackgroundColor).edgesIgnoringSafeArea(.all))
//                            #endif
//                                .tag(ClassSplitSelection(classEntity: entity))
//
//                        }
//
//                    }
//                    Text("\(scrolled.description)")
//                }
//                .background(
//                    GeometryReader { proxy in
//                        Color.clear
//                            .preference(key: ScrollPreferenceKey.self, value: proxy.frame(in: .named("scroll")).minY)
//                    }
//                )
//            }
//            .coordinateSpace(name: "scroll")
//            .onPreferenceChange(ScrollPreferenceKey.self, perform: { value in
//                withAnimation(.spring(response: 0.1, dampingFraction: 3)) {
////                    scrollValue = Int(value)
//                    print(value)
//                    scrolled = value < 200
////                    scrolledFar = value < scrollFarTrigger
//                }
//            })
//            .toolbar(.hidden)
//            .overlay(
//                FluidNavigationBar(title: "Test", titleColor: .primary, scrolled: $scrolled, content: {
//
//                }, toolbar: {
//
//                })
//                )
//        }
//
//}
//
//#else
//struct ClassesSettings: View {
//    var color: Color = Color.accentColor
//    @State var scrolled: Bool = false
//    @State var edit: Bool = false
//    @State private var numbers = [1,2,3,4,5,6,7,8,9]
//
//    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)]) var classEntities: FetchedResults<ClassEntity>
//    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)]) var splitters: FetchedResults<SplitterEntity>
//
//    @State private var selectedItems: Set<ClassSplitSelection> = []
//
//        var body: some View {
//            NavigationSplitView(){
//                GeometryReader { g in
//                    ScrollView {
//                        ScrollDetector(scrolled: $scrolled)
//
//
//                        List(selection: $selectedItems) {
//                                        Section(header: Text("Class Entities")) {
//                                            ForEach(Array(classEntities.enumerated()), id: \.element) { index, entity in
//                                                ZStack(alignment: .leading) {
//
//
//
//                                                    NavigationLink(
//                                                        destination: {
//                                                            ClassComposer(entity: entity)
//                                                                .onAppear{
//
//                                                                        selectedItems = [ClassSplitSelection(classEntity: entity)]
//                                                                }
//                                                                .onDisappear{
//                                                                    selectedItems = []
//                                                                }
//                                                        }
//                                                    ) {
//                                                            EmptyView()
//                                                            .frame(height: 55)
//                                                        }
//
//                                                        .opacity(0)
//
//
//                                                    ClassPeelItem(entity: entity, progressOffset: edit ? 0.2 : 0, edit: $edit)
//
//                                                        .frame(height: 55)
//
//
//
//
//
//                                            }
//
//
//                                                .buttonStyle(BouncyButton())
//
//                                                .listRowSeparator(.hidden, edges: [.bottom])
//
//                                                .frame(height: 68)
//
//
//                                                .listRowInsets(EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 15))
//                                                .listRowBackground(Color(NSColor.windowBackgroundColor).edgesIgnoringSafeArea(.all))
//
//                                                    .tag(ClassSplitSelection(classEntity: entity))
//                                            }
//
//                                        }
//                                        .listSectionSeparator(.hidden, edges: .top)
//
//                                        Section(header: Text("Splitter Entities")) {
//                                            ForEach(splitters) { entity in
//                                                NavigationLink(destination: {
//                                                    SplitterEdit(entity: entity)
//
//                                                }, label: {
//                                                    Text(entity.name ?? "Untitled")
//                                                })
//                                                .tag(ClassSplitSelection(splitterEntity: entity))
//                                            }
//                                            .listRowInsets(EdgeInsets(top: 3, leading: 28, bottom: 3, trailing: 25))
//                                        }.listSectionSeparator(.hidden, edges: .top)
//                                    }
//                        .listRowSeparator(.hidden, edges: [.bottom])
//                        .listStyle(.plain)
//                        .scrollContentBackground(.hidden)
//                        .listSectionSeparator(.hidden)
//
//
//                        .frame(width: g.size.width, height: g.size.height, alignment: .center)
//
//                    }
//                    .background(Color(NSColor.windowBackgroundColor).ignoresSafeArea())
//                    .animation(.smooth, value: selectedItems)
//#if os(iOS) || os(visionOS)
//.toolbar(.hidden)
//.coordinateSpace(name: "scroll")
//.overlay(
//    FluidNavigationBar(title: VariableDataNames().classesName(), titleColor: .primary,  type: .back, scrolled: $scrolled, content: {
//        #if os(iOS) || os(visionOS)
//        EditButton()
//            .buttonStyle(NavigationButton(color: color, scrolled: $scrolled, width: 58, height: 44))
//        #endif
//        Button {
//
//        } label: {
//            Text("Add")
//        }
//        .buttonStyle(NavigationButton(color: color, scrolled: $scrolled, width: 55, height: 44))
//
//    }, toolbar: {
//
//    })
//)
//#endif
//
//                }
//
//
//            } detail: {
//                Text("Select a Class or Split to edit")
//            }
//
//#if os(macOS)
//            .navigationTitle("Classes & Splits")
//            #else
//
//            .toolbar(.hidden)
//#endif
//
//        }
//
//}
//#endif
//
//struct ClassesSettings_Previews: PreviewProvider {
//    static var previews: some View {
//        ClassesSettings(color: .red)
//    }
//}
//
//
//struct classListItemPreview: View {
//    var title: String
//    var title2: String?
//    var icon: String
//    var color1: String
//    var color2: String
//    @State var enableShadow = true
//    @Environment(\.colorScheme) var colorScheme
//
//    @AppStorage("darkenText") var darkenText = false
//    @Environment(\.managedObjectContext) private var viewContext
//
//
//    var body: some View {
//        GeometryReader { geo in
//
//
//            let c1 = Color(hex: color1)
//            let brightness1 = (darkenText ? Color(hex: color1).getBrightness() : 0.0)
//            let brightness2 = (darkenText ? Color(hex: color2).getBrightness() : 0.0)
//
//            ZStack {
//                if !darkenText && (Color(hex: color1).getBrightness() > 0.85 || Color(hex: color1).getBrightness() > 0.85){
//                    LinearGradient(gradient: Gradient(colors: [Color.getAdjustedColor(color: Color(hex: color1), colorScheme: colorScheme, factor: 2).moreSaturated(factor: 4), Color.getAdjustedColor(color: Color(hex: color2), colorScheme: colorScheme, factor: 2).moreSaturated(factor: 4)]), startPoint: .topLeading, endPoint: .bottomTrailing)
//
//                        .mask(
//                            RoundedRectangle(cornerRadius: 25, style: .continuous)
//
//                        )
//                }
//                else{
//                    LinearGradient(gradient: Gradient(colors: [Color(hex: color1 ), Color(hex: color2)]), startPoint: .topLeading, endPoint: .bottomTrailing)
//                        .mask(
//                            RoundedRectangle(cornerRadius: 25, style: .continuous)
//
//                        )
//                }
//                  //  .shadow(color: Color(hex: entity.color1 ?? "98C6D1").opacity(enableShadow ? 0.5 : 0), radius: 4, x:0, y: 4)
//
//                    VStack(alignment: .leading, spacing: 4) {
//                        HStack {
//                            Image(systemName: icon)
//                            .symbolRenderingMode(/*@START_MENU_TOKEN@*/.hierarchical/*@END_MENU_TOKEN@*/)
//                                .font(.system(size: 23))
//                                .padding(10)
//                                .frame(width: 50, height: 50)
//                                .foregroundColor(brightness1 > 0.85 ? c1.darken(by: 0.5) : Color.white)
//                                .padding(.trailing, 3)
//                            VStack(alignment: .leading){
//
//                                        Text(title)
//                                        //   .strikethrough(past ? true : false)
//                                            .textCase(.uppercase)
//                                            .font(Font.body.weight(.semibold))
//                                            .lineLimit(2)
//                                            .minimumScaleFactor(0.5)
//                                            .foregroundColor(brightness1 > 0.85 ? c1.darken(by: 0.5) : Color.white)
//                                            .lineSpacing(1)
//                                            .multilineTextAlignment(.leading)
//                                if let title2 = title2{
//                                    Text(title2)
//                                    //   .strikethrough(past ? true : false)
//                                        .textCase(.uppercase)
//                                        .font(Font.caption.weight(.regular))
//                                        .lineLimit(2)
//                                        .minimumScaleFactor(0.5)
//                                        .foregroundColor(brightness1 > 0.85 ? c1.darken(by: 0.5) : Color.white)
//                                        .lineSpacing(1)
//                                        .multilineTextAlignment(.leading)
//                                }
//
//                            }
//                            Spacer()
//
////                            Image(systemName: "chevron.forward")
////
////
////                                .font(.body.weight(.regular))
////                                .foregroundColor(brightness2 > 0.85 ? Color.black : Color.white)
////                            .padding(.leading, 6)
//
//                        }
//
//                    }
//                    .padding(.leading, 11)
//                    .padding(.trailing, 25)
//                    .padding(.vertical, 10)
//
//            }
//
//        }
//        .frame(height: 70 )
//
//    }
//
//
//
//}
