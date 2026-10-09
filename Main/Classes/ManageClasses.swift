//
//  ManageClasses.swift
//  KyoNeo
//
//  Created by Aether on 28/01/2023.
//

import SwiftUI
import AmethystUI

struct ManageClasses: View {

    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "number", ascending: true)],
                  predicate: NSPredicate(format: "singleDayWeek == nil OR singleDayWeek == %@", NSNumber(value: false))
    ) var weeks: FetchedResults<Week>


    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "number", ascending: true),
                                    // Add more sort descriptors if needed
                                   ],
                  predicate: NSPredicate(format: "singleDayWeek == %@", NSNumber(value: true))
    ) var singleDayweeks: FetchedResults<Week>
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "number", ascending: true)]) var days: FetchedResults<Day>
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)]) var classEntities: FetchedResults<ClassEntity>
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "timestamp", ascending: true)]) var timeSlots: FetchedResults<TimeSlot>

    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss

    @State var classCreate = false

    //scroll logic
    @State var scrollValue = 0.0
    @State var scrolled: Bool = false
    
    @State var edit: Bool = false

    var color: Color = Color("1")

    var body: some View {
        NavigationStack {
            ZStack{
                Color("bw")
                    .opacity(0.6)
                    .ignoresSafeArea()

                ScrollView {
                    ScrollDetector(scrolled: $scrolled)
                    
                    LazyVStack(spacing: edit ? 16 : 13) {
                        ForEach(classEntities) { entity in
                            NavigationLink {
                                ClassComposer(entity: entity)
                            } label: {
                                VStack{
                                    ClassPeelItem(entity: entity, progressOffset: edit ? 0.2 : 0, edit: $edit)
                                }

                            }

                            .buttonStyle(BouncyButton())


                        }
                    }
                    

                        .padding(.horizontal, 20)
                }
                .coordinateSpace(name: "scroll")


                .safeAreaInset(edge: .top, content: {
                    Color.clear.frame(height: 100)
                })
                .safeAreaInset(edge: .bottom, content: {
                    Color.clear.frame(height: 30)
                })
                #if os(iOS) || os(visionOS)
                .overlay(alignment: .top){

                    FluidNavigationBar(title: VariableDataNames().classesName(), titleColor: .primary,   tintColor: color, scrolled: $scrolled){
                        navBarContent
                            .padding(.trailing, -5)
                            .padding(.top, 15)
                    }toolbar: {

                        ViewThatFits{
                            Text("^[\(classEntities.count) \(VariableDataNames().className().titleCase())](inflect: true)")
                                .transition(.blur.animation(.smooth))

                            Text("")
                        }
                        .transition(.blur.animation(.smooth))
                        .padding(.trailing, -5)

                        .scaledFrame(width: nil, height: 42, relativeTo: .body, alignment: .leading)
                        .padding(.top, 15)

                    }

                }
#endif
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
                    classCreate.toggle()
            } label: {


                    Image(systemName: "plus")
                        .font(.body.weight(.regular))

                        .scaledFrame(width: 44, height: 42, relativeTo: .body)

                    }
                    .buttonStyle(NavigationButton(color: color, scrolled: $scrolled))
                    .transition(.blur)
            }
                Button {
                    withAnimation(.smoothCard){
                        edit.toggle()
                    }
            } label: {

                Text(edit ? "Done" : "Edit")
                        .font(.body.weight(.regular))

                        .scaledFrame(width: nil, height: 42, relativeTo: .body, alignment: .center)
                        .padding(.horizontal, 15)
                        .contentShape(Rectangle())
            }
                .buttonStyle(NavigationButton(color: color, scrolled: $scrolled))

                .transition(.blur)
#if os(iOS) || os(visionOS)
                .fullScreenCover(isPresented: $classCreate) {
                    ClassComposer(color1: color, color2: color)

                }
                #endif



            if !edit{
                Button {
                    dismiss()
                } label: {


                    Text("Done")
                        .font(.body.weight(.regular))

                        .scaledFrame(width: nil, height: 42, relativeTo: .body, alignment: .leading)
                        .padding(.horizontal, 15)
                        .contentShape(Rectangle())

                }
                .buttonStyle(NavigationButton(color: color, scrolled: $scrolled))
                //            .buttonStyle(borderlessButton(color: color, scrolled: $scrolled))
                .transition(.blur)
            }



        }
        .animation(.smooth, value: edit)
        .fixedSize()


    }

    


}


struct classListItem: View {
    var entity: ClassEntity
    @State var dragX: Double = 0.0
    @State var dragXOffset: Double = 0.0
    @State var mid = false
    @State var hideItem = false
    @State var confirmDelete: Bool = false
    @State var haptic = false
    @State var width = 0.0
    @State var dragged = false
    @Binding var edit: Bool
    @State var enableShadow = true
    @Environment(\.colorScheme) var colorScheme

    @AppStorage("darkenText") var darkenText = false

    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "number", ascending: true)],
                  predicate: NSPredicate(format: "singleDayWeek == nil OR singleDayWeek == %@", NSNumber(value: false))
    ) var weeks: FetchedResults<Week>


    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "number", ascending: true),
                                    // Add more sort descriptors if needed
                                   ],
                  predicate: NSPredicate(format: "singleDayWeek == %@", NSNumber(value: true))
    ) var singleDayweeks: FetchedResults<Week>
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "number", ascending: true)]) var days: FetchedResults<Day>
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "timestamp", ascending: true)]) var timeSlots: FetchedResults<TimeSlot>

    @Environment(\.managedObjectContext) private var viewContext


    var body: some View {
        if !hideItem{
        GeometryReader { geo in
            
            let brightness1 = (darkenText ? Color(hex: entity.color1 ?? "98C6D1" ).getBrightness() : 0.0)
            let brightness2 = (darkenText ? Color(hex: entity.color2 ?? "98C6D1" ).getBrightness() : 0.0)

            ZStack {
                LinearGradient(
                    gradient: Gradient(
                        colors: !darkenText && (Color(hex: entity.color1 ?? "98C6D1" ).getBrightness() > 0.85 || Color(hex: entity.color2 ?? "98C6D1" ).getBrightness() > 0.85) ? [
                            Color.getAdjustedColor(color: Color(hex: entity.color1 ?? "98C6D1" ), colorScheme: colorScheme, factor: 2).moreSaturated(factor: 4),
                            Color.getAdjustedColor(color: Color(hex: entity.color2 ?? "98C6D1" ), colorScheme: colorScheme, factor: 2).moreSaturated(factor: 4)
                        ] : [
                             Color(hex: entity.color1 ?? "98C6D1" ),
                            Color(hex: entity.color2 ?? "98C6D1" )
                        ]
                    ),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                    .mask(
                        RoundedRectangle(cornerRadius: 25, style: .continuous)

                    )
                  //  .shadow(color: Color(hex: entity.color1 ?? "98C6D1").opacity(enableShadow ? 0.5 : 0), radius: 4, x:0, y: 4)

                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Image(systemName: entity.icon ?? "square")
                            .symbolRenderingMode(/*@START_MENU_TOKEN@*/.hierarchical/*@END_MENU_TOKEN@*/)
                                .font(.system(size: 23))
                                .padding(10)
                                .frame(width: 50, height: 50)
                                .shadow(color: Color(hex: entity.color1 ?? "98C6D1").opacity(0.2), radius: 3, y: 3)
                                .background(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 14,style: .continuous))
                                .foregroundColor(Color.getAdjustedColor(color: Color(hex: entity.color1 ?? "98C6D1"), colorScheme: colorScheme))
                                .padding(.trailing, 3)
                            VStack(alignment: .leading){

                                if entity.shortName != ""{
                                    if entity.name?.count ?? 0 <= 16{
                                        Text(entity.name ?? "Untitled")
                                        //   .strikethrough(past ? true : false)
                                            .textCase(.uppercase)
                                            .font(Font.body.weight(.semibold))
                                            .lineLimit(2)
                                            .minimumScaleFactor(0.5)
                                            .foregroundColor(brightness1 > 0.85 ? Color.black : Color.white)
                                            .lineSpacing(1)
                                            .multilineTextAlignment(.leading)

                                        Text(entity.shortName ?? "Untitled")
                                        //   .strikethrough(past ? true : false)
                                            .textCase(.uppercase)
                                            .font(Font.caption.weight(.regular))
                                            .lineLimit(2)
                                            .minimumScaleFactor(0.5)
                                            .foregroundColor(brightness1 > 0.85 ? Color.black : Color.white)
                                            .lineSpacing(1)
                                            .multilineTextAlignment(.leading)
                                    }
                                    else{
                                        Text(entity.shortName ?? "Untitled")
                                        //   .strikethrough(past ? true : false)
                                            .textCase(.uppercase)
                                            .font(Font.body.weight(.semibold))
                                            .lineLimit(2)
                                            .minimumScaleFactor(0.5)
                                            .foregroundColor(Color.white)
                                            .lineSpacing(1)
                                            .multilineTextAlignment(.leading)

                                        Text(entity.name?.shortened() ?? "Untitled")
                                        //   .strikethrough(past ? true : false)
                                            .textCase(.uppercase)
                                            .font(Font.caption.weight(.regular))
                                            .lineLimit(2)
                                            .minimumScaleFactor(0.5)
                                            .foregroundColor(brightness1 > 0.85 ? Color.black : Color.white)
                                            .lineSpacing(1)
                                            .multilineTextAlignment(.leading)
                                    }
                                    
                                }
                                else{

                                        Text(entity.name ?? "Untitled")
                                        //   .strikethrough(past ? true : false)
                                            .textCase(.uppercase)
                                            .font(Font.body.weight(.semibold))
                                            .lineLimit(2)
                                            .minimumScaleFactor(0.5)
                                            .foregroundColor(brightness1 > 0.85 ? Color.black : Color.white)
                                            .lineSpacing(1)
                                            .multilineTextAlignment(.leading)
                                }
                            }
                            Spacer()

                            Image(systemName: "chevron.forward")


                                .font(.body.weight(.regular))
                                .foregroundColor(brightness2 > 0.85 ? Color.black : Color.white)
                            .padding(.leading, 6)




                        }

                    }
                  //  .fr
                    .padding(.leading, 11)
                    .padding(.trailing, 25)
                    .padding(.vertical, 10)


            }

            .offset(x: edit ? -100 : dragX + dragXOffset)
            .background(


                    HStack{
                        Spacer()
                        ZStack(alignment: .leading) {
                            Color.red
                        }

                        .frame(width:

                                edit ?
                               80
                               :
                                dragged ?
                                (-(dragX + dragXOffset) - 20) < 80 ?
                               80:
                                (-(dragX + dragXOffset) - 20) > geo.size.width ?
                               geo.size.width
                               :
                               -(dragX + dragXOffset) - 20

                               :

                                80
                        )

                        .mask(
                            RoundedRectangle(cornerRadius: 25, style: .continuous)

                        )

                      //  .frame(height: 70 )


                        //    .frame(minHeight: 50)
                            .onTapGesture {
                                withAnimation(.smoothCard){

                                       // dragX = -500.0

                                    confirmDelete = true
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
                                .opacity(dragged || edit ? 1 : 0)
                            }

                            .scaleEffect((-(dragX + dragXOffset) - 20) < 80 ? 0.9 : 1)
                    } .opacity(dragged || edit ? 1 : 0)


            )

#if !os(tvOS)
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
#endif

        }
        //.frame(minHeight:  50)
#if os(iOS)
                .actionSheet(isPresented: $confirmDelete) {
                                ActionSheet(
                                    title: Text("Are you sure you want to delete \(entity.name ?? "Untilted \(VariableDataNames().className())")? This will delete all entries of this \(VariableDataNames().className())"),
                                    buttons: [
                                        .destructive(Text("Delete \(entity.name ?? "Untilted \(VariableDataNames().className())")")) {
                                            withAnimation(.closeCard){
                                                dragged = false
                                                hideItem = true
                                                deleteClass(entity: entity)
                                            }

                                        },

                                        .cancel(){
                                            withAnimation(.closeCard){
                                                dragged = false
                                                dragX = 0.0
                                                dragXOffset = 0.0
                                            }
                                        }
                                    ]
                                )
                            }
                .onChange(of: haptic) { newValue in

                    let impactMed = UIImpactFeedbackGenerator(style: .soft)
                    impactMed.impactOccurred()

                }
#endif
                .frame(height: 70 )
                .contentShape(
                    RoundedRectangle(cornerRadius: 25, style: .continuous))
                .contextMenu {
                    Button {
                        entity.id = UUID()


                        do {
                            try viewContext.save()
                        } catch {
                            let nsError = error as NSError
                            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                        }
                    } label: {
                        Label("Recalculate ID", image: "")
                    }

                }
        }

    }



    private func deleteClass(entity: ClassEntity){
        print("attempting to delete week")
      //  deleteWeekContents(week: week)

        for timeSlot in timeSlots{
            if timeSlot.classEntity == entity{
                viewContext.delete(timeSlot)
            }
        }

        viewContext.delete(entity)
        do {
            try viewContext.save()
            print("deleted week entry")
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }

    }



}

struct ManageClasses_Previews: PreviewProvider {
    static var previews: some View {
        ManageClasses()
    }
}


