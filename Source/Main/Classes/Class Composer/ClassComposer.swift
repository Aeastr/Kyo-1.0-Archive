//
//  AddClass.swift
//  KyoNeo
//
//  Created by Aether on 28/01/2023.
//

import SwiftUI
import SymbolPicker
import AmethystUI



struct ClassComposer: View {
    /// Core Data
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)]) var classes: FetchedResults<ClassEntity>
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)]) var tags: FetchedResults<TagItem>
    var entity: ClassEntity?


    /// Fields
    @State var title: String = ""
    @State var shortTitle: String = ""
    @State var icon: String = "book.closed"
    @State var iconEdit: Bool = false
    @State private var selectedTags: Set<TagItem?> = []
    @State var showAddTag = false
    @State var tagAddName: String = ""
    @AppStorage("shortnameField") var shortnameField = true

    @FocusState private var focusedField: FocusField?
    enum FocusField: Hashable {
        case title
        case shortTitle
        case none
    }

    /// Colours
    @State var color1: Color = Color("1")
    @State var color2: Color = .red

    /// View Logic
    @State var scrolled: Bool = false
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @Binding var passThroughClass: ClassEntity?
    @State private var cancelAlert = false


    init(entity: ClassEntity? = nil,
         color1: Color = Color(hex: "7FA5F2"),
         color2: Color = Color(hex: "77BAF4"),
         passThroughClass: Binding<ClassEntity?> = .constant(nil)) {

        self._passThroughClass = passThroughClass

        if let entity = entity {
            self.entity = entity
            self._title = State(initialValue: entity.name ?? "")
            self._shortTitle = State(initialValue: entity.shortName ?? "")
            self._color1 = State(initialValue: Color(hex: entity.color1 ?? Color.accentColor.hexString))
            self._color2 = State(initialValue: Color(hex: entity.color2 ?? Color.accentColor.hexString))
            self._icon = State(initialValue: entity.icon ?? "square")

            var tagSet: Set<TagItem?> = Set(entity.tags?.compactMap { $0 as? TagItem } ?? [])
            self._selectedTags = State(initialValue: tagSet)

        } else {
            self._color1 = State(initialValue: color1)
            self._color2 = State(initialValue: color2)
        }
    }

    // FIX: Archive access is unconditional; do not read or update a persisted purchase flag.

    private var kyoPlus_hasPlus: Bool { true }

    var body: some View {
        ZStack {

            pageTopHue(color: color1)

            ScrollView{
                ScrollDetector(scrolled: $scrolled)
                VStack{
                    preview

                    HStack{
                        nameField
                        iconButton
                    }
                    .padding(.horizontal, 20)

                    colorSection

                }

            }
            .coordinateSpace(name: "scroll")



            .safeAreaInset(edge: .top, content: {
                                AdjustableInset()
                            })
            .safeAreaInset(edge: .bottom, content: {
                if kyoPlus_hasPlus{
#if !os(iOS)
                    Color.clear.frame(height: 30)
#else
#endif
                }
                else{
                    KyoPlusButton(color: color1, kyoPlus_hasPlus: .constant(true), text: "Upgrade to Kyo+ for more colours", emoji: "🎨")
#if os(iOS)
                        .padding(.bottom, 30)
                    #else
                        .padding(.bottom, 10)
                    #endif
                }
            })
        }
        .amethystNavigationBar(title: entity == nil ? VariableDataNames().newClassName() : VariableDataNames().editClassName(), titleColor: .primary,   tintColor: color1, compactMode: true, overrideType: entity == nil ? .regular : .back, scrolled: $scrolled, inSheet: true) {
            navBarContent
            #if os(iOS)
                .padding(.trailing, -5)
                .padding(.top, 15)
            #endif
        }toolbar: {
#if os(iOS)
            Text(title == "" ? "Untitled" : title.shortenedClassName(maxLength: 25))
                .foregroundColor(Color.getAdjustedColor(color: color1, colorScheme: colorScheme))
                .padding(.trailing, -5)

                .scaledFrame(width: nil, height: 42, relativeTo: .body, alignment: .leading)
                .padding(.top, 15)
#endif
        }


        .alert("Hold on", isPresented: $cancelAlert) {
            Button(role: .destructive) {
                dismiss()
            } label: {
                Text("Discard")
            }
            Button {
                cancelAlert.toggle()
            } label: {
                Text("Keep Editing")
            }

        } message: {
            Text(entity == nil ?  "Are you sure you want to discard this draft?" : "Are you sure you want to discard your changes?" )
        }


    }

    var preview: some View{
        VStack{
            Text("Preview")
                .sectionTitle(topPadding: 0)
                .padding(.horizontal, 20)

            ClassTemplateItem(name: title, icon: icon, color1: color1, color2: color2, shortName: shortTitle)
                .padding(.horizontal, 20)
        }
    }

    var nameField: some View{
        VStack{

            Text("Name")
                .sectionTitle()
            HStack(spacing: 0) {
                Image(systemName: "character.cursor.ibeam")
                    .font(Font.body.weight(.bold))
                    .foregroundColor(Color.getAdjustedColor(color: color1, colorScheme: colorScheme))
                    .padding(.leading, 13)
                    .padding(.trailing, 5)
                TextField("Enter name..", text: $title, onCommit: {
                    if /*!userHasEditedShortName &&*/ shortnameField {
                        shortTitle = title.shortenedClassName()
                    }
                    if kyoPlus_hasPlus{
                        icon = getIconForClassName(title)
                    }

                })
                .textFieldStyle(.plain)
                .onAppear{
                    if kyoPlus_hasPlus{
                        if icon == "requestSetIcon"{
                            icon = getIconForClassName(title)
                        }
                    }
                    else{
                        if icon == "requestSetIcon"{
                            icon = "book.closed"
                        }
                    }
                }
                .focused($focusedField, equals: .title)
                .onAppear{
                    if entity == nil{
                        focusedField = .title
                    }
                }
                .textContentType(.name)
#if os(iOS) || os(visionOS)
                .keyboardType(.asciiCapable)
                .submitLabel(.done)
#endif
                .autocorrectionDisabled(true)
                .tint(Color.getAdjustedColor(color: color1, colorScheme: colorScheme))


            }
            .neoFieldCard()

        }
    }

    var iconButton: some View{
        VStack{

            Text("Icon")
                .sectionTitle(horizontalPadding: 0)
            Button {
                iconEdit.toggle()
            } label: {
                Image(systemName: icon)

                    .symbolRenderingMode(/*@START_MENU_TOKEN@*/.hierarchical/*@END_MENU_TOKEN@*/)
                    .font(.system(size: 20))
                    .foregroundColor(Color.getAdjustedColor(color: color2, colorScheme: colorScheme))
                    .frame(minHeight: 50)
                    .frame(minWidth: 50)
                    .background ( Color("NeoButton").opacity(0.6) )
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .regularOutline()
            }
            .buttonStyle(bounceButton())


        }
        .frame(width: 50)
        .sheet(isPresented: $iconEdit, content: {
                SymbolPicker(symbol: $icon, background: Color("Background3"), accent: (Color.getAdjustedColor(color: color2, colorScheme: colorScheme)))

                    .symbolRenderingMode(/*@START_MENU_TOKEN@*/.hierarchical/*@END_MENU_TOKEN@*/)
                    .tint(color1)
                    .presentationCornerRadius(25)

        })
    }

    var tagsPicker: some View{
        VStack{
        Text("Tags")
            .sectionTitle()
            .padding(.horizontal, 20)

        Menu {

            Section("Tags") {

                Toggle(isOn: Binding(
                    get: { selectedTags.isEmpty },
                    set: { isSelected in
                        if isSelected {
                            selectedTags = []
                        } else {
                            selectedTags = []
                        }
                    }
                )) {
                    Label("None", systemImage: "tag")



                }

                ForEach(tags, id: \.self) { tag in
                    Toggle(isOn: Binding(
                        get: { selectedTags.contains(tag) },
                        set: { isSelected in
                            if isSelected {
                                selectedTags.insert(tag)
                            } else {
                                selectedTags.remove(tag)
                            }
                        }
                    )) {
                        Label(tag.name ?? "Untitled", systemImage: "tag")



                    }

                }
#if !os(macOS)
                .menuActionDismissBehavior(.disabled)
#endif


            }
            Button {

            } label: {
                Text("Edit Tags")
                Image(systemName: "pencil")
            }
            Button {
                showAddTag.toggle()
            } label: {
                Text("New Tag")
                Image(systemName: "plus")
            }




        } label: {

            HStack(spacing: 0) {
                let brightness1 = color1.getBrightness()

                Image(systemName: "tag")

                    .font(Font.body.weight(.semibold))

                    .foregroundStyle(color1)

                    .frame(width: 20, height: 15)
                    .padding(.leading, 13)
                    .padding(.trailing, 13)

                ZStack(alignment: .leading){
                    Text("Select Tags")
                        .opacity(selectedTags.isEmpty ? 1 : 0)
                    HStack(spacing: 5){
                        ForEach(selectedTags.sorted(by: { $0?.name ?? "" < $1?.name ?? "" }), id: \.self) { tag in

                            Text(tag?.name ?? "")
                                .font(.caption)
                                .padding(6)
                                .background(color1)
                                .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
                                .padding(.vertical, -6)
                                .foregroundStyle(brightness1 > 0.73 ? color1.darken(by: 0.5) : Color.white)
                        }

                    }
                    .animation(.smooth, value: selectedTags.count)
                }

                Spacer()
            } .animation(.smooth, value: selectedTags.count)

        }

        .buttonStyle(regularOutlineMenu(color: color1))
        .animation(.smooth, value: selectedTags.count)
        .contentShape(Rectangle())
        .alert("New Tag", isPresented: $showAddTag) {
            TextField("Enter Tag name", text: $tagAddName)
            Button("Add",action: {
                let newTag = TagItem(context: viewContext)
                newTag.name = tagAddName

                do {
                    try viewContext.save()
                } catch {
                    let nsError = error as NSError
                    fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                }

                selectedTags.insert(newTag)
            })
            Button("Cancel", role: .cancel) { }

        }

        .padding(.horizontal, 20)

        if shortnameField{
            Text("Short name")
                .padding(.horizontal, 20)
                .sectionTitle()

            HStack(spacing: 0) {
                Image(systemName: "rectangle.portrait.arrowtriangle.2.inward")
                    .font(Font.body.weight(.bold))
                    .foregroundColor(Color.getAdjustedColor(color: color2, colorScheme: colorScheme))
                    .padding(.leading, 13)
                    .padding(.trailing, 5)
                TextField("Enter short class name..", text: $shortTitle, onCommit: {
//                    userHasEditedShortName = true
                })

                .focused($focusedField, equals: .shortTitle)
                .textContentType(.none)
#if os(iOS) || os(visionOS)
                .keyboardType(.asciiCapable)
                .submitLabel(.done)
#endif
                .autocorrectionDisabled(true)

            }
            .neoFieldCard()
            .padding(.horizontal, 20)
        }
    }
    }

    var colorSection: some View{
        VStack{
            Text("Colour")
                .sectionTitle()
                .padding(.horizontal, 20)

            ColorPanel(current1: $color1, current2: $color2)
        }
    }

    func createClassEntry(){
        log("[CreateClass] Creating a new class entry", debug: true)

        let classEntry = ClassEntity(context: viewContext)
        classEntry.id = UUID()
        log("[CreateClass] Assigned UUID: \(String(describing: classEntry.id))", debug: true)

        classEntry.color1 = color1.hexString
        classEntry.color2 = color2.hexString
        log("[CreateClass] Assigned colors: (\(String(describing: classEntry.color1)), \(String(describing: classEntry.color2)))", debug: true)

        classEntry.name = title
        log("[CreateClass] Assigned name: \(String(describing: classEntry.name))", debug: true)
        
        classEntry.icon = icon
        log("[CreateClass] Assigned icon: \(String(describing: classEntry.icon))", debug: true)

        classEntry.shortName = shortTitle

        for tag in selectedTags{
            if let tag = tag{
                classEntry.addToTags(tag)
            }
        }
        log("[CreateClass] Assigned short name: \(String(describing: classEntry.shortName))", debug: true)

        do {
            try viewContext.save()
            log("[CreateClass] Saved class entry to view context", debug: true)

            passThroughClass = classEntry
            log("[CreateClass] Updated passThroughClass with new class entry", debug: true)
        } catch {
            let nsError = error as NSError
            log("[CreateClass] Unresolved error \(nsError), \(nsError.userInfo)", debug: true)
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }

    func updateClassEntry() {
        log("[UpdateClass] Updating class entry", debug: true)

        if let classEntry = entity {
            classEntry.color1 = color1.hexString
            classEntry.color2 = color2.hexString
            log("[UpdateClass] Updated colors: (\(String(describing: classEntry.color1)), \(String(describing: classEntry.color2)))", debug: true)

            classEntry.name = title
            log("[UpdateClass] Updated name: \(String(describing: classEntry.name))", debug: true)

            classEntry.icon = icon
            log("[UpdateClass] Updated icon: \(String(describing: classEntry.icon))", debug: true)

            classEntry.shortName = shortTitle
            log("[UpdateClass] Updated short name: \(String(describing: classEntry.shortName))", debug: true)

            if let tags = entity?.tags as? Set<AnyHashable> {
                print("get tags")
                for tag in tags {
                    if let tagItem = tag as? TagItem {
                        if !selectedTags.contains(tagItem){
                            classEntry.removeFromTags(tagItem)
                        }
                    }
                }
            }
            for tag in selectedTags{
                if let tag = tag{
                    classEntry.addToTags(tag)
                }
            }
        } else {
            log("[UpdateClass] No class entry found to update", debug: true)
        }

        do {
            try viewContext.save()
            log("[UpdateClass] Saved updated class entry to view context", debug: true)
#if os(iOS)
            if let entity = entity {

//                SharedDataManager.shared.sendClassDataToWatch(entity: entity)

            }
            #endif
        } catch {
            let nsError = error as NSError
            log("[UpdateClass] Unresolved error \(nsError), \(nsError.userInfo)", debug: true)
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }

    var navBarContent: some View{
        HStack(spacing: 13){
                      
            if entity == nil{
                let condition = (entity == nil ? (title != "") : (title != entity?.name) || (icon != entity?.icon))

                Button {
                    if condition{
                        cancelAlert.toggle()
                    }
                    else{
                        dismiss()
                    }
                } label: {

                    Text(condition ? "Discard" : "Cancel")
#if os(iOS)
                        .foregroundColor(scrolled ? .primary : color2)
                        .font(.body.weight(.regular))
                        .padding(11)
//                      .neoNavigationButtonStyle(cornerRadius: 14, color: color)
                    #endif
                }
            }
            else{
                let condition = (entity == nil ? (title != "") : (title != entity?.name) || (icon != entity?.icon))

                Button { 
                    if condition{
                        cancelAlert.toggle()
                    }
                    else{
                        dismiss()
                    }
                } label: {

                    Text(condition ? "Discard" : "Cancel")
#if os(iOS)
                        .foregroundColor(scrolled ? .primary : color2)
                        .font(.body.weight(.regular))
                        .padding(11)
//                      .neoNavigationButtonStyle(cornerRadius: 14, color: color)
                    #endif
                }
            }
            Button {
                if entity == nil{
                    if title != ""{
                        createClassEntry()
                        dismiss()
                    }
                }
                if entity != nil{
                    if title != ""{
                        updateClassEntry()
                        dismiss()
                    }
                }
            } label: {
                Text(entity == nil ? "Create" : "Save")
                    .font(.body.weight(.regular))
#if os(iOS)
                    .scaledFrame(width: entity == nil ? 80 : 70, height: 40, relativeTo: .body)
                #endif
            }
#if os(iOS)
            .buttonStyle(NavigationButton(color: color1.darken(by: 0.2), scrolled: $scrolled))
            #endif
        }
    }
}
