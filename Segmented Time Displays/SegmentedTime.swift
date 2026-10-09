//
//  SegmentedTime.swift
//  KyoNeo
//
//  Created by Aether on 13/01/2023.
//

import SwiftUI

enum segmentedTimeType{
    case time
    case timeDate
    case date
}

//struct SegmentedTime: View {
//    @Environment(\.colorScheme) var colorScheme
//
//    @Binding var selectedDate: Date
//    var time = "03:00"
//    var title = "Start"
//
//    var type: segmentedTimeType = .time
//    @State var state = "AM"
//    @State var first = ""
//    @State var second = ""
//    @State var third = ""
//    @State var forth = ""
//    @State var showSplit = true 
//    @State var error = false
//    @State var onTapped = false
//    @State var move = false
//    var maxWidth: CGFloat = 200
//    var height: CGFloat = 50
//    @Binding var active: Bool
//
//    var color: Color = Color(hex: "6295A9")
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 0) {
//            HStack(spacing: 0) {
//                if type == .timeDate{
//                    HStack(spacing: 0) {
//                        Text(selectedDate, style: .date)
//                            .font(.headline)
//                            .foregroundColor(color)
//                            .lineLimit(1)
//                    }
//                }
//                else{
//                    Text(title)
//                        .foregroundColor(.secondary)
//                        .font(.caption)
//                }
//                Spacer()
//                if timeType() == .twelve{
//                    Text(state)
//                        .foregroundColor(.secondary)
//                        .font(.caption)
//                }
//            }
//
//            .padding(.horizontal, active ? 13 : 0)
//            let backgroundOpacity = 0.05
//            HStack(spacing: 0){
//                Image("Number=\(first)")
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//                    .background(Image("Number=0")
//                        .resizable()
//                        .aspectRatio(contentMode: .fit).opacity(backgroundOpacity))
//
//                Image("Number=\(second)")
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//                    .background(Image("Number=0")
//                        .resizable()
//                        .aspectRatio(contentMode: .fit).opacity(backgroundOpacity))
//
//                if showSplit{
//                    Image("split")
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//                        .frame(width: 10)
//                }
//                else{
//                    Color.clear
//                        .frame(width: 10, height: 0)
//                }
//
//                Image("Number=\(third)")
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//                    .background(Image("Number=0")
//                        .resizable()
//                        .aspectRatio(contentMode: .fit).opacity(backgroundOpacity))
//
//                Image("Number=\(forth)")
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//                    .background(Image("Number=0")
//                        .resizable()
//                        .aspectRatio(contentMode: .fit).opacity(backgroundOpacity))
//            }
//            .animation(nil)
//            .frame(height: height)
//            .padding(.top, 8)
//            .padding(.bottom, 2)
//            .frame(maxWidth: maxWidth, alignment: .leading)
//            .contentShape(Rectangle())
//            .zIndex(2)
////            .scaleEffect(active ? 0.6 : 1, anchor: .leading)
//            .foregroundColor(error ? .red : color)
//            .onAppear{
//                calculateTime(calc: selectedDate)
//            }
//            .onChange(of: selectedDate) { newValue in
//                calculateTime(calc: newValue)
//            }
//            .shadow(color: color.opacity(onTapped ? 0.6 : 0.4), radius: onTapped ? 4 : 5, y: 4)
//
//            .onTapGesture {
//                withAnimation(.bouncy(duration: 0.45)){
//                    active.toggle()
//                }
//            }
//            .padding(.horizontal, active ? 13 : 0)
//            if active {
//
//                    DatePicker(selection: $selectedDate,  displayedComponents: .hourAndMinute, label: { Text("") })
//                #if os(iOS) || os(visionOS)
//                        .datePickerStyle(.wheel)
//                #endif
//                        .labelsHidden()
//                        .scaleEffect(0.75)
//                .frame(width: 170, height: 110)
//                .scaleEffect(1)
//                .contentShape(Rectangle())
//                .compositingGroup()
//                .clipped()
//                .transition(.blur)
//                .zIndex(1)
//
//            }
//        }
//        .padding(active ? 0 : 13)
//        .padding(.top, active ? 13 : 0)
//        .padding(.bottom, 1.5)
//        .background(Color("bw"))
//        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
//        .regularOutline()
//        .scaleEffect(active ? 1.3 : 1)
//        .offset(x: active ? title == "Start" ? 20 : -20 : 0)
//
//        .modify {
//            if #available(iOS 17.0, *) {
//                $0.sensoryFeedback(.impact(flexibility: .soft, intensity: .infinity), trigger: active) { oldValue, newValue in
//                    newValue == true
//                }
//
//            }
//            else {
//                $0
//            }
//        }
//        .shadow(color: color.darken(by: 0.2).opacity(active ?  0.3 : 0), radius: 12)
//      //  .offset(y: active ? -110 : 0)
//
//    }
//
//    func calculateTime(calc: Date){
//        let dateFormat = getsegmentedTimeFormat()
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = dateFormat
//        var calc = dateFormatter.string(from: selectedDate)
//        print(calc)
//        let characters = Array(calc)
//        if characters.count == 5{
//            let dateFormat = "a"
//            let dateFormatter = DateFormatter()
//            dateFormatter.dateFormat = dateFormat
//            state = dateFormatter.string(from: selectedDate)
//            error = false
//            first = "\(characters[0])"
//            second = "\(characters[1])"
//            third = "\(characters[3])"
//            forth = "\(characters[4])"
//            showSplit = true
//        }
//        else{
//            error = true
//            first = "E"
//            second = "r"
//            third = "r"
//            forth = ""
//            showSplit = false
//        }
//    }
//}

struct SegmentedTime: View {
    @Environment(\.colorScheme) var colorScheme

    @Binding var selectedDate: Date
    var time = "03:00"
    var title = "Start"

    var type: segmentedTimeType = .time
    @State var state = "AM"
    @State var first = ""
    @State var second = ""
    @State var third = ""
    @State var forth = ""
    @State var showSplit = true
    @State var error = false
    @State var onTapped = false
    @State var move = false
    var maxWidth: CGFloat = 200
    var height: CGFloat = 40

    var color: Color = Color(hex: "6295A9")

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 0) {
                if type == .timeDate{
                    HStack(spacing: 0) {
                        Text(selectedDate, style: .date)
                            .font(.headline)
                            .foregroundColor(color)
                            .lineLimit(1)
                    }
                }
                else{
                    Text(title)
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
                Spacer()
                if timeType() == .twelve{
                    Text(state)
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
            }

            let backgroundOpacity = 0.05
            HStack(spacing: 0){
                Image("Number=\(first)")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .background(Image("Number=0")
                        .resizable()
                        .aspectRatio(contentMode: .fit).opacity(backgroundOpacity))

                Image("Number=\(second)")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .background(Image("Number=0")
                        .resizable()
                        .aspectRatio(contentMode: .fit).opacity(backgroundOpacity))

                if showSplit{
                    Image("split")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 10)
                }
                else{
                    Color.clear
                        .frame(width: 10, height: 0)
                }

                Image("Number=\(third)")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .background(Image("Number=0")
                        .resizable()
                        .aspectRatio(contentMode: .fit).opacity(backgroundOpacity))

                Image("Number=\(forth)")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .background(Image("Number=0")
                        .resizable()
                        .aspectRatio(contentMode: .fit).opacity(backgroundOpacity))
            }
            .animation(nil)
            .frame(height: height)
            .padding(.top, 8)
            .padding(.bottom, 2)
            .frame(maxWidth: maxWidth, alignment: .leading)
            .contentShape(Rectangle())
            .zIndex(2)
//            .scaleEffect(active ? 0.6 : 1, anchor: .leading)
            .foregroundColor(error ? .red : color)
            .onAppear{
                calculateTime(calc: selectedDate)
            }
            .onChange(of: selectedDate) { newValue in
                calculateTime(calc: newValue)
            }
            .shadow(color: color.opacity(onTapped ? 0.6 : 0.4), radius: onTapped ? 4 : 5, y: 4)


        }
        .padding(13)
        .padding(.bottom, 1.5)
        #if !os(visionOS)
        .background(Color("NeoButton").opacity(0.4))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .regularOutline()
        #else
        .padding(7)
        .background(Color.white.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
        #endif

      //  .offset(y: active ? -110 : 0)

    }

    func calculateTime(calc: Date){
        let dateFormat = getsegmentedTimeFormat()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        var calc = dateFormatter.string(from: selectedDate)
        print(calc)
        let characters = Array(calc)
        if characters.count == 5{
            let dateFormat = "a"
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = dateFormat
            state = dateFormatter.string(from: selectedDate)
            error = false
            first = "\(characters[0])"
            second = "\(characters[1])"
            third = "\(characters[3])"
            forth = "\(characters[4])"
            showSplit = true
        }
        else{
            error = true
            first = "E"
            second = "r"
            third = "r"
            forth = ""
            showSplit = false
        }
    }
}


struct SegmentedTime_Previews: PreviewProvider {
    static var previews: some View {
        testSegTimeView()
    }
}

struct testSegTimeView: View {
    @State var active = false
    @State var active2 = false
    @State var endTime: Date = Date()
    var body: some View {
        HStack(spacing: active || active2 ? 22 : 15) {
            Color.clear
                .overlay {
                    SegmentedTime(selectedDate: $endTime, color: .teal)

                        .zIndex(active ? 2 : 0)
                }
                .zIndex(active ? 2 : 0)

                Color.clear
                .overlay{
                    SegmentedTime(selectedDate: $endTime, color: .blue)
                }
                .zIndex(active ? 0 : 2)
                .onChange(of: active) { value in
                    if value == true{
                        active2 = false
                    }
                }
                .onChange(of: active2) { value in
                    if value == true{
                        active = false
                    }
                }

        }
        .padding(40)
    }
}

struct SegmentedTimeTest: View {
    @Environment(\.colorScheme) var colorScheme
    
    @Binding var selectedDate: Date
    var time = "03:00"
    var title = "Start"

    var type: segmentedTimeType = .time
    @State var state = "AM"
    @State var first = ""
    @State var second = ""
    @State var third = ""
    @State var forth = ""
    @State var showSplit = true
    @State var error = false
    @State var onTapped = false

    var maxWidth: CGFloat = 200
    @Binding var active: Bool
    var namespace: Namespace.ID
    var color: Color = Color(hex: "6295A9")

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 0) {
                if type == .timeDate{
                    HStack(spacing: 0) {
                        Text(selectedDate, style: .date)
                            .font(.headline)
                            .foregroundColor(color)
                            .lineLimit(1)
                    }
                }
                else{
                    Text(title)
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
                Spacer()
                if timeType() == .twelve{
                    Text(state)
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
            }

            .padding(.horizontal, active ? 13 : 0)
            let backgroundOpacity = 0.03
            HStack(spacing: 0){

            }

            .frame(height: 50)

            .frame(maxWidth: maxWidth, alignment: .leading)
            .foregroundColor(error ? .red : color)
//            .onAppear{
//                calculateTime(calc: selectedDate)
//            }
//            .onChange(of: selectedDate) { newValue in
//                calculateTime(calc: newValue)
//            }
            .shadow(color: color.opacity(onTapped ? 0.6 : 0.4), radius: onTapped ? 4 : 5, y: 4)

            .padding(.horizontal, active ? 13 : 0)
            .padding(.bottom, active ? 2 : 0)
//            if active {
//
//                    DatePicker(selection: $selectedDate,  displayedComponents: .hourAndMinute, label: { Text("") })
//                        .datePickerStyle(.wheel)
//                        .labelsHidden()
//                        .scaleEffect(0.75)
//                .frame(width: 170, height: 110)
//                .scaleEffect(1)
//                .contentShape(Rectangle())
//                .compositingGroup()
//                .clipped()
//                .transition(.blur)
//                .onTapGesture {
//                    print("tapped !")
//                    move.toggle()
//                }
//
//            }
        }
        .padding(active ? 0 : 13)
        .padding(.top, active ? 13 : 0)
        .padding(.bottom, 1.5)
        .background{
            Color("bw")

        }
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .regularOutline()

    // .matchedGeometryEffect(id: "bgstuffs", in: namespace)
        .scaleEffect(active ? 1.17 : 1)
        .offset(x: active ? title == "Start" ? 16 : -16 : 0)
        .animation(.smooth)
//        .modify {
//            if #available(iOS 17.0, *) {
//                $0.sensoryFeedback(.impact(flexibility: .soft, intensity: .infinity), trigger: active) { oldValue, newValue in
//                    newValue == true
//                }
//
//            } else {
//                $0
//            }
//        }
        .shadow(color: color.opacity(active ?  0.3 : 0), radius: 10)


        .onTapGesture {
            active.toggle()
        }

    }

    func calculateTime(calc: Date){
        let dateFormat = getsegmentedTimeFormat()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        var calc = dateFormatter.string(from: selectedDate)
        print(calc)
        let characters = Array(calc)
        if characters.count == 5{
            let dateFormat = "a"
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = dateFormat
            state = dateFormatter.string(from: selectedDate)
            error = false
            first = "\(characters[0])"
            second = "\(characters[1])"
            third = "\(characters[3])"
            forth = "\(characters[4])"
            showSplit = true
        }
        else{
            error = true
            first = "E"
            second = "r"
            third = "r"
            forth = ""
            showSplit = false
        }
    }
}
