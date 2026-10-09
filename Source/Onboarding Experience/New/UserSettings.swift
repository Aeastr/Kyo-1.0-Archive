// FIX: Use archive identifiers to keep this build and its data separate from the original app.
//
//  UserSettings.swift
//  KyoNeo
//
//  Created by Aether on 04/04/2023.
//

import SwiftUI
import AmethystUI
import UserNotifications

struct UserSettings: View {
    @State var scrolled: Bool = false
    @Binding var index: Int
    @Environment(\.colorScheme) var colorScheme

    @AppStorage("name") var name = ""

    @State var showMapSetup: Bool = false

    @State private var notificationStatus: UNAuthorizationStatus = .notDetermined

    @AppStorage("schedule_SingleDayMode", store: UserDefaults(suiteName: "group.com.example.kyoarchive")) var schedule_SingleDayMode: Bool = false


    var color: Color
    var body: some View {
        NavigationStack{
                ScrollView{
                    ScrollDetector(scrolled: $scrolled)
                    Group{
                        Text("Name")
                            .sectionTitle()
                            HStack(spacing: 0) {

                                TextField("Enter your name, or leave blank!", text: $name)
                                    .textFieldStyle(.plain)
                                    .scaledFrame(width: nil, height: 50, relativeTo: .body)
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
                            .padding(.leading, 13)
//                            .padding(.vertical, 15)
                            .background {
                                Color("textField").opacity( 0.3)
                                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                                // .shadow(color: actualColor.opacity(scrolled ? 0 : 0.3), radius: 7, x: 0, y: 8)
                                    .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.primary.opacity(0.15), lineWidth: 1.5))
                            }

                            .padding(.bottom, 5)

                        Text("Kyo will display your name in certain parts of the app")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)


                            Text("Schedule System")
                                .sectionTitle()

                        VStack{
                            Text( schedule_SingleDayMode ? "Create a single day schedule. Once set, Kyo will always show the same day all the time" : "Create a schedule for any number of weeks. Once set, Kyo cycles through these weeks continuously. For example, if you create a 3-week schedule, it will rotate through Week 1, Week 2, Week 3, then back to Week 1, repeating this pattern continuously.")
                                                        .font(.caption)
                                                        .padding(6)
                                                        .frame(maxWidth: .infinity)
                                                        .neoSettingsCard()
                            Button {
                                schedule_SingleDayMode = false
                            } label: {
                                HStack(spacing: 13){
                                    Image(systemName: "square.stack")
                                        .font(.title)
                                    VStack(spacing: 3){
                                    Text("Repeating Weeks")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    //
                                    Text("Ideal for students with a set\nof repeating weeks")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .font(.caption)
                                        .opacity(0.7)
                                }
                                }
                            }
                            .buttonStyle(PolishedButton(color: color, background: !schedule_SingleDayMode))


                            Button {
                                schedule_SingleDayMode = true
                            } label: {
                                HStack(spacing: 13){
                                    Image(systemName: "square")
                                        .font(.title)
                                    VStack(spacing: 3){
                                        Text("Single Day")
                                            .frame(maxWidth: .infinity, alignment: .leading)

                                        Text("Ideal for students with the\nsame day every day")
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .font(.caption)
                                            .opacity(0.7)
                                    }
                                }
                            }
                            .buttonStyle(PolishedButton(color: color, background: schedule_SingleDayMode))
                        }


                    }
                    .padding(.horizontal, 20)

//                    Group{
//                        Text("Notifications")
//                            .font(.title3)
//                            .frame(maxWidth: .infinity, alignment: .leading)
//                            .padding(.bottom, 1.5)
//                        Text("Notifications can inform you of upcoming tasks and entries in your planner")
//                            .font(.caption)
//                            .foregroundColor(.secondary)
//                            .frame(maxWidth: .infinity, alignment: .leading)
//                            .padding(.bottom, 5)
//
//                        Button {
//                            NotificationHelper().requestPermission()
//
//                        } label: {
//                            if notificationStatus == .authorized {
//                                            Text("Permission Allowed")
//                                        } else {
//                                            Text("Allow Permission")
//                                        }
//
//                        }
//                        .onAppear{
//                            checkNotificationPermission()
//                        }
//                        .buttonStyle(BentoButton(color: Color("Default/2")))
//
//                    }
//                        .padding(.horizontal, 20)

//                    if #available(iOS 17.0, *) {
//                        Group{
//                            Text("Campus")
//                                .sectionTitle()
//
//                            Text("You can add your campus location and we'll give you infomration based on it, such as travel times, as well as enabling additional planner features")
//                                .font(.caption2)
//                                .foregroundColor(.secondary)
//                                .frame(maxWidth: .infinity, alignment: .leading)
//
//
//                            Button {
//
//                                showMapSetup.toggle()
//                            } label: {
//                                Text("Get Started")
//                            }
//                            .buttonStyle(BentoButton(color: Color("Default/2")))
//                            .fullScreenCover(isPresented: $showMapSetup) {
//                                MapSearch(show: $showMapSetup)
//                            }
//                        }
//                        .padding(.horizontal, 20)
//                    }

//                Group{
//                    Text("Integrations")
//                        .sectionTitle()
//
//                    Text("Coming Soon")
//                        .font(.caption2)
//                        .foregroundColor(.secondary)
//                        .frame(maxWidth: .infinity, alignment: .leading)
//
//                }
//                    .padding(.horizontal, 20)

                }
                .coordinateSpace(name: "scroll")
              #if os(iOS)
                .safeAreaInset(edge: .top, content: {
                    Color.clear.frame(height: 50)
                })

                .overlay(alignment: .top) {
                    FluidNavigationBar(title: "Get Started", titleColor: .primary,   tintColor: color, type: .back, scrolled: $scrolled, linelimit: 2, method: .custom, content: {

                    }, toolbar: {
                        Text(" ")
                    }, overrideBackAction: {
                        withAnimation(.smoothCard){
                            index = index - 1
                        }
                    })
                }
            #endif
                .safeAreaInset(edge: .bottom) {
                    #if os(iOS)
                    VStack{
                        HStack{


                            Button(action: {
                                withAnimation(.smoothCard){
                                    index = index + 1
                                }
                            }, label: {
                                Text("Next")
                                    .frame(maxWidth: .infinity, alignment: .center)
                            })
                            .padding()
                            .buttonStyle(PolishedButton(color: color, background: true))

                            .padding(.horizontal, 10)
                           // .disabled(weeks.count == 0 ? true : false)
                        }


                        Color.clear.frame(height: 20)
                    }
                    #else
                    HStack{
                        Button(action: {
                            withAnimation(.smoothCard){
                            index = index - 1 > -1 ? index - 1 : index
                            }
                        }, label: {
                            Text("Back")
                                .font(.callout )
                        })
                        .buttonStyle(PolishedButton(color: color, background: false))
                        Spacer()
                        Button {
                            withAnimation(.smoothCard){
                                index = index + 1
                            }
                        } label: {
                            Text("Next")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(PolishedButton(color: color, background: true))
                    }
                    .padding(.bottom, 17)
                    .padding(.horizontal, 20)
                    #endif
                }
                .ignoresSafeArea(edges: .bottom)
              
                #if os(iOS) || os(visionOS)
                .navigationTitle("")
                .navigationBarHidden(true)
            #else
                .navigationTitle("Get Started")
                
                #endif
            }
            .ignoresSafeArea()





    }


    private func checkNotificationPermission() {
        NotificationHelper().checkNotificationPermission { status in
            DispatchQueue.main.async {
                notificationStatus = status
            }
        }
    }
}
