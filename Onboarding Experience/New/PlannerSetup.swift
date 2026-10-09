//
//  PlannerSetup.swift
//  KyoNeo
//
//  Created by Aether on 09/08/2023.
//

import SwiftUI
import AmethystUI

struct PlannerSetup: View {
    @State var scrolled: Bool = false
    @Binding var index: Int
    @Environment(\.colorScheme) var colorScheme

#if os(iOS)
    @AppStorage("planner_View") var planner_View: plannerViewMode = .pages
#else
    @AppStorage("planner_View") var planner_View: plannerViewMode = .week
#endif
   @AppStorage("planner_Style") var planner_Style:  typeEntryViewMode = .blocks

    @State var showMapSetup: Bool = false

    var body: some View {
        NavigationStack{
                ScrollView{
                    ScrollDetector(scrolled: $scrolled)
                    Group{

                        Text("Planner Style")
                            .sectionTitle()
                        HStack(spacing: 25){
                            Button {
                                withAnimation{
                                    planner_Style = .threads
                                }
                            } label: {
                                VStack(spacing: 10){
                                    Image("plannerOnboarding/Threads")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .regularOutline()
                                    HStack(alignment: .center, spacing: 5){
                                        Text(Image(systemName: planner_Style == .threads ? "checkmark.circle.fill" : "circle"))
                                            .font(.body)
                                            .foregroundStyle(planner_Style == .threads ? Color("Default/2") : Color.primary)

                                        Text("Threads")
                                            .font(.footnote)
                                    }
                                }
                            }
                            .buttonStyle(bounceButton())

                            Button {
                                withAnimation{
                                    planner_Style = .blocks
                                }
                            } label: {
                                VStack(spacing: 10){
                                Image("plannerOnboarding/Blocks")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .regularOutline()
                                    HStack(alignment: .center, spacing: 5){
                                        Text(Image(systemName: planner_Style == .blocks ? "checkmark.circle.fill" : "circle"))
                                            .font(.body)
                                            .foregroundStyle(planner_Style == .blocks ? Color("Default/2") : Color.primary)

                                        Text("Blocks")
                                            .font(.footnote)
                                    }
                            }
                            }
                            .buttonStyle(bounceButton())


                        }
                        .frame(height: 260)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 13)
                        .padding(.vertical, 10)
                        .padding(.top, 4)
                        .regularOutline()
                        Text("Planner View")
                            .sectionTitle()

                        HStack(spacing: 25){

                            Button {
                                withAnimation{
                                    planner_View = .timeline
                                }
                            } label: {
                                VStack(spacing: 10){
                                    if (planner_Style == .blocks){
                                        Image("plannerOnboarding/TimelineBlocks")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .regularOutline()
                                            .transition(.blur.animation(.smooth))
                                    }
                                    if (planner_Style == .threads){
                                        Image("plannerOnboarding/TimelineThreads")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .regularOutline()
                                            .transition(.blur.animation(.smooth))
                                    }

                                    HStack(alignment: .center, spacing: 5){
                                        Text(Image(systemName: planner_View == .timeline ? "checkmark.circle.fill" : "circle"))
                                            .font(.body)
                                            .foregroundStyle(planner_View == .timeline ? Color("Default/2") : Color.primary)

                                        Text("Timeline")
                                            .font(.footnote)
                                    }
                            }
                            }
                            .buttonStyle(bounceButton())


                                Button {
                                    withAnimation{
                                        planner_View = .pages
                                    }
                                } label: {
                                    VStack(spacing: 10){

                                            if (planner_Style == .blocks){
                                                Image("plannerOnboarding/PagesBlocks")
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .regularOutline()
                                                    .transition(.blur.animation(.smooth))
                                            }
                                            if (planner_Style == .threads){
                                                Image("plannerOnboarding/PagesThreads")
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .regularOutline()
                                                    .transition(.blur.animation(.smooth))
                                            }
                                        HStack(alignment: .center, spacing: 5){
                                            Text(Image(systemName: planner_View == .pages ? "checkmark.circle.fill" : "circle"))
                                                .font(.body)
                                                .foregroundStyle(planner_View == .pages ? Color("Default/2") : Color.primary)

                                            Text("Pages")
                                                .font(.footnote)
                                        }
                                    }
                                }
                                .buttonStyle(bounceButton())


                        }
                        .frame(height: 260)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 13)
                        .padding(.vertical, 10)
                        .padding(.top, 4)
                        .regularOutline()


                    }
                    .padding(.horizontal, 20)


                }
                .coordinateSpace(name: "scroll")
                .safeAreaInset(edge: .top, content: {
                    Color.clear.frame(height: 65)
                })
                .overlay(alignment: .top){
                    FluidNavigationBar(title: "Setup Planner", titleColor: .primary,   tintColor: Color("Default/2"), scrolled: $scrolled, linelimit: 2, content: {
                        
                    }, toolbar: {
                        
                    })
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
                                    .padding(.vertical, 2)
                                    .frame(width: 60)
                            })
                            .padding([.vertical, .leading])
                            .buttonStyle(PolishedButton(color: Color("Default/2"), background: false))
                            .shadow(color: Color("Default/2").opacity(0.15), radius: 10, y: 5)
                            .padding(.leading, 10)

                            Button(action: {
                                withAnimation(.smoothCard){
                                    index = index + 1
                                }
                            }, label: {
                                Text("Next")
                                    .frame(maxWidth: .infinity, alignment: .center)
                            })
                            .padding()
                            .buttonStyle(PolishedButton(color: Color("Default/2"), background: true))
                            .shadow(color: Color("Default/2").opacity(0.15), radius: 10, y: 5)
                            .padding(.trailing, 10)
                           // .disabled(weeks.count == 0 ? true : false)
                        }


                        Color.clear.frame(height: 20)
                    }.background(LinearGradient(gradient: Gradient(colors: [Color.clear, Color("bw").opacity(0.5)]), startPoint: .top, endPoint: .bottom))
                    #if os(iOS) || os(visionOS)
                        .background(VariableBlurView().rotationEffect(Angle(degrees: 180)).ignoresSafeArea())
                    #endif
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


}
