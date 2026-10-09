////
////  Custom Date Picker.swift
////  KyoNeo
////
////  Created by Aether on 13/01/2023.
////
//
//import SwiftUI
//
//#if os(iOS) || os(visionOS)
//struct Custom_Date_Picker: View {
//    @State var showsPopoverStart = false
//    @State var showsPopoverEnd = false
//    @State var time = "00:01"
//    @State var selectedDate1: Date = Date()
//    @State var selectedDate2: Date = Date()
//
//    var color: Color = Color(hex: "6295A9")
//
//    var body: some View {
//        VStack(spacing: 50) {
//
//            HStack(spacing: 10) {
//
//
//                SegmentedTime(selectedDate: $selectedDate1, color: color)
//
//                Spacer()
//
//                SegmentedTime(selectedDate: $selectedDate2, title: "End", color: color)
//                  
//
//
//
//
//            }
//            .padding(30)
//            .shadow(color: color.opacity(0.15), radius: 10, y: 5)
//
//
//            
//
//        }
//    }
//}
//
//
//
//
//struct Custom_Date_Picker_Previews: PreviewProvider {
//    static var previews: some View {
//        ZStack{
//            Color("Background")
//                .ignoresSafeArea()
//                Image("dots")
//                .resizable()
//                .ignoresSafeArea()
//                .blendMode(.multiply)
//                .opacity(0.2)
//            Custom_Date_Picker()
//        }
//    }
//}
//#endif
