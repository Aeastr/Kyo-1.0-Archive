//
//  Customise.swift
//  KyoNeo
//
//  Created by Aether on 30/04/2023.
//

import SwiftUI
import AmethystUI
import RevenueCatUI
import UniformTypeIdentifiers

enum landscapeTabBarSide: String, CaseIterable{
    case left
    case right
}

struct Customise: View {
    var color: Color

    @State var startTime = Date()
    @State var endTime = Date()
    @AppStorage("showClassIconPlanner") var showClassIconPlanner = false

    @Environment(\.colorScheme) private var colorScheme

    @State var scrolled: Bool = false

    @State var showFileImport: Bool = false

    @AppStorage("showPageTopHue") var showPageTopHue = true

    @AppStorage("navigationFont") var fontDesign: navigationFont = .expanded
    @State var fontDesignState: navigationFont = .expanded

    @AppStorage("fontWeightIndex") private var fontWeightIndex: Int = 1
    @AppStorage("fontCaseIndex") private var fontCaseIndex: Int = 0

    @AppStorage("animationModeKey") private var animationsMode: AnimationMode = .enabled

    @AppStorage("activeAppIcon") var activeAppIcon: String = "AppIconDefault"

    @AppStorage("multicolored") var multicolored = true
    @AppStorage("appAccentColor") var appAccentColor = "Default"
    @AppStorage("appAccentColorIndex") var appAccentColorIndex = 1

    @AppStorage("swipeChangeTabs") var swipeChangeTabs = true

    @AppStorage("landscapeTabBarOrientation") var landscapeTabBarOrientation: landscapeTabBarSide = .left

    @AppStorage("accentImageName") var accentImageName = "doodle1"
    @Namespace var namepsace

    @Environment(\.accessibilityReduceMotion) var reduceMotion

    @AppStorage("Contrast") var contrast = false
    @AppStorage("tintPages") var tintPages = false
    @AppStorage("global_Compact") var global_Compact  = false

    @AppStorage("terminology") var terminology: terminologySettings = .regular

    @State var TEMPmulticolored = true
    @State var TEMPappAccentColor = "Default"
    @State var TEMPappAccentColorIndex = 0


@State private var fontWeightIndexState: Int = 1
@State private var fontCaseIndexState: Int = 1

    func exportTheme(){
        let settings: [String: Any] = [
                    "selectedTheme": appAccentColor,
                    "selectedImage": accentImageName,
                    "animationMode": animationsMode.rawValue,
                    "activeAppIcon": activeAppIcon,
                    "fontDesign": fontDesign.rawValue,
                    "fontWeightIndex": fontWeightIndex,
                    "fontCaseIndex": fontCaseIndex
                ]
        print("exporting !")
        // Convert the dictionary to JSON data
//        if let jsonData = try? JSONSerialization.data(withJSONObject: settings) {
//                    // Save JSON data to a temporary file
//                    let tempDirectory = FileManager.default.temporaryDirectory
//                    let jsonFilePath = tempDirectory.appendingPathComponent("Theme\(UUID()).json")
//
//                    do {
//                        try jsonData.write(to: jsonFilePath)
//
//                        // Create a ZIP archive with the JSON file
//                        let zipFilePath = tempDirectory.appendingPathComponent("Theme\(UUID()).zip")
//                        let fileManager = FileManager()
//                        try fileManager.zipItem(at: jsonFilePath, to: zipFilePath)
//
//                        // Rename the ZIP file to have the '.kyoTheme' extension
//                        let renamedZipFilePath = zipFilePath.deletingPathExtension().appendingPathExtension("kyoTheme")
//
//                        try fileManager.moveItem(at: zipFilePath, to: renamedZipFilePath)
//
//                        // Share the renamed ZIP archive
//                        let activityViewController = UIActivityViewController(activityItems: [renamedZipFilePath], applicationActivities: nil)
//                        UIApplication.shared.windows.first?.rootViewController?.present(activityViewController, animated: true, completion: nil)
//                    } catch {
//                        print("Error exporting settings: \(error)")
//                    }
//                }

    }
    var tintBinding: Binding<Bool> {
            Binding(
                get: { contrast ? true : tintPages },
                set: { tintPages = $0 }
            )
        }


    @State var TEMPaccentImageName = "doodle1"

    var body: some View {


            ScrollView {
                ScrollDetector(scrolled: $scrolled)
                content

                .frame(maxWidth: 700)

                Color.clear.frame(height: 1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .shadow(color: .primary.opacity(0.05), radius: 13, x: 0, y: 5)
            .coordinateSpace(name: "scroll")
            #if os(iOS)
            .safeAreaInset(edge: .top, content: {
                Color.clear.frame(height: 70)
            })
#endif
            .safeAreaInset(edge: .bottom, content: {
                KyoPlusButton(color: color, kyoPlus_hasPlus: .constant(true), text: "Upgrade to Kyo+ to access more customisation options")
                                .padding(.vertical, 5)
                                .padding(.top, 20)
                                .background(LinearGradient(stops: [Gradient.Stop(color: Color("bw").opacity(0.0), location: 0.11), Gradient.Stop(color: Color("bw").opacity(0.7), location: 0.6)], startPoint: .top, endPoint: .bottom))
            })
//            .overlay(alignment: .top){
//                FluidNavigationBar(title: "Look & Feel", titleColor: .primary, tintColor: color, compactMode: true, type: .back, scrolled: $scrolled, content: {
//
//                }, toolbar: {
//
//                })
//                .fluidAccentImage(Image(TEMPaccentImageName))
////                Image(systemName: "paintpalette")
////                    .foregroundStyle(color)
////                    .padding(.trailing, 15)
////                    .font(.headline)
//                }
            .amethystNavigationBar(title: "Look & Feel", titleColor: .primary, tintColor: Color(TEMPmulticolored ? "\(TEMPappAccentColor)/5" : "\(TEMPappAccentColor)/\(TEMPappAccentColorIndex)"), compactMode: true, scrolled: $scrolled, content: {

            }, toolbar: {

            })
#if os(iOS) || os(visionOS)
//            .fluidTitleDesign(fontDesignState.design)
//            .fluidTitleWidth(fontDesignState.wdith)
//            .fluidTitleWeight(fontWeights[min(max(fontWeightIndexState, 0), 3)].weight)
//            .fluidTitleOpenDyslexic(fontDesignState == .OpenDyslexic)
            .fluidAccentImage(Image(TEMPaccentImageName))
////
//            .fluidTextCase(fontCaseIndexState == 1 ? .uppercase : fontCaseIndexState == 2 ? .lowercase : .none)
#endif

        .tint(Color(TEMPmulticolored ? "\(TEMPappAccentColor)/5" : "\(TEMPappAccentColor)/\(TEMPappAccentColorIndex)"))
    }

    // FIX: Archive access is unconditional; do not read or update a persisted purchase flag.

    private var kyoPlus_hasPlus: Bool { true }

    @State private var kyoPlus_showPurchaseScreen: Bool = false

    var content: some View {
        Group{

            #if os(iOS) || os(visionOS)
            #if os(iOS)

            #endif
//accentColorOptions



            HStack{
                if !kyoPlus_hasPlus{
                                   Image(systemName: "lock")
                                       .framelessSectionTitle()
                               }

                Text("Accent Colour")
                    .sectionTitle()
                Spacer()
#if os(iOS)
                if kyoPlus_hasPlus{
                    Menu {
                    Picker(selection: $TEMPappAccentColor) {
                        ForEach(accentColorOptions, id: \.name){ option in
                            Text(option.name)
                        }
                    } label: {

                    }

                } label: {

                    Text(TEMPappAccentColor + " \(!TEMPmulticolored ? "\(TEMPappAccentColorIndex)" : "")")
                        .font(Font.caption.weight(.semibold))

                        .contentTransition(.numericText())
                        .textCase(.uppercase)
                        .fixedSize()
                        .animation(.smooth)




                }

                .animation(.smooth)
            }
                else{
                    Button(action: {
                                            kyoPlus_showPurchaseScreen.toggle()
                                        }, label: {
                                            // Text("Get Kyo+")
                                        })
                                                        .framelessSectionTitle()
                }
            #endif

        }
            
        .padding(.horizontal, 20)
        AccentColor(TEMPmulticolored: $TEMPmulticolored, TEMPappAccentColor: $TEMPappAccentColor, TEMPappAccentColorIndex: $TEMPappAccentColorIndex, kyoPlus_hasPlus: .constant(true))
            .padding(.horizontal, 20)
            .disabled(!kyoPlus_hasPlus)
            .opacity(!kyoPlus_hasPlus ? 0.5 : 1.0)
            .onTapGesture {
                        if !kyoPlus_hasPlus{
                            kyoPlus_showPurchaseScreen.toggle()
                        }
                    }

            #if os(visionOS)
            Menu {
                Picker(selection: $TEMPappAccentColor) {
                    ForEach(accentColorOptions, id: \.name){ option in
                                        Text(option.name)
                                    }
                } label: {

                }

            } label: {

                    Text(TEMPappAccentColor + " \(!TEMPmulticolored ? "\(TEMPappAccentColorIndex)" : "")")
                        .font(Font.caption.weight(.semibold))

                .contentTransition(.numericText())
                    .textCase(.uppercase)
                    .fixedSize()
                    .animation(.smooth)
            }
            .clipShape(Capsule())
            .animation(.smooth)
            .frame(maxWidth: .infinity, alignment: .topTrailing)
            .frame(height: 0)
            .offset(x: -10)
            .offset(y: -10)
            .shadow(color: .black.opacity(0.22), radius: 15)
            #endif
            #if os(iOS)
            HStack{
                            if !kyoPlus_hasPlus{
                                               Image(systemName: "lock")
                                                   .framelessSectionTitle()
                                           }

                            Text("Accent Image")
                                .sectionTitle()
                            Spacer()
            #if os(iOS)
                            if !kyoPlus_hasPlus{
                                Button(action: {
                                                        kyoPlus_showPurchaseScreen.toggle()
                                                    }, label: {
                                                        // Text("Get Kyo+")
                                                    })
                                                                    .framelessSectionTitle()
                            }

                        #endif

                    }
                    .padding(.horizontal, 20)

            AccentImage(TEMPaccentImageName: $TEMPaccentImageName, color: Color(TEMPmulticolored ? "\(TEMPappAccentColor)/5" : "\(TEMPappAccentColor)/\(TEMPappAccentColorIndex)"))
                .padding(.horizontal, 20)
                .disabled(!kyoPlus_hasPlus)
                            .opacity(!kyoPlus_hasPlus ? 0.5 : 1.0)
                            .onTapGesture {
                                        if !kyoPlus_hasPlus{
                                            kyoPlus_showPurchaseScreen.toggle()
                                        }
                                    }
            #endif

            GroupSection(label: ("Terminology")) {
                SettingsGroup(color: Color(TEMPmulticolored ? "\(TEMPappAccentColor)/5" : "\(TEMPappAccentColor)/\(TEMPappAccentColorIndex)"), [GroupItem(label: "Terminology", description: "Customise words Kyo uses", icon: "rectangle.compress.vertical", customContent: AnyView(
                    Picker("Terminology Mode", selection: $terminology) {
                        ForEach(terminologySettings.allCases, id:\.self){ mode in
                            Text(mode.name)
                                .tag(mode)
                        }
                    }
                ))], background: true)
            }
            .padding(.horizontal, 20)

//            #if os(iOS)
//        Text("Animations")
//            .sectionTitle()
//            .padding(.horizontal, 20)
//            AnimationsView(color: Color(TEMPmulticolored ? "\(TEMPappAccentColor)/5" : "\(TEMPappAccentColor)/\(TEMPappAccentColorIndex)"))
//
//
//            if reduceMotion{
//                Label("Reduce Motion Enabled in System Settings", systemImage: "exclamationmark.triangle")
//
//                    .padding(.horizontal, 20)
//                    .padding(.top, 5)
//                    .font(Font.caption.weight(.regular))
//                    .opacity(0.6)
//            }
//
//#endif
            #endif
            #if os(iOS)
            HStack{
                if !kyoPlus_hasPlus{
                    Image(systemName: "lock")
                        .framelessSectionTitle()
                }
                Text("App Icon")
                    .sectionTitle()
                Spacer()
                if !kyoPlus_hasPlus{
                    Button(action: {
                        kyoPlus_showPurchaseScreen.toggle()
                    }, label: {
                        // Text("Get Kyo+")
                    })
                                    .framelessSectionTitle()
                                    .fullScreenCover(isPresented: $kyoPlus_showPurchaseScreen, onDismiss: {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {

                                            // FIX: No purchase check or access-state write is needed; Kyo+ is permanently unlocked.

                                        }
                                    }, content: {
                                        KyoPlus()
                                    })


                }


            }
            .padding(.horizontal, 20)
            .onAppear{

                // FIX: No purchase check or access-state write is needed; Kyo+ is permanently unlocked.

            }
        Group{

            AppIcon(color: Color(TEMPmulticolored ? "\(TEMPappAccentColor)/5" : "\(TEMPappAccentColor)/\(TEMPappAccentColorIndex)"))
        }
        
        .padding(.horizontal, 20)
        .disabled(!kyoPlus_hasPlus)
        .opacity(!kyoPlus_hasPlus ? 0.5 : 1.0)
        .onTapGesture {
            if !kyoPlus_hasPlus{
                kyoPlus_showPurchaseScreen.toggle()
            }
        }
            #endif
#if os(iOS)
            ZStack {

                VStack {

                    HStack{
                                    if !kyoPlus_hasPlus{
                                        Image(systemName: "lock")
                                            .framelessSectionTitle()
                                    }
                                    Text("Title Style")
                                        .sectionTitle()
                                    Spacer()
                                    if !kyoPlus_hasPlus{
                                        Button(action: {
                                            kyoPlus_showPurchaseScreen.toggle()
                                        }, label: {
                                            // Text("Get Kyo+")
                                        })
                                                        .framelessSectionTitle()


                                    }


                                }

                        .padding(.horizontal, 20)

                    ForEach(navigationFont.allCases , id: \.self){ font in
                        if font == .OpenDyslexic{
                                                            Divider()
                                                                .padding(.horizontal, 30)
                                                                .padding(.vertical, 5)
                                                        }


                        Button {
                            withAnimation(.smoothCard){
                                fontDesign = font
                            }

                        } label: {
                            HStack{

                                if #available(iOS 16.0, *) {
                                    Text(font.rawValue)

                                        .textCase((fontCaseIndex == 1 ? .uppercase : fontCaseIndex == 2 ? .lowercase : nil))


                                        .font(font != .OpenDyslexic ?  .system(.title3, design: font.design) : .custom("OpenDyslexic-Regular", size: 18, relativeTo: .title))
                                        .fontWidth(font.wdith)
                                        .fontWeight(fontWeights[fontWeightIndex].weight)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    if font.wdith == .expanded{
                                        Text("Default")
                                            .font(.caption)
                                    }
                                    if fontDesign == font{
                                        Spacer()
                                        Image(systemName: "checkmark")
                                    }
                                }
                                else{
                                    Text(font.rawValue)
                                        .textCase(.uppercase)
                                        .font(.system(size: 20, weight: fontWeights[fontWeightIndex].weight, design: font.design))


                                        .frame(maxWidth: .infinity, alignment: .leading)

                                    if fontDesign == font{
                                        Spacer()
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                            .animation(.smoothCard, value: fontDesignState)
                            .animation(.smoothCard, value: fontWeightIndexState)
                            .animation(.smoothCard, value: fontCaseIndexState)
                        }
                        .buttonStyle(FlatButton(color: Color(TEMPmulticolored ? "\(TEMPappAccentColor)/5" : "\(TEMPappAccentColor)/\(TEMPappAccentColorIndex)"), background: fontDesign == font ? true : false))
                        .padding(.horizontal, 20)
                        .disabled(font != navigationFont.OpenDyslexic && font != navigationFont.expanded ? !kyoPlus_hasPlus : false)
                        .opacity(font != navigationFont.OpenDyslexic && font != navigationFont.expanded ? !kyoPlus_hasPlus ? 0.5 : 1.0 : 1.0)
                    }
//                    .onAppear{
//                        fontDesignState = fontDesign
//                    }

//                    .onDisappear{
//                        fontDesign = fontDesignState
//                    }

                    HStack{
                                                        if !kyoPlus_hasPlus{
                                                            Image(systemName: "lock")
                                                                .framelessSectionTitle()
                                                        }
                                                        Text("Title Weight")
                                                            .sectionTitle()
                                                        Spacer()
                                                        if !kyoPlus_hasPlus{
                                                            Button(action: {
                                                                kyoPlus_showPurchaseScreen.toggle()
                                                            }, label: {
                                                                // Text("Get Kyo+")
                                                            })
                                                                            .framelessSectionTitle()

                                                        }


                                                    }
                        .padding(.horizontal, 20)

                    TitleWeight(fontWeightIndexState: $fontWeightIndexState, color: Color(TEMPmulticolored ? "\(TEMPappAccentColor)/5" : "\(TEMPappAccentColor)/\(TEMPappAccentColorIndex)"))
                        .disabled(!kyoPlus_hasPlus)
                        .opacity(!kyoPlus_hasPlus ? 0.5 : 1.0)

                    .padding(.horizontal, 20)

                    HStack{
                                                                            if !kyoPlus_hasPlus{
                                                                                Image(systemName: "lock")
                                                                                    .framelessSectionTitle()
                                                                            }
                                                                            Text("Title Case")
                                                                                .sectionTitle()
                                                                            Spacer()
                                                                            if !kyoPlus_hasPlus{
                                                                                Button(action: {
                                                                                    kyoPlus_showPurchaseScreen.toggle()
                                                                                }, label: {
                                                                                    // Text("Get Kyo+")
                                                                                })
                                                                                                .framelessSectionTitle()

                                                                            }


                                                                        }
                        .padding(.horizontal, 20)

                    TitleCase(fontCaseIndexState: $fontCaseIndexState, color: Color(TEMPmulticolored ? "\(TEMPappAccentColor)/5" : "\(TEMPappAccentColor)/\(TEMPappAccentColorIndex)"))
                        .disabled(!kyoPlus_hasPlus)
                        .opacity(!kyoPlus_hasPlus ? 0.5 : 1.0)

                    .padding(.horizontal, 20)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .shadow(color: .primary.opacity(0.05), radius: 13, x: 0, y: 5)

    //            .overlay(
    //                NavigationBar(type: .backButton,  title: "Title Font", color: color, scrolled: $scrolled, content: {
    //
    //                }, toolbar: {
    //
    //                })
    //            )
            }
#endif
    }
    }
}
let fontWeights: [(name: String, weight: Font.Weight)] = [
//    ("Light", .light),
    ("Regular", .regular),
    ("Semibold", .semibold),
//    ("Bold", .bold),
    ("Heavy", .heavy),
]

enum fontCaseEnum{
    case regular
    case capitalised
    case lowercase
}

let fontCase: [(name: String, case: fontCaseEnum)] = [
//    ("Light", .light),
    ("Regular", .regular),
    ("Capitalised", .capitalised),
//    ("Bold", .bold),
    ("Lowercase", .lowercase),
]
//struct TitleFont: View {
//    var color: Color
//    @AppStorage("Contrast") var contrast = false
//    @AppStorage("tintPages") var tintPages = false
//
//    @State var startTime = Date()
//    @State var endTime = Date()
//
//    @Environment(\.colorScheme) private var colorScheme
//    @State var scrolled: Bool = false
//    @AppStorage("navigationFont") var fontDesign: navigationFont = .expanded
//
//    @AppStorage("fontWeightIndex") private var fontWeightIndex: Int = 1
//    @AppStorage("fontCaseIndex") private var fontCaseIndex: Int = 0
//
//        // Create an array of Font.Weight values
//    @State private var fontWeightIndexState: Int = 1
//    @State private var fontCaseIndexState: Int = 1
//
//
//    var body: some View {
//
//    }
//
//}

struct Customise_Previews: PreviewProvider {
    static var previews: some View {
        Customise(color: Color(hex: "94B8FA"))
    }
}
