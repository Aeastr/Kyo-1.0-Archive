// FIX: Use archive identifiers to keep this build and its data separate from the original app.
//
//  HolidayModeView.swift
//  KyoNeo
//
//  Created by Aether on 10/12/2023.
//

import SwiftUI

struct HolidayModeView: View {
    @AppStorage("global_breakMode", store: UserDefaults(suiteName: "group.com.example.kyoarchive")) var global_breakMode: Bool = false

    @AppStorage("navigationFont") var fontDesign: navigationFont = .expanded
    @AppStorage("fontWeightIndex") private var fontWeightIndex: Int = 1
    @AppStorage("fontCaseIndex") private var fontCaseIndex: Int = 0

    var color: Color
    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 10) {
                // Large Title
                Text("Break Mode")

                    .font(.system(.largeTitle, design: fontDesign.design, weight: fontWeights[min(max(fontWeightIndex, 0), 3)].weight).width(fontDesign.wdith))
                                           .textCase(fontCaseIndex == 1 ? .uppercase : fontCaseIndex == 2 ? .lowercase : nil)
                    .padding(.top, 100)
                    .fontWeight(.bold)

                HStack{
                    // Umbrella Icon from SF Symbols
                                   Image(systemName: "sun.max.fill")
                                       .foregroundColor(color)
                    // Umbrella Icon from SF Symbols
                                   Image(systemName: "beach.umbrella")
                                       .foregroundColor(color)
                    // Umbrella Icon from SF Symbols
                                   Image(systemName: "snowflake")
                                       .foregroundColor(color)
                    // Umbrella Icon from SF Symbols
                                   Image(systemName: "car.side")
                                       .foregroundColor(color)
                }
                .font(.system(size: 65))
                .clipped()
                .padding(.top, 30)

                // Description
                Text("Disable your planner, silences all reminders, and turn off widgets. Designed to give you a break from your usual schedule and notifications, so you can fully enjoy your break without any interruptions from Kyo.")
                    .padding(.top, 30)
                    .padding(.horizontal, 20)


            }
            .padding()
        }
        .safeAreaInset(edge: .bottom) {
                             VStack{
                                 HStack{
                                   Button(action: {
                                       global_breakMode.toggle()
                                     }, label: {
                                         Text(global_breakMode ? "Disable" : "Enable")
                                             .frame(maxWidth: .infinity, alignment: .center)
                                     })
                                     .padding()
                                     .buttonStyle(PolishedButton(color: color, background: !global_breakMode))

                                     .padding(.horizontal, 10)
                                 }


                                 Color.clear.frame(height: 20)
                             }
                         }
                         .ignoresSafeArea(edges: .bottom)
    }

}


#Preview {
    HolidayModeView(color: .blue)
}

struct HolidayModeActive: View {
    @AppStorage("global_breakMode", store: UserDefaults(suiteName: "group.com.example.kyoarchive")) var global_breakMode: Bool = false

    @AppStorage("navigationFont") var fontDesign: navigationFont = .expanded
    @AppStorage("fontWeightIndex") private var fontWeightIndex: Int = 1
    @AppStorage("fontCaseIndex") private var fontCaseIndex: Int = 0

    @State var show: Bool = false

    @Binding var overrideBreakMode: Bool
    var color: Color
    var body: some View {

            VStack(alignment: .leading, spacing: 10) {


                HStack{
                    // Umbrella Icon from SF Symbols
                                   Image(systemName: "sun.max.fill")
                                       .foregroundColor(color)
                    // Umbrella Icon from SF Symbols
                                   Image(systemName: "beach.umbrella")
                                       .foregroundColor(color)
                    // Umbrella Icon from SF Symbols
                                   Image(systemName: "snowflake")
                                       .foregroundColor(color)
                    // Umbrella Icon from SF Symbols
                                   Image(systemName: "car.side")
                                       .foregroundColor(color)
                }
                .font(.system(size: 45))
                .clipped()
                .padding(.top, 30)
                .padding(.horizontal, 20)

                // Description
                Text("Planner, all reminders, and widgets are disabled in break mode.")
                    .padding(.top, 20)
                    .padding(.horizontal, 20)
                HStack(spacing: 16){

                    Button {
                        show.toggle()
                    } label: {
                        Text("Settings")
                    }
                    .buttonStyle(PolishedButton(color: color, background: true))

                    Button {
                        withAnimation(.smooth){
                            overrideBreakMode.toggle()
                        }
                    } label: {
                        Text("View Anyway")
                    }
                    .buttonStyle(PolishedButton(color: color, background: false))
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .sheet(isPresented: $show) {

                } content: {
                    HolidayModeView(color: color)
                        .presentationCornerRadius(25)
                }




            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .offset(y: -30)

//        .safeAreaInset(edge: .bottom) {
//                             VStack{
//                                 HStack{
//                                   Button(action: {
//                                       global_breakMode.toggle()
//                                     }, label: {
//                                         Text(global_breakMode ? "Disable" : "Enable")
//                                             .frame(maxWidth: .infinity, alignment: .center)
//                                     })
//                                     .padding()
//                                     .buttonStyle(PolishedButton(color: color, background: !global_breakMode))
//
//                                     .padding(.horizontal, 10)
//                                 }
//
//
//                                 Color.clear.frame(height: 20)
//                             }
//                         }
//                         .ignoresSafeArea(edges: .bottom)
    }

}
