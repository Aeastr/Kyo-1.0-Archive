//
//  Beta Notice.swift
//  KyoNeo
//
//  Created by Aether on 04/04/2023.
//

import SwiftUI
import AmethystUI

struct welcomeScreen: View {
    @State var scrolled: Bool = false
    @Binding var index: Int
    @Environment(\.colorScheme) var colorScheme

    @AppStorage("showOnboardNeo") var showOnboardNeo = true
    @AppStorage("buildNum") var buildNum = 0

    @FetchRequest(sortDescriptors: []) var classes: FetchedResults<ClassEntity>
    @FetchRequest(sortDescriptors: []) var splits: FetchedResults<SplitterEntity>
    // FIX: Archive access is unconditional; do not read or update a persisted purchase flag.
    private var kyoPlus_hasPlus: Bool { true }

    var color: Color
    var body: some View {
        NavigationStack{
                ScrollView{
                    ScrollDetector(scrolled: $scrolled)

                    Image("kyoBanner")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .frame(maxWidth: 700)
                    ScheduleOverview(color: color, setupMode: true)

                        .frame(maxWidth: 700)
                    SettingsGroup(color: ColorEngine().getXColor(2, colorScheme: colorScheme),
                                  [GroupItem(label: "Edit", icon: "list.bullet", action: {
                        withAnimation(.smoothCard){
                            index = 2
                        }
                    })
                                    ]
                    ).padding(.horizontal, 20)

                    GroupSection(label: "Classes & Splits") {

                        Text("You have ^[\(classes.count) Classes](inflect: true, partOfSpeech: noun) and ^[\(splits.count) Splits](inflect: true, partOfSpeech: noun)")
                            .font(.caption)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.bottom, 3)
                            .opacity(0.5)


                        SettingsGroup(color: ColorEngine().getXColor(2, colorScheme: colorScheme),
                                      [GroupItem(label: "Edit", icon: "list.bullet", action: {
                            withAnimation(.smoothCard){
                                    index = index - 1
                            }
                        })
                                        ]
                        )

                    }
                    .padding(.horizontal, 20)

                    if !kyoPlus_hasPlus{
                        GroupSection(label: "Kyo+"){
                            KyoPlusButton(color: color, kyoPlus_hasPlus: .constant(true))
                                .padding(.horizontal, -15)
                        }
                        .padding(.horizontal, 20)
                    }

                }
                .coordinateSpace(name: "scroll")
              #if os(iOS)
                .safeAreaInset(edge: .top, content: {
                    Color.clear.frame(height: 50)
                })

                .overlay(alignment: .top) {
                    FluidNavigationBar(title: "Setup Complete", titleColor: .primary,   tintColor: color, type: .back, scrolled: $scrolled, linelimit: 2, method: .custom, content: {

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
                    VStack{
                        HStack{


                            Button(action: {
                                withAnimation(.smoothCard){
                                    buildNum = 52
                                    showOnboardNeo = false
                                }
                            }, label: {
                                Text("Finish")
                                    .frame(maxWidth: .infinity, alignment: .center)
                            })
                            .padding()
                            .buttonStyle(PolishedButton(color: color, background: true))

                            .padding(.horizontal, 10)
                           // .disabled(weeks.count == 0 ? true : false)
                        }


                        Color.clear.frame(height: 20)
                    }
                }
                .ignoresSafeArea(edges: .bottom)

            }
            .ignoresSafeArea()


    }
}

struct betaNotice: View {
    @State var scrolled: Bool = false
    @Binding var index: Int
    @Environment(\.colorScheme) var colorScheme

    @AppStorage("showOnboardNeo") var showOnboardNeo = true
    @AppStorage("buildNum") var buildNum = 0

    @AppStorage("name") var name = ""

    var body: some View {
            NavigationStack{
                ScrollView{
                    ScrollDetector(scrolled: $scrolled)
                    Group{
                        Text("Please remember to check changelogs for errors, and report anything you come across")
                            .font(.caption)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding([.bottom])
                        Text("You can check build notes in testlight or the craft page. You'll find help + Q/A on the craft page too, just head to settings to find the link")
                            .font(.caption)
                            .foregroundColor(.blue)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding([.bottom])
                        Text("You can also join the public telegram group in settings")
                            .font(.caption)
                            .foregroundColor(.blue)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding([.bottom])

                            Text("Please note bugs will occur, data could be lost and notifications could be messed up")
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding([.bottom])


                        Text("Please check the changelogs for possible fixes to known issues")
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding([.bottom])
                            Text("Some features may have broken due to changes compared to the last build, again please refer to change logs in testflight, craft or the telegram group")
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding([.bottom])

                    }
                    .padding(.horizontal, 20)

                }
                .coordinateSpace(name: "scroll")
                .safeAreaInset(edge: .top) {
                    VStack{
                        Color.clear.frame(height: 10)
                        if #available(iOS 16.0, *) {
                            Text("Beta Notice")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.title3)
                                .fontWidth(.expanded)
                                .fontWeight(.semibold)
                        }
                        else{
                            Text("Beta Notice")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.title3)
                        }



                    }.padding(.horizontal, 20)

                        .background(
                            Color.clear
                                .frame(height: 350)
                                .background(.ultraThinMaterial)
                                .offset(y:-50)
                                .blur(radius: 10)
                                .opacity(scrolled ? 1 : 0)
                                .animation(.linear(duration: 0.1), value: scrolled)
                                .transition(.opacity.animation(.linear(duration: 0.1)))
                                .contrast(colorScheme == .dark ? 1.3 : 1)
                        )

                }
                .safeAreaInset(edge: .bottom) {
                    VStack{
                        HStack{
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

                            Button(action: {
                                withAnimation(.smoothCard){
                                    buildNum = 52
                                    showOnboardNeo = false
                                }
                            }, label: {
                                Text("Finish ")
                                    .frame(maxWidth: .infinity, alignment: .center)
                            })
                            .padding()
                            .buttonStyle(PolishedButton(color: Color("Default/2"), background: true))
                            .shadow(color: Color("Default/2").opacity(0.15), radius: 10, y: 5)
                            .padding(.horizontal, 10)
                           // .disabled(weeks.count == 0 ? true : false)
                        }


                        Color.clear.frame(height: 20)
                    }
                }
                .ignoresSafeArea(edges: .bottom)
                .background{
                    ZStack{
                        NeoDotBackground(color1: Color("Default/2"))
                }.ignoresSafeArea()
                }
                #if os(iOS) || os(visionOS)
                .navigationTitle("")
                .navigationBarHidden(true)
                #endif
            }
            .ignoresSafeArea()





    }
}
