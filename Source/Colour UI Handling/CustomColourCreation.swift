//
//  CustomColour.swift
//  KyoNeo
//
//  Created by Aether on 12/03/2023.
//

import SwiftUI
import CoreData

struct CustomColour: View {
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "timestamp", ascending: true)]) var colors: FetchedResults<CustomUserColor>
    @Environment(\.managedObjectContext) private var viewContext

    @Environment(\.dismiss) var dismiss

    @Binding var color1: Color
    @Binding var color2: Color

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack {

            Color("Background3")
                .ignoresSafeArea()

            LinearGradient(gradient: Gradient(colors: [color1, color2]), startPoint: .topLeading, endPoint: .bottomTrailing).opacity(0.1)
                .ignoresSafeArea()

                VStack{
                    HStack(spacing: 20){
                        LinearGradient(gradient: Gradient(colors: [color1, color2]), startPoint: .topLeading, endPoint: .bottomTrailing)
                            .frame(minHeight: 100)
                            .frame(maxHeight: 250)
                            .mask(
                                RoundedRectangle(cornerRadius: 25, style: .continuous)
                            )
                            .background{

                                LinearGradient(gradient: Gradient(colors: [color1, color2]), startPoint: .topLeading, endPoint: .bottomTrailing)
                                    .frame(minHeight: 100)
                                    .frame(maxHeight: 250)
                                    .mask(
                                        RoundedRectangle(cornerRadius: 25, style: .continuous)
                                    )
                                    .blur(radius: 10)
                                    .offset(y: 10)
                                    .opacity(0.6)
                            }
                        if (color1.isLight() ?? false ) || (color2.isLight() ?? false)
                        {
                            LinearGradient(gradient: Gradient(colors: [Color.getAdjustedColor(color: color1, colorScheme: colorScheme, factor: 2).moreSaturated(factor: 4), Color.getAdjustedColor(color: color2, colorScheme: colorScheme, factor: 2).moreSaturated(factor: 4)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                                .frame(minHeight: 100)
                                .frame(maxHeight: 250)
                                .mask(
                                    RoundedRectangle(cornerRadius: 25, style: .continuous)
                                )
                                .background{

                                    LinearGradient(gradient: Gradient(colors: [Color.getAdjustedColor(color: color1, colorScheme: colorScheme), Color.getAdjustedColor(color: color2, colorScheme: colorScheme)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                                        .frame(minHeight: 100)
                                        .frame(maxHeight: 250)
                                        .mask(
                                            RoundedRectangle(cornerRadius: 25, style: .continuous)
                                        )
                                        .blur(radius: 10)
                                        .offset(y: 10)
                                        .opacity(0.6)
                                }
                        }
                        
                    }
                        .padding(25)


                    Spacer()
                    ColorPicker(selection: $color1) {
                        Text("Primary")
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 5)

                    Spacer()

                    ColorPicker(selection: $color2) {
                        Text("Secondary")
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 20)

                    Spacer()

                    HStack{
                        Button {
                            withAnimation(.smoothCard){
                                dismiss()
                            }
                        } label: {
                            Label {
                                Text("Cancel")
                            } icon: {

                            }
                            .padding(.vertical, 10)
                            .padding(.horizontal, 20)
                            .foregroundColor(Color.getAdjustedColor(color: color2, colorScheme: colorScheme))
                        }
                        Spacer()
                        Button {
                            withAnimation(.smoothCard){
                                createColour()
                            }
                        } label: {
                            Label {
                                Text("Create")
                            } icon: {
                                Image(systemName: "plus")
                            }

                        }
                        .buttonStyle(neoButton(color: Color.getAdjustedColor(color: color1, colorScheme: colorScheme)))
                    }
                    .padding(.horizontal, 30)
                }

        }
    }

    func createColour(){
        let newItem = CustomUserColor(context: viewContext)
        newItem.color1 = color1.hexString
        newItem.color2 = color2.hexString
        newItem.timestamp = Date()

        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        
        dismiss()
    }
    
}


struct EditCustomColour: View {
    var entity: CustomUserColor
    @Environment(\.managedObjectContext) private var viewContext

    @Environment(\.dismiss) var dismiss

    @State var color1: Color = .blue
    @State var color2: Color = .teal
    var body: some View {
        ZStack {

            Color("Background3")
                .ignoresSafeArea()

            ScrollView{
                LinearGradient(gradient: Gradient(colors: [color1, color2]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    .frame(height: 100)
                    .mask(
                        RoundedRectangle(cornerRadius: 25, style: .continuous)
                        )
                    .padding(25)


                ColorPicker(selection: $color1, supportsOpacity: false) {
                    Text("Primary").fontWeight(.semibold)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 5)
                ColorPicker(selection: $color2, supportsOpacity: false) {
                    Text("Secondary").fontWeight(.semibold)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 10)
                HStack{
                    Button {
                        withAnimation(.smoothCard){
                            dismiss()
                        }
                    } label: {
                        Label {
                            Text("Cancel")
                        } icon: {

                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 20)

                    }
                    Spacer()
                    Button {
                        withAnimation(.smoothCard){
                            createColour()
                        }
                    } label: {
                        Label {
                            Text("Save")
                        } icon: {
                            Image(systemName: "pencil")
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 20)

                    }
                    .buttonStyle(neoButton(color: color1))
                }
                .padding(.horizontal, 30)
            }
        }
        .onAppear{
            color1 = Color(hex: entity.color1 ?? "")
            color2 = Color(hex: entity.color2 ?? "")
        }
    }

    func createColour(){

        entity.color1 = color1.hexString
        entity.color2 = color2.hexString
        entity.timestamp = Date()

        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }

        dismiss()
    }

}

