//
//  ClassPeelItem.swift
//  KyoNeo
//
//  Created by Aether on 15/07/2023.
//

import SwiftUI

struct ClassPeelItem: View {
    // MARK: - Class Entity Properties
    var entity: ClassEntity

    // MARK: - Initializers
    init(entity: ClassEntity, progressOffset: CGFloat = 0.0, icon: String = "chevron.forward",  edit: Binding<Bool>) {
        self.entity = entity
        self.progressOffset = progressOffset
        self.icon = icon
        self._edit = edit
    }

    // MARK: - Swipe-to-Delete State Properties
    @State private var dragProgress: CGFloat = 0
        @State private var dragProgressOffset: CGFloat = 0
        @State private var dragProgressMultiplier: CGFloat = 1
        @State private var confirmDelete: Bool = false
        @State private var startedDrag: Bool = false
    @State private var halfway: Bool = true

    // MARK: - Other Properties
    var progressOffset: CGFloat = 0.0
    var icon: String = "chevron.forward"

    // MARK: - Darken Text App Storage Property
    @AppStorage("darkenText") var darkenText = false

    // MARK: - Fetch Request Properties for Weeks, Days, and TimeSlots
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "number", ascending: true)],
                  predicate: NSPredicate(format: "singleDayWeek == nil OR singleDayWeek == %@", NSNumber(value: false))
    ) var weeks: FetchedResults<Week>


    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "number", ascending: true),
                                    // Add more sort descriptors if needed
                                   ],
                  predicate: NSPredicate(format: "singleDayWeek == %@", NSNumber(value: true))
    ) var singleDayweeks: FetchedResults<Week>
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "number", ascending: true)]) var days: FetchedResults<Day>
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "timestamp", ascending: true)]) var timeslots: FetchedResults<TimeSlot>

    // MARK: - Color Scheme Environment Property
    @Environment(\.colorScheme) var colorScheme

    // MARK: - Managed Object Context Environment Property
    @Environment(\.managedObjectContext) private var viewContext

    @Binding var edit: Bool

    var body: some View{
        classSticker

//            .mask{
//                classStickerMask
//            }
//
//        .shadow(color: Color(hex: entity.color1 ?? "98C6D1").opacity(0.3), radius: 3, x:0, y: 1)
//
//            .overlay{
//                stickerEffect
//
//            }
//            .overlay{
//                deleteButtonArea
//
//            }
//            .background{
//                deletionIndicator
//
//            }
        

        #if os(iOS) || os(visionOS)
            .actionSheet(isPresented: $confirmDelete) {
                            ActionSheet(
                                title: Text("Are you sure you want to delete \(entity.name ?? "Untitled"). This will delete all entries of this class"),
                                buttons: [
                                    .destructive(Text("Delete \(entity.name ?? "Untitled")")) {
                                        withAnimation(.closeCard){
                                            withAnimation(.closeCard){
                                                    dragProgress = .zero
                                                    dragProgressOffset = 0.0
                                                    dragProgressMultiplier = 1.0
                                                    startedDrag = false
                                                    confirmDelete = false
                                            }

                                            deleteClass()
                                        }

                                    },

                                    .cancel(){
                                        withAnimation(.closeCard){
                                                dragProgress = .zero
                                                dragProgressOffset = 0.0
                                                dragProgressMultiplier = 1.0
                                                startedDrag = false
                                                confirmDelete = false
                                        }
                                    }
                                ]
                            )
                        }
        #elseif os(macOS)
            .popover(isPresented: $confirmDelete, arrowEdge: .bottom) {
                    VStack {
                        Text("Are you sure you want to delete \(entity.name ?? "Untitled"). This will delete all entries of this class")
                            .padding()

                        HStack {
                            Button("Delete \(entity.name ?? "Untitled")") {
                                withAnimation(.closeCard) {
                                    // Reset your dragProgress variables here
                                    deleteClass()
                                    confirmDelete = false
                                }
                            }
                            .foregroundColor(.red) // For a destructive appearance

                            Spacer()

                            Button("Cancel") {
                                withAnimation(.closeCard) {
                                    // Reset your dragProgress variables here
                                    confirmDelete = false
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .frame(width: 300) // Adjust the popover width as needed
                }
        #endif
            .onChange(of: edit) { mode in
                if mode == false{
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.7)){
                        dragProgressOffset = 0.0
                    }
                }
            }
    }

    var classSticker: some View{
        ZStack {
            let brightness1 =  Color(hex: entity.color1 ?? "98C6D1" ).getBrightness()
            let c1 = Color(hex: entity.color1 ?? "98C6D1" )
//            (darkenText ? Color(hex: entity.color1 ?? "98C6D1" ).getBrightness() : 0.0)
            let brightness2 = Color(hex: entity.color2 ?? "98C6D1" ).getBrightness()
//            (darkenText ? Color(hex: entity.color2 ?? "98C6D1" ).getBrightness() : 0.0)

            LinearGradient(
                gradient: Gradient(
//                    colors: !darkenText && (Color(hex: entity.color1 ?? "98C6D1" ).getBrightness() > 0.82 || Color(hex: entity.color2 ?? "98C6D1" ).getBrightness() > 0.82) ? [
//                        Color.getAdjustedColor(color: Color(hex: entity.color1 ?? "98C6D1" ), colorScheme: colorScheme, factor: 2).moreSaturated(factor: 4),
//                        Color.getAdjustedColor(color: Color(hex: entity.color2 ?? "98C6D1" ), colorScheme: colorScheme, factor: 2).moreSaturated(factor: 4)
//                    ] :
                    colors: [
                         Color(hex: entity.color1 ?? "98C6D1" ),
                        Color(hex: entity.color2 ?? "98C6D1" )
                    ]
                ),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

                #if os(iOS) || os(visionOS)
                .mask(
                    RoundedRectangle(cornerRadius: 25, style: .continuous)
                )
#elseif os(macOS)
                .mask(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                )
#endif

                VStack(alignment: .leading, spacing: 4) {
                    HStack{
                        Image(systemName: entity.icon ?? "square")
                        .symbolRenderingMode(/*@START_MENU_TOKEN@*/.hierarchical/*@END_MENU_TOKEN@*/)
                            .padding(10)
                        #if os(iOS) || os(visionOS)
                            .font(.system(size: 23))
                            .frame(width: 50, height: 50)
                        #elseif os(macOS)
                            .font(.system(size: 17))
                            .frame(width: 35, height: 35)
                        #endif
                            .shadow(color: Color(hex: entity.color1 ?? "98C6D1").opacity(0.2), radius: 3, y: 3)
                            .background(.white)

                    #if os(iOS) || os(visionOS)
                            .clipShape(RoundedRectangle(cornerRadius: 14,style: .continuous))
                        #elseif os(macOS)
                            .clipShape(RoundedRectangle(cornerRadius: 12,style: .continuous))
                        #endif
                            .foregroundColor(brightness1 > 0.82 ? c1.darken(by: 0.5) : c1)
                            .padding(.trailing, 10)
                        VStack(alignment: .leading){

                                    Text(entity.name ?? "Untitled")
                                    //   .strikethrough(past ? true : false)
                                        .font(Font.body.weight(.semibold))
                                        .lineLimit(2)
                                        .minimumScaleFactor(0.5)
                                        .foregroundColor(brightness1 > 0.82 ? c1.darken(by: 0.5) : Color.white)
                                        .lineSpacing(1)
                                        .multilineTextAlignment(.leading)

                            HStack(spacing: 5){
                                if let array = (Array(entity.tags ?? []) as? [TagItem])?.sorted(by: { $0.name! < $1.name! }) {
                                    HStack{
                                        ForEach(array, id: \.self) { tag in
                                            Text(tag.name ?? "")
                                                .font(.caption)
                                                .padding(6)
                                                .background(c1)
                                                .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
                                                .padding(.vertical, -6)
                                                .foregroundColor(brightness1 > 0.82 ? c1.darken(by: 0.5) : Color.white)
                                        }
                                    }
                            }
                            }

                        }
                        Spacer()

                        Image(systemName: icon)


                            .font(.body.weight(.regular))
                            .foregroundColor(brightness2 > 0.82 ? Color.black : Color.white)
                        .padding(.leading, 6)




                    }

                }
              //  .fr

            .padding(.trailing, 25)
        #if os(iOS) || os(visionOS)
                .padding(.leading, 14)
                .padding(.vertical, 13)
            #elseif os(macOS)
                .padding(.leading, 9)
                .padding(.vertical, 7)
            #endif


        }

    }

    var classStickerUnderside: some View{
            ZStack {
                let brightness1 =  Color(hex: entity.color1 ?? "98C6D1" ).getBrightness()
                let c1 = Color(hex: entity.color1 ?? "98C6D1" )
    //            (darkenText ? Color(hex: entity.color1 ?? "98C6D1" ).getBrightness() : 0.0)
                let brightness2 = Color(hex: entity.color2 ?? "98C6D1" ).getBrightness()
    //            (darkenText ? Color(hex: entity.color2 ?? "98C6D1" ).getBrightness() : 0.0)

                LinearGradient(
                    gradient: Gradient(
    //                    colors: !darkenText && (Color(hex: entity.color1 ?? "98C6D1" ).getBrightness() > 0.82 || Color(hex: entity.color2 ?? "98C6D1" ).getBrightness() > 0.82) ? [
    //                        Color.getAdjustedColor(color: Color(hex: entity.color1 ?? "98C6D1" ), colorScheme: colorScheme, factor: 2).moreSaturated(factor: 4),
    //                        Color.getAdjustedColor(color: Color(hex: entity.color2 ?? "98C6D1" ), colorScheme: colorScheme, factor: 2).moreSaturated(factor: 4)
    //                    ] :
                        colors: [
                             Color(hex: entity.color1 ?? "98C6D1" ),
                            Color(hex: entity.color2 ?? "98C6D1" )
                        ]
                    ),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                    #if os(iOS) || os(visionOS)
                    .mask(
                        RoundedRectangle(cornerRadius: 25, style: .continuous)
                    )
    #elseif os(macOS)
                    .mask(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                    )
    #endif

                    VStack(alignment: .leading, spacing: 4) {
                        HStack{
                            Image(systemName: entity.icon ?? "square")
                            .symbolRenderingMode(/*@START_MENU_TOKEN@*/.hierarchical/*@END_MENU_TOKEN@*/)
                                .padding(10)
                            #if os(iOS) || os(visionOS)
                                .font(.system(size: 23))
                                .frame(width: 50, height: 50)
                            #elseif os(macOS)
                                .font(.system(size: 17))
                                .frame(width: 35, height: 35)
                            #endif
                                .shadow(color: Color(hex: entity.color1 ?? "98C6D1").opacity(0.2), radius: 3, y: 3)
                                .background(.white)

                        #if os(iOS) || os(visionOS)
                                .clipShape(RoundedRectangle(cornerRadius: 14,style: .continuous))
                            #elseif os(macOS)
                                .clipShape(RoundedRectangle(cornerRadius: 12,style: .continuous))
                            #endif
                                .foregroundColor(brightness1 > 0.82 ? c1.darken(by: 0.5) : c1)
                                .padding(.trailing, 10)
                            VStack(alignment: .leading){

                                        Text(entity.name ?? "Untitled")
                                        //   .strikethrough(past ? true : false)
                                            .font(Font.body.weight(.semibold))
                                            .lineLimit(2)
                                            .minimumScaleFactor(0.5)
                                            .foregroundColor(brightness1 > 0.82 ? c1.darken(by: 0.5) : Color.white)
                                            .lineSpacing(1)
                                            .multilineTextAlignment(.leading)

                                HStack(spacing: 5){
                                    if let array = (Array(entity.tags ?? []) as? [TagItem])?.sorted(by: { $0.name! < $1.name! }) {
                                        HStack{
                                            ForEach(array, id: \.self) { tag in
                                                Text(tag.name ?? "")
                                                    .font(.caption)
                                                    .padding(6)
                                                    .background(c1)
                                                    .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
                                                    .padding(.vertical, -6)
                                                    .foregroundColor(brightness1 > 0.82 ? c1.darken(by: 0.5) : Color.white)
                                            }
                                        }
                                }
                                }

                            }
                            Spacer()

                            Image(systemName: icon)


                                .font(.body.weight(.regular))
                                .foregroundColor(brightness2 > 0.82 ? Color.black : Color.white)
                            .padding(.leading, 6)




                        }

                    }
                
                  //  .fr

                .padding(.trailing, 25)
            #if os(iOS) || os(visionOS)
                    .padding(.leading, 14)
                    .padding(.vertical, 13)
                #elseif os(macOS)
                    .padding(.leading, 9)
                    .padding(.vertical, 7)
                #endif


            }

        }

    var deletionIndicator: some View{
        GeometryReader {
            let size = $0.size
            RoundedRectangle(cornerRadius: 25)
                .fill(.red.opacity(0.8))
                .overlay(alignment: .trailing){
                    HStack{
                        Image(systemName: "minus.circle.fill")
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                        .padding(.trailing, 20)
                        .foregroundColor(.white)
                        .padding(.trailing, max(0, size.width * ((dragProgress + max(progressOffset,dragProgressOffset)) * dragProgressMultiplier) - 100))
                }
                .padding(3)
                .padding(.horizontal, startedDrag ? 0 : 5)
                .offset(x: dragProgress * 2.5)
                .padding(.leading, 20)
        }
    }

    var deleteButtonArea: some View{
        GeometryReader {
            let size = $0.size
            Color.clear

                .contentShape(Rectangle())
                .frame(width: size.width * (((dragProgress + max(progressOffset,dragProgressOffset)) * dragProgressMultiplier)))
                .frame(width: size.width,alignment: .trailing)
                .onTapGesture {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.7)){
                        dragProgress = .zero
                        dragProgressOffset = 1.0
                        dragProgressMultiplier = 1.0
                        startedDrag = false
                        confirmDelete = true
                    }
                }
                .animation(.spring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.7))
        }
    }

    var stickerEffect: some View{
        GeometryReader {
            let globalFrame = $0.frame(in: .global)
            let size = $0.size

            let overallProgress = ((dragProgress + max(progressOffset,dragProgressOffset)) * dragProgressMultiplier)
            let scale = max(1,(min(1.09,1 + (Double(overallProgress)) / 2.5) - 0.015))

            classStickerUnderside

                .scaleEffect(x: -1)
                .overlay(
                    LinearGradient(gradient: Gradient(colors: [Color.white.opacity(0.20), Color.white.opacity(0.03)]), startPoint: .init(x: 0, y: 0), endPoint: .init(x: 0.6, y: 0))


                        .frame(width: size.width * (((dragProgress + max(progressOffset,dragProgressOffset)) * dragProgressMultiplier)))
                        .frame(width: size.width, alignment: .leading)
                        .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
                )

            .overlay(
                LinearGradient(gradient: Gradient(colors: [Color.red.opacity(0.003), Color.red.opacity(0.4)]), startPoint: .init(x: 0.6, y: 0), endPoint: .init(x: 1, y: 0))


                .blur(radius: 4)
                .scaleEffect(1.3)
                .scaleEffect(x:  1.1 + overallProgress)
                .offset(x: 15)

                .scaleEffect(overallProgress < 0.035 ? 1 : 1.05)
                    .frame(width: size.width * (((dragProgress + max(progressOffset,dragProgressOffset)) * dragProgressMultiplier)))
                    .frame(width: size.width, alignment: .leading)

                    .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
            )


            .scaleEffect(scale)
                .offset(x: size.width - (size.width * ((dragProgress + max(progressOffset,dragProgressOffset)) * dragProgressMultiplier)))
                .offset(x: size.width * -((dragProgress + max(progressOffset,dragProgressOffset)) * dragProgressMultiplier))

                .mask{
                    RoundedRectangle(cornerRadius: 3)

                        .scaleEffect(scale)
                        .offset(x: size.width * -((dragProgress + max(progressOffset,dragProgressOffset)) * dragProgressMultiplier))
                }

                .shadow(color: Color(hex: entity.color1 ?? "98C6D1").darken(by: 0.3).opacity(0.6),radius: 10)
                .contentShape(Rectangle())
            #if os(iOS) || os(visionOS)
                .simultaneousGesture(
                    DragGesture(minimumDistance: 20.0)
                        .onChanged({ value in
                            var translationX = value.translation.width
                            translationX = max(-translationX, 0)

                                let progress = translationX / size.width
                            startedDrag = true
                            withAnimation(Animation.spring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.7)){
                                dragProgress = progress
                                if (-(value.translation.width) / size.width) + dragProgressOffset < (0.2){
                                    dragProgressOffset = 0.0
                                    halfway = false
                                }
                                if (-(value.translation.width) / size.width) + dragProgressOffset < (0.4){
                                    dragProgressMultiplier = 0.8
                                    halfway = false
                                }
                                else{
                                    dragProgressMultiplier = 1.1
                                    halfway = true
                                }
                            }
                        })
                        .onEnded({ value in
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.7)){
                                if dragProgress < 0.2 {
                                    dragProgress = .zero
                                    dragProgressMultiplier = 1.0
                                    startedDrag = false
                                }
                                else if !(dragProgress < 0.4){
                                    dragProgress = .zero
                                    dragProgressOffset = 1.0
                                    dragProgressMultiplier = 1.01
                                    startedDrag = false
                                    confirmDelete = true
                                }
                                else{
                                    
                                    dragProgress = .zero
                                    dragProgressOffset = 0.2
                                    dragProgressMultiplier = 1.0
                                    startedDrag = false
                                }
                            }
                        })
                    
                )
            #endif

//                .modify {
//                    if #available(iOS 17.0, *) {
//                        $0.sensoryFeedback(.impact(flexibility: .solid, intensity: .infinity), trigger: confirmDelete) { oldValue, newValue in
//                            newValue == true
//                        }
//
//                    }
//                    else{
//                        $0
//                    }
//                }
//
//
//            .modify {
//                if #available(iOS 17.0, *) {
//                    $0.sensoryFeedback(.impact(flexibility: .soft, intensity: .infinity), trigger: confirmDelete) { oldValue, newValue in
//                        newValue == false
//                    }
//
//                }
//                else{
//                    $0
//                }
//            }
//                .modify {
//                    if #available(iOS 17.0, *) {
//                        $0.sensoryFeedback(.increase, trigger: startedDrag)
//
//                    }
//                    else{
//                        $0
//                    }
//                }
//                .modify {
//                    if #available(iOS 17.0, *) {
//                        $0.sensoryFeedback(.impact(flexibility: .soft, intensity: .infinity), trigger: halfway)
//
//                    }
//                    else{
//                        $0
//                    }
//                }



        }
    }

    var classStickerMask: some View{
        GeometryReader {
            let globalFrame = $0.frame(in: .global)

            RoundedRectangle(cornerRadius: 3)
                .padding(.trailing, max(0, (((dragProgress + max(progressOffset,dragProgressOffset)) * dragProgressMultiplier) * globalFrame.width ) ))
        }
    }

    func deleteClass(){
        let linkedTimeSlots = timeslots.filter{  timeslot in
            timeslot.classEntity == entity
        }
        for linkedTimeSlot in linkedTimeSlots {
            viewContext.delete(linkedTimeSlot)
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


struct ClassItem: View {

    var entity: ClassEntity

    var body: some View{
        ZStack {
            let brightness1 =  Color(hex: entity.color1 ?? "98C6D1" ).getBrightness()
            let c1 = Color(hex: entity.color1 ?? "98C6D1" )
//            (darkenText ? Color(hex: entity.color1 ?? "98C6D1" ).getBrightness() : 0.0)
            let brightness2 = Color(hex: entity.color2 ?? "98C6D1" ).getBrightness()
//            (darkenText ? Color(hex: entity.color2 ?? "98C6D1" ).getBrightness() : 0.0)

            LinearGradient(
                gradient: Gradient(
//                    colors: !darkenText && (Color(hex: entity.color1 ?? "98C6D1" ).getBrightness() > 0.82 || Color(hex: entity.color2 ?? "98C6D1" ).getBrightness() > 0.82) ? [
//                        Color.getAdjustedColor(color: Color(hex: entity.color1 ?? "98C6D1" ), colorScheme: colorScheme, factor: 2).moreSaturated(factor: 4),
//                        Color.getAdjustedColor(color: Color(hex: entity.color2 ?? "98C6D1" ), colorScheme: colorScheme, factor: 2).moreSaturated(factor: 4)
//                    ] :
                    colors: [
                         Color(hex: entity.color1 ?? "98C6D1" ),
                        Color(hex: entity.color2 ?? "98C6D1" )
                    ]
                ),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

                #if os(iOS) || os(visionOS)
                .mask(
                    RoundedRectangle(cornerRadius: 25, style: .continuous)
                )
#elseif os(macOS)
                .mask(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                )
#endif

                VStack(alignment: .leading, spacing: 4) {
                    HStack{
                        Image(systemName: entity.icon ?? "square")
                        .symbolRenderingMode(/*@START_MENU_TOKEN@*/.hierarchical/*@END_MENU_TOKEN@*/)
                            .padding(10)
                        #if os(iOS) || os(visionOS)
                            .font(.system(size: 23))
                            .frame(width: 50, height: 50)
                        #elseif os(macOS)
                            .font(.system(size: 17))
                            .frame(width: 35, height: 35)
                        #endif
                            .shadow(color: Color(hex: entity.color1 ?? "98C6D1").opacity(0.2), radius: 3, y: 3)
                            .background(.white)

                    #if os(iOS) || os(visionOS)
                            .clipShape(RoundedRectangle(cornerRadius: 14,style: .continuous))
                        #elseif os(macOS)
                            .clipShape(RoundedRectangle(cornerRadius: 12,style: .continuous))
                        #endif
                            .foregroundColor(brightness1 > 0.82 ? c1.darken(by: 0.5) : c1)
                            .padding(.trailing, 10)
                        VStack(alignment: .leading){

                                    Text(entity.name ?? "Untitled")
                                    //   .strikethrough(past ? true : false)
                                        .font(Font.body.weight(.semibold))
                                        .lineLimit(2)
                                        .minimumScaleFactor(0.5)
                                        .foregroundColor(brightness1 > 0.82 ? c1.darken(by: 0.5) : Color.white)
                                        .lineSpacing(1)
                                        .multilineTextAlignment(.leading)

                            HStack(spacing: 5){
                                if let array = (Array(entity.tags ?? []) as? [TagItem])?.sorted(by: { $0.name! < $1.name! }) {
                                    HStack{
                                        ForEach(array, id: \.self) { tag in
                                            Text(tag.name ?? "")
                                                .font(.caption)
                                                .padding(6)
                                                .background(c1)
                                                .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
                                                .padding(.vertical, -6)
                                                .foregroundColor(brightness1 > 0.82 ? c1.darken(by: 0.5) : Color.white)
                                        }
                                    }
                            }
                            }

                        }
                        Spacer()

                    }

                }
              //  .fr

            .padding(.trailing, 25)
        #if os(iOS) || os(visionOS)
                .padding(.leading, 14)
                .padding(.vertical, 13)
            #elseif os(macOS)
                .padding(.leading, 9)
                .padding(.vertical, 7)
            #endif


        }

    }
}
