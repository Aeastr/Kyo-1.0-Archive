//
//  ManageTasks.swift
//  KyoNeo
//
//  Created by Aether on 03/04/2023.
//

import Foundation
import SwiftUI
import AmethystUI

struct TaskCategoryManage: View {

    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "title", ascending: true)]) var categories: FetchedResults<TaskTypeEntity>

    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss

    @State var create = false

    //scroll logic
    @State var scrollValue = 0.0
    @State var scrolled: Bool = false

    @State var edit = false
    var color: Color = Color("1")

    var body: some View {

                ScrollView {
                    ScrollDetector(scrolled: $scrolled)
                    VStack(spacing: 0) {
                        ForEach(categories) { entity in
                            NavigationLink {
                                CreateCategory(entity: entity , editMode: true, color1: color, color2: color)
                            } label: {
                                CategoryMenuItem(data: entity, edit: $edit)
                                    .tint(color)

                            }
                        }
                    }
                        .background(Color("NeoButton"))
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .regularOutline()
                        .padding(.horizontal, 20)
                }
                .coordinateSpace(name: "scroll")

                .safeAreaInset(edge: .top, content: {
                  AdjustableInset()
                })


        .amethystNavigationBar(title: "Categories",titleColor: .primary,   tintColor: color, scrolled: $scrolled) {
                       navBarContent
                   }toolbar: {

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

                        .scaledFrame(width: 60, height: 44, relativeTo: .body)

            }
            .buttonStyle(NavigationButton(color: color, scrolled: $scrolled))
            .padding(.leading, 5)

                Button {
                    create.toggle()
            } label: {


                    Image(systemName: "plus")
                        .font(.body.weight(.regular))
                        .scaledFrame(width: 40, height: 44, relativeTo: .body)



            }
            .frame(maxHeight: .infinity)
            .buttonStyle(NavigationButton(color: color, scrolled: $scrolled))


                Button {
                    dismiss()
                } label: {


                        Text("Done")
                            .font(.body.weight(.regular))
                            .scaledFrame(width: 60, height: 44, relativeTo: .body)

                }
                .buttonStyle(NavigationButton(color: color, scrolled: $scrolled))

#if os(iOS) || os(visionOS)
                .sheet(isPresented: $create) {
                    NavigationStack{
                        CreateCategory(color1: color, color2: color)
                    }
                }
                #endif
            }
            else{
                Button {
                    withAnimation(.smoothCard){
                        edit = false
                    }
                } label: {
                    ZStack{

                            Rectangle()
                                .fill(Color.clear)

                        Text("Done")
                            .font(.body.weight(.regular))
                            .scaledFrame(width: 60, height: 44, relativeTo: .body)
                    }
                }
                .buttonStyle(NavigationButton(color: color, scrolled: $scrolled))

            }





        }
        .frame(maxWidth: .infinity, alignment: .trailing)


    }

  


}

struct CategoryMenuItem: View{
    var data: TaskTypeEntity

    @State var dragX: Double = 0.0
    @State var dragXOffset: Double = 0.0
    @State var mid = false
    @State var hideItem = false
    @State var confirmDelete: Bool = false
    @State var haptic = false
    @Binding var edit: Bool
    @State var dragged = false
    @State var enableSwipe = true

    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)]) var splitters: FetchedResults<SplitterEntity>

    var body: some View {
        if !hideItem{
            GeometryReader { geo in
                ZStack{
                    HStack(spacing: 0) {
                        
                        Image(systemName: data.icon ?? "Book")
                            .padding(.leading, 13)
                            .frame(width: 35, alignment: .center)
                        Text(data.title ?? "Untitled")
                        
                            .foregroundColor(.primary)
                        
#if os(iOS) || os(visionOS)
                            .autocapitalization(.none)
                            .textContentType(.name)
                            .padding(.leading, 8)
#endif
                        Spacer()
                        
                        
                        Image(systemName: "chevron.forward")
                        
                            .font(Font.body.bold())
                            .padding(.leading, 6)
                            .padding(.trailing, 13)
                    }
                    
                    .frame(minHeight: 50)
                    .background(Color("NeoButton"))
                    .offset(x: edit ?
                            confirmDelete ?
                            (dragX + dragXOffset) : -100
                            :
                                dragged ?

                            (dragX + dragXOffset)

                            :

                                0)

                    .background(
                        HStack{
                            Spacer()
                            ZStack(alignment: .leading) {
                                Color.red
                            }.frame(width:
                                        
                                        edit ?
                                    confirmDelete ?
                                    -(dragX + dragXOffset) : 100
                                    :
                                        dragged ?
                                    
                                    -(dragX + dragXOffset)
                                    
                                    :
                                        
                                        0
                            )
                            
                            .frame(minHeight: 50)
                            .onTapGesture {
                                withAnimation(.smoothCard){
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
                                        confirmDelete = true
                                        dragX = -(geo.size.width)
                                        dragXOffset = 0
                                    }
                                }







                            })
                    )

                }

                    .frame(minHeight:  50)
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
            .animation(.smooth, value: confirmDelete)
    #if os(iOS) || os(visionOS)
                    .actionSheet(isPresented: $confirmDelete) {
                        ActionSheet(
                            title: Text("Are you sure you want to delete " + (data.title ?? "Untitled")),
                            buttons: [
                                .destructive(Text("Delete")) {
                                    withAnimation(.closeCard){
                                        hideItem = true
                                        viewContext.delete(data)
                                        confirmDelete = false
                                        do {
                                            try viewContext.save()
                                        } catch {
                                            let nsError = error as NSError
                                            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                                        }
                                    }

                                },

                                    .cancel(){
                                        withAnimation(.closeCard){
                                            confirmDelete = false
                                            dragX = 0.0
                                            dragXOffset = 0.0
                                        }
                                    }
                            ]
                        )
                    }
#endif

            .frame(height: 50)


        }

    }


}
