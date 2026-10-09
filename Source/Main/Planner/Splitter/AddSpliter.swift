//
//  AddSpliter.swift
//  KyoNeo
//
//  Created by Aether on 29/01/2023.
//

import SwiftUI

struct AddSpliterEntity: View {
    var color: Color = Color.accentColor
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)]) var classes: FetchedResults<ClassObject>
    @Environment(\.managedObjectContext) private var viewContext
    @State var name: String = ""

    @Binding var selectedSplitter: Splitter
    @FocusState private var focusedField: Bool
    @Binding var SplitterHasBeenSelected: Bool

    @State var scrolled: Bool = false
    @State var showColorEdit: Bool = false
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {

            Color("Background3")
                .ignoresSafeArea()
            Image("dots")
                .resizable()
                .ignoresSafeArea()
                .blendMode(colorScheme == .light ? .multiply : .normal)
                .opacity(0.1)
            ScrollView{
                scrollDetection


                Text("NAME")
                    .sectionTitle(topPadding: 0)
                HStack(spacing: 0) {
                    Image(systemName: "character.cursor.ibeam")
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .padding(.leading, 13)
                        .padding(.trailing, 5)
                    TextField("Enter name..", text: $name)
                        .focused($focusedField)
                        .onAppear{
                            focusedField = true
                        }
                        .textContentType(.none)
                        .keyboardType(.asciiCapable)
                        .autocorrectionDisabled(true)
                        .submitLabel(.done)
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
                .background(Color("textField"))
                .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(LinearGradient(gradient: Gradient(colors: [Color("outline1"), Color("outline2")]), startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1.17))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .padding(.horizontal, 25)
                .shadow(color: .primary.opacity(0.05), radius: 13, x: 0, y: 5)



            }
            .coordinateSpace(name: "scroll")
            .safeAreaInset(edge: .top, content: {
                Color.clear.frame(height: 70)
            })



        }.overlay(
            NavigationBar(type: .blank, title: "New Class", color: color, scrolled: $scrolled){
                navBarContent
            }
            )
    }

    func createSplitterEntity(){
        let splitterEntity = Splitter(context: viewContext)
        splitterEntity.name = name
        selectedSplitter = splitterEntity
        SplitterHasBeenSelected = true

        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }

    var scrollDetection: some View {
        GeometryReader { proxy in
            //   Text("\(proxy.frame(in: .named("scroll")).minY)")
            Color.clear
                .preference(key: ScrollPreferenceKey.self, value: proxy.frame(in: .named("scroll")).minY)

        }
        .frame(height: 0)
        .onPreferenceChange(ScrollPreferenceKey.self, perform: { value in
           // scrollValue = value
            withAnimation(.spring(response: 0.1, dampingFraction: 3)) {
                if value < -13 {
                    scrolled = true
                }
                else{
                    scrolled = false
                }
            }

        })
    }

    var navBarContent: some View{
        HStack(spacing: 13){
            Button {

                dismiss()
            } label: {

                Text("Cancel")
                    .foregroundColor(color)
                    .font(.body.weight(.regular))
                    .padding(11)
                //  .neoNavigationButtonStyle(cornerRadius: 14, color: color)
            }


            Button {
                if name != ""{
                    createSplitterEntity()
                    dismiss()

                }
                else{
                   // showError.toggle()
                    //errorText = "Please fill all the boxes"
                }
            } label: {
                Text("Create")
                    .foregroundColor(color)
                    .font(.body.weight(.regular))
                    .padding(11)
                    .neoNavigationButtonStyle(cornerRadius: 14, color: color)

            }
        }
    }
}


