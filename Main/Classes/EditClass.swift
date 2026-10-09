//
//  EditClass.swift
//  KyoNeo
//
//  Created by Aether on 28/01/2023.
//

import SwiftUI
import SymbolPicker
import AmethystUI

struct EditClass: View {
    var entity: ClassEntity

    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)]) var classes: FetchedResults<ClassEntity>
    @Environment(\.managedObjectContext) private var viewContext
    @State var title: String = ""
    @State var shortTitle: String = ""
    @State var backButton: Bool = true
    @State var color1: Color
    @State var color2: Color
    @State var icon: String
    @State var iconEdit: Bool = false

    @AppStorage("shortnameField") var shortnameField = true

    enum FocusField: Hashable {
    case title
    case shortTitle
        case none
    }
    // State variable for focus state
    @FocusState private var focusedField: FocusField?

    @Environment(\.colorScheme) var colorScheme

    @State var scrolled: Bool = false
    @State var showColorEdit: Bool = false
    @State var userHasEditedShortName = false
    @Environment(\.dismiss) var dismiss

    init(entity: ClassEntity, color1: Color, color2: Color, backButton: Bool = true) {
        self.entity = entity
        self._icon = State(initialValue: entity.icon ?? "book.closed")
        self._title = State(initialValue: entity.name ?? "")
        self._color1 = State(initialValue: Color(hex: entity.color1 ?? "98C6D1"))
        self._color2 = State(initialValue: Color(hex: entity.color2 ?? "98C6D1"))
        self._shortTitle = State(initialValue: entity.shortName ?? "")
        self._backButton = State(initialValue: backButton)
        if entity.shortName != "" {
            self._userHasEditedShortName = State(initialValue: true)
        }
    }


    var body: some View {
        ZStack {

            pageTopHue(color: color1)
            
            ScrollView{
                ScrollDetector(scrolled: $scrolled)
                HStack{
                    VStack{
                        Text("NAME")
                            .sectionTitle(topPadding: 0)
                        HStack(spacing: 0) {
                            Image(systemName: "character.cursor.ibeam")
                                .font(Font.body.weight(.bold))
                                .foregroundColor(Color.getAdjustedColor(color: color1, colorScheme: colorScheme))
                                .padding(.leading, 13)
                                .padding(.trailing, 5)
                            TextField("Enter name..", text: $title, onCommit: {
                                if !userHasEditedShortName && shortnameField {
                                    shortTitle = title.shortenedClassName()
                                }
                            })
                                .focused($focusedField, equals: .title)
                                .onAppear{
                                    focusedField = .title
                                }
                                .textContentType(.none)
#if os(iOS) || os(visionOS)
                                .keyboardType(.asciiCapable)
                                .submitLabel(.done)
#endif


                        }





                        .frame(minHeight: 50)
                        .background(Color("textField"))
                        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(LinearGradient(gradient: Gradient(colors: [Color("outline1"), Color("outline2")]), startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1.17))
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

                    }
                    VStack{

                        Text("Icon")
                            .sectionTitle(topPadding: 0, horizontalPadding: 0)
                        Button {
                            iconEdit.toggle()
                        } label: {
                            Image(systemName: icon)

                            .symbolRenderingMode(/*@START_MENU_TOKEN@*/.hierarchical/*@END_MENU_TOKEN@*/)
                            .font(.system(size: 20).weight(.bold))
                            .foregroundColor(Color.getAdjustedColor(color: color2, colorScheme: colorScheme))
                                .frame(minHeight: 50)
                                .frame(minWidth: 50)
                                .background(Color("textField"))
                                .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(LinearGradient(gradient: Gradient(colors: [Color("outline1"), Color("outline2")]), startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1.17))
                                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        }
                        .buttonStyle(bounceButton())


                    }
                    .frame(width: 50)
                }
                .padding(.horizontal, 20)
                .shadow(color: .primary.opacity(0.05), radius: 13, x: 0, y: 5)

                if shortnameField{
                    Text("Short name")
                        .padding(.horizontal, 20)
                        .sectionTitle()

                    HStack(spacing: 0) {
                        Image(systemName: "rectangle.portrait.arrowtriangle.2.inward")
                            .font(Font.body.weight(.bold))
                            .foregroundColor(Color.getAdjustedColor(color: color1, colorScheme: colorScheme))
                            .padding(.leading, 13)
                            .padding(.trailing, 5)
                        TextField("Enter short class name..", text: $shortTitle, onCommit: {
                            userHasEditedShortName = true
                        })
                            .focused($focusedField, equals: .shortTitle)
                            .textContentType(.none)
#if os(iOS) || os(visionOS)
                            .keyboardType(.asciiCapable)
                            .submitLabel(.done)
#endif

                    }
                    .neoFieldCard()
                    .padding(.horizontal, 20)
                }
                VStack{
                    Text("COLOUR")
                        .sectionTitle()
                        .padding(.horizontal, 20)
                    ColorPanel(current1: $color1, current2: $color2)
                }
                .sheet(isPresented: $iconEdit, content: {
                    if #available(iOS 16.4, *) {

                            SymbolPicker(symbol: $icon, background: Color("Background3"), accent: color1)

                        .symbolRenderingMode(/*@START_MENU_TOKEN@*/.hierarchical/*@END_MENU_TOKEN@*/)
                            .tint(color1)

                            .presentationDetents([.fraction(0.7), .large])

                            .presentationCornerRadius(25)
                    } else {
                        SymbolPicker(symbol: $icon, background: Color("Background3"), accent: color1)

                    .symbolRenderingMode(/*@START_MENU_TOKEN@*/.hierarchical/*@END_MENU_TOKEN@*/)
                        .tint(color1)
                        .presentationCornerRadius(25)
                    }
                })


            }
            .coordinateSpace(name: "scroll")

            .safeAreaInset(edge: .top, content: {
                Color.clear.frame(height: 85)
            })



        }
        .overlay(alignment: .top){
            FluidNavigationBar(
                title: entity.name?.count ?? 0 <= 16 ?  "Edit \(entity.name ?? "Class")".shortened(maxLength: 19) :"Edit \(entity.shortName ?? "Class")".shortened(maxLength: 19) , 
                
                titleColor: .primary,   tintColor: color1, type: backButton ? .back : .regular, scrolled: $scrolled, content: {
                    navBarContent
                }, toolbar: {
                    
                })
            
        }
#if os(iOS) || os(visionOS)
        .navigationBarTitle("")
            .navigationBarHidden(true)
#endif
    }

    func updateClassEntry(){
        let classEntry = entity
        classEntry.color1 = color1.hexString
        classEntry.color2 = color2.hexString
        classEntry.name = title
        classEntry.icon = icon
        classEntry.shortName = shortTitle


        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }

    var navBarContent: some View{
        HStack(spacing: 0){

            Button {
                if title != ""{
                    updateClassEntry()
                    dismiss()

                }
            } label: {
                Text("Done")
                    .font(.body.weight(.regular))
                    .scaledFrame(width: 70, height: 40, relativeTo: .body)

        }
            .buttonStyle(NavigationButton(color: Color.getAdjustedColor(color: color1, colorScheme: colorScheme), scrolled: $scrolled))
        }
    }
}
