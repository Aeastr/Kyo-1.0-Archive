//
//  CustomColorCircle.swift
//  KyoNeo
//
//  Created by Aether on 12/03/2023.
//
// x
import SwiftUI
import AmethystUI

struct CustomColorCircle: View {
    var hue: CustomUserColor
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var current1: Color
    @Binding var current2: Color
    var colors: FetchedResults<CustomUserColor>
    @Environment(\.colorScheme) var colorScheme

    @State var showEditMenu = false
    
    var body: some View {

        ZStack{
            Button {
                    withAnimation(.smoothCard){
                        current1 = Color(hex: hue.color1 ?? "")
                        print(current1)
                        print(hue.color1)
                        current2 = Color(hex: hue.color2 ?? "")
                    }
            } label: {


                    VStack(spacing: 0){
                        LinearGradient(gradient: Gradient(colors: [Color(hex: hue.color1 ?? ""), Color(hex: hue.color2 ?? "")]), startPoint: /*@START_MENU_TOKEN@*/.leading/*@END_MENU_TOKEN@*/, endPoint: /*@START_MENU_TOKEN@*/.trailing/*@END_MENU_TOKEN@*/)

//                        LinearGradient(gradient: Gradient(colors: [Color.getAdjustedColor(color:  Color(hex: hue.color1 ?? ""), colorScheme: colorScheme, factor: 2).moreSaturated(factor: 4), Color.getAdjustedColor(color: Color(hex: hue.color2 ?? "") , colorScheme: colorScheme, factor: 2).moreSaturated(factor: 4)]), startPoint: .topLeading, endPoint: .bottomTrailing)

                    }
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(Color.primary.opacity(0.8), lineWidth: 1.5)
                            .opacity(hue.color1  == current1.hexString && hue.color2 == current2.hexString ? 1 : 0)
                    )
                    .scaleEffect( hue.color1  == current1.hexString && hue.color2 == current2.hexString ? 1.03 : 1)



            }

            .buttonStyle(colourCircleButton())
            .contentShape(RoundedRectangle(cornerRadius: 18))

           // #endif
            .contextMenu {
                Button(role: .destructive){
                    withAnimation(.smoothCard){
                        
                        viewContext.delete(hue)
                        
                        do {
                            try viewContext.save()
                        } catch {
                            let nsError = error as NSError
                            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                        }
                    }
                } label: {
                    Label("Delete", systemImage: "trash")
                }
                Button {
                    showEditMenu.toggle()
                } label: {
                    Label("Edit", systemImage: "pencil")
                }


            }
        }

            .sheet(isPresented: $showEditMenu, content: {
                if #available(iOS 16.4, *) {
                    EditCustomColour(entity: hue)
                        .presentationDetents([.fraction(0.4)])

                        .presentationCornerRadius(25)
                } else {

                        EditCustomColour(entity: hue)
                }
    })
            
    }
}


struct CustomColorCircleHard: View {
    var hue: colorItem
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "timestamp", ascending: true)]) var colors: FetchedResults<CustomUserColor>
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var current1: Color
    @Binding var current2: Color
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss

    @State var showEditMenu = false
    @Binding var colourName: String

    @AppStorage("selectedHueSet") var selectedHueSet: HueSet = .defaultHues
    @State var selectedHueSet2: HueSet = .defaultHues

    @State var showMaker: Bool = false

    var body: some View {

        ZStack{
            Button {
                    withAnimation(.smoothCard){
                        current1 = hue.color1
                        print(current1)
                        print(hue.color1)
                        current2 = hue.color2
                        colourName = hue.name
                    }
            } label: {


                    VStack(spacing: 0){
                       LinearGradient(gradient: Gradient(colors: [hue.color1, hue.color2]), startPoint: /*@START_MENU_TOKEN@*/.leading/*@END_MENU_TOKEN@*/, endPoint: /*@START_MENU_TOKEN@*/.trailing/*@END_MENU_TOKEN@*/)

                        .aspectRatio(1, contentMode: .fit)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                            .overlay(content: {

                                Text(hue.name != "Accent" ? "#" + hue.name : "\(hue.color1.hexString)")
                                    .font(.system(size: 8.3).weight((hue.color1.hexString  == current1.hexString && hue.color2.hexString == current2.hexString) ? .bold : .regular))

                                    .lineLimit(3)
                                    .minimumScaleFactor(0.9)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                                    .padding(10)


                                    .foregroundColor(hue.color1.getBrightness() > 0.70 ? hue.color1.darken(by: 0.5) : Color.white)
                            })
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(Color.primary.opacity(0.8), lineWidth: 1.5)
                                .opacity(hue.color1.hexString  == current1.hexString && hue.color2.hexString == current2.hexString ? 1 : 0)
                        )

//                        LinearGradient(gradient: Gradient(colors: [Color.getAdjustedColor(color:  hue.color1, colorScheme: colorScheme, factor: 2).moreSaturated(factor: 4), Color.getAdjustedColor(color: hue.color2 , colorScheme: colorScheme, factor: 2).moreSaturated(factor: 4)]), startPoint: .topLeading, endPoint: .bottomTrailing)

                    }
                    .scaleEffect( hue.color1  == current1 && hue.color2 == current2 ? 1.03 : 1)




            }

            .buttonStyle(colourCircleButton())
#if !os(macOS)
            .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 18))
            #endif
            .contextMenu{
                Button {
                    current1 = hue.color1
                    print(current1)
                    print(hue.color1)
                    current2 = hue.color2
                    colourName = hue.name
//                    selectedHueSet = .customColours

                    showMaker.toggle()
                } label: {
                    Label("Create Combination", systemImage: "paintbrush.pointed")
                }

            }
            .sheet(isPresented: $showMaker) {
                ScrollView{
                    Menu {
                        Picker("", selection: $selectedHueSet2) {
                            ForEach(HueSet.allCases, id: \.self){ set in
                                Label(set.rawValue.capitalized, systemImage: "")
                                    .id(set)
                                    .foregroundStyle(.blue)
                            }
                        }
                    } label: {
                        HStack(spacing: 4){
                            Text(selectedHueSet2.rawValue.capitalized)
                                .contentTransition(.interpolate)
                                .fixedSize(horizontal: true, vertical: false)

                            Image(systemName: "chevron.down")
                                .font(.caption)
                                .offset(y: 1)
                        }
                        .padding(10)

                        .padding(.horizontal, 5)
                        .regularOutline()
                    }
                    .buttonStyle(BouncyButton())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .animation(.smooth, value: selectedHueSet2)
                    .padding(.bottom, 6)

#if !os(macOS)
let columns = [
        GridItem(.adaptive(minimum: 60))

]
#elseif os(macOS)

let columns = [
        GridItem(.adaptive(minimum: 60)),
        GridItem(.adaptive(minimum: 60)),
        GridItem(.adaptive(minimum: 60)),
        GridItem(.adaptive(minimum: 60)),
        GridItem(.adaptive(minimum: 60)),
        GridItem(.adaptive(minimum: 60)),
        GridItem(.adaptive(minimum: 60))

]
#endif

                    LazyVGrid(columns: columns, spacing: 10) {
                        if let hues = selectedHueSet2.hues{
                            ForEach(hues, id: \.id) { hue22 in

                                VStack(spacing: 0){
                                    //                                    LinearGradient(gradient: Gradient(colors: [Color(hex: hue.color1 ?? ""), Color(hex: hue.color2 ?? "")]), startPoint: /*@START_MENU_TOKEN@*/.leading/*@END_MENU_TOKEN@*/, endPoint: /*@START_MENU_TOKEN@*/.trailing/*@END_MENU_TOKEN@*/)
                                    Button {
                                        let newItem = CustomUserColor(context: viewContext)
                                        newItem.color1 = hue.color1.hexString
                                        newItem.color2 = hue22.color2.hexString
                                        newItem.timestamp = Date()
                                        do {
                                            try viewContext.save()
                                        } catch {
                                            let nsError = error as NSError
                                            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                                        }



                                        if let c1 = newItem.color1{
                                            current1 = Color(hex: c1)
                                        }

                                        if let c2 = newItem.color2{
                                            current2 = Color(hex: c2)
                                        }


                                        selectedHueSet = .customColours

                                    } label: {



                                    LinearGradient(gradient: Gradient(colors: [hue22.color1, hue22.color2]), startPoint: /*@START_MENU_TOKEN@*/.leading/*@END_MENU_TOKEN@*/, endPoint: /*@START_MENU_TOKEN@*/.trailing/*@END_MENU_TOKEN@*/)
                                }
                                }
                                .clipShape(RoundedRectangle(cornerRadius: 18))
                                    .modify {
                                        if #available(iOS 17.0, *) {
                                            $0.scrollTransition { content, phase in
                                                content
                                                    .opacity(phase.isIdentity ? 1 : 0.5)
                                            }
                                        }
                                        else{
                                            $0
                                        }
                                    }
                                    .aspectRatio(1, contentMode: .fit)
                                    .transition(.move(edge: .trailing).animation(.smooth))
                            }
                        }
                        else if selectedHueSet2 == .customColours{



                            ForEach(colors, id: \.self) { hue22 in
                                Button {
                                    let newItem = CustomUserColor(context: viewContext)
                                    newItem.color1 = hue.color1.hexString
                                    newItem.color2 = hue22.color2
                                    newItem.timestamp = Date()
                                    do {
                                        try viewContext.save()
                                    } catch {
                                        let nsError = error as NSError
                                        fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                                    }

                                    if let c1 = newItem.color1{
                                        current1 = Color(hex: c1)
                                    }

                                    if let c2 = hue22.color2{
                                        current2 = Color(hex: c2)
                                    }


                                    selectedHueSet = .customColours

                                } label: {



                                LinearGradient(gradient: Gradient(colors: [Color(hex: hue22.color1 ?? ""), Color(hex: hue22.color2 ?? "")]), startPoint: /*@START_MENU_TOKEN@*/.leading/*@END_MENU_TOKEN@*/, endPoint: /*@START_MENU_TOKEN@*/.trailing/*@END_MENU_TOKEN@*/)
                                    .clipShape(RoundedRectangle(cornerRadius: 18))
                                //  .shadow(color: hue.color1.opacity(0.5), radius: 6, y: 5)
                            }
                                .modify {
                                    if #available(iOS 17.0, *) {
                                        $0.scrollTransition { content, phase in
                                            content
                                                .opacity(phase.isIdentity ? 1 : 0.5)
                                        }
                                    }
                                    else{
                                        $0
                                    }
                                }

                                    .aspectRatio(1, contentMode: .fit)
                            }

                        }
                        else if selectedHueSet2 == .appAccents{
                            ForEach(accentColorOptions, id: \.self){ option in
                                ForEach(1..<6) { i in
                                    Button {
                                        let newItem = CustomUserColor(context: viewContext)
                                        newItem.color1 = hue.color1.hexString
                                        newItem.color2 = Color("\(option.name)/\(i)").hexString
                                        newItem.timestamp = Date()

                                        do {
                                            try viewContext.save()
                                        } catch {
                                            let nsError = error as NSError
                                            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                                        }

                                        if let c1 = newItem.color1{
                                            current1 = Color(hex: c1)
                                        }

                                            current2 = Color("\(option.name)/\(i)")


                                        selectedHueSet = .customColours
                                    } label: {



                                        LinearGradient(gradient: Gradient(colors: [Color("\(option.name)/\(i)"), Color("\(option.name)/\(i)")]), startPoint: .leading, endPoint: .trailing)
                                    }
                                .clipShape(RoundedRectangle(cornerRadius: 18))
        //
        //                            CustomColorCircle(hue: hue, current1: $current1, current2: $current2, colors: colors)
        //                            //  .shadow(color: hue.color1.opacity(0.5), radius: 6, y: 5)

                                        .modify {
                                            if #available(iOS 17.0, *) {
                                                $0.scrollTransition { content, phase in
                                                    content
                                                        .opacity(phase.isIdentity ? 1 : 0.5)
                                                }
                                            }
                                            else{
                                                $0
                                            }
                                        }

                                        .aspectRatio(1, contentMode: .fit)
                                }
                            }
                        }
                    }
                    .padding(.bottom)
                    .padding(.horizontal, 30)
                }
                .onAppear{
                    selectedHueSet2 = selectedHueSet
                }
                .safeAreaInset(edge: .top, content: {
                    Color.clear
                        .frame(height: 105)
                })
                .overlay(alignment: .top){
                    FluidNavigationBar( title:"Pick a colour", titleColor: .primary, tintColor: hue.color1, compactMode: true, scrolled: .constant(false)) {

                    }toolbar: {

                        Button(action: {
                            dismiss()
                        }, label: {
                            Text("Cancel")
                                .foregroundColor(hue.color1)

                                    .scaledFrame(width: nil, height: 42, relativeTo: .body, alignment: .leading)
                                    .padding(.top, 15)
                        })
                    }

                    }
                .presentationDetents([.large])
                .presentationCornerRadius(25)
                .interactiveDismissDisabled()
            }
          //  #if os(iOS) || os(visionOS)
            //.contentShape(.contextMenuPreview, Circle())
           // #endif
        }

    }
}
