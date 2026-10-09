//
//  CreateTask.swift
//  KyoNeo
//
//  Created by Aether on 02/04/2023.
//

import SwiftUI
import AmethystUI

struct TaskWorkshop: View{

    //classes logic
    @State var selectedClass: ClassEntity?
    @State var editMode = false
    var entity: TaskEntity?
    @State var selectedType: TaskTypeEntity?
    @State var showClassEdit: Bool = false
    @State var attemptedCreate: Bool = false
    @State var showClassCreate: Bool = false
    @State var showTypeCreate: Bool = false
    @Environment(\.managedObjectContext) private var viewContext
    @State var cancelCheckAlert: Bool = false
    enum FocusField: Hashable {
    case title
    case notes
        case none
    }
    // State variable for focus state
    @FocusState private var focusedField: FocusField?


    @State var scrolled: Bool = false
    @State var dateEdit: Bool = false
    @State var time: Date = Date()
    @State var color1: Color = .red
    @State var color2: Color = .orange
    @State var title: String = ""
    @State var notes: String = ""
    @State var attachedLink: String = ""
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)]) var classes: FetchedResults<ClassEntity>
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "title", ascending: true)]) var taskTypes: FetchedResults<TaskTypeEntity>
    @State var muted: Bool = false

    init(entity: TaskEntity? = nil, editMode: Bool = false, color: Color = .primary) {
            self.entity = entity
            self._selectedType = .init(initialValue: entity?.taskType)
            self._selectedClass = .init(initialValue: entity?.classEntity)
            self._time = .init(initialValue: entity?.due ?? Date())
        self._color1 = .init(initialValue: color)
        self._color2 = .init(initialValue: color)

            self._title = .init(initialValue: entity?.label ?? "")
            self._notes = .init(initialValue: entity?.notes ?? "")
        if let attachedLink = entity?.link{
            self._attachedLink = .init(initialValue: attachedLink)
        }
            self._editMode = .init(initialValue: editMode)
        if let muted = entity?.muted{
            self._muted = .init(initialValue: muted)
        }
    }
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    init(selectedClass: ClassEntity?){
        print("should init with class")
        print("class init \(selectedClass)")
        if let selectedClass = selectedClass {
            self._selectedClass = .init(initialValue: selectedClass)

//            if let c1 = selectedClass.color1{
//                self._color1 = .init(initialValue: Color(hex: (c1)))
//            }
//            else{
//                self._color1 = .init(initialValue: .red)
//            }
//
//            if let c2 = selectedClass.color2{
//                self._color2 = .init(initialValue: Color(hex: (c2)))
//            }
//            else{
//                self._color2 = .init(initialValue: .red)
//            }
        }
    }

    var body: some View{
        ZStack{

                Color("bw")
                    .opacity(0.6)
                    .ignoresSafeArea()
            .onTapGesture {
                focusedField = .none
            }
        ScrollView{


            ScrollDetector(scrolled: $scrolled)
            VStack{


                VStack{
                    HStack{
                        Text("Title")
                            .sectionTitle()
                        Spacer()
                        Image(systemName: "exclamationmark.circle")
                            .textCase(.uppercase)
                            .font(Font.caption.weight(.regular))
                            .opacity(attemptedCreate ? title == "" ? 1 : 0 : 0)

                    }
                    .foregroundColor(attemptedCreate ? title == "" ? .red : .primary : .primary)

                    TextField("Add a title..", text: $title)
                        .lineLimit(3)
                        .padding(.leading, 13)
                        .padding(.trailing, 5)
#if !os(visionOS)
            .neoFieldCard(color: color2)
#else
            .padding(.vertical, 13.5)
            .background(Color.white.opacity(0.3))
            .clipShape(Capsule())
#endif
                        .focused($focusedField, equals: .title)
                        .onAppear {
                            if entity == nil{
                                self.focusedField = .title
                            }
                                }
                }
                    .padding(.horizontal, 20)

                typeSelector

                VStack{

                        HStack{
                            Text("Category")
                                .sectionTitle()
                            Spacer()

                        }

                    Menu {
                        Picker(selection: $selectedType) {
                            Text("None")
                                .tag(nil as TaskTypeEntity?)
                            ForEach(taskTypes) { type in
                                Label(type.title ?? "Untitled \(type.id)", systemImage: type.icon ?? "square")
                                    .symbolRenderingMode(.hierarchical)
                                    .tag(type as TaskTypeEntity?)


                            }
                        } label: {

                        }

                        Section{
                            Button {
                                focusedField = .none
                                showTypeCreate.toggle()
                            } label: {
                                Label("New Category", systemImage: "plus")
                            }
                        }

                    } label: {
                        HStack(spacing: 0) {
                            Image(systemName: selectedType != nil ? selectedType?.icon ?? "filemenu.and.selection" :"filemenu.and.selection")

                                .frame(width: 20, height: 15)
                                .font(Font.body.weight(.semibold))
#if !os(visionOS)
                        .padding(.leading, 13)
                        .foregroundColor(color1)
#endif
                                .padding(.trailing, 5)
                                .animation(.smooth, value: selectedType)
                            Text(selectedType != nil ? selectedType?.title ?? "Untitled \(selectedType?.id)" : "Select Category")
#if !os(visionOS)
                            .foregroundColor(color2)
#endif

#if os(iOS) || os(visionOS)
                            .autocapitalization(.none)
                            .textContentType(.name)
                            
#endif
                            Spacer()
                        }
#if !os(visionOS)
                .neoFieldCard(color: color1)
#else
                .padding(.vertical, 14)

#endif
                    }
                        
                }
                .padding(.horizontal, 20)
                .sheet(isPresented: $showTypeCreate) {
                    NavigationStack{
                        CreateCategory(color1: color1 , color2: color2)
                    }
                    .presentationCornerRadius(25)
                }



                VStack{
                    HStack{
                        Text("Due")
                            .sectionTitle()

                        let state = TimeHelper.getTaskTemplateTimeState(due: time)

                                Label {
                                    Text(state.rawValue.capitalized)
                                } icon: {
                                    Image(systemName: state.symbol)
                                }


                            .textCase(.uppercase)
                            .font(Font.caption.weight(.regular))
#if !os(visionOS)
                            .foregroundColor(color1)
#else
                            .foregroundColor(Color.primary)
#endif



                    }
                        Button {
                            focusedField = .none
                            dateEdit.toggle()
                        } label: {
                            #if !os(visionOS)
                            SegmentedTime(selectedDate: $time,title: "",type: .timeDate ,maxWidth: 150, color: color1)
                            #else
                            SegmentedTime(selectedDate: $time,title: "",type: .timeDate ,maxWidth: 150, color: Color.primary)
                            #endif

                        }.buttonStyle(bounceButton())
                    

                }
                .padding(.horizontal, 20)


                VStack{
                    Text("Notes")
                        .sectionTitle()

                    TextField("Add some notes about the task..", text: $notes,axis: .vertical)
                        .lineLimit(5...10)
                        .padding(.leading, 10)
                                                .padding(.trailing, 10)
            #if !os(visionOS)
                        .neoFieldCard(color: color2)
            #else
                        .padding(.vertical, 13.5)
                        .background(Color.white.opacity(0.3))
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            #endif
                        .focused($focusedField, equals: .notes)
                }
                    .padding(.horizontal, 20)

                VStack{
                    Text("Link")
                        .sectionTitle()
                    TextField("Attach a link to your task", text: $attachedLink)
                        .autocorrectionDisabled()
#if os(iOS) || os(visionOS)
                        .textInputAutocapitalization(.never)
                    #endif
                        .lineLimit(3)
                        .padding(.leading, 13)
                        .padding(.trailing, 5)
#if !os(visionOS)
            .neoFieldCard(color: color2)
#else
            .padding(.vertical, 13.5)
            .background(Color.white.opacity(0.3))
            .clipShape(Capsule())
#endif
                        .focused($focusedField, equals: .notes)
                }
                    .padding(.horizontal, 20)


//                VStack{
//
//                    Text("Notifications")
//                        .sectionTitle()
//                Toggle(isOn: $muted) {
//                    HStack{
//                        Image(systemName: "app.badge.fill")
//                            .frame(width: 20, alignment: .center)
//                            .symbolRenderingMode(/*@START_MENU_TOKEN@*/.hierarchical/*@END_MENU_TOKEN@*/)
//                            .foregroundColor(color2)
//
//                    VStack(alignment: .leading, spacing: 3){
//                        Text("Muted")
//                            .frame(maxWidth: .infinity, alignment: .leading)
//                    }
//                }
//                }
//                .padding(.horizontal, 13)
////                .tint(color2)
//                .neoFieldCard()
//
//                }
//                .padding(.horizontal, 20)

            }
#if os(iOS)
            .safeAreaInset(edge: .top, content: {
                Color.clear.frame(height: horizontalSizeClass == .compact ? 90 : 50)
            })
            #endif
            .safeAreaInset(edge: .bottom, content: {
                Color.clear.frame(height: 30)
            })
            .sheet(isPresented: $showClassCreate) {
                NavigationStack{
                    ClassComposer(passThroughClass: $selectedClass)
                }
                        .presentationCornerRadius(25)
            }
            .onAppear{
                if let selectedClass = selectedClass{
                    if let c1 = selectedClass.color1{

                        withAnimation(.smooth){
                            color1 = Color.getAdjustedColor(color: Color(hex: (c1)), colorScheme: colorScheme)
                        }
                    }


                    if let c2 = selectedClass.color2{

                        withAnimation(.smooth){
                            color2 = Color.getAdjustedColor(color: Color(hex: (c2)), colorScheme: colorScheme)
                        }
                    }

                }
                else{
                    withAnimation(.smooth){
                        color1 = Color.getAdjustedColor(color: color1, colorScheme: colorScheme)
                        color2 = Color.getAdjustedColor(color: color2, colorScheme: colorScheme)
                    }
                }
            }
            .onChange(of: selectedClass){
                if let selectedClass = selectedClass{
                    if let c1 = selectedClass.color1{
                        withAnimation(.smooth){
                            color1 = Color.getAdjustedColor(color: Color(hex: (c1)), colorScheme: colorScheme)
                        }
                    }


                    if let c2 = selectedClass.color2{
                        withAnimation(.smooth){
                            color2 = Color.getAdjustedColor(color: Color(hex: (c2)), colorScheme: colorScheme)
                        }
                    }

                }
                else{
                    withAnimation(.smooth){
                        color1 = Color.getAdjustedColor(color: color1, colorScheme: colorScheme)
                        color2 = Color.getAdjustedColor(color: color2, colorScheme: colorScheme)
                    }
                }
            }
            .onChange(of: colorScheme){
                if let selectedClass = selectedClass{
                    if let c1 = selectedClass.color1{
                       color1 = Color.getAdjustedColor(color: Color(hex: (c1)), colorScheme: colorScheme)
                    }


                    if let c2 = selectedClass.color2{
                        color2 = Color.getAdjustedColor(color: Color(hex: (c2)), colorScheme: colorScheme)
                    }

                }
                else{
                    color1 = Color.getAdjustedColor(color: color1, colorScheme: colorScheme)
                    color2 = Color.getAdjustedColor(color: color2, colorScheme: colorScheme)
                }
            }

        }
        .coordinateSpace(name: "scroll")
       
        .alert("Hold on", isPresented: $cancelCheckAlert, actions: {

            Button(role: .cancel) {

            } label: {
                Text("Keep Editing")
            }
            Button(role: .destructive) {
                dismiss()
            } label: {
                Text("Discard")
            }


        }, message: {
            Text(entity == nil ? "Are you sure you want to discard this draft?" : "Are you sure you want to discard your edits?")
        })
        .sheet(isPresented: $dateEdit, content: {
            ZStack{
                Color.clear
                    .background(.ultraThinMaterial)
                    .background(color1.opacity(colorScheme == .dark ? 0.3 : 0.55))


                    DatePicker(selection: $time) {
                    }
                    .labelsHidden()
                    .datePickerStyle(.graphical)
#if os(visionOS)
                    .frame(maxHeight: .infinity, alignment: .bottom)
                    .padding(.bottom, 20)
#endif
//                    .tint(color2)

        }
            .presentationDetents([.fraction(0.55)])
            .presentationBackground(.clear)
            .ignoresSafeArea()
            .presentationDragIndicator(.visible)
#if os(iOS)
            .presentationCornerRadius(max(0, cornerRadiusForDevice() - 10))
            #else
            .frame(width: 500, height: 600)
            .overlay(alignment: .topTrailing, content: {
                Button {
                    dateEdit.toggle()
                                                        } label: {
                                                            Image(systemName: "xmark")
                                                        }
                                                        .padding(25)
            })
            #endif
        })

//        .sheet(isPresented: $dateEdit, content: {
//            ZStack{
//
//
////                let color2 = Color.getAdjustedColor(color: Color(hex: selectedClass?.color2 ?? color2.hexString!), colorScheme: colorScheme)
//
//
//
//                    DatePicker(selection: $time) {
//                    }
//                    .labelsHidden()
//                    .datePickerStyle(.graphical)
//                    .tint(color2)
//                    .padding(25)
//                    .background(.ultraThinMaterial)
//                    .background(color1.opacity(colorScheme == .dark ? 0.3 : 0.55))
//                    .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
//                    .padding(25)
//                    .frame(maxHeight: .infinity, alignment: .bottom)
//                    .padding(.bottom, 5)
//
//
//
//
//
//
//        }
//            .presentationDetents([.fraction(0.52)])
//
//            .presentationBackground(.clear)
//            .ignoresSafeArea()
//            .presentationDragIndicator(.visible)
//            .presentationCornerRadius(25)
//        })
    }

        .amethystNavigationBar(title: entity != nil ? "Edit Task" : selectedClass != nil ? "\(selectedClass?.name ?? "Untitled") Task" : "New Task",titleColor: .primary,   tintColor: color1, compactMode: true, overrideType: .regular, scrolled: $scrolled, inSheet: true) {
            navBarContent
            #if os(iOS)
                .padding(.trailing, -5)
                .padding(.top, 15)

            .padding(.bottom, -3)
            #endif
        }toolbar: {
            Button {
                if let entity = entity{
                    if selectedType != entity.taskType || selectedClass != entity.classEntity || entity.notes != notes || title != entity.label{
                            cancelCheckAlert.toggle()
                    }
                    else{
                        dismiss()
                    }
                }
                else if selectedType != nil || title != "" || selectedClass != nil || notes != "" || title != "" {
                    cancelCheckAlert.toggle()
                }
                else{
                    dismiss()
                }

            } label: {

                if let entity = entity{
                    Text((selectedType != entity.taskType || selectedClass != entity.classEntity || entity.notes != notes || title != entity.label) ? "Discard Edits" : "Cancel")
#if os(iOS)
                        .foregroundColor(color2)
                        .font(.body.weight(.regular))
                        .scaledFrame(width: nil, height: 44, relativeTo: .body, alignment: .leading)
                        .padding(.trailing)
                        .contentTransition(.numericText())
                        .animation(.smooth, value: (selectedType != entity.taskType || selectedClass != entity.classEntity || entity.notes != notes || title != entity.label))
                    #endif
                }
                else{
                    Text((selectedType != nil || title != "" || selectedClass != nil || notes != "" || title != "") ? "Discard" : "Cancel")
                    #if os(iOS)
                        .foregroundColor(color2)
                        .font(.body.weight(.regular))
                        .scaledFrame(width: nil, height: 44, relativeTo: .body, alignment: .leading)
                        .padding(.trailing)
                        .contentTransition(.numericText())
                        .animation(.smooth, value: (selectedType != nil || title != "" || selectedClass != nil || notes != "" || title != ""))
                    #endif
                }
            }

            .scaledFrame(width: nil, height: 44, relativeTo: .body, alignment: .leading)
#if os(iOS)
            .padding(.top, 15)

        .padding(.bottom, -5)
        .buttonStyle(bounceButton())
            #endif
        }

        
    }

    func checkInput() -> Bool{
        if title != "" {

            return true
        }
        attemptedCreate = true
        return false
    }
    
    var navBarContent: some View{
        HStack(spacing: 13){




            Button {
                if checkInput(){
                    createTask()

                    dismiss()
                }
            } label: {
                Text(entity != nil ? "Save" : "Create")
                    .font(.body.weight(.regular))
#if os(iOS)
                    .scaledFrame(width: entity != nil ? 60 : 80, height: 44, relativeTo: .body)
                #endif

            }
#if os(iOS)
            .buttonStyle(NavigationButton(color: color1, scrolled: $scrolled))
            #endif
        }
    }

    var typeSelector: some View{
        VStack{

            //            let color2 = Color.getAdjustedColor(color: Color(hex: selectedClass?.color2 ?? color2.hexString!), colorScheme: colorScheme)


            HStack{
                Text("Class")
                    .sectionTitle()

                    .sheet(isPresented: $showClassEdit) {
                        if let selectedClass = selectedClass{
                            if let c1 = selectedClass.color1{
                                color1 = Color.getAdjustedColor(color: Color(hex: (c1)), colorScheme: colorScheme)
                            }


                            if let c2 = selectedClass.color2{
                                color2 = Color.getAdjustedColor(color: Color(hex: (c2)), colorScheme: colorScheme)
                            }

                        }
                        else{
                            color1 = Color.getAdjustedColor(color: color1, colorScheme: colorScheme)
                            color2 = Color.getAdjustedColor(color: color2, colorScheme: colorScheme)
                        }
                    } content: {
                        ClassComposer(entity: selectedClass, passThroughClass: $selectedClass)
                            .presentationCornerRadius(25)
                    }

#if !os(visionOS)

                Button {
                    focusedField = .none
                    showClassEdit.toggle()
                } label: {
                    Text(selectedClass != nil ? selectedClass?.name?.count ?? 0 <= 16 ?  "Edit \(selectedClass?.name ?? "Class")".shortened(maxLength: 19) :"Edit \(selectedClass?.shortName ?? "Class")".shortened(maxLength: 19) : "")

                        .foregroundColor(color1)


                        .font(.caption)
                        .fontWeight(.semibold)
                        .padding(.bottom, 6)
                        .padding(.top, 8)
                        .padding(.vertical,  3)


                }
#endif

            }


            .padding(.horizontal, 20)
            HStack{
            Menu {

                Section(VariableDataNames().classesName()){
                    Picker(selection: $selectedClass) {
                        Text("None")
                            .tag(nil as ClassEntity?)
                        ForEach(classes, id: \.self) { c in
                            HStack{
                                Text(c.name ?? "")
                                Image(systemName: c.icon ?? "book.closed")
                            }
                            .tag(c as ClassEntity?)
                        }
                    } label: {

                    }

                }
                Divider()
                Button {
                    focusedField = .none
                    showClassCreate.toggle()
                } label: {
                    Text(VariableDataNames().newClassName())
                    Image(systemName: "plus")
                }



            } label: {

                HStack(spacing: 0) {
                    Image(systemName: selectedClass != nil ? (selectedClass?.icon ?? "book.closed") : "character.cursor.ibeam")

                        .frame(width: 20, height: 15)
                        .font(Font.body.weight(.semibold))
#if !os(visionOS)
                        .padding(.leading, 13)
                        .foregroundColor(color1)
#endif
                        .padding(.trailing, 5)
                    Text(selectedClass != nil ? (selectedClass?.name ?? "Untitled") :"Select Class" )
                        .lineLimit(1)
#if !os(visionOS)
                        .foregroundColor(color1)
#endif

#if os(iOS) || os(visionOS)
                        .autocapitalization(.none)
                        .textContentType(.name)
#endif
                    Spacer()
                }
#if !os(visionOS)
                .neoFieldCard(color: color1)
#else
                .padding(.vertical, 14)

#endif
            }


#if os(visionOS)
                if let name = selectedClass?.name {
                    Button {

                        showClassEdit.toggle()


                    } label: {

                        Text("Edit \(name)")
                            .transition(.blur.animation(.smooth))
                            .padding(.vertical, 13)
                    }

                }
#endif
        }
            .padding(.horizontal, 20)

            
        }
    }

    func createTask(){
        let notificationHelper = NotificationHelper()

        if entity == nil{
            let task = TaskEntity(context: viewContext)
            task.classEntity = selectedClass
            task.taskType = selectedType
            if attachedLink != ""{
                task.link = attachedLink
            }
            task.due = time
            task.notes = notes
            task.label = title
            task.muted = muted

            if !muted{
                notificationHelper.makeTaskNotification(for: task) { result in
                    print(result)
                    switch result {
                    case .success(let success):
                        print("Notification(s) created successfully: \(success)")
                    case .failure(let error):
                        let errorMessage = error.reason
                        print("Error: \(errorMessage)")
                        // Present an alert or show the error message to the user
                    }
                }
            }
        }
        else{
            if let task = entity{
                notificationHelper.cancelTaskNotifications(for: task)
                task.classEntity = selectedClass
                task.taskType = selectedType
                if attachedLink != ""{
                    task.link = attachedLink
                }
                task.due = time
                task.notes = notes
                task.label = title
                task.muted = muted

                if !muted{
                notificationHelper.makeTaskNotification(for: task) { result in
                    print(result)
                    switch result {
                    case .success(let success):
                        print("Notification(s) created successfully: \(success)")
                    case .failure(let error):
                        let errorMessage = error.reason
                        print("Error: \(errorMessage)")
                        // Present an alert or show the error message to the user
                    }
                }
            }
            }
        }

        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }

        

    }
}
