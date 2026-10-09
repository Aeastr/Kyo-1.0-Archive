//
//  NeoClassPlaceholder.swift
//  KyoNeo
//
//  Created by Aether on 26/11/2022.
//
import AmethystUI
import SwiftUI

struct EntryTemplate: View {
    var title: String
    var icon: String = "box"
    var room: String
    var teacher: String = ""
    var start: String
    var end: String
    var color1: Color
    var color2: Color
    var idle: Bool = true
    var radius: CGFloat = 25
    var adpativeHeight: Bool = false
    var followRules: Bool = false
    @State var currentState: timeState = .upcoming
    @State var currentlyActive: Bool = false
    @State var past: Bool = false
    var timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    @AppStorage("darkenText") var darkenText = false

    @AppStorage("showDetails") var showDetails = true
    @AppStorage("showLength") var showLength = true
    @AppStorage("planner_CountDown") var planner_CountDown : Bool = true
    @AppStorage("planner_TimelineBubbles") var planner_TimelineBubbles:  Bool = true

    var planner_Style:  typeEntryViewMode = .blocks
    @AppStorage("showClassIconPlanner") var showClassIconPlanner = true
    @AppStorage("global_Compact") var global_Compact  = false

    @AppStorage("scaleMode") var scaleMode:  plannerScaleMode = .regular

    @AppStorage("scaleWithDuration") var scaleWithDuration: Bool = true
    @Environment(\.colorScheme) var colorScheme

    
    var body: some View {
        ZStack {

            let brightness1 = color1.getBrightness()
            //let brightness2 = (darkenText ? Color(hex: color2).getBrightness() : 0.0)
            let beCompact = followRules ?global_Compact : false
            let showIcon = followRules ? showClassIconPlanner : true

            VStack(alignment: .leading, spacing: 0) {



                HStack{

                    if planner_TimelineBubbles{
                        Image(systemName: icon)
                            .frame(width: planner_Style == .threads ?global_Compact ? 55 : 65 : 40, height: planner_Style == .threads ?global_Compact ? 55 : 65 : 40)
                            .font(.system(size: 23))
                            .background{
                                if planner_Style == .threads && followRules{
                                    Circle()
                                        .fill(LinearGradient(gradient: Gradient(colors: [color1, color2]), startPoint: .topLeading, endPoint: .bottomTrailing)
                                        )
                                        .transition(.opacity)
                                }
                            }
                            .padding(.trailing, planner_Style == .threads && followRules ? 5 : 0)
                            .foregroundStyle(planner_Style == .blocks || !followRules ? brightness1 > 0.73 ? color1.darken(by: 0.5) : Color.white : (brightness1 > 0.73 ? color1.darken(by: 0.5) : Color.white) )
                            .transition(.blur.animation(.smooth))
                    }

                VStack(alignment: .leading, spacing: 4){
                    HStack{
                        Text(title)
                            .textCase(.uppercase)
                            .font(.body.weight(.semibold))
                            .lineLimit(1)

                        Spacer()
                    }
                    switch currentState {
                    case .error:
                        Group{
                            Text("State Error")
                                .font(.footnote.weight(.regular))
                        }
                    case .upcoming:
                        HStack{
                            Group{
                                Text(start)
                                    .font(.footnote.weight(.regular))
                                +
                                Text(" - ")
                                    .font(.footnote.weight(.regular))
                                +
                                Text(end)
                                    .font(.footnote.weight(.regular))
                            }
                            Spacer()
                            
                            if showLength{
                                let number = differenceBetween(start, end)
                                let roundedNumber = decimalToFraction(number)
                                Text(roundedNumber + "\(differenceBetween(start, end) > 1 ? " hrs" : " hr")")
                                    .textCase(.uppercase)
                                    .font(Font.footnote.weight(.semibold))
                                    .fixedSize(horizontal: true, vertical: false)
                                    .opacity(0.7)
                                    .transition(.blur)
                            }
                        }
                    case .upcomingOnOtherDay:
                        Group{
                            Text("State Error")
                                .font(.footnote.weight(.regular))
                        }
                    case .past:
                        
                        Group{
                            Text("Ended ")
                                .font(.footnote.weight(.regular))
                            +
                            Text(end)
                                .font(.footnote.weight(.regular))
                        }
                    case .current:

                        HStack{
                            if planner_CountDown{
                                Text("\("Remaining") \(TimeFormatter.toDate((end)) ?? Date(), style: .timer)")
                                    .monospacedDigit()
                                    .font(.footnote.weight(.regular))
                                    .transition(.blur)
                            }
                            else{
                                Text("Now")
                                    .monospacedDigit()
                                    .font(.footnote.weight(.regular))
                                    .transition(.blur)
                            }

                            
                            
                            Spacer()
                            Text(Image(systemName: "arrow.right"))
                                .font(.footnote.weight(.light))
                            +
                            Text(" " + (end))
                                .font(.footnote.weight(.regular))
                        }.textCase(.uppercase)
                            .animation(.smooth)
                    

                    case .today:
                        Group{
                            Text("State Error")
                                .font(.footnote.weight(.regular))
                        }
                    default:
                        EmptyView()
                    }


                    if showDetails{
                        Divider()
                            .padding(.vertical, 2)
                            .tint(color1.darken(by: 0.5))

                        HStack(spacing: 3){
                            
                            Group{
                                Text(Image(systemName: "square.split.bottomrightquarter"))
                                    .font(.caption.weight(.regular))
                                + Text(" ")
                                    .font(.caption2)
                                + Text((room) + (teacher != "" ? "," : ""))
                                    .font(.caption.weight(.regular))
                            }
                            Group{
                                Text(Image(systemName: "person"))
                                    .font(.caption.weight(.regular))
                                + Text(" ")
                                    .font(.caption2)
                                + Text((teacher))
                                    .font(.caption.weight(.regular))
                            }
                            
                            
                        }.transition(.blur)
                    }
                }
//                .background(.red)

                .frame(minHeight: scaleWithDuration ? planner_Style == .blocks && followRules ? ((differenceBetween(start, end) * (global_Compact ? 65 : 70)) * getTimeSlotHeightMultiplier(start: start, end: end, mode: scaleMode)) : 90 : 92 )

                .animation(.smooth, value: scaleMode)

            }
                .animation(.smooth, value: planner_TimelineBubbles)
                .padding(.vertical ,  scaleWithDuration && followRules && planner_Style == .blocks ? differenceBetween(start, end) * 11.2 : 0)
                .padding(.vertical, scaleWithDuration ? 0 : 5)

                .padding(.horizontal, 15)
                .background(planner_Style == .blocks || !followRules ? color1.gradient : Color.clear.gradient)
                .foregroundStyle(planner_Style == .blocks || !followRules ? brightness1 > 0.73 ? color1.darken(by: 0.5) : Color.white : (colorScheme == .dark ? color1.darken(by: -0.5) : color1.darken(by: 0.5)))


                .clipShape(RoundedRectangle(cornerRadius:global_Compact ? 0 : 28, style: .continuous))
                #if os(iOS) || os(visionOS)
                .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius:global_Compact ? 0 : 28, style: .continuous))
                #endif
            }
            .animation(.smooth, value: scaleWithDuration)
            .animation(.smooth, value: scaleMode)






        }
        .transition(.opacity.animation(.smooth))
        .animation(.bouncy, value: global_Compact)
        .animation(.bouncy, value: showDetails)
        .animation(.bouncy, value: showLength)
        .animation(.bouncy, value: planner_CountDown)

        .onAppear{
            getState()
            if currentState == .past{
                self.timer.upstream.connect().cancel()
            }
        }
        .onReceive(timer) { input in
            getState()
            if currentState == .past{
                self.timer.upstream.connect().cancel()
            }
        }
        .ignoresSafeArea()

        // .shadow(color: Color(fadeHex: data.color1 ?? "98C6D1"), radius: currentState == .current ? 10 : 0, x:0, y: currentState == .current ? 8 : 0)

    }

    func getState(){
        if !idle{
            self.currentState = TimeHelper.getTimeState(startTime: start, endTime: end)

        }
    }
}
