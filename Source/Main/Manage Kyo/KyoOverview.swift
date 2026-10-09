// FIX: RevenueCat is removed from the unlocked archive; original purchase code is on original-source.
//
//  KyoOverview.swift
//  KyoNeo
//
//  Created by Aether on 23/12/2023.
//

import SwiftUI
import AmethystUI
import StoreKit

// FIX: Purchase-status checking is removed from main; historical implementation is on original-source.

//struct KyoOverview: View {
//    @AppStorage("kyoPlus_hasPlus") var kyoPlus_hasPlus: Bool = false
//    // Amethyst
//    var color: Color = Color.accentColor
//    @State private var scrolled: Bool = false
//   
//    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)]) var teachers: FetchedResults<TeacherEntity>
//    @FetchRequest(sortDescriptors: []) var classes: FetchedResults<ClassEntity>
//    @FetchRequest(sortDescriptors: []) var splits: FetchedResults<SplitterEntity>
//
//    @State private var kyoPlus_showPurchaseScreen: Bool = false
//    @State private var showClasManage: Bool = false
//    @State private var path = NavigationPath()
//    
//    @AppStorage("showOnboardNeo") var showOnboardNeo = true
//    @AppStorage("buildNum") var buildNum = 0
//
//    @Environment(\.colorScheme) private var colorScheme
//    @AppStorage("showSettingsPage") var showSettingsPage: Bool = false
//
//
//    var body: some View {
//        ZStack{
//            ScrollView {
//                #if !os(visionOS)
//                ScrollDetector(scrolled: $scrolled)
//                    .onChange(of: path) {
//                        print(path)
//                    }
//                #endif
//
//
////                Button {
//////                    kyoPlus_showPurchaseScreen.toggle()
////                } label: {
////                    VStack(alignment: .leading){
////                        Text("Kyo releasing soon")
////                            .bold()
////                            .foregroundStyle(Color.getForegroundColor(color: color))
////                            .lineLimit(2)
////                            .minimumScaleFactor(0.5)
////                    }
////                    .frame(maxWidth: .infinity, alignment: .leading)
////                    .padding(.trailing, 45)
////
////                }
////                .buttonStyle(PolishedButton(color: color, background: true))
////                .overlay(alignment: .bottomTrailing, content: {
////                    Text("⭐")
////                        .font(.system(size: 40))
////                        .stroke(color: Color.white, width: 4)
////                        .overlay(content: {
////                            LinearGradient(stops:
////                                            [
////                                                Gradient.Stop(color: Color.clear, location: 0.0),
////                                                Gradient.Stop(color: Color.white.opacity(0.6), location: 0.7),
////                                                Gradient.Stop(color: Color.clear, location: 1.0)
////                                            ],
////                                           startPoint: .top, endPoint: .bottom)
////                            .mask {
////                                Text("⭐")
////                                    .font(.system(size: 60))
////                            }
////                        })
////                        .rotationEffect(Angle(degrees: -20))
////                        .offset(x: 13, y: 11)
////                        .shadow(color: .black.opacity(0.15), radius: 3, y: 3)
////
////                })
////                .padding(.horizontal, 20)
//
//                if !kyoPlus_hasPlus{
//                    Button {
//                        kyoPlus_showPurchaseScreen.toggle()
//                    } label: {
//                        VStack(alignment: .leading){
//                            Text("Upgrade to Kyo+ to access more features and customisation options")
//                                .bold()
//                                .foregroundStyle(Color.getForegroundColor(color: color))
//#if os(visionOS)
//                                .lineLimit(3)
//#else
//                                .lineLimit(2)
//#endif
//
//                                .minimumScaleFactor(0.5)
//                        }
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                        .padding(.trailing, 45)
//
//                    }
//                    .onAppear{
//
//                        KyoPlus().checkPaymentStatus { Bool in
//                            kyoPlus_hasPlus = Bool
//                        }
//                    }
//#if os(visionOS)
//                    .buttonStyle(PolishedButton(color: color, background: true))
//#else
//                    .buttonStyle(PolishedButton(color: color, background: true))
//#endif
//
//                    .overlay(alignment: .bottomTrailing, content: {
//                        Text("🚀")
//                            .font(.system(size: 60))
//                            .stroke(color: Color.white, width: 4)
//                            .overlay(content: {
//                                LinearGradient(stops:
//                                                [
//                                                    Gradient.Stop(color: Color.clear, location: 0.0),
//                                                    Gradient.Stop(color: Color.white.opacity(0.6), location: 0.7),
//                                                    Gradient.Stop(color: Color.clear, location: 1.0)
//                                                ],
//                                               startPoint: .top, endPoint: .bottom)
//                                .mask {
//                                    Text("🚀")
//                                        .font(.system(size: 60))
//                                }
//                            })
//                            .rotationEffect(Angle(degrees: -20))
//                            .offset(x: 13, y: 11)
//                            .shadow(color: .black.opacity(0.15), radius: 3, y: 3)
//
//
//                    })
//                    .padding(.horizontal, 20)
//
//                    .sheet(isPresented: $kyoPlus_showPurchaseScreen, onDismiss: {
//                        KyoPlus().checkPaymentStatus { Bool in
//                            kyoPlus_hasPlus = Bool
//                        }
//                    }, content: {
//#if !os(visionOS)
//                        NavigationStack{
//                            KyoPlus(color: color)
//                        }
//                        .presentationCornerRadius(25)
//#else
//
//                        NavigationStack{
//                            KyoPlus(color: .accentColor)
//                                .toolbar {
//                                    ToolbarItem(placement: .navigation) {
//                                        Button {
//                                            kyoPlus_showPurchaseScreen.toggle()
//                                        } label: {
//                                            Image(systemName: "xmark")
//                                        }
//
//                                    }
//                                }
//                        }
//                        .frame(idealWidth: 600, idealHeight: 900)
//#endif
//
//                    })
//                }
//
//
//                ScheduleOverview(color: color)
//                    .navigationDestination(isPresented: $showClasManage) {
//                        ClassesSettings(color: color)
//                    }
//
//                    GroupSection(label: "Classes & Splits") {
//
//
//                        Text("You have ^[\(classes.count) Classes](inflect: true, partOfSpeech: noun) and ^[\(splits.count) Splits](inflect: true, partOfSpeech: noun)")
//                            .font(.caption)
//                            .frame(maxWidth: .infinity, alignment: .leading)
//                            .padding(.bottom, 3)
//                            .opacity(0.5)
//
//
//                        SettingsGroup(color: ColorEngine().getXColor(2, colorScheme: colorScheme),
//                                        [GroupItem(label: VariableDataNames().classesName(), icon: "book.closed.fill", destinationView: AnyView(ClassesSettings(color: color))),
//                                         GroupItem(label: "Splits", icon: "scissors", destinationView: AnyView(SplitsSettings(color: color)))
//                                        ]
//                        )
//                        
//                    }
//
//
//                .padding(.horizontal, 20)
//
//                GroupSection(label: "Teachers") {
//                    SettingsGroup(color: ColorEngine().getXColor(3, colorScheme: colorScheme),
//                                  [GroupItem(label: "Manage", icon: "person.fill", destinationView: AnyView(ManageTeachers(color: color)))
//                                    ]
//                    )
//                }
//                .padding(.horizontal, 20)
//                .onAppear{
//                    KyoPlus().checkPaymentStatus(fetchPolicy: .notStaleCachedOrFetched) { Bool in
//                        kyoPlus_hasPlus = Bool
//                    }
//                }
//
//                GroupSection(label: "About") {
//
//
//                    SettingsGroup(color: ColorEngine().getXColor(5, colorScheme: colorScheme),
//                                  [GroupItem(label: "About", icon: "info.circle.fill", destinationView: AnyView(About(color: color)))
//                                    ]
//                    )
//                }
//                .padding(.horizontal, 20)
//
//
//            Color.clear.frame(height: 20)
//
//        }
//        .coordinateSpace(name: "scroll")
//            #if os(iOS)
//        .safeAreaInset(edge: .top, content: {
//            Color.clear.frame(height: 90)
//        })
//            #endif
//        .amethystNavigationBar(title: kyoPlus_hasPlus ? "Kyo+" : "Kyo", tintColor: color, scrolled: $scrolled) {
//            HStack(spacing: 10){
//#if os(iOS)
//                Button(action: {
//                    showSettingsPage = true
//                }, label: {
//                    Image(systemName: "gearshape.fill")
//                        .scaledFrame(width: 44, height: 44, relativeTo: .body)
//                })
//                .modify {
//                    if #available(iOS 17.0, *) {
//                        $0.buttonStyle(NavigationButton(color: color, scrolled: $scrolled))
//
//                    } else {
//                        $0.menuStyle(NavigationMenu(color: color, scrolled: $scrolled))
//                    }
//                }
//                #endif
//            }
//        } toolbar: {
//            Menu {
//                if kyoPlus_hasPlus{
//                    Button {
//                        Task {
//                            do {
//                            } catch {
//                                print("Error showing manage subscriptions: \(error)")
//                                // Handle the error appropriately, possibly with an alert to the user.
//                            }
//                        }
//                    } label: {
//                        Label("Manage Membership", systemImage: "ticket")
//                    }
//                }
//                else{
//                    Button {
//                        kyoPlus_showPurchaseScreen.toggle()
//                                        } label: {
//                                            Label("Upgrade", systemImage: "ticket")
//                                        }
//                }
//
//            } label: {
//                Label(kyoPlus_hasPlus ? "Plus" : "Free Tier", systemImage: "ticket")
//            }
//
//        }
//    }
//
//    }
//
//
//
//}

struct KyoOverview: View {
    // FIX: Read the local Pro preview setting, defaulting to on; no purchase checks are used.
    @AppStorage("archivePlusEnabled") private var kyoPlus_hasPlus = true
    // Amethyst
    var color: Color = Color.accentColor
    @State private var scrolled: Bool = false

    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "pinned", ascending: false), NSSortDescriptor(key: "name", ascending: true)]) var teachers: FetchedResults<TeacherEntity>
    @FetchRequest(sortDescriptors: []) var classes: FetchedResults<ClassEntity>
    @FetchRequest(sortDescriptors: []) var splits: FetchedResults<SplitterEntity>

    @State private var kyoPlus_showPurchaseScreen: Bool = false
    @State private var showClasManage: Bool = false
    @State private var path = NavigationPath()

    @AppStorage("showOnboardNeo") var showOnboardNeo = true
    @AppStorage("buildNum") var buildNum = 0

    @Environment(\.colorScheme) private var colorScheme
    @AppStorage("showSettingsPage") var showSettingsPage: Bool = false
    @State var showAboutPage: Bool = false


    
    var body: some View {
        ZStack{
            ScrollView {
                #if !os(visionOS)
                ScrollDetector(scrolled: $scrolled)
                    .onChange(of: path) {
                        print(path)
                    }
                #endif


//                Button {
////                    kyoPlus_showPurchaseScreen.toggle()
//                } label: {
//                    VStack(alignment: .leading){
//                        Text("Kyo releasing soon")
//                            .bold()
//                            .foregroundStyle(Color.getForegroundColor(color: color))
//                            .lineLimit(2)
//                            .minimumScaleFactor(0.5)
//                    }
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                    .padding(.trailing, 45)
//
//                }
//                .buttonStyle(PolishedButton(color: color, background: true))
//                .overlay(alignment: .bottomTrailing, content: {
//                    Text("⭐")
//                        .font(.system(size: 40))
//                        .stroke(color: Color.white, width: 4)
//                        .overlay(content: {
//                            LinearGradient(stops:
//                                            [
//                                                Gradient.Stop(color: Color.clear, location: 0.0),
//                                                Gradient.Stop(color: Color.white.opacity(0.6), location: 0.7),
//                                                Gradient.Stop(color: Color.clear, location: 1.0)
//                                            ],
//                                           startPoint: .top, endPoint: .bottom)
//                            .mask {
//                                Text("⭐")
//                                    .font(.system(size: 60))
//                            }
//                        })
//                        .rotationEffect(Angle(degrees: -20))
//                        .offset(x: 13, y: 11)
//                        .shadow(color: .black.opacity(0.15), radius: 3, y: 3)
//
//                })
//                .padding(.horizontal, 20)

                if !kyoPlus_hasPlus{
                    Button {
                        kyoPlus_showPurchaseScreen.toggle()
                    } label: {
                        VStack(alignment: .leading){
                            Text("Upgrade to Kyo+ to access more features and customisation options")
                                .bold()
                                .foregroundStyle(Color.getForegroundColor(color: color))
#if os(visionOS)
                                .lineLimit(3)
#else
                                .lineLimit(2)
#endif

                                .minimumScaleFactor(0.5)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.trailing, 45)

                    }
                    .onAppear{

                        // FIX: No purchase check is needed; access follows the local Pro setting.

                    }
#if os(visionOS)
                    .buttonStyle(PolishedButton(color: color, background: true))
#else
                    .buttonStyle(PolishedButton(color: color, background: true))
#endif

                    .overlay(alignment: .bottomTrailing, content: {
                        Text("🚀")
                            .font(.system(size: 60))
                            .stroke(color: Color.white, width: 4)
                            .overlay(content: {
                                LinearGradient(stops:
                                                [
                                                    Gradient.Stop(color: Color.clear, location: 0.0),
                                                    Gradient.Stop(color: Color.white.opacity(0.6), location: 0.7),
                                                    Gradient.Stop(color: Color.clear, location: 1.0)
                                                ],
                                               startPoint: .top, endPoint: .bottom)
                                .mask {
                                    Text("🚀")
                                        .font(.system(size: 60))
                                }
                            })
                            .rotationEffect(Angle(degrees: -20))
                            .offset(x: 13, y: 11)
                            .shadow(color: .black.opacity(0.15), radius: 3, y: 3)


                    })
                    .padding(.horizontal, 20)

                    .sheet(isPresented: $kyoPlus_showPurchaseScreen, onDismiss: {

                        // FIX: No purchase check is needed; access follows the local Pro setting.

                    }, content: {
#if !os(visionOS)
                        NavigationStack{
                            KyoPlus(color: color)
                        }
                        .presentationCornerRadius(25)
#else

                        NavigationStack{
                            KyoPlus(color: .accentColor)
                                .toolbar {
                                    ToolbarItem(placement: .navigation) {
                                        Button {
                                            kyoPlus_showPurchaseScreen.toggle()
                                        } label: {
                                            Image(systemName: "xmark")
                                        }

                                    }
                                }
                        }
                        .frame(idealWidth: 600, idealHeight: 900)
#endif

                    })
                }


                ScheduleOverview(color: color)
                    .navigationDestination(isPresented: $showClasManage) {
                        ClassesSettings(color: color)
                    }

                    GroupSection(label: "Classes & Splits") {


                        Text("You have ^[\(classes.count) Classes](inflect: true, partOfSpeech: noun) and ^[\(splits.count) Splits](inflect: true, partOfSpeech: noun)")
                            .font(.caption)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.bottom, 3)
                            .opacity(0.5)


                        SettingsGroup(color: ColorEngine().getXColor(2, colorScheme: colorScheme),
                                        [GroupItem(label: VariableDataNames().classesName(), icon: "book.closed.fill", destinationView: AnyView(ClassesSettings(color: color))),
                                         GroupItem(label: "Splits", icon: "scissors", destinationView: AnyView(SplitsSettings(color: color)))
                                        ]
                        )

                    }


                .padding(.horizontal, 20)

                let colTeacher = ColorEngine().getXColor(3, colorScheme: colorScheme)
                let teacherEntities = teachers.map { teacher in
                            // Initialize an array to hold icons
                        var icons: [String] = []

                            // Conditionally add phone, email, and pin icons
                            if let phone = teacher.phone, !phone.isEmpty {
                                icons.append("phone.fill")
                            }
                            if let email = teacher.email, !email.isEmpty {
                                icons.append("envelope.fill")
                            }
                            if teacher.pinned {
                                icons.append("pin.fill")
                            }

                            let title = TitleEnum(rawValue: teacher.title) ?? .none
                            let name = teacher.name ?? "Unknown"
                            let label = title != .none ? "\(title.description) \(name)" : "\(name)"
                    

                            return GroupItem(
                                label: label,
                                icon: "person.fill",  // main icon
                                trailingIcons: icons,  // array of icons
                                destinationView: AnyView(TeacherComposer(teacher, color: colTeacher))
                            )
                        }

                GroupSection(label: "Teachers") {
                    SettingsGroup(color: colTeacher,
                                  [GroupItem(
                                      label: "Manage",
                                      icon: "person.2.fill",
                                      destinationView: AnyView(ManageTeachers(color: .blue))
                                  )]
                    )

                    TeachersListSection(useColor: ColorEngine().getXColor(3, colorScheme: colorScheme))

//                    SettingsGroup(color: ColorEngine().getXColor(3, colorScheme: colorScheme),
//                                  teacherEntities
//                    )

                }
                .padding(.horizontal, 20)
                .onAppear{

                    // FIX: No purchase check is needed; access follows the local Pro setting.

                }


//                GroupSection(label: "Clubs") {
//                    SettingsGroup(color: ColorEngine().getXColor(3, colorScheme: colorScheme),
//                                  [GroupItem(label: "View All", icon: "person.fill", destinationView: AnyView(ManageTeachers(color: color)))
//                                    ]
//                    )
//                }
//                .padding(.horizontal, 20)

            Color.clear.frame(height: 20)

        }
        .coordinateSpace(name: "scroll")
            #if os(iOS)
        .safeAreaInset(edge: .top, content: {
            Color.clear.frame(height: 90)
        })
        .sheet(isPresented: $showAboutPage, content: {
            NavigationStack{
                About(color: color)
            }
            .presentationCornerRadius(25)

        })
            #endif
        .amethystNavigationBar(title: kyoPlus_hasPlus ? "Kyo+" : "Kyo", tintColor: color, scrolled: $scrolled) {
            HStack(spacing: 10){

                Button(action: {
                    showAboutPage = true
                }, label: {
                    Image(systemName: "info.circle.fill")
                        .scaledFrame(width: 44, height: 44, relativeTo: .body)
                })
                .buttonStyle(NavigationButton(color: color, scrolled: $scrolled))
#if os(iOS)
                Button(action: {
                    showSettingsPage = true
                }, label: {
                    Image(systemName: "gearshape.fill")
                        .scaledFrame(width: 44, height: 44, relativeTo: .body)
                })
                .modify {
                    if #available(iOS 17.0, *) {
                        $0.buttonStyle(NavigationButton(color: color, scrolled: $scrolled))

                    } else {
                        $0.menuStyle(NavigationMenu(color: color, scrolled: $scrolled))
                    }
                }
                #endif
            }
        } toolbar: {
            Menu {
                if kyoPlus_hasPlus{
                    Button {

                        // FIX: No subscription management exists in the unlocked archive.

                    } label: {
                        Label("Kyo+ Included", systemImage: "ticket")
                    }
                        .disabled(true)
                }
                else{
                    Button {
                        kyoPlus_showPurchaseScreen.toggle()
                                        } label: {
                                            Label("Upgrade", systemImage: "ticket")
                                        }
                }

            } label: {
                Label(kyoPlus_hasPlus ? "Plus" : "Free Tier", systemImage: "ticket")
            }

        }
    }

    }


}

//struct KyoOverview: View {
//    @AppStorage("kyoPlus_hasPlus") var kyoPlus_hasPlus: Bool = false
//    // Amethyst
//    var color: Color = Color.accentColor
//    @State private var scrolled: Bool = false
//
//    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "pinned", ascending: false), NSSortDescriptor(key: "name", ascending: true)]) var teachers: FetchedResults<TeacherEntity>
//    @FetchRequest(sortDescriptors: []) var classes: FetchedResults<ClassEntity>
//    @FetchRequest(sortDescriptors: []) var splits: FetchedResults<SplitterEntity>
//
//    @State private var kyoPlus_showPurchaseScreen: Bool = false
//    @State private var showClasManage: Bool = false
//    @State private var path = NavigationPath()
//
//    @AppStorage("showOnboardNeo") var showOnboardNeo = true
//    @AppStorage("buildNum") var buildNum = 0
//
//    @Environment(\.colorScheme) private var colorScheme
//    @AppStorage("showSettingsPage") var showSettingsPage: Bool = false
//    @State var showAboutPage: Bool = false
//
//    var body: some View {
//        ZStack{
//            List{
//
//                Section("Schedule"){
//                    NavigationLink(value: GroupItem(label: "Rotation", icon: "repeat", destinationView: AnyView(AutomaticWeeks(color: ColorEngine().getXColor(1, colorScheme: colorScheme))))) {
//                        Label("Rotation", systemImage: "repeat")
//                    }
//                    .listRowInsets(.init(top: 20, leading: 20, bottom: 20, trailing: 20))
//                    .swipeActions(content: {
//                        Button {
//
//                        } label: {
//
//                        }
//
//                    })
//
//
////                    .listRowBackground(Color.clear)
//
//                    NavigationLink(value: GroupItem(label: "Rotation", icon: "repeat", destinationView: AnyView(WeekSlider(color: ColorEngine().getXColor(1, colorScheme: colorScheme))))) {
//                        Label("Edit", systemImage: "calendar")
//                    }
//                    .listRowInsets(.init(top: 20, leading: 20, bottom: 20, trailing: 20))
////                    .listRowBackground(Color.clear)
//                }
//                .tint(ColorEngine().getXColor(1, colorScheme: colorScheme))
//
//                .listRowInsets(.init(top: 10, leading: 0, bottom: 10, trailing: 20))
//                .regularOutline()
//
//                //                ScheduleOverview(color: color)
//                //                    .navigationDestination(isPresented: $showClasManage) {
//                //                        ClassesSettings(color: color)
//                //                    }
//                //
//                //                    GroupSection(label: "Classes & Splits") {
//                //
//                //
//                //                        Text("You have ^[\(classes.count) Classes](inflect: true, partOfSpeech: noun) and ^[\(splits.count) Splits](inflect: true, partOfSpeech: noun)")
//                //                            .font(.caption)
//                //                            .frame(maxWidth: .infinity, alignment: .leading)
//                //                            .padding(.bottom, 3)
//                //                            .opacity(0.5)
//                //
//                //
//                //                        SettingsGroup(color: ColorEngine().getXColor(2, colorScheme: colorScheme),
//                //                                        [GroupItem(label: VariableDataNames().classesName(), icon: "book.closed.fill", destinationView: AnyView(ClassesSettings(color: color))),
//                //                                         GroupItem(label: "Splits", icon: "scissors", destinationView: AnyView(SplitsSettings(color: color)))
//                //                                        ]
//                //                        )
//                //
//                //                    }
//                //
//                //
//                //                .padding(.horizontal, 20)
//            }
//
//
//            .scrollContentBackground(.hidden)
//            .environment(\.defaultMinListRowHeight, 50)
//        .coordinateSpace(name: "scroll")
//            #if os(iOS)
//        .safeAreaInset(edge: .top, content: {
//            Color.clear.frame(height: 90)
//        })
//        .sheet(isPresented: $showAboutPage, content: {
//            NavigationStack{
//                About(color: color)
//            }
//            .presentationCornerRadius(25)
//
//        })
//            #endif
//        .amethystNavigationBar(title: kyoPlus_hasPlus ? "Kyo+" : "Kyo", tintColor: color, scrolled: $scrolled) {
//            HStack(spacing: 10){
//
//                Button(action: {
//                    showAboutPage = true
//                }, label: {
//                    Image(systemName: "info.circle.fill")
//                        .scaledFrame(width: 44, height: 44, relativeTo: .body)
//                })
//                .buttonStyle(NavigationButton(color: color, scrolled: $scrolled))
//#if os(iOS)
//                Button(action: {
//                    showSettingsPage = true
//                }, label: {
//                    Image(systemName: "gearshape.fill")
//                        .scaledFrame(width: 44, height: 44, relativeTo: .body)
//                })
//                .modify {
//                    if #available(iOS 17.0, *) {
//                        $0.buttonStyle(NavigationButton(color: color, scrolled: $scrolled))
//
//                    } else {
//                        $0.menuStyle(NavigationMenu(color: color, scrolled: $scrolled))
//                    }
//                }
//                #endif
//            }
//        } toolbar: {
//            Menu {
//                if kyoPlus_hasPlus{
//                    Button {
//                        Task {
//                            do {
//                            } catch {
//                                print("Error showing manage subscriptions: \(error)")
//                                // Handle the error appropriately, possibly with an alert to the user.
//                            }
//                        }
//                    } label: {
//                        Label("Manage Membership", systemImage: "ticket")
//                    }
//                }
//                else{
//                    Button {
//                        kyoPlus_showPurchaseScreen.toggle()
//                                        } label: {
//                                            Label("Upgrade", systemImage: "ticket")
//                                        }
//                }
//
//            } label: {
//                Label(kyoPlus_hasPlus ? "Plus" : "Free Tier", systemImage: "ticket")
//            }
//
//        }
//    }
//
//    }
//
//
//}

#Preview {
    KyoOverview(color: Color.accentColor)
}

extension View {
    func stroke(color: Color, width: CGFloat = 1) -> some View {
        modifier(StrokeModifer(strokeSize: width, strokeColor: color))
    }
}

struct StrokeModifer: ViewModifier {
    private let id = UUID()
    var strokeSize: CGFloat = 1
    var strokeColor: Color = .blue

    func body(content: Content) -> some View {
        if strokeSize > 0 {
            appliedStrokeBackground(content: content)
        } else {
            content
        }
    }

    private func appliedStrokeBackground(content: Content) -> some View {
        content
            .padding(strokeSize*2)
            .background(
                Rectangle()
                    .foregroundColor(strokeColor)
                    .mask(alignment: .center) {
                        mask(content: content)
                    }
            )
    }

    func mask(content: Content) -> some View {
        Canvas { context, size in
            context.addFilter(.alphaThreshold(min: 0.01))
            context.drawLayer { ctx in
                if let resolvedView = context.resolveSymbol(id: id) {
                    ctx.draw(resolvedView, at: .init(x: size.width/2, y: size.height/2))
                }
            }
        } symbols: {
            content
                .tag(id)
                .blur(radius: strokeSize)
        }
    }
}
