//
//  CosmicGoalsSync.swift
//  KyoNeo
//
//  Created by Aether on 10/07/2023.
//

import SwiftUI
import AmethystUI

struct CosmicGoalsSync: View {
    var color: Color
    @AppStorage("Contrast") var contrast = false
    @AppStorage("tintPages") var tintPages = false

    @Environment(\.colorScheme) private var colorScheme

    @State var load = false

    @State var scrolled: Bool = false
    var body: some View {
        ZStack {

            cosmicBackground()
            ScrollView {
                ScrollDetector(scrolled: $scrolled)
                Group{
                VStack(alignment: .leading, spacing: 10){
                    Text("Link Cosmic with Kyo!")
                        .font(.title3)
                    
                    
                    Text("Align your study efforts with your academic goals and stay organized in one central location.")
                        .font(.caption)
                    
                    
                    Text("Stay on top of your assignments and exams, manage your study schedule, and track your progress through your expanding planetary system.")
                        .font(.caption)
                    
                    Text("Link your study sessions to specific classes and tasks.")
                        .font(.caption)
                    
                    Text("Maximize your productivity and reach your academic potential with the power of Cosmic and Kyo combined.")
                        .font(.caption)
                }
                .padding(.horizontal, 20)
                Color.clear
                    .frame(height: 100)
                VStack(alignment: .leading, spacing: 10){
                    Text("Cosmic and Kyo use iOS app groups to securely share data on the user's device, without relying on cloud storage. When the user enables the link between the two apps, Cosmic gains permission to access Kyo's local data store via the app group, ensuring seamless integration. It's worth noting that Cosmic maintains a separate local data store, ensuring privacy and data integrity.")
                    
                    
                    Text("This separation allows users to have distinct categories for their data in both Cosmic and Kyo, ensuring privacy and maintaining data integrity.")
                    
                }
                .padding(.horizontal, 20)
                .font(.caption2)
                .opacity(0.7)
            }
           
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .shadow(color: .primary.opacity(0.05), radius: 13, x: 0, y: 5)
            .safeAreaInset(edge: .bottom){
                VStack{
                    if load{
                        Text("Cosmic couldn't be found on your device, if you believe this is an error, please send a report")
                            .font(.caption)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.bottom, 3)
                        HStack{
                            
                            Button(action: {
                                guard let url = URL(string: "https://www.apple.com/app-store/") else { return }
                                #if os(iOS) || os(visionOS)
                                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                #elseif os(macOS)
                                NSWorkspace.shared.open(url)
                                #endif
                            }) {
                                HStack {
                                    Label("Get Cosmic", systemImage: "arrow.down.app")
                                        .contentTransition(.opacity)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 3)
                                }
                            }
                            .buttonStyle(BentoButton(color: .white, role: .regularAction, scrolled: $scrolled))


                            
                            Button(action: {
                            }) {
                                HStack{
                                    Label("Set up", systemImage: "globe.asia.australia")
                                        .contentTransition(.opacity)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 3)

                                    ProgressView()
                                        .tint(.white)
                                }
                            }
                            .buttonStyle(BentoButton(color: .white, role: .create, scrolled: $scrolled))
                            .disabled(true)
                            .opacity(0.8)

                        }.transition(.move(edge: .bottom))
                    }
                    else{
                        ProgressView()
                            .tint(.white)
                            .onAppear{
                                // Generate a random delay between 0 and 7 seconds
                                let randomDelay: TimeInterval = Double.random(in: 1..<3.7)

                                // Schedule the action to be performed after the random delay
                                DispatchQueue.main.asyncAfter(deadline: .now() + randomDelay) {
                                    // Action to be executed after the random delay
                                    withAnimation(.bouncy){
                                        load = true
                                    }
                                }
                            }
                            .padding(.top, 10)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)

        .frame(maxWidth: .infinity)
                .background{
                    LinearGradient(
                                gradient: Gradient(stops: [
                                    .init(color: Color(red: 0, green: 0, blue: 0, opacity: 0.8), location: 0),
                                    .init(color: Color(red: 0, green: 0, blue: 0, opacity: 0.4), location: 0.5),
                                    .init(color: Color(red: 0, green: 0, blue: 0, opacity: 0), location: 1)
                                ]),
                                startPoint: .bottom,
                                endPoint: .top
                            )
                        .ignoresSafeArea()
                }

            }
#if os(iOS) || os(visionOS)
            .navigationTitle("")
            .navigationBarHidden(true)
            #endif
            .coordinateSpace(name: "scroll")
            .safeAreaInset(edge: .top, content: {
                Color.clear.frame(height: 80)
            })
            .overlay(alignment: .top){
                FluidNavigationBar(title: "Sync with Cosmic", titleColor: .white,   tintColor: .white, compactMode: true, type: .back, scrolled: $scrolled, content: {
                    
                }, toolbar: {
                    
                })
            }
        }
        .foregroundStyle(.white)

    }

}


struct cosmicBackground: View {
    var body: some View {
        ZStack {
            RadialGradient(
                gradient: Gradient(stops: [
                    .init(color: Color("purple/main"), location: 0.5055999755859375),
                    .init(color: Color("purple/main-2"), location: 1)]),
                center: UnitPoint(x: 0.5000000620586026, y: 0),
                startRadius: 2.009228053884991,
                endRadius: 223.60679346929834
            )


//            RadialGradient(
//                gradient: Gradient(stops: [
//                    .init(color: Color(#colorLiteral(red: 0.1764705926, green: 0.01176470611, blue: 0.5607843399, alpha: 1)), location: 0),
//                    .init(color: Color(#colorLiteral(red: 0.3294117748737335, green: 0, blue: 0.2823529541492462, alpha: 1)), location: 0.5555999755859375),
//                    .init(color: Color(#colorLiteral(red: 0, green: 0, blue: 0.15294118225574493, alpha: 1)), location: 1)]),
//                center: UnitPoint(x: 0.5000000620586026, y: 0.499567378432425),
//                startRadius: 2.009228053884991,
//                endRadius: 403.60679346929834
//            )
//            .opacity(0.3)

            //                LinearGradient(
            //                    gradient: Gradient(stops: [
            //                        .init(color: Color(#colorLiteral(red: 0.1098039373755455, green: 0.06666667759418488, blue: 0.20392157137393951, alpha: 0)), location: 0.6770833134651184),
            //                        .init(color: Color(#colorLiteral(red: 0.10980392247438431, green: 0.06666667014360428, blue: 0.20392157137393951, alpha: 1)), location: 0.8802083134651184)]),
            //                    startPoint: UnitPoint(x: 0.5, y: -3.0616171314629196e-17),
            //                    endPoint: UnitPoint(x: 0.5, y: 0.9999999999999999))

            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: Color("purple/overlay"), location: 0),
                    .init(color: Color("purple/overlay").opacity(0), location: 1)]),
                startPoint: UnitPoint(x: 0.2162849736372674, y: -0.17605632821586972),
                endPoint: UnitPoint(x: 1.2849872464096836, y: 0.9999999973325171))
            .blendMode(.color)

            .opacity(0.5)



        }
        .drawingGroup()
        
        .ignoresSafeArea()
    }
}
