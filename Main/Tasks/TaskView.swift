//
//  TaskView.swift
//  KyoNeo
//
//  Created by Aether on 11/01/2023.
//

// _fetchRequest = FetchRequest<TimeSlot>(sortDescriptors: [NSSortDescriptor(key: "timestamp", ascending: true)], predicate: NSPredicate(format:"day.name = %@ AND day.week.number = %i", dayName, weekNum))

import SwiftUI
import AmethystUI
import ConfettiSwiftUI




struct TaskView: View {
    //core data
    @Environment(\.managedObjectContext) private var viewContext
    @State var showArchive: Bool = false
    @State var scrolled: Bool = false
    @State var searchText: String = ""
    @State var searchTextDummy: String = ""
    @State var scrolledValue: Double = 0.0
    @State var scrolledValue2: Double = 0.0
    @State var showTaskCreation: Bool = false
    @State var edit: Bool = false
    @State var categoryCreate: Bool = false
    @State var manageCategories: Bool = false

    @AppStorage("Selected Task Type") var selectedTaskType: taskTimeState = .upcoming

    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "due", ascending: true)]) var tasks: FetchedResults<TaskEntity>


    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)]) var classes: FetchedResults<ClassEntity>

    @AppStorage("alwaysShowButtons") var alwaysShowButtons = false
    @AppStorage("global_Compact") var global_Compact  = false

    @State var selectedTasksEdit: Set<TaskEntity> = []

    @State var taskCreationClass: ClassEntity? = nil

    @State var showSearch: Bool = true
    @State var searchMode: Bool = false
    @State var searchMode2: Bool = false

    //nav color logic
    var color: Color = .red

    @State var show: Bool = false

    @State var cardShow = false

    //general models

    @State private var counter: Int = 0

    @AppStorage("filtersActive") private var filtersActive: Bool = false
    @AppStorage("rememberFilters") private var rememberFilters: Bool = false

    @AppStorage("showEmptyTaskClassCategories") private var showEmptyTaskClassCategories: Bool = false

    @AppStorage("selectedClassesID") private var selectedClassesID: Set<String> = []

    @AppStorage("selectedStatus") private var selectedStatus: Set<String> = []

    @AppStorage("selectedTaskSortingOption") private var selectedTaskSortingOption: TaskSortingOption = .due

    @AppStorage("selectedTaskSortingPolarity") private var selectedTaskSortingPolarity: SortingOptionPolarity = .ascending

    @AppStorage("selectedCategories") private var selectedCategories: Set<String> = []
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    var body: some View {
        ScrollView(showsIndicators: true) {


            var allCases: [taskTimeState] {
                var cases: [taskTimeState] = [
                    selectedTaskType
                ]


                return cases
            }

            let index = 0
            ScrollDetector(scrolled: $scrolled)
            VStack{
            LazyVStack(spacing: global_Compact ? 0 : 5){
               

                let filteredAndSortedClasses = classes.filter { classEntity in
                    return (!selectedClassesID.isEmpty ? selectedClassesID.contains(classEntity.id?.uuidString ?? "") : true)
                }.sorted {
                    switch selectedTaskSortingPolarity {
                    case .ascending:
                        // Replace `propertyName` with the actual property you want to sort by
                        return $0.name! < $1.name!
                    case .descending:
                        // Replace `propertyName` with the actual property you want to sort by
                        return $0.name! > $1.name!
                    }
                }


                ForEach(filteredAndSortedClasses, id: \.id) { classData in
                    let tasksFilter = tasks.filter{ task in
                        return
                        
                        (task.classEntity?.name == classData.name)
                        
                        && (selectedStatus.isEmpty ? true : selectedStatus.contains(TimeHelper.getTaskTimeState(task: task).rawValue))
                        
                        && !task.archived
                        && (searchText != "" ? task.label?.lowercased().contains(searchText.lowercased()) ?? false : true)
                        
                        
                    }.sorted {$0.due! < $1.due!}
                    
                    if !tasksFilter.isEmpty{
                        Text("\(classData.name ?? "Untitled Class")")

                            .padding(.horizontal, 20)
                            .sectionTitle()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .zIndex(2)
                    }

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 300))], spacing: 10) {
                    ForEach(Array(tasksFilter.enumerated()), id: \.element) { index, task in
                        if let dueDate = task.due{

                            ZStack{
                                TaskItem(data: task)
                                //                                            Text(task.label ?? "No label")
//                                    .padding(.horizontal, global_Compact ? 0 : 28)
                                
                                
//                                    .padding(.vertical,global_Compact ? 0 : 3)
                                
                                    .transition((global_Compact ? AnyTransition.blurWithoutScale : AnyTransition.blur).animation(.bouncy))
                                    .allowsHitTesting(!edit)
                                
                            }
                            .contentShape(Rectangle())
                            .onTapGesture(perform: {
                                if edit{
                                    print("YA ")
                                    selectedTasksEdit.insert(task)
                                }
                            })
                            .zIndex(1)
                            //                                            .animation(.bouncy(duration: 0.35))
                            
                        }
                    }
                    .animation(.bouncy(duration: 0.35, extraBounce: -0.5), value: selectedClassesID)
                    .animation(.bouncy(duration: 0.35, extraBounce: -0.5), value: selectedStatus)
                    .animation(.bouncy(duration: 0.35, extraBounce: -0.5), value: showEmptyTaskClassCategories)
                }.padding(.horizontal, global_Compact ? 0 : 28)


                    if tasksFilter.isEmpty && showEmptyTaskClassCategories{
                        Text("\(classData.name ?? "Untitled Class")")
                            .sectionTitle()
                            .padding(.horizontal, 20)
                            .transition(.blurWithoutScale.animation(.smooth))


                        LazyVStack{
                            HStack(spacing: 2){
                                Button {
                                    taskCreationClass = classData
                                } label: {
                                    Label("Add Task", systemImage: "plus")
                                        .foregroundColor(color)
                                        .font(.caption.weight(.bold))
                                }
                                .contentShape(Rectangle())
                                .sheet(item: $taskCreationClass) { item in
                                    NavigationStack{
                                        TaskWorkshop(selectedClass: item)
                                            .frame(idealWidth: 570, idealHeight:  640)
                                    }
                                                .interactiveDismissDisabled()
                                    .presentationCornerRadius(25)
                                }




                            }

                        }
                        .frame(height: 30)
                        .frame(maxWidth: .infinity)
                        .neoSettingsCard()
                        .padding(.horizontal, 30)
                        .transition(.blurWithoutScale.animation(.smooth))

                    }



                }

                if tasks.isEmpty{
                    LazyVStack{

                        Text("No tasks, add a task with ")
                            .font(.caption)
                        +
                        Text(Image(systemName: "plus"))
                            .foregroundColor(color)
                            .font(.footnote)
                            .bold()

                        +
                        Text(" to get started")
                            .font(.caption)

                    }

                    .frame(height: 18)
                    .frame(maxWidth: .infinity)
                    .neoSettingsCard()
                    .padding(.horizontal, 28)
                    .padding(.vertical, 2)
                    .overlay(content: {
                        Image("cat2paws")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 45)
                            .foregroundStyle(Color("bw"))
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .offset(y: -37)
                            .padding(.trailing, 8)
                            .padding(.horizontal, 28)
                    })
                    .overlay(content: {
                        Image("cat2")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 45)
                            .foregroundStyle(Color.primary)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .offset(y: -37)
                            .padding(.trailing, 13)
                            .padding(.horizontal, 28)
                            .opacity(0.30)
                    })
                    .padding(.top, 35)
                }



                let tasksFilter = tasks.filter { task in
                    return (task.classEntity == nil && (selectedStatus.isEmpty ? true : selectedStatus.contains(TimeHelper.getTaskTimeState(task: task).rawValue)))
                    && !task.archived && (searchText != "" ? task.label?.lowercased().contains(searchText.lowercased()) ?? false : true)



                    && !task.archived
                }.sorted {$0.due! > $1.due!}

                if (selectedClassesID.isEmpty || selectedClassesID.contains("kyotaskNoClassTIS[3242]--.dot.-dash")){
                    ForEach(Array(tasksFilter.enumerated()), id: \.element) { index, task in
                        if let dueDate = task.due{
                            let calendar = Calendar.current
                            if index == 0 {
                                Text("No Attached Class")
                                    .sectionTitle()
                                    .padding(.horizontal, 20)
                            }
                            ZStack{
                                TaskItem(data: task)
                                //                                            Text(task.label ?? "No label")
                                    .overlay(RoundedRectangle(cornerRadius:global_Compact ? 0 : 25).strokeBorder(Color.primary.opacity(0.19), lineWidth: selectedTasksEdit.contains(task) ? 2.0 : 0.0))
                                    .scaleEffect(selectedTasksEdit.contains(task) ? 0.98 : 1.0)
                                    .padding(.horizontal, global_Compact ? 0 : 25)


                                    .padding(.vertical,global_Compact ? 0 : 3)

                                    .transition(.blurWithoutScale.animation(.smooth))
                                    .allowsHitTesting(!edit)

                            }
                            .contentShape(Rectangle())
                            .onTapGesture(perform: {
                                if edit{
                                    withAnimation(.smooth(duration: 0.4)){
                                        if !selectedTasksEdit.contains(task){
                                            selectedTasksEdit.insert(task)
                                        }
                                        else{
                                            selectedTasksEdit.remove(task)
                                        }
                                    }
                                }
                            })


                            //                               /\~-_
                            //                             =(°^°= 7
                            //                             ----O--O-------------
                            //                             |   fix this later  |
                            //                             ---------------------
                        }
                    }
                }

            }
        }.animation(.bouncy(duration: 0.35, extraBounce: -0.5), value: selectedClassesID)
                    .animation(.bouncy(duration: 0.35, extraBounce: -0.5), value: selectedStatus)
                    .animation(.bouncy(duration: 0.35, extraBounce: -0.5), value: showEmptyTaskClassCategories)

                    .animation(.smooth, value: showSearch)
                //                .offset(y: showSearch ? 20 : 10)
                    .animation(.bouncy(duration: 0.35), value: alwaysShowButtons)
                    .animation(.bouncy(duration: 0.35), value: global_Compact)





                Color.clear
                    .frame(height: 75)
                    .sheet(isPresented: $showTaskCreation) {
                        NavigationStack{
                            TaskWorkshop(color: color)
                                .frame(idealWidth: 570, idealHeight:  640)
                        }
                                    .interactiveDismissDisabled()
                        .presentationCornerRadius(25)
                    }
            }
        .searchable(text: $searchText)
            //                            .contentShape(Rectangle())
            //                            .gesture(searchText != "" ? DragGesture() : nil)



            .coordinateSpace(name: "scroll")

#if os(iOS)
            .safeAreaInset(edge: .top, content: {
                Color.clear.frame(height: horizontalSizeClass == .compact ? 80 : 40)
            })

#endif




        .animation(.smooth, value: showSearch)

        .sheet(isPresented: $showArchive, content: {
            NavigationStack{
                TaskArchive(color: color)
                                .presentationCornerRadius(25)
            }

        })

        .safeAreaInset(edge: .bottom, content: {
            if edit{
            ZStack{

                HStack{

                    Menu(content: {

                        Button("Cancel") {
                            // This closure does nothing, as you requested a cancel button with no action.
                        }

                        Button(role: .destructive) {
                            for item in selectedTasksEdit{
                                viewContext.delete(item)
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                                .frame(maxWidth: .infinity)
                        }
                    }, label: {
                        Text("Delete")
                            .frame(maxWidth: .infinity)

                    })
                    .buttonStyle(BentoButton(backgroundTint: Color("bw").opacity(0.8), role: .destructive))
                    .disabled(selectedTasksEdit.isEmpty)
                    .opacity(selectedTasksEdit.isEmpty ? 0.6 : 1)

                    Button {


                        for task in tasks{
                            selectedTasksEdit.insert(task)
                        }

                    } label: {
                        Text("Select All")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(BentoButton(color: color, backgroundTint: Color("bw").opacity(0.8)))

                    Button {
                        for item in selectedTasksEdit{
                            item.completed.toggle()
                        }
                    } label: {
                        Text("Complete")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(BentoButton(color: color, backgroundTint: Color("bw").opacity(0.8)))

                }
                .transition(.blur)

            }
            .padding(.bottom, 20)
            .padding(.top, 10)
            .padding(.horizontal, 20)
            .ignoresSafeArea()
            .frame(maxWidth: .infinity)
        }

//#if os(iOS) || os(visionOS)
//            .background{
//                if let doodleImage = UIImage(named: "maskbottomtotop") {
//                    // Display the image only if it's successfully loaded
//                    VariableBlurView(gradientMask: doodleImage)
//                        .ignoresSafeArea()
//                        .opacity(edit ? 1 : 0)
//                }
//            }
//#endif

        })
        #if !os(visionOS)
        .tint(color)
        #endif
        //        .overlay(alignment: .bottomLeading, content: {
        //            if !edit{
        //                var allCases: [taskTimeState] {
        //                        var cases: [taskTimeState] = [
        //                            selectedTaskType
        //                        ]
        //                    if searchTextDummy == "" {
        //                        cases = taskTimeState.allCases
        //                    }
        //
        //                        return cases
        //                    }
        //            Menu {
        //
        //            } label: {
        //                HStack{
        //                    ForEach(allCases, id: \.self) { selection in
        //                        Circle()
        //                            .fill(selection == selectedTaskType ? Color.primary : Color.primary.opacity(0.4))
        //                            .frame(width: selection == selectedTaskType ? 8 : 6, height:selection == selectedTaskType ? 8 : 6)
        //                    }
        //
        //                }
        //                .padding(10)
        //                .animation(.smooth, value: selectedTaskType)
        //            }
        //            .background(.ultraThinMaterial)
        //            .clipShape(Capsule())
        //            .regularOutline()
        //            .frame(maxWidth: .infinity, alignment: .bottomLeading)
        //            .padding([.horizontal, .top] ,20)
        //            .padding([.bottom] ,5)
        //
        //        }
        //        })
        .amethystNavigationBar(title: "Tasks", titleColor: .primary,  tintColor: color, overrideType: .regular, scrolled: $scrolled) {
                                HStack(spacing: 14){
                                        navigationBarButtons
                                            .frame(maxWidth: .infinity, alignment: .trailing)
                                            .transition(.blur )

                                }
        } toolbar: {
            Group{


                                        Button {
                                            showArchive.toggle()
                                        } label: {
                                            Label("Archive", systemImage: "archivebox")
                                        }
                                        .foregroundStyle(color)
                                        .frame(maxWidth: .infinity, alignment: .leading)


                
                                }
        }



#if os(iOS) || os(visionOS)


        .sheet(isPresented: $categoryCreate) {
            NavigationStack{
                CreateCategory(color1: color, color2: color)
            }
            .interactiveDismissDisabled()
            .presentationCornerRadius(25)
        }
        .sheet(isPresented: $manageCategories) {
            NavigationStack{
                TaskCategoryManage(color: color)
            }
            .interactiveDismissDisabled()
            .presentationCornerRadius(25)
        }
//        .overlay(alignment: .top, content: {
//            ZStack{
//                VariableBlurView()
//                LinearGradient(colors: [Color.white.opacity(0.7), Color.white.opacity(0.6), Color.clear], startPoint: .top, endPoint: .bottom)
//            }
//                .frame(height: 130)
//                .ignoresSafeArea()
//        })
#endif
    }


    var navigationBarButtons: some View {
        HStack(spacing: 10){
            if edit{
                //                Button {
                //                    selectedTasksEdit = []
                //                    withAnimation(.bouncy){
                //                        show.toggle()
                //                        edit.toggle()
                //
                //                    }
                //                } label: {
                //                    Text("Select All")
                //                        .scaledFrame(width: nil, height: 40, relativeTo: .body)
                //                        .padding(.horizontal, 12)
                //
                //                }
                //                .buttonStyle(NavigationButton(color: color, scrolled: $scrolled))

                Button {
                    do {
                        try viewContext.save()

                    } catch {
                        let nsError = error as NSError
                        fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                    }

                    selectedTasksEdit = []
                    withAnimation(.bouncy){
                        show.toggle()
                        edit.toggle()

                    }
                } label: {
                    Text("Done")
                        .scaledFrame(width: nil, height: 40, relativeTo: .body)
                        .padding(.horizontal, 12)

                }
                .buttonStyle(NavigationButton(color: color, scrolled: $scrolled))
            }



            if !edit{



                Menu {
//                    Button {
//                        withAnimation(.bouncy){
//                            show.toggle()
//                            edit.toggle()
//                        }
//                    } label: {
//
//                        Label("edit-text", systemImage: "pencil")
//
//                    }

                    Button {
                        manageCategories.toggle()
                    } label: {
                        Label("Manage Categories", systemImage: "list.bullet.rectangle")
                    }

                    Divider()


                    Toggle(isOn: $showEmptyTaskClassCategories) {
                        Label("Show Empty", systemImage: "rectangle")
                    }
#if !os(macOS)
                    .menuActionDismissBehavior(.disabled)
                    #endif
                    Toggle(isOn: $alwaysShowButtons) {
                        Label("Show Details", systemImage: "text.quote")
                    }
#if !os(macOS)
                    .menuActionDismissBehavior(.disabled)
                    #endif

                    Toggle(isOn: $global_Compact, label: {
                        Label("Compact Mode", systemImage: "rectangle.arrowtriangle.2.inward")
                    })
#if !os(macOS)
                    .menuActionDismissBehavior(.disabled)
                    #endif

//                    Button {
//
//                    } label: {
//                        Label("Sync with Reminders", systemImage: "app.badge")
//                    }




                } label: {
                    Image(systemName: "ellipsis")
                        .font(.body.weight(.regular))
                    #if !os(visionOS)
                        .scaledFrame(width: horizontalSizeClass == .compact ? 44 : nil, height: horizontalSizeClass == .compact ? 44 : nil, relativeTo: .body)
                    #endif


                }
#if !os(visionOS)
                .modify {
                    if horizontalSizeClass == .compact{
                        if #available(iOS 17.0, *) {
                            $0.buttonStyle(NavigationButton(color: color, scrolled: $scrolled))

                        } else {
                            $0.menuStyle(NavigationMenu(color: color, scrolled: $scrolled))
                        }
                    }
                    else{
                        $0
                    }
                }
                .zIndex(3)
                #else
                .menuStyle(.button)
                #endif

                //
                //                Button(action: {
                //                    showSearch.toggle()
                //                }, label: {
                //
                //                        Image(systemName: "magnifyingglass")
                //                            .font(.body.weight(.regular))
                //
                //                            .scaledFrame(width: 44, height: 44, relativeTo: .body)
                //                })
                //                .buttonStyle(NavigationButton(color: color, scrolled: $scrolled))
                #if !os(visionOS)
                if horizontalSizeClass == .compact{
                    Menu {

                                        Menu(){


                                            Toggle(isOn: Binding(
                                                get: { selectedClassesID.isEmpty },
                                                set: { isSelected in
                                                    if isSelected{

                                                        selectedClassesID = []
                                                    }
                                                    else{
                                                        selectedClassesID = []
                                                    }

                                                }
                                            )) {
                                                Text("All Classes")
                                            }
                    #if !os(macOS)
                                        .menuActionDismissBehavior(.disabled)
                                        #endif

                                            Divider()

                                            ForEach(classes, id: \.self) { classEntity in
                                                let tasksFilter = tasks.filter { task in
                                                    return task.classEntity?.id == classEntity.id
                                                }
                                                if showEmptyTaskClassCategories || !tasksFilter.isEmpty{


                                                    Toggle(isOn: Binding(
                                                        get: { selectedClassesID.contains(classEntity.id?.uuidString ?? "") },
                                                        set: { isSelected in
                                                            if isSelected {
                                                                selectedClassesID.insert(classEntity.id?.uuidString ?? "")
                                                            } else {
                                                                selectedClassesID.remove(classEntity.id?.uuidString ?? "")
                                                            }
                                                        }
                                                    )) {
                                                        Text(classEntity.name ?? "Untitled")


                                                        Text("^[\(tasksFilter.count) Task](inflect: true)")
                                                    }
                                                }
                                            }
                    #if !os(macOS)
                                            .menuActionDismissBehavior(.disabled)
                                            #endif

                                            Toggle(isOn: Binding(
                                                get: { selectedClassesID.contains("kyotaskNoClassTIS[3242]--.dot.-dash") },
                                                set: { isSelected in
                                                    if isSelected{

                                                        selectedClassesID.insert("kyotaskNoClassTIS[3242]--.dot.-dash")
                                                    }
                                                    else{
                                                        selectedClassesID.remove("kyotaskNoClassTIS[3242]--.dot.-dash")
                                                    }

                                                }
                                            )) {
                                                Text("No Attached Class")
                                                let tasksFilter = tasks.filter { task in
                                                    return task.classEntity == nil
                                                }

                                                Text("^[\(tasksFilter.count) Task](inflect: true)")

                                            }
                    #if !os(macOS)
                                            .menuActionDismissBehavior(.disabled)
                                            #endif



                                        } label: {
                                            Label("Class", systemImage: "book.closed")
                                        }
                                        .pickerStyle(.menu)
                                        Menu{
                                            Toggle(isOn: Binding(
                                                get: { selectedStatus.isEmpty },
                                                set: { isSelected in
                                                    if isSelected{

                                                        selectedStatus = []
                                                    }
                                                    else{
                                                        selectedStatus = []
                                                    }

                                                }
                                            )) {
                                                Text("All States")
                                            }
                    #if !os(macOS)
                                            .menuActionDismissBehavior(.disabled)
                                            #endif

                                            Divider()

                                            ForEach(taskTimeState.allCases, id: \.self) { state in

                                                Toggle(isOn: Binding(
                                                    get: { selectedStatus.contains(state.rawValue) },
                                                    set: { isSelected in
                                                        if isSelected {
                                                            selectedStatus.insert(state.rawValue)
                                                        } else {
                                                            selectedStatus.remove(state.rawValue)
                                                        }
                                                    }
                                                )) {
                                                    Label(state.rawValue, systemImage: state.symbol)
                                                    let tasksFilter = tasks.filter { task in
                                                        return TimeHelper.getTaskTimeState(task: task) == state
                                                    }

                                                    Text("^[\(tasksFilter.count) Task](inflect: true)")
                                                }
                    #if !os(macOS)
                                        .menuActionDismissBehavior(.disabled)
                                        #endif

                                            }

                                        } label: {
                                            Label("Status", systemImage: "wand.and.stars")
                                        }
                                        .pickerStyle(.menu)

//                        Menu{
//                                                                    Toggle(isOn: Binding(
//                                                                        get: { selectedStatus.isEmpty },
//                                                                        set: { isSelected in
//                                                                            if isSelected{
//
//                                                                                selectedStatus = []
//                                                                            }
//                                                                            else{
//                                                                                selectedStatus = []
//                                                                            }
//
//                                                                        }
//                                                                    )) {
//                                                                        Text("All States")
//                                                                    }
//                                            #if !os(macOS)
//                                                                    .menuActionDismissBehavior(.disabled)
//                                                                    #endif
//
//                                                                    Divider()
//
//                                                                    ForEach(taskTimeState.allCases, id: \.self) { state in
//
//                                                                        Toggle(isOn: Binding(
//                                                                            get: { selectedStatus.contains(state.rawValue) },
//                                                                            set: { isSelected in
//                                                                                if isSelected {
//                                                                                    selectedStatus.insert(state.rawValue)
//                                                                                } else {
//                                                                                    selectedStatus.remove(state.rawValue)
//                                                                                }
//                                                                            }
//                                                                        )) {
//                                                                            Label(state.rawValue, systemImage: state.symbol)
//                                                                            let tasksFilter = tasks.filter { task in
//                                                                                return TimeHelper.getTaskTimeState(task: task) == state
//                                                                            }
//
//                                                                            Text("^[\(tasksFilter.count) Task](inflect: true)")
//                                                                        }
//                                            #if !os(macOS)
//                                                                .menuActionDismissBehavior(.disabled)
//                                                                #endif
//
//                                                                    }
//
//                                                                } label: {
//                                                                    Label("Category", systemImage: "line.3.horizontal")
//                                                                }
//                                                                .pickerStyle(.menu)
//                        Menu {
//                            ForEach(TaskSortingOption.allCases, id: \.self) { state in
//
//                                Toggle(isOn: Binding(
//                                    get: { selectedTaskSortingOption == state },
//                                    set: { isSelected in
//                                        if isSelected {
//                                            selectedTaskSortingOption = state
//                                        } else {
//
//                                        }
//                                    }
//                                )) {
//                                    Label(state.rawValue, systemImage: state.symbol)
//
//                                }
//#if !os(macOS)
//                                .menuActionDismissBehavior(.disabled)
//#endif
//
//                            }
//                            Section("Sort"){
//
//                            ForEach(SortingOptionPolarity.allCases, id: \.self) { state in
//
//                                Toggle(isOn: Binding(
//                                    get: { selectedTaskSortingPolarity == state },
//                                    set: { isSelected in
//                                        if isSelected {
//                                            selectedTaskSortingPolarity = state
//                                        } else {
//
//                                        }
//                                    }
//                                )) {
//                                    Label(state.rawValue.capitalized, systemImage: state.symbol)
//
//                                }
//#if !os(macOS)
//                                .menuActionDismissBehavior(.disabled)
//#endif
//
//                            }
//                        }
//
//                        } label: {
//                            Label("Group By", systemImage: "folder")
//                        }

//                        Picker(selection: $selectedTaskSortingOption) {
//                            ForEach(TaskSortingOption.allCases, id: \.self) { state in
//                                Text(state.rawValue)
//                            }
//                        }


                                        Divider()

//                                        Toggle(isOn: $rememberFilters) {
//                                            Label("Remember Filters", systemImage: "brain")
//                                        }
                    #if !os(macOS)
                                        .menuActionDismissBehavior(.disabled)
                                        #endif

                                        Button {
                                            filtersActive = false
                                            selectedClassesID = []
                                            selectedStatus = []
                                        } label: {
                                            Label("Reset Filters", systemImage: "clear")
                                        }
                    #if !os(macOS)
                                            .menuActionDismissBehavior(.disabled)
                                            #endif






                                    } label: {

                                        HStack{
                                            Image(systemName: "line.3.horizontal.decrease")
                                                .scaledFrame(width: 44, height: 44, relativeTo: .body)

                                            if filtersActive{
                                                Text("Filtered")
                                                    .transition(.blur.animation(.bouncy))
                                                    .padding(.trailing, 5)
                                                    .offset(x: -8.5)
                                                    .fixedSize()


                                            }
                                        }
                                        .foregroundColor(scrolled ? .primary : filtersActive ? .white : color)

                                        .background {
                                            ZStack{
                                                Color("navButton")
                                                    .opacity( 0.6)
                                                    .background(BackdropBlurView(radius: 4))
                                                    .scaleEffect(2)

                                                Color(color)
                                                    .scaleEffect(5)
                                                    .opacity(filtersActive ? 1 : 0)

                                            }
                                        }
                                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                        .shadow(color: color.opacity(scrolled ? 0.04 : 0.07), radius: 5, x: 0, y: 4)
                                        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder((scrolled ? .primary : color).opacity(scrolled ? 0.15 : 0.3), lineWidth: 1.4))

                                        .animation(.bouncy(duration: 0.45, extraBounce: 0.0), value: filtersActive)

                                        .scaledFrame(width: 115, height: nil, relativeTo: .body, alignment: .trailing)


                                    }


                                    .buttonStyle(expbounceButton(offset: !filtersActive))
                                    .scaledFrame(width: filtersActive ? nil : 44, height: nil, relativeTo: .body, alignment: .trailing)
                                    .padding(.leading,filtersActive ? -1 : 0)

                                    .zIndex(1)
                                    //                .modify {
                                    //                    if #available(iOS 17.0, *) {
                                    //                        $0.buttonStyle(NavigationButton(color: color, scrolled: $scrolled, fillBackground: filtersActive))
                                    //
                                    //                    } else {
                                    //                        $0.menuStyle(NavigationMenu(color: color, scrolled: $scrolled))
                                    //                    }
                                    //                }

                                    //                .animation(.bouncy(extraBounce: 0.5))
                                    .onChange(of: selectedClassesID.count) { newValue in
                                        if newValue == 0 {
                                            filtersActive = false
                                        } else {
                                            filtersActive = true

                                            if selectedClassesID.count == classes.count{

                                                filtersActive = false
                                                selectedClassesID = []

                                            }
                                        }
                                    }

                                    .onChange(of: selectedStatus.count) { newValue in
                                        if newValue == 0 {
                                            filtersActive = false
                                        } else {
                                            filtersActive = true

                                            if selectedStatus.count == 4{

                                                filtersActive = false
                                                selectedStatus = []

                                            }
                                        }
                                    }

                                    .onAppear{
                                        if !rememberFilters{
                                            filtersActive = false
                                            selectedClassesID = []
                                            selectedStatus = []
                                        }
                                    }
                }
                else{
                    Menu {

                                        Menu(){


                                            Toggle(isOn: Binding(
                                                get: { selectedClassesID.isEmpty },
                                                set: { isSelected in
                                                    if isSelected{

                                                        selectedClassesID = []
                                                    }
                                                    else{
                                                        selectedClassesID = []
                                                    }

                                                }
                                            )) {
                                                Text("All Classes")
                                            }
                    #if !os(macOS)
                                        .menuActionDismissBehavior(.disabled)
                                        #endif

                                            Divider()

                                            ForEach(classes, id: \.self) { classEntity in
                                                let tasksFilter = tasks.filter { task in
                                                    return task.classEntity?.id == classEntity.id
                                                }
                                                if showEmptyTaskClassCategories || !tasksFilter.isEmpty{


                                                    Toggle(isOn: Binding(
                                                        get: { selectedClassesID.contains(classEntity.id?.uuidString ?? "") },
                                                        set: { isSelected in
                                                            if isSelected {
                                                                selectedClassesID.insert(classEntity.id?.uuidString ?? "")
                                                            } else {
                                                                selectedClassesID.remove(classEntity.id?.uuidString ?? "")
                                                            }
                                                        }
                                                    )) {
                                                        Text(classEntity.name ?? "Untitled")


                                                        Text("^[\(tasksFilter.count) Task](inflect: true)")
                                                    }
                                                }
                                            }
                    #if !os(macOS)
                                            .menuActionDismissBehavior(.disabled)
                                            #endif

                                            Toggle(isOn: Binding(
                                                get: { selectedClassesID.contains("kyotaskNoClassTIS[3242]--.dot.-dash") },
                                                set: { isSelected in
                                                    if isSelected{

                                                        selectedClassesID.insert("kyotaskNoClassTIS[3242]--.dot.-dash")
                                                    }
                                                    else{
                                                        selectedClassesID.remove("kyotaskNoClassTIS[3242]--.dot.-dash")
                                                    }

                                                }
                                            )) {
                                                Text("No Attached Class")
                                                let tasksFilter = tasks.filter { task in
                                                    return task.classEntity == nil
                                                }

                                                Text("^[\(tasksFilter.count) Task](inflect: true)")

                                            }
                    #if !os(macOS)
                                            .menuActionDismissBehavior(.disabled)
                                            #endif



                                        } label: {
                                            Label("Class", systemImage: "book.closed")
                                        }
                                        .pickerStyle(.menu)
                                        Menu{
                                            Toggle(isOn: Binding(
                                                get: { selectedStatus.isEmpty },
                                                set: { isSelected in
                                                    if isSelected{

                                                        selectedStatus = []
                                                    }
                                                    else{
                                                        selectedStatus = []
                                                    }

                                                }
                                            )) {
                                                Text("All States")
                                            }
                    #if !os(macOS)
                                            .menuActionDismissBehavior(.disabled)
                                            #endif

                                            Divider()

                                            ForEach(taskTimeState.allCases, id: \.self) { state in

                                                Toggle(isOn: Binding(
                                                    get: { selectedStatus.contains(state.rawValue) },
                                                    set: { isSelected in
                                                        if isSelected {
                                                            selectedStatus.insert(state.rawValue)
                                                        } else {
                                                            selectedStatus.remove(state.rawValue)
                                                        }
                                                    }
                                                )) {
                                                    Label(state.rawValue, systemImage: state.symbol)
                                                    let tasksFilter = tasks.filter { task in
                                                        return TimeHelper.getTaskTimeState(task: task) == state
                                                    }

                                                    Text("^[\(tasksFilter.count) Task](inflect: true)")
                                                }
                    #if !os(macOS)
                                        .menuActionDismissBehavior(.disabled)
                                        #endif

                                            }

                                        } label: {
                                            Label("Status", systemImage: "wand.and.stars")
                                        }
                                        .pickerStyle(.menu)


                                        Divider()

                                        Toggle(isOn: $rememberFilters) {
                                            Label("Remember Filters", systemImage: "memorychip")
                                        }
                    #if !os(macOS)
                                        .menuActionDismissBehavior(.disabled)
                                        #endif

                                        Button {
                                            filtersActive = false
                                            selectedClassesID = []
                                            selectedStatus = []
                                        } label: {
                                            Label("Reset Filters", systemImage: "clear")
                                        }
                    #if !os(macOS)
                                            .menuActionDismissBehavior(.disabled)
                                            #endif






                                    } label: {

                                        HStack{
                                            Image(systemName: "line.3.horizontal.decrease")

                                            if filtersActive{
                                                Text("Filtered")
                                                    .transition(.blur.animation(.bouncy))
                                                    .padding(.trailing, 5)
                                                    .offset(x: -4.5)
                                                    .fixedSize()


                                            }
                                        }


                                    }

                                    //                .modify {
                                    //                    if #available(iOS 17.0, *) {
                                    //                        $0.buttonStyle(NavigationButton(color: color, scrolled: $scrolled, fillBackground: filtersActive))
                                    //
                                    //                    } else {
                                    //                        $0.menuStyle(NavigationMenu(color: color, scrolled: $scrolled))
                                    //                    }
                                    //                }

                                    //                .animation(.bouncy(extraBounce: 0.5))
                                    .onChange(of: selectedClassesID.count) { newValue in
                                        if newValue == 0 {
                                            filtersActive = false
                                        } else {
                                            filtersActive = true

                                            if selectedClassesID.count == classes.count{

                                                filtersActive = false
                                                selectedClassesID = []

                                            }
                                        }
                                    }

                                    .onChange(of: selectedStatus.count) { newValue in
                                        if newValue == 0 {
                                            filtersActive = false
                                        } else {
                                            filtersActive = true

                                            if selectedStatus.count == 4{

                                                filtersActive = false
                                                selectedStatus = []

                                            }
                                        }
                                    }

                                    .onAppear{
                                        if !rememberFilters{
                                            filtersActive = false
                                            selectedClassesID = []
                                            selectedStatus = []
                                        }
                                    }
                }
                #else
                Menu {

                                                       Menu(){


                                                           Toggle(isOn: Binding(
                                                               get: { selectedClassesID.isEmpty },
                                                               set: { isSelected in
                                                                   if isSelected{

                                                                       selectedClassesID = []
                                                                   }
                                                                   else{
                                                                       selectedClassesID = []
                                                                   }

                                                               }
                                                           )) {
                                                               Text("All Classes")
                                                           }
                                   #if !os(macOS)
                                                       .menuActionDismissBehavior(.disabled)
                                                       #endif

                                                           Divider()

                                                           ForEach(classes, id: \.self) { classEntity in
                                                               let tasksFilter = tasks.filter { task in
                                                                   return task.classEntity?.id == classEntity.id
                                                               }
                                                               if showEmptyTaskClassCategories || !tasksFilter.isEmpty{


                                                                   Toggle(isOn: Binding(
                                                                       get: { selectedClassesID.contains(classEntity.id?.uuidString ?? "") },
                                                                       set: { isSelected in
                                                                           if isSelected {
                                                                               selectedClassesID.insert(classEntity.id?.uuidString ?? "")
                                                                           } else {
                                                                               selectedClassesID.remove(classEntity.id?.uuidString ?? "")
                                                                           }
                                                                       }
                                                                   )) {
                                                                       Text(classEntity.name ?? "Untitled")


                                                                       Text("^[\(tasksFilter.count) Task](inflect: true)")
                                                                   }
                                                               }
                                                           }
                                   #if !os(macOS)
                                                           .menuActionDismissBehavior(.disabled)
                                                           #endif

                                                           Toggle(isOn: Binding(
                                                               get: { selectedClassesID.contains("kyotaskNoClassTIS[3242]--.dot.-dash") },
                                                               set: { isSelected in
                                                                   if isSelected{

                                                                       selectedClassesID.insert("kyotaskNoClassTIS[3242]--.dot.-dash")
                                                                   }
                                                                   else{
                                                                       selectedClassesID.remove("kyotaskNoClassTIS[3242]--.dot.-dash")
                                                                   }

                                                               }
                                                           )) {
                                                               Text("No Attached Class")
                                                               let tasksFilter = tasks.filter { task in
                                                                   return task.classEntity == nil
                                                               }

                                                               Text("^[\(tasksFilter.count) Task](inflect: true)")

                                                           }
                                   #if !os(macOS)
                                                           .menuActionDismissBehavior(.disabled)
                                                           #endif



                                                       } label: {
                                                           Label("Class", systemImage: "book.closed")
                                                       }
                                                       .pickerStyle(.menu)
                                                       Menu{
                                                           Toggle(isOn: Binding(
                                                               get: { selectedStatus.isEmpty },
                                                               set: { isSelected in
                                                                   if isSelected{

                                                                       selectedStatus = []
                                                                   }
                                                                   else{
                                                                       selectedStatus = []
                                                                   }

                                                               }
                                                           )) {
                                                               Text("All States")
                                                           }
                                   #if !os(macOS)
                                                           .menuActionDismissBehavior(.disabled)
                                                           #endif

                                                           Divider()

                                                           ForEach(taskTimeState.allCases, id: \.self) { state in

                                                               Toggle(isOn: Binding(
                                                                   get: { selectedStatus.contains(state.rawValue) },
                                                                   set: { isSelected in
                                                                       if isSelected {
                                                                           selectedStatus.insert(state.rawValue)
                                                                       } else {
                                                                           selectedStatus.remove(state.rawValue)
                                                                       }
                                                                   }
                                                               )) {
                                                                   Label(state.rawValue, systemImage: state.symbol)
                                                                   let tasksFilter = tasks.filter { task in
                                                                       return TimeHelper.getTaskTimeState(task: task) == state
                                                                   }

                                                                   Text("^[\(tasksFilter.count) Task](inflect: true)")
                                                               }
                                   #if !os(macOS)
                                                       .menuActionDismissBehavior(.disabled)
                                                       #endif

                                                           }

                                                       } label: {
                                                           Label("Status", systemImage: "wand.and.stars")
                                                       }
                                                       .pickerStyle(.menu)


                                                       Divider()

                                                       Toggle(isOn: $rememberFilters) {
                                                           Label("Remember Filters", systemImage: "memorychip")
                                                       }
                                   #if !os(macOS)
                                                       .menuActionDismissBehavior(.disabled)
                                                       #endif

                                                       Button {
                                                           filtersActive = false
                                                           selectedClassesID = []
                                                           selectedStatus = []
                                                       } label: {
                                                           Label("Reset Filters", systemImage: "clear")
                                                       }
                                   #if !os(macOS)
                                                           .menuActionDismissBehavior(.disabled)
                                                           #endif






                                                   } label: {
                                                       Image(systemName: "line.3.horizontal.decrease")

                                                   }
                                                   .menuStyle(.button)
                                                   .background(color.opacity(filtersActive ? 0.35 : 0.0), in: Capsule())
                                                   .glassBackgroundEffect(displayMode: filtersActive ? .always : .never)

                                                   //                .modify {
                                                   //                    if #available(iOS 17.0, *) {
                                                   //                        $0.buttonStyle(NavigationButton(color: color, scrolled: $scrolled, fillBackground: filtersActive))
                                                   //
                                                   //                    } else {
                                                   //                        $0.menuStyle(NavigationMenu(color: color, scrolled: $scrolled))
                                                   //                    }
                                                   //                }

                                                   //                .animation(.bouncy(extraBounce: 0.5))
                                                   .onChange(of: selectedClassesID.count) { newValue in
                                                       if newValue == 0 {
                                                           filtersActive = false
                                                       } else {
                                                           filtersActive = true

                                                           if selectedClassesID.count == classes.count{

                                                               filtersActive = false
                                                               selectedClassesID = []

                                                           }
                                                       }
                                                   }

                                                   .onChange(of: selectedStatus.count) { newValue in
                                                       if newValue == 0 {
                                                           filtersActive = false
                                                       } else {
                                                           filtersActive = true

                                                           if selectedStatus.count == 4{

                                                               filtersActive = false
                                                               selectedStatus = []

                                                           }
                                                       }
                                                   }

                                                   .onAppear{
                                                       if !rememberFilters{
                                                           filtersActive = false
                                                           selectedClassesID = []
                                                           selectedStatus = []
                                                       }
                                                   }
                #endif




                Menu {
                    Section(){
                        Button {
                            showTaskCreation.toggle()
                        } label: {
                            Text("Task")
                            Image(systemName: "rectangle.badge.plus")


                        }
                    }
                    Section(){
                        Button {
                            categoryCreate.toggle()
                        } label: {

                            Text("New Category")
                            Image(systemName: "text.badge.plus")

                        }



                    }


                } label: {
                        Image(systemName: "plus")
                            .font(.body.weight(.regular))

                            .scaledFrame(width: horizontalSizeClass == .compact ? 44 : nil, height: horizontalSizeClass == .compact ? 44 : nil, relativeTo: .body)




                } primaryAction: {
                    showTaskCreation.toggle()
                }
                #if !os(visionOS)
                .modify {
                    if horizontalSizeClass == .compact{
                        if #available(iOS 17.0, *) {
                            $0.buttonStyle(NavigationButton(color: color, scrolled: $scrolled))

                        } else {
                            $0.menuStyle(NavigationMenu(color: color, scrolled: $scrolled))
                        }
                    }
                    else{
                        $0
                    }
                }
                #else
                .menuStyle(.button)
                #endif
            }
        }
        .animation(.bouncy(extraBounce: 0.0), value: filtersActive)
    }



    private func setState(atOffset offset: CGSize) -> taskTimeState {
        let stateCount = taskTimeState.allCases.count
        let currentIndex = taskTimeState.allCases.firstIndex(of: selectedTaskType)!
        let predictedIndex = currentIndex - Int(round(offset.width / 50))
        let index = Swift.max(0, Swift.min(predictedIndex, stateCount - 1))
        return taskTimeState.allCases[index]
    }
}


struct taskSelection: View{
    var color: Color = .red
    @Environment(\.colorScheme) var colorScheme
    @State var type: NavigationBarType
    @Binding var scrolled: Bool
    @Binding var showArchive: Bool
    @AppStorage("Selected Task Type") var selectedTaskType: taskTimeState = .upcoming

    var body: some View{
        Menu {
            ForEach(taskTimeState.allCases, id: \.self) { selection in
                Button {
                    withAnimation(.bouncy){
                        selectedTaskType = selection
                    }
                } label: {
                    Label {

                        Text(selection.rawValue.capitalized)
                            .font(.system(size: 16))
                    } icon: {
                        Image(systemName: selection.symbol)

                            .font(.system(size: 18))
                    }
                }

            }
            //            Divider()
            //            Button {
            //                showArchive.toggle()
            //            } label: {
            //                Label("Archive", systemImage: "archivebox")
            //            }

        } label: {
            Color.clear

                .frame(height: 25)
                .overlay{
                    GeometryReader{ geo in

                        HStack(spacing: 0){
                            ForEach(taskTimeState.allCases, id: \.self) { selection in
                                Label {
                                    Text(selection.rawValue.capitalized)
                                        .font(.system(size: 16))
                                } icon: {
                                    Image(systemName: selection.symbol)

                                        .font(.system(size: 18))
                                }
                                .frame(width: 130, alignment: .leading)
                                .opacity(selection == selectedTaskType ? 1 : 0)
                            }
                        }
                        .padding(.leading, 20)
                        .frame(height: 25)
                        .offset(x: selectedTaskType == .today ? -130 : selectedTaskType == .upcoming ? -260 : selectedTaskType == .completed ? -390 : 0)
                        .animation(.smooth(duration: 0.3), value: selectedTaskType)

                    }
                    .frame(height: 25)
                    .mask {
                        Rectangle()
                            .fill(LinearGradient(gradient:
                                                    Gradient(stops:
                                                                [Gradient.Stop(color: Color.clear, location: 0.0),
                                                                 Gradient.Stop(color: Color.white, location: 0.10),
                                                                 Gradient.Stop(color: Color.white, location: 0.87),
                                                                 Gradient.Stop(color: Color.clear, location: 1.0)]),
                                                 startPoint: /*@START_MENU_TOKEN@*/.leading/*@END_MENU_TOKEN@*/, endPoint: /*@START_MENU_TOKEN@*/.trailing/*@END_MENU_TOKEN@*/))
                            .frame(width: 280, height: 25, alignment: .leading)
                    }
                    .offset(x: -20)
                }

                .frame(width: 150, height: 25, alignment: .leading)
                .contentShape(Rectangle())
        }
        .foregroundColor(color)
        .brightness(scrolled ? colorScheme == .dark ? 1 : -1 : 0)
        .fixedSize(horizontal: true, vertical: false )

        .frame(maxWidth: .infinity, alignment: .leading)

    }
}





