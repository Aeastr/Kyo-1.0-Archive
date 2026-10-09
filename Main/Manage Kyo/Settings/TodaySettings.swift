//
//  TodaySettings.swift
//  KyoNeo
//
//  Created by Aether on 13/07/2023.
//

import SwiftUI
import AmethystUI

struct TodaySettings: View {
    var color: Color

    @State var startTime = Date()
    @State var endTime = Date()
    @AppStorage("showClassIconPlanner") var showClassIconPlanner = false

    @Environment(\.colorScheme) private var colorScheme
    @State var scrolled: Bool = false
    @AppStorage("navigationFont") var fontDesign: navigationFont = .expanded

    @AppStorage("fontWeightIndex") private var fontWeightIndex: Int = 1

    @AppStorage("Contrast") var contrast = false
    @AppStorage("tintPages") var tintPages = false
    @AppStorage("global_Compact") var global_Compact  = false

    
    @AppStorage("countdownOnlyCurrent") var countdownOnlyCurrent = true

    @AppStorage("allowCustomDayToday") var allowCustomDayToday = false

    //plannerCountDownMode
    @AppStorage("showLength") var showLength = false
    @AppStorage("planner_CountDown") var planner_CountDown : Bool = true


    @AppStorage("today_viewSettings_twoColumn") var today_viewSettings_twoColumn : Bool = true

    #if !os(macOS)
    func getDeviceType() -> UIUserInterfaceIdiom {
        let deviceType = UIDevice.current.userInterfaceIdiom
        return deviceType
    }
    #endif
    var body: some View {
        ZStack {
            pageTopHue(color: color)
        Color("1")
            .opacity(contrast ? colorScheme == .dark ?  0.15 : 0.08 : tintPages ? colorScheme == .dark ? 0.1 : 0.03 : 0)
            .ignoresSafeArea()
            ScrollView {
                ScrollDetector(scrolled: $scrolled)

                GroupSection {
                    SettingsGroup(
                        [
                            GroupItem(label: "Show Map", icon: "map.fill", color: color, linkedBoolBinding: { Binding<Bool>(get: { self.showClassIconPlanner }, set: { self.showClassIconPlanner = $0 }) }),
                            GroupItem(label: "Compact Mode", description: "Entries will take up less space", icon: "rectangle.compress.vertical", color: color, linkedBoolBinding: { Binding<Bool>(get: { self.global_Compact }, set: { self.global_Compact = $0 }) })
                        ], background: true, dividers: true)
                }
                .padding(.horizontal, 20)

                #if !os(macOS)
                if getDeviceType() != .phone{
                    GroupSection {
                        SettingsGroup(
                            [
                                GroupItem(label: "2 Column Layout", description: "Split Content into 2 columns", icon: "square.split.2x1", color: color, linkedBoolBinding: { Binding<Bool>(get: { self.today_viewSettings_twoColumn }, set: { self.today_viewSettings_twoColumn = $0 }) })
                            ], background: true, dividers: true)
                    }
                    .padding(.horizontal, 20)
                }
                #else
                GroupSection {
                    SettingsGroup(
                        [
                            GroupItem(label: "2 Column Layout", description: "Split Content into 2 columns", icon: "square.split.2x1", color: color, linkedBoolBinding: { Binding<Bool>(get: { self.today_viewSettings_twoColumn }, set: { self.today_viewSettings_twoColumn = $0 }) })
                        ], background: true, dividers: true)
                }
                .padding(.horizontal, 20)
                #endif

          
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .shadow(color: .primary.opacity(0.05), radius: 13, x: 0, y: 5)

#if os(iOS)

            .coordinateSpace(name: "scroll")
            .safeAreaInset(edge: .top, content: {
                Color.clear.frame(height: 80)
            })
#endif

            .amethystNavigationBar(title: "Today Settings", titleColor: .primary,   tintColor: color, compactMode: true, overrideType: .back, scrolled: $scrolled, content: {

                }, toolbar: {
                    
                })
                

        }
        .tint(color)
    }


}
