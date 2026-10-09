//
//  CreateSplitter.swift
//  KyoNeo
//
//  Created by Aether on 29/01/2023.
//

import SwiftUI
import AmethystUI



struct CreateSplitter: View {
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)]) var splitters: FetchedResults<SplitterEntity>
    @Environment(\.managedObjectContext) private var viewContext
    @FocusState private var focusedField: Bool
    @State var title: String = ""
    @State var color1: Color = Color("1")
    @State var color2: Color = Color("1")
    @State var scrolled: Bool = false
    @State var showColorEdit: Bool = false
    @State var divider: Bool = true
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            let accent = Color.getAdjustedColor(color: color1, colorScheme: colorScheme)
            let accent2 = Color.getAdjustedColor(color: color2, colorScheme: colorScheme)
            pageTopHue(color: color1)

            ScrollView{
                ScrollDetector(scrolled: $scrolled)


                Text("NAME")
                    .sectionTitle(topPadding: 0)
                    .padding(.horizontal, 20)
                HStack(spacing: 0) {
                    Image(systemName: "character.cursor.ibeam")
                        .font(Font.body.weight(.bold))
                        .foregroundColor(accent)
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
                    //  .toolbar{
                    //     ToolbarItemGroup(placement: .keyboard) {
                    //  toolbarContentCreation(filter: title, title: $title, room: $room, color1: $color1, color2: $color2)
                    //  Button {
                    //       focusedField = .none
                    //   } label: {
                    //      Text("Done")
                    //   }


                    // }

                    // }

                }

                .frame(minHeight: 50)
                .background(Color("NeoButton"))


                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .regularOutline()
                .padding(.horizontal, 20)


                VStack{

                    Text("Type")
                        .sectionTitle()
                    Toggle(isOn: $divider) {
                    HStack{
                        Image(systemName: "line.3.horizontal")
                            .frame(width: 20, alignment: .center)
                            .symbolRenderingMode(/*@START_MENU_TOKEN@*/.hierarchical/*@END_MENU_TOKEN@*/)
                            .foregroundColor(accent)

                    VStack(alignment: .leading, spacing: 3){
                        Text("Divider ")
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("This splitter will appear as a divider")
                            .font(.caption).opacity(0.5)
                            .offset(x: 1)
                    }
                }
                }
                .padding(.horizontal, 13)
                .tint(accent)
                .neoFieldCard()
                }
                .padding(.horizontal, 20)


                Text("COLOUR")
                    .sectionTitle()
                    .padding(.horizontal, 20)
                ColorPanel(current1: $color1, current2: $color2)


            }
            .coordinateSpace(name: "scroll")


            .safeAreaInset(edge: .top, content: {
                Color.clear.frame(height: 85)
            })
            .safeAreaInset(edge: .bottom, content: {
                Color.clear.frame(height: 30)
            })



        } 
        .overlay(alignment: .top){
            FluidNavigationBar(title: "Create Split", titleColor: .primary,    tintColor: color1 ,scrolled: $scrolled, content: {
                navBarContent
            }, toolbar: {
                
            })
        }
    }

    func createSplitEntry(){
        let entry = SplitterEntity(context: viewContext)
        entry.id = UUID()
        entry.color1 = color1.hexString
        entry.color2 = color2.hexString
        entry.name = title

        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }


    var navBarContent: some View{
        HStack(spacing: 13){
            let accent = Color.getAdjustedColor(color: color1, colorScheme: colorScheme)
            let accent2 = Color.getAdjustedColor(color: color2, colorScheme: colorScheme)
            
            Button {

                dismiss()
            } label: {

                Text("Cancel")
                    .foregroundColor(accent)
                    .brightness(scrolled ? -1 : 0)
                    .font(.body.weight(.regular))
                    .padding(11)

            }


            Button {
                if title != ""{
                    createSplitEntry()
                    dismiss()

                }
                else{
                    // showError.toggle()
                    //errorText = "Please fill all the boxes"
                }
            } label: {
                Text("Create")
                    .font(.body.weight(.regular))
                    .scaledFrame(width: 80, height: 40, relativeTo: .body)
            }
            .buttonStyle(NavigationButton(color: accent, scrolled: $scrolled))
        }
    }
}
