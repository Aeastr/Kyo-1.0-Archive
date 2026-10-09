//
//  SplitterManage.swift
//  KyoNeo
//
//  Created by Aether on 29/01/2023.
//

import SwiftUI
import AmethystUI

struct SplitterManage: View {

    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)]) var splitters: FetchedResults<SplitterEntity>

    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss

    @State var create = false

    //scroll logic
    @State var scrollValue = 0.0
    @State var scrolled: Bool = false

    @State var edit = false
    var color: Color = Color("1")

    var body: some View {
        NavigationView {
            ZStack{
//                pageTopHue(color: color)
                Color("bw")
                    .opacity(0.6)
                    .ignoresSafeArea()

                ScrollView {
                    ScrollDetector(scrolled: $scrolled)

                    VStack(spacing: edit ? 16 : 13) {
                        ForEach(splitters, id: \.id) { entity in
                            NavigationLink {
                                SplitterEdit(entity: entity)
                            } label: {
                                SplitPeelItem(entity: entity, progressOffset: edit ? 0.2 : 0, edit: $edit)

                            }

                            .buttonStyle(BouncyButton())
                        }
                    }
                    .padding(.horizontal, 20)

                    Divider()
                        .padding(.horizontal, 30)
                        .padding(.vertical, 8)
                    VStack(spacing: 0) {
//                        for splitter in defaultSplitters{
//                            let newSplitter = SplitterEntity(context: viewContext)
//                            newSplitter.id = UUID()
//                            newSplitter.name = splitter.text
//
//                            newSplitter.color1 = Color.random().hexString
//                            newSplitter.color2 = Color.random().hexString
//                            newSplitter.number = Int64(index)
//
//                        }
//
//                        do {
//                            try viewContext.save()
//                        } catch {
//                            let nsError = error as NSError
//                            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//                        }
                        ForEach(defaultSplitters, id: \.id){ splitter in
                            if !(splitters.contains(where: { split in
                                split.name == splitter.text
                            })){

                                Button {
                                    let newSplitter = SplitterEntity(context: viewContext)
                                                                newSplitter.id = UUID()
                                                                newSplitter.name = splitter.text
                                    
                                                                newSplitter.color1 = Color.random().hexString
                                                                newSplitter.color2 = Color.random().hexString
                                                               
                                                            do {
                                                                try viewContext.save()
                                                            } catch {
                                                                let nsError = error as NSError
                                                                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                                                            }
                                } label: {
                                    HStack(spacing: 0) {

                                        Text("Add \(splitter.text)")

                                            .foregroundColor(.primary)

                                            .padding(.leading, 13)
                                        Spacer()


                                        Image(systemName: "plus")

                                            .font(Font.body.bold())
                                            .padding(.leading, 6)
                                            .padding(.trailing, 18)

                                    }
                                    .frame(minHeight: 50)
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(bounceButton())


                            }
                        }
                    }
                    .background(Color("NeoButton").opacity(0.6))
                    .regularOutline()
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .padding(.horizontal, 20)
                    .shadow(color: .primary.opacity(0.04), radius: 15, x: 0, y: 3)



                }
                .coordinateSpace(name: "scroll")


                .safeAreaInset(edge: .top, content: {
                    Color.clear.frame(height: 100)
                })
                .safeAreaInset(edge: .bottom, content: {
                    Color.clear.frame(height: 30)
                })
                .overlay(alignment: .top){
                    FluidNavigationBar(title: "Splits", titleColor: .primary,   tintColor: color, scrolled: $scrolled){
                        navBarContent
                            .padding(.top, 15)
                    }toolbar: {
                        
                        ViewThatFits{
                            Text("^[\(splitters.count) Split](inflect: true)")
                                .transition(.blur.animation(.smooth))
                            Text("")
                        }
                        .transition(.blur.animation(.smooth))
                        .scaledFrame(width: nil, height: 42, relativeTo: .body, alignment: .leading)
                        .padding(.top, 15)
                    }
                    
                }
            }
#if os(iOS) || os(visionOS)
            .navigationTitle("")
            .navigationBarHidden(true)
#endif
        }
    }

    var navBarContent: some View{
        HStack(spacing: 13){

            if !edit{
                Button {
                    withAnimation(.smoothCard){
                        edit = true
                    }
            } label: {

                    Text("Edit")
                        .font(.body.weight(.regular))
                        .scaledFrame(width: nil, height: 42, relativeTo: .body)
                        .padding(.horizontal, 15)

            }
            .buttonStyle(NavigationButton(color: color, scrolled: $scrolled))

                Button {
                    create.toggle()
            } label: {


                    Image(systemName: "plus")
                        .font(.body.weight(.regular))
                        .scaledFrame(width: 42, height: 42, relativeTo: .body)



            }
            .frame(maxHeight: .infinity)
            .buttonStyle(NavigationButton(color: color, scrolled: $scrolled))


#if os(iOS) || os(visionOS)
                .fullScreenCover(isPresented: $create) {
                    CreateSplitter(color1: color)

                }
                #endif

                Button {
                    dismiss()
                } label: {


                    Text("Done")
                        .font(.body.weight(.regular))

                        .scaledFrame(width: nil, height: 42, relativeTo: .body, alignment: .leading)
                        .padding(.horizontal, 15)

                }
                        .buttonStyle(NavigationButton(color: color, scrolled: $scrolled))

                .transition(.blur)

            }
            else{
                Button {
                    withAnimation(.smoothCard){
                        edit = false
                    }
                } label: {

                        Text("Done")
                            .font(.body.weight(.regular))
                            .scaledFrame(width: 70, height: 40, relativeTo: .body)
                    
                }
                .buttonStyle(NavigationButton(color: color, scrolled: $scrolled))

            }





        }
        .fixedSize()


    }

    


}


struct SplitterManage_Previews: PreviewProvider {
    static var previews: some View {
        SplitterManage()
    }
}
