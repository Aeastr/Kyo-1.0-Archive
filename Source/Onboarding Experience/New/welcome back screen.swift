//
//  welcome back screen.swift
//  KyoNeo
//
//  Created by Aether on 26/09/2023.
//

import SwiftUI
import AmethystUI
import UserNotifications

struct welcomeBack: View {
    @State var scrolled: Bool = false
    @Binding var index: Int
    @Environment(\.colorScheme) var colorScheme

    @AppStorage("name") var name = ""

    @State var showMapSetup: Bool = false

    @State private var notificationStatus: UNAuthorizationStatus = .notDetermined

    var body: some View {
        NavigationStack{
                ScrollView{
                    ScrollDetector(scrolled: $scrolled)
                    VStack{

                        Text("Looks like you've used Kyo before")
                            .font(.caption)
                            .foregroundStyle(Color.primary.opacity(0.6))

                            .lineLimit(nil)
                            .frame(maxWidth: .infinity)



                            .padding(.horizontal, 2)
                            .padding(13)
                            .background {
                                Color("NeoButton")
                                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                                    .regularOutline(cornerRadius: 18)

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
//                .safeAreaInset(edge: .top) {
//                    VStack{
//                        Color.clear.frame(height: 10)
//                        if #available(iOS 16.0, *) {
//                            Text("Hello!")
//                                .frame(maxWidth: .infinity, alignment: .leading)
//                                .font(.title3)
//                                .fontWidth(.expanded)
//                                .fontWeight(.semibold)
//                        }
//                        else{
//                            Text("Hello!")
//                                .frame(maxWidth: .infinity, alignment: .leading)
//                                .font(.title3)
//                        }
//                        Text("First things first, let's sort some info out, while you set up Kyo, we'll sort out some things in the background")
//                            .frame(maxWidth: .infinity, alignment: .leading)
//                            .padding(.top, 10)
//                            .font(.body.weight(.regular))
//
//                    }.padding(.horizontal, 20)
//
//                        .background(
//                            Color.clear
//                                .frame(height: 350)
//                                .background(.ultraThinMaterial)
//                                .offset(y:-50)
//                                .blur(radius: 10)
//                                .opacity(scrolled ? 1 : 0)
//                                .animation(.linear(duration: 0.1), value: scrolled)
//                                .transition(.opacity.animation(.linear(duration: 0.1)))
//                                .contrast(colorScheme == .dark ? 1.3 : 1)
//                        )
//
//                }
                .safeAreaInset(edge: .top, content: {
                    Color.clear.frame(height: 70)
                })
                .overlay(alignment: .top){
                    FluidNavigationBar(title: "Welcome Back\(name != "" ? ", \(name)!" : "!")", titleColor: .primary,   tintColor: Color("Default/2"), scrolled: $scrolled, linelimit: 1, content: {
                        
                    }, toolbar: {
                        
                    })
                }
                .safeAreaInset(edge: .bottom) {
                    VStack{
                        HStack(alignment: .bottom){
                            Button(action: {

                                withAnimation(.smoothCard){
                                    index = index - 1
                                }
                            }, label: {
                                Image(systemName: "arrow.left")
                            })
                            .padding([.vertical, .leading])
                            .buttonStyle(PolishedButton(color: Color("Default/2"), background: false))
                            .shadow(color: Color("Default/2").opacity(0.15), radius: 10, y: 5)
                            .padding(.leading, 10)
                            .padding(.trailing, 5)
                            VStack(spacing: 0){




                                Button {

                                } label: {
                                    Text("Skip to customisation settings")
                                        .frame(maxWidth: .infinity, alignment: .center)
                                }   .padding()
                                    .buttonStyle(PolishedButton(color: Color("Default/2"), background: false))
                                    .shadow(color: Color("Default/2").opacity(0.15), radius: 10, y: 5)
                                    .padding(.horizontal, 10)

                                Button {

                                } label: {
                                    Text("Skip setup")
                                        .frame(maxWidth: .infinity, alignment: .center)
                                }   .padding()
                                    .buttonStyle(PolishedButton(color: Color("Default/2"), background: false))
                                    .shadow(color: Color("Default/2").opacity(0.15), radius: 10, y: 5)
                                    .padding(.horizontal, 10)

                                Button {

                                    withAnimation(.smoothCard){
                                        index = index + 1
                                    }

                                } label: {
                                    Text("Continue regular setup")
                                        .frame(maxWidth: .infinity, alignment: .center)
                                }
                                .padding()
                                .buttonStyle(PolishedButton(color: Color("Default/2"), background: true))
                                .shadow(color: Color("Default/2").opacity(0.15), radius: 10, y: 5)
                                .padding(.horizontal, 10)

                            }
                           // .disabled(weeks.count == 0 ? true : false)
                        }


                        Color.clear.frame(height: 20)
                    }
                }
                .ignoresSafeArea(edges: .bottom)
                .background{
                    ZStack{
                        pageTopHue(color: Color("Default/2"))
                }.ignoresSafeArea()
                }
                #if os(iOS) || os(visionOS)
                .navigationTitle("")
                .navigationBarHidden(true)
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
