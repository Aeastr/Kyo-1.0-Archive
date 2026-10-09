//
//  TaskTypeCreation .swift
//  KyoNeo
//
//  Created by Aether on 03/04/2023.
//

import SwiftUI
import SymbolPicker
import AmethystUI

struct CreateCategory: View{
    @State var color1: Color = .white
    @State var color2: Color = .white

    @Environment(\.managedObjectContext) private var viewContext

    @State var title: String = ""
    @State var icon: String = "book"
    var entity: TaskTypeEntity?

    @Environment(\.colorScheme) var colorScheme

    @Environment(\.dismiss) var dismiss

    @FocusState private var focusedField: Bool

    @State var scrolled: Bool = false
    @State var iconEdit: Bool = false
    @State var editMode: Bool = false

    init(entity: TaskTypeEntity? = nil, editMode: Bool = false, color1: Color = .white, color2: Color = .white){
            self.entity = entity
        self._title = .init(initialValue: entity?.title ?? "")
        self._icon = .init(initialValue: entity?.icon ?? "book")
        self._color1 = .init(initialValue: color1)
        self._color2 = .init(initialValue: color2)
        self._editMode = .init(initialValue: editMode)

    }

    var body: some View{
        ZStack{

            pageTopHue(color: color1)
            
                .sheet(isPresented: $iconEdit, content: {
                    if #available(iOS 16.4, *) {

                            SymbolPicker(symbol: $icon, background: Color("Background3"), accent: color1)

                        .symbolRenderingMode(/*@START_MENU_TOKEN@*/.hierarchical/*@END_MENU_TOKEN@*/)
                            .tint(color1)

                            .presentationDetents([.fraction(0.4), .large])
                            .presentationCornerRadius(25)
                    } else {
                        SymbolPicker(symbol: $icon, background: Color("Background3"), accent: color1)

                    .symbolRenderingMode(/*@START_MENU_TOKEN@*/.hierarchical/*@END_MENU_TOKEN@*/)
                        .tint(color1)
                    }
                })



            ScrollView{
                ScrollDetector(scrolled: $scrolled)

                HStack{
                    VStack{
                        Text("NAME")
                            .sectionTitle(topPadding: 0)
                        HStack(spacing: 0) {
                            Image(systemName: "character.cursor.ibeam")
                                .font(Font.body.weight(.bold))
                                .foregroundColor(color1)
                                .padding(.leading, 13)
                                .padding(.trailing, 5)
                            TextField("Enter name..", text: $title)
                                .focused($focusedField)
                                .onAppear{
                                    focusedField = true
                                }
                                .textContentType(.none)
#if os(iOS) || os(visionOS)
                                .keyboardType(.asciiCapable)
                                .submitLabel(.done)
#endif
                                .autocorrectionDisabled(true)


                        }





                        .frame(minHeight: 50)
                        .background(Color("NeoButton"))
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .regularOutline()

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
                            .foregroundColor(color1)
                                .frame(minHeight: 50)
                                .frame(minWidth: 50)
                                .background(Color("NeoButton"))
                                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                                .regularOutline()
                        }
                        .buttonStyle(bounceButton())


                    }
                    .frame(width: 50)
                }
                .padding(.horizontal, 20)

            }
            .coordinateSpace(name: "scroll")

            .safeAreaInset(edge: .top, content: {
                Color.clear.frame(height: 90)
            })
            .safeAreaInset(edge: .bottom, content: {
                Color.clear.frame(height: 70)
            })

        }
        .amethystNavigationBar(title: editMode ? "Edit" : "Category", titleColor: .primary,   tintColor: color1, overrideType: editMode ? .back : .regular, scrolled: $scrolled) {
            navBarContent
        } toolbar: {

        }



    }


    var navBarContent: some View{
        HStack(spacing: 13){

            Button {

                dismiss()

            } label: {

                Text("Cancel")
                    .foregroundColor(scrolled ? .primary : color2)
                    .font(.body.weight(.regular))
                    .scaledFrame(width: 80, height: 44, relativeTo: .body)
            }
            .buttonStyle(bounceButton())


            Button {
                createCategory()
                dismiss()
            } label: {
                Text(editMode ? "Save" : "Create")
                    .font(.body.weight(.regular))
                    .scaledFrame(width: editMode ? 60 : 80, height: 44, relativeTo: .body)

            }
            .buttonStyle(NavigationButton(color: color1, scrolled: $scrolled))
        }
    }
    func createCategory(){
        if !editMode{
            let category = TaskTypeEntity(context: viewContext)
            category.id = UUID()
            category.title = title
            category.icon = icon
        }
        else{
            entity?.title = title
            entity?.icon = icon
        }
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}
