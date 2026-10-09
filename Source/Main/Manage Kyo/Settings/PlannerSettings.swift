//
//  PlannerSettings.swift
//  KyoNeo
//
//  Created by Aether on 04/05/2023.
//

import SwiftUI
import AmethystUI
struct PlannerSettings: View {
    var color: Color

    @State var startTime = Date()
    @State var endTime = Date()
    @AppStorage("showClassIconPlanner") var showClassIconPlanner = true

    @Environment(\.colorScheme) private var colorScheme
    @State var scrolled: Bool = false
    @AppStorage("navigationFont") var fontDesign: navigationFont = .expanded

    @AppStorage("fontWeightIndex") private var fontWeightIndex: Int = 1

    @AppStorage("Contrast") var contrast = false
    @AppStorage("tintPages") var tintPages = false
    @AppStorage("global_Compact") var global_Compact  = false


    @AppStorage("planner_TimelineBubbles") var planner_TimelineBubbles:  Bool = true
    @AppStorage("countdownOnlyCurrent") var countdownOnlyCurrent = true
    @AppStorage("automaticDay") var automaticDay = true
    @AppStorage("planner_Suggestions") var planner_Suggestions = false
    //plannerCountDownMode
    @AppStorage("showLength") var showLength = false
    @AppStorage("showDetails") var showDetails = true
    @AppStorage("planner_CountDown") var planner_CountDown : Bool = true

    @AppStorage("appAccentColor") var appAccentColor = "Default"


    @AppStorage("planner_View") var planner_View: plannerViewMode = .pages

    @AppStorage("planner_Style") var planner_Style:  typeEntryViewMode = .blocks

    @AppStorage("scaleWithDuration") var scaleWithDuration: Bool = true
    @AppStorage("scaleMode") var scaleMode:  plannerScaleMode = .regular

    #if !os(iOS)
    @AppStorage("planner_viewSettings_twoColumn") var planner_viewSettings_twoColumn : Bool = false
    #else
    var planner_viewSettings_twoColumn : Bool = false
    #endif

    // FIX: Read the local Pro preview setting, defaulting to on; no purchase checks are used.

    @AppStorage("archivePlusEnabled") private var kyoPlus_hasPlus = true
    @State var kyoPlus_showPurchaseScreen: Bool = false

    @State var kyoPlus_mockSetting_planner_Style:  typeEntryViewMode = .blocks

    var body: some View {
        ZStack {
            pageTopHue(color: color)
            Color("1")
                .opacity(contrast ? colorScheme == .dark ?  0.15 : 0.08 : tintPages ? colorScheme == .dark ? 0.1 : 0.03 : 0)
                .ignoresSafeArea()
            ScrollView {
                ScrollDetector(scrolled: $scrolled)

                Group{

                    if kyoPlus_hasPlus{
                        TabView(selection: $planner_Style) {
                                                VStack(spacing:global_Compact ? 0 : 15){
                                                    EntryTemplate(title: "Maths" ,
                                                                  icon: "ruler",
                                                                  room: "DC5",
                                                                  start: "8:30",
                                                                  end: "9:15",
                                                                  color1: color,
                                                                  color2: color,
                                                                  adpativeHeight: true,
                                                                  followRules: true,
                                                                  planner_Style: .blocks)

                                                    EntryTemplate(title: "History" ,
                                                                  icon: "book",
                                                                  room: "B2",
                                                                  start: "9:30",
                                                                  end: "11:30",
                                                                  color1: color,
                                                                  color2: color,
                                                                  adpativeHeight: true,
                                                                  followRules: true)

                                                    EntryTemplate(title: "Science" ,
                                                                  icon: "flask",
                                                                  room: "Lab A",
                                                                  start: TimeFormatter.getTimeString(Date()),
                                                                  end: TimeFormatter.getTimeString(Date().addingTimeInterval(60 * (60))),
                                                                  color1:  color,
                                                                  color2:  color,
                                                                  idle: false,
                                                                  adpativeHeight: true,
                                                                  followRules: true)
                                                }
                                                .scaleEffect( 0.78)
                                                .scaleEffect(scaleMode == .large ? 0.82 : 1)

                                                .animation(.smooth, value: global_Compact)
                                                .animation(.smooth, value: showClassIconPlanner)
                                                .animation(.smooth, value: scaleMode)
                                                .animation(.smooth, value: kyoPlus_mockSetting_planner_Style)
                                                .animation(.smooth)

                                                .frame(height: 300)
                                                .tag(typeEntryViewMode.blocks)


                                                VStack(spacing: 0){
                                                    EntryTemplate(title: "Maths" ,
                                                                  icon: "ruler",
                                                                  room: "DC5",
                                                                  start: "8:30",
                                                                  end: "9:00",
                                                                  color1: color,
                                                                  color2: color,
                                                                  adpativeHeight: true,
                                                                  followRules: true,
                                                                  planner_Style: .threads)

                                                    EntryTemplate(title: "History" ,
                                                                  icon: "book",
                                                                  room: "B2",
                                                                  start: "9:30",
                                                                  end: "11:30",
                                                                  color1: color,
                                                                  color2: color,
                                                                  adpativeHeight: true,
                                                                  followRules: true,
                                                                  planner_Style: .threads)

                                                    EntryTemplate(title: "Science" ,
                                                                  icon: "flask",
                                                                  room: "Lab A",
                                                                  start: TimeFormatter.getTimeString(Date()),
                                                                  end: TimeFormatter.getTimeString(Date().addingTimeInterval(60 * (60))),
                                                                  color1:  color,
                                                                  color2:  color,
                                                                  idle: false,
                                                                  adpativeHeight: true,
                                                                  followRules: true,
                                                                  planner_Style: .threads)
                                                }
                                                .scaleEffect(0.85)
                                                .frame(height: 250)
                                                .tag(typeEntryViewMode.threads)



                                            }
                                            .frame(height: 310)
                                            .frame(maxWidth: .infinity, alignment: .center)
                                            .padding(.bottom, 26)
                        #if !os(macOS)
                                            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                                            .tabViewStyle(.page(indexDisplayMode: .always))
                                            .indexViewStyle(.page(backgroundDisplayMode: .always))
                                            #endif
                                            .padding(.top, -20)
                                            .padding(.bottom, -20)
                                            .onAppear() {
                        #if !os(macOS)
                                                UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(color)
                                                #endif

                                            }
                                            .onDisappear{
                        #if !os(macOS)
                                                UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(Color.white)
                                                #endif

                                            }

                                            .animation(.smooth, value: scaleMode)
                                            .frame(maxWidth: 700)
                    }
                    else{
                        TabView(selection: $kyoPlus_mockSetting_planner_Style) {
                                                VStack(spacing:global_Compact ? 0 : 15){
                                                    EntryTemplate(title: "Maths" ,
                                                                  icon: "ruler",
                                                                  room: "DC5",
                                                                  start: "8:30",
                                                                  end: "9:15",
                                                                  color1: color,
                                                                  color2: color,
                                                                  adpativeHeight: true,
                                                                  followRules: true,
                                                                  planner_Style: .blocks)

                                                    EntryTemplate(title: "History" ,
                                                                  icon: "book",
                                                                  room: "B2",
                                                                  start: "9:30",
                                                                  end: "11:30",
                                                                  color1: color,
                                                                  color2: color,
                                                                  adpativeHeight: true,
                                                                  followRules: true)

                                                    EntryTemplate(title: "Science" ,
                                                                  icon: "flask",
                                                                  room: "Lab A",
                                                                  start: TimeFormatter.getTimeString(Date()),
                                                                  end: TimeFormatter.getTimeString(Date().addingTimeInterval(60 * (60))),
                                                                  color1:  color,
                                                                  color2:  color,
                                                                  idle: false,
                                                                  adpativeHeight: true,
                                                                  followRules: true)
                                                }
                                                .scaleEffect( 0.78)
                                                .scaleEffect(scaleMode == .large ? 0.82 : 1)

                                                .animation(.smooth, value: global_Compact)
                                                .animation(.smooth, value: showClassIconPlanner)
                                                .animation(.smooth, value: scaleMode)
                                                .animation(.smooth)

                                                .frame(height: 300)
                                                .tag(typeEntryViewMode.blocks)


                                                VStack(spacing: 0){
                                                    Label("Upgrade to Kyo+ to use this style", systemImage: "lock")
                                                        .padding(.bottom)
                                                        .font(.caption)
                                                    EntryTemplate(title: "Maths" ,
                                                                  icon: "ruler",
                                                                  room: "DC5",
                                                                  start: "8:30",
                                                                  end: "9:00",
                                                                  color1: color,
                                                                  color2: color,
                                                                  adpativeHeight: true,
                                                                  followRules: true,
                                                                  planner_Style: .threads)
                                                    .opacity(0.3)

                                                    EntryTemplate(title: "History" ,
                                                                  icon: "book",
                                                                  room: "B2",
                                                                  start: "9:30",
                                                                  end: "11:30",
                                                                  color1: color,
                                                                  color2: color,
                                                                  adpativeHeight: true,
                                                                  followRules: true,
                                                                  planner_Style: .threads)
                                                    .opacity(0.3)

                                                    EntryTemplate(title: "Science" ,
                                                                  icon: "flask",
                                                                  room: "Lab A",
                                                                  start: TimeFormatter.getTimeString(Date()),
                                                                  end: TimeFormatter.getTimeString(Date().addingTimeInterval(60 * (60))),
                                                                  color1:  color,
                                                                  color2:  color,
                                                                  idle: false,
                                                                  adpativeHeight: true,
                                                                  followRules: true,
                                                                  planner_Style: .threads)
                                                    .opacity(0.3)
                                                }
                                                .scaleEffect(0.85)
                                                .frame(height: 250)
                                                .tag(typeEntryViewMode.threads)
                                                .offset(y: -18)



                                            }
                                            .frame(height: 310)
                                            .frame(maxWidth: .infinity, alignment: .center)
                                            .padding(.bottom, 26)
                        #if !os(macOS)
                                            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                                            .tabViewStyle(.page(indexDisplayMode: .always))
                                            .indexViewStyle(.page(backgroundDisplayMode: .always))
                                            #endif
                                            .padding(.top, -20)
                                            .padding(.bottom, -20)
                                            .onAppear() {
                        #if !os(macOS)
                                                UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(color)
                                                #endif

                                            }
                                            .onDisappear{
                        #if !os(macOS)
                                                UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(Color.white)
                                                #endif

                                            }

                                            .animation(.smooth, value: scaleMode)
                                            .frame(maxWidth: 700)
                    }




                    GroupSection {
#if !os(iOS)
                        SettingsGroup([
                            GroupItem(label: "2 Column Layout", description: "Split Content into 2 columns", icon: "square.split.2x1", color: color, linkedBoolBinding: { Binding<Bool>(get: { self.planner_viewSettings_twoColumn }, set: { self.planner_viewSettings_twoColumn = $0 }) })], background: true, dividers: true
                        )
                        #endif

                        SettingsGroup(
                            [
                                GroupItem(label: "Compact Mode", description: "Entries will take up less space", icon: "rectangle.compress.vertical", color: color, linkedBoolBinding: { Binding<Bool>(get: { self.global_Compact }, set: { self.global_Compact = $0 }) }),

                                GroupItem(label: "Scale with duration", description: "Entry height will scale with entry duration ", icon: "lines.measurement.vertical", color: color, linkedBoolBinding: { Binding<Bool>(get: { self.scaleWithDuration }, set: { self.scaleWithDuration = $0 }) }, visible: !(planner_Style == .threads) || !(kyoPlus_mockSetting_planner_Style == .threads), enabled: kyoPlus_hasPlus),

                                GroupItem(label: "Scale", 
                                          description: "Entry height will scale with entry duration ",
                                          icon: "rectangle.compress.vertical",
                                          color: color,
                                          customContent:
                                            AnyView( Picker("Scale Mode", selection: $scaleMode) {
                                                ForEach(plannerScaleMode.allCases, id:\.self){ mode in
                                                    Text(mode.rawValue)
                                                        .id(mode)
                                                }
                                            }), 
                                          visible: (!(planner_Style == .threads) || !(kyoPlus_mockSetting_planner_Style == .threads) ) && scaleWithDuration, enabled: kyoPlus_hasPlus
                                         ),

                                GroupItem(label: "Show Bubbles", 
                                          description: "Show bubbles next to info",
                                          icon: "bubbles.and.sparkles.fill",
                                          color: color, 
                                          linkedBoolBinding: { Binding<Bool>(get: { self.planner_TimelineBubbles }, set: { self.planner_TimelineBubbles = $0 }) },
                                          visible: (planner_Style == .threads) || (kyoPlus_mockSetting_planner_Style == .threads), enabled: kyoPlus_hasPlus),

                                GroupItem(label: "Countdown", 
                                          description: "Display a coutdown for current entries",
                                          icon: "clock.arrow.2.circlepath",
                                          color: color,
                                          linkedBoolBinding: { Binding<Bool>(get: { self.planner_CountDown }, set: { self.planner_CountDown = $0 }) }, enabled: kyoPlus_hasPlus),

                                GroupItem(label: "Duration", 
                                          description: "Shows total time of an entry",
                                          icon: "clock.fill",
                                          color: color,
                                          linkedBoolBinding: { Binding<Bool>(get: { self.showLength }, set: { self.showLength = $0 }) }, enabled: kyoPlus_hasPlus),

                                GroupItem(label: "Show Suggestions", 
                                          description: "Suggest entries",
                                          icon: "sparkles.square.fill.on.square",
                                          color: color,
                                          linkedBoolBinding: { Binding<Bool>(get: { self.planner_Suggestions }, set: { self.planner_Suggestions = $0 }) }, enabled: kyoPlus_hasPlus),

                                GroupItem(label: "Details", 
                                          description: "Shows room, link, and teacher",
                                          icon: "text.badge.star",
                                          color: color,
                                          linkedBoolBinding: { Binding<Bool>(get: { self.showDetails }, set: { self.showDetails = $0 }) }, enabled: kyoPlus_hasPlus),

                                GroupItem(label: "View", 
                                          description: "Customise planner view",
                                          icon: "rectangle.compress.vertical",
                                          color: color,
                                          customContent: AnyView(
                                                                    Picker("View Mode", selection: $planner_View) {
                                                                        ForEach(plannerViewMode.allCases, id:\.self){ mode in
                                                                            Text(mode.rawValue)
                                                                                .id(mode)
                                                                        }
                                                                    }
                                                                )
                                          , enabled: kyoPlus_hasPlus),



                            ], background: true, dividers: true)
                    }
                    .padding(.horizontal, 20)

                    Group{

                        Group{
                            // FIX: Add explicit view content so this empty Group compiles with the current SDK.
                            // Preserve the original commented-out code below; this addition does not change the UI.
                            EmptyView()



                            //                        HStack(spacing: 25){
                            //                            Button {
                            //                                withAnimation{
                            //                                    planner_Style = .threads
                            //                                }
                            //                            } label: {
                            //                                VStack(spacing: 10){
                            //                                    ZStack{
                            //                                        Image("plannerOnboarding/Threads")
                            //                                            .resizable()
                            //                                            .aspectRatio(contentMode: .fit)
                            //                                            .overlay {
                            //                                                color.darken(by: 0.4).opacity(0.8)
                            //                                                    .clipShape(RoundedRectangle(cornerRadius: 13.4, style: .continuous))
                            //                                                    .blendMode(.color)
                            //                                            }
                            //
                            //                                            .drawingGroup()
                            //
                            //                                    }
                            //                                        .transition(.blur.animation(.smooth))
                            //                                    HStack(alignment: .center, spacing: 5){
                            //                                        Text(Image(systemName: planner_Style == .threads ? "checkmark.circle.fill" : "circle"))
                            //                                            .font(.body)
                            //                                            .foregroundStyle(planner_Style == .threads ? Color("Default/2") : Color.primary)
                            //
                            //                                        Text("Threads")
                            //                                            .font(.footnote)
                            //                                    }
                            //                                }
                            //                            }
                            //                            .buttonStyle(bounceButton())
                            //
                            //                            Button {
                            //                                withAnimation{
                            //                                    planner_Style = .blocks
                            //                                }
                            //                            } label: {
                            //                                VStack(spacing: 10){
                            //                                    ZStack{
                            //                                        Image("plannerOnboarding/Blocks")
                            //                                            .resizable()
                            //                                            .aspectRatio(contentMode: .fit)
                            //                                            .overlay {
                            //                                                color.darken(by: 0.4).opacity(0.5)
                            //                                                    .clipShape(RoundedRectangle(cornerRadius: 13.4, style: .continuous))
                            //                                                    .blendMode(.color)
                            //                                            }
                            //
                            //                                            .drawingGroup()
                            //
                            //                                    }
                            //                                    HStack(alignment: .center, spacing: 5){
                            //                                        Text(Image(systemName: planner_Style == .blocks ? "checkmark.circle.fill" : "circle"))
                            //                                            .font(.body)
                            //                                            .foregroundStyle(planner_Style == .blocks ? Color("Default/2") : Color.primary)
                            //
                            //                                        Text("Blocks")
                            //                                            .font(.footnote)
                            //                                    }
                            //                            }
                            //                            }
                            //                            .buttonStyle(bounceButton())
                            //
                            //
                            //                        }
                            //                        .frame(height: 260)
                            //                        .frame(maxWidth: .infinity)
                            //                        .padding(.horizontal, 13)
                            //                        .padding(.vertical, 10)
                            //                        .padding(.top, 4)
                            //                        .background {
                            //                            Color("NeoButton").opacity(0.6)
                            //                                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                            //                                .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.primary.opacity(colorScheme == .dark ? 0.15 : 0.08), lineWidth: 1.2))
                            //
                            //                        }
                            //                        .neoOutline()



                        }



                        //       }


                    }
                    .padding(.horizontal, 20)
                    .tint(color)
                    Spacer()
                }

            }

            .animation(.smooth, value: scaleWithDuration)
            .animation(.smooth, value: scaleMode)
            .animation(.smooth, value: planner_Style)
            .animation(.smooth, value: kyoPlus_mockSetting_planner_Style)

            .frame(maxWidth: .infinity, alignment: .leading)
            .shadow(color: .primary.opacity(0.05), radius: 13, x: 0, y: 5)
#if os(iOS)
    .safeAreaInset(edge: .top, content: {
        Color.clear.frame(height: 80)
    })
            .coordinateSpace(name: "scroll")
#endif
            .safeAreaInset(edge: .bottom) {
                               KyoPlusButtonBinding(color: color, kyoPlus_hasPlus: $kyoPlus_hasPlus, kyoPlus_showPurchaseScreen: $kyoPlus_showPurchaseScreen, text: "Upgrade to Kyo+ to further customise your planner", emoji: "🫧", rotation: -10 , position: CGPoint(x: 13 ,y: 8))
                                   .padding(.bottom, 15)
                                   .padding(.horizontal, -2)
//                                   .padding(.top, 40)
//                                   .background(BackdropBlurView(radius: 5).ignoresSafeArea())
                           }
            .amethystNavigationBar(title: "Planner", titleColor: .primary,   tintColor: color, compactMode: true, overrideType: .back, scrolled: $scrolled, content: {

            }, toolbar: {

            })
        }
        .tint(color)
    }


}

struct PlannerSettings_Previews: PreviewProvider {
    static var previews: some View {
        PlannerSettings(color: .mint)
    }
}




enum plannerCountDownMode : String, CaseIterable{
    case seconds = "Seconds"
    case minutes = "Minutes"
    case none = "None"


    public var icon: String {
        switch self{
        case .seconds:
            return "rectangle.expand.vertical"
        case .minutes:
            return "rectangle"
        case .none:
            return "rectangle"

        }
    }
}
