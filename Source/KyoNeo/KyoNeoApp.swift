//
//  KyoNeoApp.swift
//  KyoNeo
//
//  Created by Aether on 18/11/2022.
//


import SwiftUI
import RevenueCat
#if canImport(WidgetKit)
import WidgetKit
#endif
import CoreData
import AmethystUI
#if canImport(RiveRuntime)
import RiveRuntime
#endif

extension Color {
    func rgbComponents() -> (red: Double, green: Double, blue: Double)? {
        guard let cgColor = self.cgColor else { return nil }
        let components = cgColor.components?.map { Double($0) }

        if let components = components, components.count == 4 {
            return (red: components[0], green: components[1], blue: components[2])
        } else if let components = components, components.count == 2 {
            return (red: components[0], green: components[0], blue: components[0])
        }

        return nil
    }
}

struct Menus: Commands {
#if os(iOS)
    @AppStorage("planner_View") var planner_View: plannerViewMode = .pages
#else
    @AppStorage("planner_View") var planner_View: plannerViewMode = .week
#endif
    @AppStorage("planner_Style") var planner_Style:  typeEntryViewMode = .blocks
    @AppStorage("global_Compact") var global_Compact  = false
    @AppStorage("selectedItem") var selectedItem: Int = 1 // Set the default selection
    @AppStorage("showTodayMap") var showTodayMap = false

    var body: some Commands {
        EmptyCommands()
        SidebarCommands()
        ToolbarCommands()
        CommandGroup(before: .newItem) {
            Button {

            } label: {
                Text("New Entry")
            }
            Button {

            } label: {
                Text(VariableDataNames().newClassName())
            }

        }
        CommandGroup(before: .textEditing) {
            Button {

            } label: {
                Text("Edit Planner")
            }
            Button {

            } label: {
                Text("Edit Weeks")
            }

        }
        CommandGroup(before: .toolbar) {
            Section("Today"){

                    Picker(selection: $planner_Style, label: Label("View", systemImage: "eye")) {
                        ForEach(typeEntryViewMode.allCases, id:\.self){ mode in
                            VStack{
                                if mode == .threads{
                                    Label("\(mode.rawValue.capitalized)", image: mode.icon)
                                }
                                else{
                                    Label("\(mode.rawValue.capitalized)", systemImage: mode.icon)
                                }
                            }
                            .tag(mode)
                        }
                    }
                

                    Toggle(isOn: $showTodayMap) {
                        Label("Show Map", systemImage: "map")
                    }
            }
            Section("Planner"){
                weekDaySelector(color: Color.primary , scrolled: .constant(false))
                Picker(selection: $planner_Style, label: Label("Style", systemImage: "paintbrush")) {
                    ForEach(typeEntryViewMode.allCases, id:\.self){ mode in
                        VStack{
                            if mode == .threads{
                                Label("\(mode.rawValue.capitalized)", image: mode.icon)
                            }
                            else{
                                Label("\(mode.rawValue.capitalized)", systemImage: mode.icon)
                            }
                        }
                        .tag(mode)
                    }
                }
                Picker(selection: $planner_View, label: Label("View", systemImage: "eye")) {
                    ForEach(plannerViewMode.allCases, id:\.self){ mode in
                        VStack{
                            Label("\(mode.rawValue.capitalized)", systemImage: mode.icon)
                        }
                        .tag(mode)
                    }
                }
                if planner_Style == .blocks || planner_View == .week{
                    Toggle(isOn: $global_Compact, label: {
                        Label("Compact Mode", systemImage: "rectangle.arrowtriangle.2.inward")
                    })
                }
            }
        }
    }
}

#if !os(macOS)
import UIKit //since UIFont is part of UIKit
#endif

@main
struct KyoNeoApp: App {

#if !os(macOS)
    @State private var overlayWindow: PassThroughWindow?
    #endif
    let persistenceController = PersistenceController.shared

    @Environment(\.colorScheme) private var colorScheme
//    @Environment(\.scenePhase) var scenePhase

    @AppStorage("buildNum") var buildNum = 0
    @AppStorage("showOnboardNeo") var showOnboardNeo = true
    @AppStorage("firstLaunch") private var firstLaunch: Bool = true
    @AppStorage("colorSchemeMode") private var colorSchemeMode: ColorSchemeMode = .system

    @AppStorage("selectedTabIndex") var selectedTabIndex: Int = 2 // Holds the currently selected tab
    @AppStorage("appAccentColor") var appAccentColor = "Default"
    @AppStorage("multicolored") var multicolored = true
    @AppStorage("appAccentColorIndex") var appAccentColorIndex = 1

    @AppStorage("accentImageName") var accentImageName = "doodle1"

    @AppStorage("navigationFont") var fontDesign: navigationFont = .expanded
    @AppStorage("fontWeightIndex") private var fontWeightIndex: Int = 1
    @AppStorage("fontCaseIndex") private var fontCaseIndex: Int = 0



    @State var showOverlay = true
    @State var loadApp = true
    @State var finishAnim = false   

    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass

    // FIX: No purchase SDK setup or launch-time entitlement writes are needed in the unlocked archive.

    func getDeviceType() -> UIUserInterfaceIdiom {
        let deviceType = UIDevice.current.userInterfaceIdiom
        return deviceType
    }

    var body: some Scene {
        WindowGroup {

//            KyoPlus(color: .red)
            Group {
                #if !os(macOS)
                if (!showOnboardNeo){
                    NavigationHandler()
                    .animation(.smooth, value: showOverlay)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .transition(.blurWithoutScale)

                }
                else{
                    if getDeviceType() == .phone{
                        neoOnboard()
                            .environment(\.managedObjectContext, persistenceController.container.viewContext)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    else{
                        VStack{
                            Text("Awaiting Setup")
                        }
                            .sheet(isPresented: .constant(true)) {
                                neoOnboard()
                                #if os(visionOS)



                                    .frame(minWidth: 800, minHeight: 900)
                                #endif
                                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .interactiveDismissDisabled()
                            }
                    }


                }
                #else
                NavigationHandler()
                .animation(.smooth, value: showOverlay)

                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .transition(.blurWithoutScale)
               
                .sheet(isPresented: $showOnboardNeo) {
                    neoOnboard()
                        .environment(\.managedObjectContext, persistenceController.container.viewContext)
                        .frame(minWidth: 400, idealWidth: 500, maxWidth: 550, minHeight: 700, idealHeight: 800, maxHeight: 820)
                        .interactiveDismissDisabled()
                }
                #endif

            } 
            #if os(macOS)
            .frame(minWidth: 680, idealWidth: 725, maxWidth: .infinity, minHeight: 700, maxHeight: .infinity)
            #elseif os(visionOS)


            
            .frame(minWidth: 800, minHeight: 900)
            #elseif os(macOS)


            #endif
            #if !os(visionOS) && !os(macOS)
            .onAppear(perform: {
                                if overlayWindow == nil {
                                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                                        let overlayWindow = PassThroughWindow(windowScene: windowScene)
                                        overlayWindow.backgroundColor = .clear
                                        overlayWindow.layer.backgroundFilters = []
                                        overlayWindow.tag = 0320
                                        let controller = StatusBarBasedController()
                                        controller.view.backgroundColor = .clear
                                        overlayWindow.rootViewController = controller
                                        overlayWindow.isHidden = false
                                        overlayWindow.isUserInteractionEnabled = true
                                        self.overlayWindow = overlayWindow
                                        //print("Overlay Window Created")
                                    }
                                }
                            })

            #endif


#if os(iOS)
            .fluidTitleDesign(fontDesign.design)
            .fluidTitleWidth(fontDesign.wdith)
            .fluidTitleWeight(fontWeights[min(max(fontWeightIndex, 0), 3)].weight)
            .fluidTitleOpenDyslexic(fontDesign == .OpenDyslexic)
            .fluidAccentImage(Image(accentImageName))
            .fluidTextCase(fontCaseIndex == 1 ? .uppercase : fontCaseIndex == 2 ? .lowercase : .none)
#endif


//            .preferredColorScheme(colorSchemeMode == .dark ? .dark : colorSchemeMode == .light ? .light : nil)
//            .onAppear{
//                if !(buildNum == 52){
//                    print("force showing")
//                    showOnboardNeo = true
//                }
//            }
//            .onChange(of: scenePhase) { newPhase in
//                if newPhase == .active {
//                    print("scenePhase Active")
//                } else if newPhase == .inactive {
//                    print("scenePhase Inactive")
//#if canImport(WidgetKit)
//                    WidgetCenter.shared.reloadAllTimelines()
//                    #endif
//                } else if newPhase == .background {
//                    print("scenePhase Background")
//#if canImport(WidgetKit)
//                    WidgetCenter.shared.reloadAllTimelines()
//                    #endif
//                }
//            }

        }

        #if os(visionOS)

        .windowResizability(.contentSize)
        #endif
#if os(macOS)

        .windowResizability(.contentSize)
        .defaultSize(width: 350, height: 570)
        .commands{
            Menus()
        }
#endif
#if os(macOS)


        Settings {
            NavigationStack{
                SettingsView()

            }

            .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
#endif

    }


}

#if !os(macOS)
class StatusBarBasedController: UIViewController {
    var statusBarStyle: UIStatusBarStyle = .default
    var isStatusBarHidden: Bool = false // New property to control status bar visibility

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return statusBarStyle
    }

    override var prefersStatusBarHidden: Bool { // Override to control the visibility
        return isStatusBarHidden
    }
}
fileprivate class PassThroughWindow: UIWindow {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let view = super.hitTest(point, with: event) else { return nil }
        return rootViewController?.view == view ? nil : view
    }
}
#endif

//import UIKit //since UIFont is part of UIKit



#if os(iOS) || os(visionOS)
import UIKit
extension UIFont { //to add more parameters to UIFont elements
    func withOptions(weight: Double, width: Double) -> UIFont {  //the function will define our new parameter
        let newDescriptor = fontDescriptor.addingAttributes([.traits: [ //descriptors go here, such as weight and width; newDescriptor is created to allow simple modification, rather than creating a variable, it's value could be given directly
            UIFontDescriptor.TraitKey.weight: weight, //adds weight as a descriptor
            UIFontDescriptor.TraitKey.width: width, //aads width as a descriptor
                                                                      ]])
        return UIFont(descriptor: newDescriptor, size: pointSize) //returns UIFont with the new propeteries
    }
    func withOptions(weight: Double) -> UIFont {  //the function will define our new parameter
        let newDescriptor = fontDescriptor.addingAttributes([.traits: [ //descriptors go here, such as weight and width; newDescriptor is created to allow simple modification, rather than creating a variable, it's value could be given directly
            UIFontDescriptor.TraitKey.weight: weight
                                                                      ]])
        return UIFont(descriptor: newDescriptor, size: pointSize) //returns UIFont with the new propeteries
    }
}

#elseif os(macOS)

import AppKit
extension NSFont { //to add more parameters to UIFont elements
    func withOptions(weight: Double, width: Double) -> NSFont {  //the function will define our new parameter
        let newDescriptor = fontDescriptor.addingAttributes([.traits: [ //descriptors go here, such as weight and width; newDescriptor is created to allow simple modification, rather than creating a variable, it's value could be given directly
            NSFontDescriptor.TraitKey.weight: weight, //adds weight as a descriptor
            NSFontDescriptor.TraitKey.width: width, //aads width as a descriptor
                                                                      ]])
        return NSFont(descriptor: newDescriptor, size: pointSize) ?? NSFont.systemFont(ofSize: 20) //returns UIFont with the new propeteries
    }
}
#endif

//VStack{
//    //228    222    242
//    let origin = Color(red: 0.9, green: 0.87, blue: 0.95)
//    ZStack{
//        origin.frame(height: 200)
//        if let rgb = origin.rgbComponents() {
//                        Text("Original, Red: \(rgb.red), Green: \(rgb.green), Blue: \(rgb.blue)")
//                .foregroundColor(origin.darken(by: -0.6))
//                .bold()
//                    } else {
//                        Text("Could not retrieve RGB values.")
//                    }
//    }
//
//
//
//
//    let col = origin.moreSaturated(factor: 3)
//    ZStack{
//        col.frame(height: 200)
//        if let rgb = col.rgbComponents() {
//            Text("Adjusted, Red: \(rgb.red), Green: \(rgb.green), Blue: \(rgb.blue)")
//                .foregroundColor(col.darken(by: -0.8))
//                .bold()
//        } else {
//            Text("Could not retrieve RGB values.")
//        }
//
//
//    }
//}
