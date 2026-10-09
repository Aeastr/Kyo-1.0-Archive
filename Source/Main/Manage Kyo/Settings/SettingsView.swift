//
//  SettingsView.swift
//  KyoNeo
//
//  Created by Aether on 11/01/2023.
//

import SwiftUI
import AmethystUI
import RevenueCat
enum prefCol: String, Codable {
    case followSys
    case light
    case dark
}

class IconManager: ObservableObject {
    @Published var iconGrid: [[String]] = []

    init() {
        var icons = [
            "book", "book.pages", "book.closed", "text.book.closed", "bookmark", "paperclip", "pin", "text.word.spacing", "graduationcap", "pencil.and.ruler",
            "ruler", "backpack", "studentdesk", "testtube.2", "flask", "cross", "cross.vial", "syringe", "pill", "pills",
            "atom", "cube", "circle", "square", "rectangle", "capsule", "oval", "triangleshape", "diamond", "octagon",
            "hexagon", "pentagon", "seal", "rhombus", "shield", "hourglass", "compass.drawing", "x.squareroot", "sum", "function",
            "percent", "plusminus", "multiply", "divide", "equal", "pencil.line", "number", "numbersign", "12.lane", "textformat.12",
            "textformat.123", "textformat.size", "textformat", "text.justify.left", "list.dash", "signature", "shippingbox", "barometer",
            "photo.artframe", "photo", "camera", "camera.aperture", "camera.macro", "videoprojector", "paintbrush", "paintbrush.pointed", "paintpalette",
            "network", "pc", "cpu", "memorychip", "opticaldisc", "sdcard", "desktopcomputer", "computermouse", "laptopcomputer", "keyboard",
            "display", "server.rack", "smartphone", "headphones", "wrench.adjustable", "hammer", "level", "wrench.and.screwdriver", "fireworks", "party.popper",
            "globe", "globe.europe.africa", "globe.americas", "globe.asia.australia", "globe.central.south.asia", "water.waves", "leaf", "tree", "wind", "tornado",
            "snowflake", "rainbow", "sun.horizon", "moon", "stethoscope", "theatermasks", "movieclapper", "theatermask.and.paintbrush", "lightbulb.max",
            "puzzlepiece", "brain", "brain.filled.head.profile", "bubble.left", "exclamationmark.bubble", "questionmark.bubble", "quote.opening", "figure.walk",
            "figure.wave", "dumbbell", "soccerball", "baseball", "basketball", "football", "tennis.racket", "hockey.puck", "cricket.ball", "tennisball",
            "volleyball", "skateboard", "skis", "snowboard", "surfboard", "gym.bag", "rosette", "trophy", "medal", "oar.2.crossed", "sailboat",
            "flag.filled.and.flag.crossed", "scissors", "stopwatch"
        ].shuffled()

        let rows = 5
        let columns = 11

        var grid: [[String]] = []
        for _ in 0..<rows {
            var row: [String] = []
            for _ in 0..<columns {
                if let icon = icons.popLast() {
                    row.append(icon)
                }
            }
            grid.append(row)
        }

        self.iconGrid = grid
    }
}

#if os(iOS) || os(visionOS)
struct SettingsView<Content: View>: View {
    var color: Color = Color("4")

    @AppStorage("name") var name = ""
    @AppStorage("showOnboardNeo") var showOnboardNeo = true
    @AppStorage("debug") var debug: Bool = false
    @State var scrolled: Bool = false

    @Environment(\.colorScheme) private var colorScheme

    @AppStorage("appAccentColor") var appAccentColor = "Default"
    @AppStorage("multicolored") var multicolored = true
    @AppStorage("appAccentColorIndex") var appAccentColorIndex = 1
    
    let navigationButtons: () -> Content

    init(color: Color = Color("4") , @ViewBuilder navigationButtons: @escaping () -> Content = { Text("") }) {
        self.color = color
        self.navigationButtons = navigationButtons
    }

    @AppStorage("kyoPlus_hasPlus") var kyoPlus_hasPlus: Bool = false
    @AppStorage("data_iCloudSync") var data_iCloudSync: Bool = true

    var body: some View {
        NavigationSplitView {
            ZStack{
            ScrollView {
#if os(iOS)
                ScrollDetector(scrolled: $scrolled)
#endif
                Group{
                    GroupSection(label: "Personal") {
                        Text("Kyo will display your name in certain parts of the app")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        HStack(spacing: 0) {
                            Image(systemName: "character.textbox")
                                .font(Font.body.weight(.semibold))
                                .foregroundStyle(.primary)
                                .padding(.leading, 3)
                                .padding(.trailing, 5)


                            TextField("Enter your name..", text: $name)
                                .padding(.leading, 3)
                                .textContentType(.name)
#if !os(macOS)
                                .keyboardType(.asciiCapable)
#endif

                            //                        .onChange(of: scrollAmmount) { oldValue, newValue in
                            //
                            //                            if newValue > oldValue {
                            //
                            //                                focusedField = false
                            //                            }
                            //                        }
                        }


                        .neoSettingsCard()
                    }

                    //
                    //
                    //
//                    GroupSection(label: "iCloud") {
//                        SettingsGroup(color: ColorEngine().getXColor(3, colorScheme: colorScheme),
//                                      [GroupItem(label: "iCloud Sync", icon: "icloud", color: ColorEngine().getXColor(3, colorScheme: colorScheme), linkedBoolBinding: { Binding<Bool>(get: { self.data_iCloudSync }, set: { self.data_iCloudSync = $0 }) })
//                                      ])
//
//
//                    }
                    //
                    GroupSection(label: "Appearance & Customisation") {
                        SettingsGroup(color: ColorEngine().getColor((multicolored ? "\(appAccentColor)/1" : "\(appAccentColor)/\(appAccentColorIndex)"), colorScheme: colorScheme),
                                      [GroupItem(label: "Look and Feel", icon: "paintpalette.fill", destinationView: AnyView(Customise(color: color)))
                                      ])
                    }
                    //
                    //
                    GroupSection(label: "Display & Layout") {
                        let color = ColorEngine().getXColor(2, colorScheme: colorScheme)
                        SettingsGroup(color: color,
                                      [GroupItem(label: "Today", icon: "doc.text.image.fill", destinationView: AnyView(TodaySettings(color: color))),
                                       GroupItem(label: "Planner", icon: "calendar.day.timeline.left", destinationView: AnyView(PlannerSettings(color: color)))
                                      ])
                    }
                    //
                    //
                    GroupSection(label: "Data Management", locked: !kyoPlus_hasPlus) {
                        SettingsGroup(color: ColorEngine().getColor((multicolored ? "\(appAccentColor)/3" : "\(appAccentColor)/\(appAccentColorIndex)"), colorScheme: colorScheme),
                                      [GroupItem(label: "Import/Export Data", icon: "externaldrive.fill", destinationView: AnyView(ImportExportNewView(color: ColorEngine().getXColor(3, colorScheme: colorScheme)))), GroupItem(label: "Advanced", icon: "wrench.and.screwdriver.fill", destinationView: AnyView(AdvancedData(color: ColorEngine().getXColor(4, colorScheme: colorScheme))))
                                      ])
                    }
                    //
                    //
                    GroupSection(label: "Support") {
                        SettingsGroup(color: ColorEngine().getColor((multicolored ? "\(appAccentColor)/4" : "\(appAccentColor)/\(appAccentColorIndex)"), colorScheme: colorScheme),
                                      [
                                        GroupItem(label: "Contact Support", icon: "questionmark.circle.fill", link: URL(string: "mailto:kyosupport@aethers.world")),
                                       GroupItem(label: "View UELA", icon: "doc.text.fill", link: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")),
//                                        GroupItem(label: "View Privacy Policy", icon: "lock.shield", link: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")),
                                        GroupItem(label: "Copy App User ID", icon: "arrow.right.doc.on.clipboard", action: {
//                                            Text("\()")
                                            UIPasteboard.general.string = Purchases.shared.appUserID

                                        }),
//                                        GroupItem(label: "Report a Bug", icon: "ladybug", link: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")),
                                      ])

//                        The terms and conditions button leads to https://www.apple.com/legal/internet-services/itunes/dev/stdeula/, and is accessible in the paywall, and under settings
                    }
                    
                    if debug{
                        GroupSection(label: "Debug & Testing") {
                            SettingsGroup(color: ColorEngine().getColor((multicolored ? "\(appAccentColor)/4" : "\(appAccentColor)/\(appAccentColorIndex)"), colorScheme: colorScheme),
                                          [GroupItem(label: "Data debug list", icon: "ladybug.fill", destinationView: AnyView(coredatadebugoverivew())),
                                           GroupItem(label: "Show Onboarding", icon: "rectangle.portrait.fill", action: {
                                showOnboardNeo = true
                            })
                                          ])
                        }
                        .transition(.blur.animation(.smooth))
                    }



                }
                .padding(.horizontal, 20)
                .navigationDestination(for: GroupItem.self) { item in
                    item.destinationView
                }
                settingsHoldButton()
                    .italic()
                    .opacity(0.6)
                    .padding(.bottom, 10)
                    .padding(.top, 10)
            }
            .coordinateSpace(name: "scroll")
            .shadow(color: .primary.opacity(0.04), radius: 15, x: 0, y: 3)
#if os(iOS)
            .safeAreaInset(edge: .top, content: {
                Color.clear.frame(height: 80)
            })

#endif
        }
            .amethystNavigationBar(title: NSLocalizedString("settings-title", comment: ""), titleColor: .primary, tintColor: color,  compactMode: true, overrideType: .regular, scrolled: $scrolled, content: {
                                navigationButtons()
                            }, toolbar: {
                                Text("Kyo 1.0")
                            })



        } detail: {

        }
        .toolbar(removing: .sidebarToggle)
        .navigationSplitViewStyle(.balanced)
        .accentColor(color)
        .tint(color)
        
    }
}
#elseif os(macOS)
struct SettingsView: View {
    @AppStorage("terminology") var terminology: terminologySettings = .regular
    @State private var selectedTabIndex: Int = 1 // Set the default index to 1 (MyInfo)


    @AppStorage("debug") var debug: Bool = false

    @AppStorage("showOnboardNeo") var showOnboardNeo = true
    var color = Color.accentColor
    var body: some View{
        TabView(selection: $selectedTabIndex) {
            ScrollView{
               Text("General")
                    .sectionTitle()

                .padding(.horizontal, 20)

                    HStack{
                        Image(systemName: "rectangle.compress.vertical")
                            .frame(width: 20, alignment: .center)
                            .symbolRenderingMode(/*@START_MENU_TOKEN@*/.hierarchical/*@END_MENU_TOKEN@*/)
                            .foregroundColor(color)

                        VStack(alignment: .leading, spacing: 3){
                            Text("Terminology")
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text("Customise words Kyo uses")
                                .font(.caption2).opacity(0.5)
                        }
                        .padding(.leading, 1)
                        Picker("Terminology Mode", selection: $terminology) {
                            ForEach(terminologySettings.allCases, id:\.self){ mode in
                                Text(mode.name)
                                    .tag(mode)
                            }
                        }
                    }
                    .neoSettingsCard()
                    .padding(.horizontal, 20)


                MyInfo(color: color)

                if debug{
                    GroupSection(label: "Debug & Testing") {
                        SettingsGroup(color: color,
                                      [GroupItem(label: "Data debug list", icon: "ladybug", destinationView: AnyView(coredatadebugoverivew())),
                                       GroupItem(label: "Show Onboarding", icon: "rectangle.portrait", action: {
                            showOnboardNeo = true
                        })
                                      ])
                    }
                    .transition(.blur.animation(.smooth))
                }

    settingsHoldButton()
        .italic()
        .opacity(0.6)
        .padding(.bottom, 10)
        .padding(.top, 10)


            }
            .tabItem {
                Label("General", systemImage: "gear")
            }
            .tag(0) // Assign a tag to each tab


//
//            Customise(color: color)
//                .tabItem {
//                    Label("Look & Feel", systemImage: "paintpalette")
//                }
//                .tag(2) // Assign a tag to the third tab


            //            NotificationSettings(color: color, index: .constant(0))
            //                .tabItem {
            //                    Label("Notifications", systemImage: "app.badge")
            //                }
            //                .tag(3) // Assign a tag to the fourth tab

            //            AutomaticWeeks(color: color)
            //                .tabItem {
            //                    Label("Auto Rotation", systemImage: "repeat")
            //                }
            //                .tag(4) // Assign a tag to the fifth tab
            TodaySettings(color: color)
                .tabItem {
                    Label("Today", systemImage: "doc.text.image")
                }
                .tag(5) // Assign a tag to the sixth tab

            PlannerSettings(color: color)
                .tabItem {
                    Label("Planner", systemImage: "calendar.day.timeline.left")
                }
                .tag(6) // Assign a tag to the seventh tab

            ImportExportNewView(color: color)// Assuming you have an ImportExportSettings view
                .tabItem {
                    Label("Import & Export", systemImage: "externaldrive")
                }
                .tag(7) // Assign a tag to the eighth tab
//
//            ResetSettings(color: color)
//                .tabItem {
//                    Label("Reset", systemImage: "trash")
//                }
//                .tag(8) // Assign a tag to the ninth tab
//                .foregroundStyle(.red)

        }
        .frame(idealWidth: 650, idealHeight: 550)

    }
}
#endif

extension Color {
    static func random() -> Color {
        return Color(red: Double.random(in: 0...1), green: Double.random(in: 0...1), blue: Double.random(in: 0...1))
    }
}
