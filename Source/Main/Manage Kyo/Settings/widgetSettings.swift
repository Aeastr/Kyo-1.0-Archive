// FIX: Use archive identifiers to keep this build and its data separate from the original app.
//
//  widgetSettings.swift
//  KyoNeo
//
//  Created by Aether on 16/08/2023.
//

import SwiftUI
import AmethystUI

struct widgetSettings: View {
    @State var scrolled: Bool = false

    @State private var widget1Position = CGPoint(x: 1, y: 1)

    @State private var isAnimating = true
        @State private var widget2Position = CGPoint(x: -1, y: 1)
        @State private var widget3Position = CGPoint(x: -1, y: -1)

    @AppStorage("colorfulWidgetBackgrounds", store: UserDefaults(suiteName: "group.com.example.kyoarchive")) var colorfulWidgetBackgrounds: Bool = true


    @State var a: Double = 6.2
    var color: Color = .blue
    var body: some View {
        ScrollView{
            ScrollDetector(scrolled: $scrolled)

            ScrollView(.horizontal, showsIndicators: false){
            HStack(spacing: 27){
                PlannerWidget1Template(color1: .orange)
                    .aspectRatio(CGSize(width: 1, height: 1), contentMode: .fit)
                
                    .padding(15)
                    .background{
                        if colorfulWidgetBackgrounds{
                            Rectangle()
                                .fill(Color.orange.gradient)
                        }
                        else{
                            Color("bw")
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 21.05263158, style: .continuous))
                    .rotation3DEffect(Angle(degrees: a),
                                                          axis: (x: widget1Position.x, y: widget1Position.y, z: 0),
                                                          anchor: .center)

                    .shadow(color: (colorfulWidgetBackgrounds ? Color.orange : Color.primary.opacity(0.5)).opacity(0.2), radius: 13, y: 1.5)


                PlannerWidget1Template(name: "Geo", room: "KB-2", taughtBy: "Mr Blair", color1: .green, startString: TimeFormatter.getTimeString(Date()), endString:TimeFormatter.getTimeString(Date().addingTimeInterval(2 * 60 * 60)), state: .current, dayName: "Wed", weekNum: 2)
                        .aspectRatio(CGSize(width: 1, height: 1), contentMode: .fit)

                        .padding(15)
                        .background{
                            if colorfulWidgetBackgrounds{
                                Rectangle()
                                    .fill(Color.green.gradient)
                            }
                            else{
                                Color("bw")
                            }
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 21.05263158, style: .continuous))
                        .rotation3DEffect(Angle(degrees: a),
                                                              axis: (x: widget2Position.x, y: widget2Position.y, z: 0),
                                                              anchor: .center)

                        .shadow(color: (colorfulWidgetBackgrounds ? Color.green : Color.primary.opacity(0.5)).opacity(0.2), radius: 13, y: 1.5)

                PlannerWidget1Template(name: "Science", room: "CB3", taughtBy: "Mr Speake", color1: .teal, startString: "1:50", endString: "2:50", state: .upcomingOnOtherDay, dayName: "Wed", weekNum: 2)
                    .aspectRatio(CGSize(width: 1, height: 1), contentMode: .fit)
                
                    .padding(15)
                    .background{
                        if colorfulWidgetBackgrounds{
                            Rectangle()
                                .fill(Color.teal.gradient)
                        }
                        else{
                            Color("bw")
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 21.05263158, style: .continuous))
                    .rotation3DEffect(Angle(degrees: a),
                                                          axis: (x: widget3Position.x, y: widget3Position.y, z: 0),
                                                          anchor: .center)

                    .shadow(color: (colorfulWidgetBackgrounds ? Color.teal : Color.primary.opacity(0.5)).opacity(0.2), radius: 13, y: 1.5)
            }.frame(height: 140)

                    .padding(.vertical, 30)
                    .padding(.horizontal, 20)
        }
            .padding(.vertical, -30)
            .padding(.bottom, 25)
                .frame(maxWidth: .infinity)

                .onAppear {
                            animatePattern()
                        }
                .onDisappear{
                    isAnimating = false
                }

            Toggle(isOn: $colorfulWidgetBackgrounds) {
                HStack{

                    Image(systemName: "paintpalette")
                        .frame(width: 20, alignment: .center)
                        .symbolRenderingMode(/*@START_MENU_TOKEN@*/.hierarchical/*@END_MENU_TOKEN@*/)
                        .foregroundColor(color)
                        .modify {
                            if #available(iOS 17.0, *) {
                                $0.symbolEffect(.bounce, value: colorfulWidgetBackgrounds)
                            }
                            else{
                                $0
                            }
                        }


                    VStack(alignment: .leading, spacing: 3){
                        Text("Colourfull Widget Backgrounds")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }

            }
            .frame(maxWidth: .infinity)
            .toggleStyle(.switch)
            .neoSettingsToggle()

            .padding(.horizontal, 20)
            .tint(color)

        }
        .safeAreaInset(edge: .top, content: {
            Color.clear.frame(height: 80)
        })
#if os(iOS) || os(visionOS)
.navigationTitle("")
.navigationBarHidden(true)
.overlay(alignment: .top){
    FluidNavigationBar(title: "Widgets", titleColor: .primary,   tintColor: color, compactMode: true, type: .back, scrolled: $scrolled, content: {
        
    }, toolbar: {
        
    })
}
        #endif

    }


        // ... other code ...

    private func animatePattern() {
            guard isAnimating else {
                return
            }

            animateStep(widgetIndex: 1, step: 1)
            animateStep(widgetIndex: 2, step: 3)
            animateStep(widgetIndex: 3, step: 4)
        }

        private func animateStep(widgetIndex: Int, step: Int) {
            guard isAnimating else {
                return
            }
            if #available(iOS 17.0, *) {
                let minDuration: Double = 2.3
                let maxDuration: Double = 4.5
                let randomDuration = Double.random(in: minDuration...maxDuration)

                let animation = Animation.linear(duration: randomDuration)

                var position: CGPoint
                switch step {
                case 1:
                    position = CGPoint(x: 1, y: 1)
                case 2:
                    position = CGPoint(x: -1, y: 1)
                case 3:
                    position = CGPoint(x: -1, y: -1)
                case 4:
                    position = CGPoint(x: 1, y: -1)
                default:
                    position = CGPoint(x: 0, y: 0)
                }

                withAnimation(animation) {
                    if widgetIndex == 1 {
                        widget1Position = position
                    } else if widgetIndex == 2 {
                        widget2Position = position
                    } else if widgetIndex == 3 {
                        widget3Position = position
                    }
                } completion: {
                    let nextStep = step < 4 ? step + 1 : 1
                    animateStep(widgetIndex: widgetIndex, step: nextStep) // Loop back to the start if step is 4
                }
            } else {
                // Fallback on earlier versions
            }
        }


}

struct PlannerWidget1Template : View {
    var name: String = "Maths"
    var room: String = "DC3"
    var taughtBy: String = "Mx Aurelia"

    var color1: Color = .blue

    var startString: String = "8:30"
    var endString: String = "10:30"
    var state: timeState = .upcoming

    var dayName: String = "Mon"
    var weekNum: Int = 1


@AppStorage("colorfulWidgetBackgrounds") private var colorfulWidgetBackgrounds: Bool = true
    var body: some View {

        let brightness1 = (color1.getBrightness())
        HStack{
            VStack(alignment: .leading, spacing: 4){



                    Text(name)
                        .font(.title3.weight(.bold))
                        .textCase(.uppercase)
                        .padding(.vertical, 1.1)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(2)
                        .minimumScaleFactor(0.65)

                ViewThatFits(content: {
                    VStack(alignment: .leading, spacing: 6.5){

                        if room != "" {
                            if findURL(in: room) == nil{
                                VStack(alignment: .leading, spacing: 5){
                                    HStack{
                                        Text(Image(systemName: "square.split.bottomrightquarter"))
                                        + Text(" " + room)
                                    }
                                    .lineLimit(1)


                                }

                            }
                            else{
                                HStack(spacing: 2){
                                    Text(Image(systemName: getIconForURL(findURL(in: room) ?? "link")))
                                        .lineLimit(1)
                                }
                            }
                        }
                        if taughtBy != ""{
                            HStack(spacing: 2){
                                Text(Image(systemName: "person"))
                                Text(taughtBy)

                            }
                            .lineLimit(1)
                        }
                    }
                    ZStack{
                        if room != "" {
                            if findURL(in: room) == nil{
                                VStack(alignment: .leading, spacing: 5){
                                    HStack{
                                        Text(Image(systemName: "square.split.bottomrightquarter"))
                                        + Text(" " + room)
                                    }
                                    .lineLimit(1)


                                }

                            }
                            else{
                                HStack(spacing: 2){
                                    Text(Image(systemName: "link"))
                                        .lineLimit(1)
                                }
                            }
                        }
                    }
                    HStack(alignment: .center, spacing: 6.5){

                        if room != "" {
                            if findURL(in: room) == nil{
                                VStack(alignment: .leading, spacing: 5){
                                    HStack{
                                        Text(Image(systemName: "square.split.bottomrightquarter"))
                                        + Text(" " + room)
                                    }
                                    .lineLimit(1)


                                }

                            }
                            else{
                                HStack(spacing: 2){
                                    Text(Image(systemName: "link"))
                                        .lineLimit(1)
                                }
                            }
                        }
                        if taughtBy != ""{
                            HStack(spacing: 2){
                                Text(Image(systemName: "person"))
                                Text(taughtBy)

                            }
                            .lineLimit(1)
                        }
                    }
                })
                .font(.footnote)

                .foregroundColor(colorfulWidgetBackgrounds ? brightness1 > 0.73 ? color1.darken(by: 0.5) : Color.white :  color1.darken(by: 0.5) )
                    if state == .upcoming{
                        VStack(alignment: .trailing, spacing: 2){
                            HStack( alignment: .center){
                                Text(Image(systemName: "arrow.right"))
                                +
                                Text(" \(startString)")
                            }
                            .font(.headline.weight(.bold))

                            Text("in \(TimeFormatter.toDate(startString, mode: .fullDate) ?? Date(), style: .timer)")
                                .font(.footnote)
                                .multilineTextAlignment(.trailing)
                                .opacity(0.7)
                                .monospacedDigit()

                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                    }
                    if state == .current{
                        VStack(alignment: .trailing, spacing: 2){
                            HStack( alignment: .center){
                                //                                Text(Image(systemName: "arrow.right"))
                                //                                +
                                Text(" \(TimeFormatter.toDate(endString, mode: .fullDate) ?? Date(), style: .timer)")
                                    .monospacedDigit()
                                    .multilineTextAlignment(.trailing)
                            }
                            .font(.headline.weight(.bold))


                            Text("Ends \(endString)")
                                .textCase(.uppercase)
                                .font(.footnote)
                                .multilineTextAlignment(.trailing)
                                .opacity(0.7)
                                .monospacedDigit()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                    }
                    if state == .upcomingOnOtherDay{
                        VStack(alignment: .trailing, spacing: 2){
                            HStack( alignment: .center){
                                //                                Text(Image(systemName: "arrow.right"))
                                //                                +
                                ViewThatFits{
                                    Text("\(getFullDayName(from: dayName) ?? dayName), Week \(weekNum)")

                                        .fixedSize(horizontal: false, vertical: true)
                                        .multilineTextAlignment(.trailing)
                                        .lineLimit(2)

                                        Text("\(dayName), Week \(weekNum)")

                                            .fixedSize(horizontal: false, vertical: true)
                                            .multilineTextAlignment(.trailing)
                                            .lineLimit(2)
                                }
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
//
                            if let w = WeekWizard().getCurrentWeek() {
                                Text(abs((w - weekNum)) == 1 ? "Next Week" : abs((w - weekNum)) == 0 ? "^[\(TimeHelper.calculateDaysBetween(start: TimeFormatter.getDayCode(date: Date()) ?? "Mon", end: dayName)) Day](inflect: true)" : (weekNum - 1) == 0 ? "Next Week" : "In \(weekNum - 1) Weeks")
                                    .textCase(.uppercase)
                                    .font(.footnote)
                                    .multilineTextAlignment(.trailing)
                                    .opacity(0.7)
                            }


                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                    }


            }
            //                if family == .systemMedium{
            //                    Color.clear.frame(width: 10)
            //                    VStack(spacing: 7){
            //
            //                            Label("Task", systemImage: "plus")
            //                            .font(.footnote)
            //                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            //                                .background(Color(.white).opacity(0.3))
            //                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            //                        Label("Edit", systemImage: "pencil")
            //                            .font(.footnote)
            //                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            //                            .background(Color(.white).opacity(0.3))
            //                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            //                        Label("Mute", systemImage: "bell.slash")
            //                            .font(.footnote)
            //                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            //                            .background(Color(.white).opacity(0.3))
            //                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            //                    }
            //                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            //                }
        }
        .foregroundColor(colorfulWidgetBackgrounds ? brightness1 > 0.73 ? color1.darken(by: 0.5) : Color.white :  color1.darken(by: 0.5) )
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .animation(.smooth)

    }
}
