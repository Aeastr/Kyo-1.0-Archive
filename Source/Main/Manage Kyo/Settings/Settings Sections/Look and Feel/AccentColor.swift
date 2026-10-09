//
//  AccentColor.swift
//  KyoNeo
//
//  Created by Aether on 11/07/2023.
//

import SwiftUI

var accentColorOptions: [accentOption] = [
//    accentOption(name: "Christmas"),
    accentOption(name: "Default"),
    accentOption(name: "Beta Days"),
    accentOption(name: "Purples"),
    accentOption(name: "Space Cadet"),
    accentOption(name: "Crimson Amethyst"),
    accentOption(name: "Blues"),
    accentOption(name: "Ecru Retreat"),
    accentOption(name: "Sky"),
    accentOption(name: "Marine"),
    accentOption(name: "Beach"),
    accentOption(name: "Minty"),
    accentOption(name: "Romance"),
    accentOption(name: "Indigo Orchid"),
    accentOption(name: "Serenity Blush"),
    accentOption(name: "Caribbean Coral"),
    accentOption(name: "Soft Brown"),
    accentOption(name: "Greys", darkColour: true)
]

//struct AccentColor: View {
//
//    @Namespace var namespace
//
//    @AppStorage("multicolored") var multicolored = true
//    @AppStorage("appAccentColor") var appAccentColor = "Default"
//    @AppStorage("appAccentColorIndex") var appAccentColorIndex = 1
//
//    var body: some View {
//        ScrollViewReader{ proxy in
//        ScrollView(.horizontal, showsIndicators: false){
//            LazyHGrid(rows: [GridItem(.flexible()) /*GridItem(.flexible()), GridItem(.flexible())*/], spacing: 10) {
//
//                ForEach(accentColorOptions, id: \.self){ option in
////                    Button {
////                        withAnimation(.smooth){
////                            appAccentColor = option.name
////                        }
////                    } label: {
//                    HStack{
//                        VStack{
////                            Text("\(option.name)")
////                                .sectionTitle(topPadding: 10, bottomPadding: 0)
//                        HStack(spacing: multicolored ? 0 : 10){
//                            ForEach(1..<6) { i in
//                                Color("\(option.name)/\(i)")
//                                    .clipShape(RoundedRectangle(cornerRadius: multicolored ? 0 : 10))
//                                    .onTapGesture {
//                                        if multicolored{
//                                            withAnimation(.smooth){
//                                                appAccentColor = option.name
//                                            }
//                                        }
//                                        else{
//                                            withAnimation(.smooth){
//                                                appAccentColor = option.name
//                                                appAccentColorIndex = Int(i)
//                                                print("set  \(option.name) to \(i), is now \(appAccentColorIndex)")
//                                            }
//                                        }
//                                    }
//                                    .overlay(
//                                        multicolored ? nil :
//                                            RoundedRectangle(cornerRadius: 10)
//                                            .stroke(Color.primary.opacity(0.8), lineWidth: 2)
//                                            .opacity(option.name == appAccentColor && Int(i) == Int(appAccentColorIndex) ? 1 : 0)
//                                            .transition(.asymmetric(insertion: .opacity, removal: .identity))
//                                    )
//
//                                    .padding(multicolored ? 0 : 1)
//                                // .matchedGeometryEffect(id: "\(option.name)/\(i)", in: namespace)
//
//
//                            }
//
//
//                        }
//                        .frame(width: multicolored ?  95 : 250, height: 75)
//
//                        .clipShape(RoundedRectangle(cornerRadius: multicolored ? 10 : 0))
//                        .overlay(
//                            multicolored ?
//                            RoundedRectangle(cornerRadius: 10)
//                                .stroke(Color.primary.opacity(0.8), lineWidth: 2)
//                                .opacity(option.name == appAccentColor ? 1 : 0)
//                                .transition(.asymmetric(insertion: .opacity, removal: .identity))
//                            : nil
//                        )
//                        .padding(multicolored ? 1 : 0)
//                    }
//                            .animation(.smooth, value: multicolored)
//                            //                            .frame(width: option.name == appAccentColor ? 120 : 90, height: option.name == appAccentColor ? 110 : 80)
//                            //                            .background{
//                            //                                HStack(spacing: 0){
//                            //                                    Color("\(option.name)/1")
//                            //                                    Color("\(option.name)/2")
//                            //                                    Color("\(option.name)/3")
//                            //                                    Color("\(option.name)/4")
//                            //                                }
//                            //                            }
//                            //                            .blur(radius: option.name == appAccentColor ? 15 : 0)
//
//                            //                            .overlay(
//                            //                                Image(systemName: "checkmark")
//                            //                                    .foregroundColor(option.darkColour ? .white : .primary)
//                            //                                    .opacity(option.name == appAccentColor ? 1 : 0)
//                            //                            )
//
//                            
//                            
//                        }
//                        
//
//
//                    .id(option.name)
//                }
//                .modify {
//                    if #available(iOS 17.0, *) {
//                        $0.sensoryFeedback(.increase, trigger: appAccentColor)
//                    }
//                    else{
//                        $0
//                    }
//                }
//
//
////                else{
////
////                    ForEach(Array(accentColorOptions.enumerated()), id: \.element) { index, option in
////
////                        ForEach(1..<(option.colorCount + 1)) { i in
////
////                        Button {
////                            withAnimation(.smooth){
////                                appAccentColor = option.name
////                                appAccentColorIndex = Int(i)
////                                print("set  \(option.name) to \(i), is now \(appAccentColorIndex)")
////                            }
////                        } label: {
////                            HStack{
////                                
////                                HStack(spacing: 0){
////                                    Color("\(option.name)/\(i)")
////
////                                    // .matchedGeometryEffect(id: "\(option.name)/\(i)", in: namespace)
////                                }
////                                .animation(.smooth, value: multicolored)
////                                //                            .frame(width: option.name == appAccentColor ? 120 : 90, height: option.name == appAccentColor ? 110 : 80)
////                                //                            .background{
////                                //                                HStack(spacing: 0){
////                                //                                    Color("\(option.name)/1")
////                                //                                    Color("\(option.name)/2")
////                                //                                    Color("\(option.name)/3")
////                                //                                    Color("\(option.name)/4")
////                                //                                }
////                                //                            }
////                                //                            .blur(radius: option.name == appAccentColor ? 15 : 0)
////                                .frame(width: 60, height: 80)
////                                .clipShape(RoundedRectangle(cornerRadius: 10))
////                                .overlay(
////                                    RoundedRectangle(cornerRadius: 10)
////                                        .stroke(Color.primary.opacity(0.8), lineWidth: 2)
////                                        .opacity(option.name == appAccentColor && Int(i) == Int(appAccentColorIndex) ? 1 : 0)
////                                )
////                                //                            .overlay(
////                                //                                Image(systemName: "checkmark")
////                                //                                    .foregroundColor(option.darkColour ? .white : .primary)
////                                //                                    .opacity(option.name == appAccentColor ? 1 : 0)
////                                //                            )
////                                .padding(1)
////                                
////                                
////                            }
////                            
////                        }
////                        .buttonStyle(bounceButton())
////
////                        .id(option.name + "1")
////                    }
////                        .modify {
////                            if #available(iOS 17.0, *) {
////                                $0.sensoryFeedback(.increase, trigger: appAccentColorIndex)
////                            }
////                            else{
////                                $0
////                            }
////                        }
////                    }
////                }
//
//            }
//            .onChange(of: multicolored) { new in
////                withAnimation(.smooth){
//                    proxy.scrollTo(appAccentColor, anchor: .center)
////                }
//            }
//
//            .padding([.horizontal, .vertical],15)
//            .animation(.bouncy(duration: 0.2), value: appAccentColor)
//
//            .onAppear{
//
//                proxy.scrollTo(appAccentColor, anchor: .center)
//            }
//            .onChange(of: appAccentColor){ change in 
//                withAnimation(.bouncy){
//                    proxy.scrollTo(appAccentColor, anchor: .center)
//                }
//            }
//
//
//        }
//    }
//        .animation(.smooth, value: multicolored)
//        .background {
//            Color("NeoButton").opacity(0.6)
//
//
//        }
//        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
//        .regularOutline()
//    }
//}

struct accentOption: Hashable, Identifiable {
    var id: UUID = UUID()
    var name: String
    var darkColour: Bool = false
    var colorCount: Int = 4
}



struct AccentColor: View {
//
//    init() {
//        UIPageControl.appearance().currentPageIndicatorTintColor = .white
//        UIPageControl.appearance().pageIndicatorTintColor = UIColor.black.withAlphaComponent(0.2)
//        }


    @AppStorage("multicolored") var multicolored = true
    @AppStorage("appAccentColor") var appAccentColor = "Default"
    @State private var selectedTab = 0
    @AppStorage("appAccentColorIndex") var appAccentColorIndex = 1

    @Binding var TEMPmulticolored: Bool
    @Binding var TEMPappAccentColor: String
    @Binding var TEMPappAccentColorIndex: Int

    @Binding var kyoPlus_hasPlus: Bool
    var body: some View {
        VStack{

            TabView(selection: $TEMPappAccentColor) {

//                let currentDate = Date()
//                        let calendar = Calendar.current
//                        let month = calendar.component(.month, from: currentDate)
//                        let day = calendar.component(.day, from: currentDate)
//
//                        // Check if the date is 3 days around the 25th of December
//                        let isChristmasPeriod = month == 12 && (day >= 22 && day <= 28)

                ForEach(kyoPlus_hasPlus ? accentColorOptions : Array(accentColorOptions.prefix(1)), id: \.name) { option in


                    HStack(spacing: 0){
                        ForEach(1..<6) { i in
                            Color("\(option.name)/\(i)")
                                .clipShape(RoundedRectangle(cornerRadius: !TEMPmulticolored ? 20 : 0, style: .continuous))
                                .scaleEffect(x: !TEMPmulticolored ? (TEMPappAccentColorIndex == i && TEMPappAccentColor == option.name) ? 0.85 : 0.65: 1, y: !TEMPmulticolored ? (TEMPappAccentColorIndex == i && TEMPappAccentColor == option.name) ? 0.80 : 0.70: 1  )
                                .animation(.smooth, value: TEMPmulticolored)
                                .animation(.smooth, value: TEMPappAccentColorIndex)
                                .animation(.smooth, value: TEMPappAccentColor)
                                .overlay{
                                    if !TEMPmulticolored{
                                        if (TEMPappAccentColorIndex == i && TEMPappAccentColor == option.name){
                                            let brightness2 = Color("\(option.name)/\(i)").getBrightness()
                                            Image(systemName: "checkmark")
                                                .fontWeight(.heavy)

                                            .foregroundStyle(brightness2 > 0.75 ? Color("\(option.name)/\(i)").darken(by: 0.5) : Color.white)
                                        }
                                    }

                                }


                                    .onTapGesture {
                                        if (TEMPappAccentColorIndex == i && TEMPappAccentColor == option.name){

                                            withAnimation(.smooth){
                                                TEMPmulticolored.toggle()
                                            }

                                        }
                                        else{
                                            
                                            withAnimation(.smooth){
                                            TEMPmulticolored = false

                                                TEMPappAccentColor = option.name
                                                TEMPappAccentColorIndex = i
                                            }
                                        }



                                    }
                            // .matchedGeometryEffect(id: "\(option.name)/\(i)", in: namespace)


                        }
                    }
//                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

                        .tag("\(option.name)")



                }
                   }
            #if !os(macOS)
                   .tabViewStyle(PageTabViewStyle(indexDisplayMode: kyoPlus_hasPlus ? .always : .never))
                   .tabViewStyle(.page(indexDisplayMode: kyoPlus_hasPlus ? .always : .never))
            #endif
//                   .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
            .frame(height: 115)

            .background {
                Color("NeoButton").opacity(0.6)


            }
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .regularOutline()
        }
        .onAppear{


            TEMPappAccentColorIndex = appAccentColorIndex

            // FIX: No purchase check or access-state write is needed; Kyo+ is permanently unlocked.

        }
        #if os(visionOS)
        .onChange(of: TEMPmulticolored) { change in
            withAnimation(.smooth){
                multicolored = change
            }
        }
        .onChange(of: TEMPappAccentColor) { change in
            withAnimation(.smooth){
                appAccentColor = change
            }
        }
        .onChange(of: TEMPappAccentColorIndex) { change in
            withAnimation(.smooth){
              appAccentColorIndex = change
            }
        }
        #else
        .onDisappear{
            multicolored = TEMPmulticolored
            appAccentColor = TEMPappAccentColor
            appAccentColorIndex = TEMPappAccentColorIndex
        }
        #endif
    }
}
