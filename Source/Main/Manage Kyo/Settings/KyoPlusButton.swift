//
//  KyoPlusButton\.swift
//  KyoNeo
//
//  Created by Aether on 22/01/2024.
//

import SwiftUI

struct KyoPlusButton: View {
    var color: Color
    @Binding var kyoPlus_hasPlus: Bool
    @State var kyoPlus_showPurchaseScreen: Bool = false

    var text: String = "Upgrade to Kyo+ to access more features and customisation options"
    var emoji: String = "🚀"
    var body: some View {
        ZStack{
            if !kyoPlus_hasPlus{
                Button {
                    kyoPlus_showPurchaseScreen.toggle()
                } label: {
                    VStack(alignment: .leading){
                        Text(text)
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

#if os(visionOS)
                .buttonStyle(PolishedButton(color: color, background: true))
#else
                .buttonStyle(PolishedButton(color: color, background: true))
#endif

                .overlay(alignment: .bottomTrailing, content: {
                    Text(emoji)
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
                                Text(emoji)
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
                    KyoPlus(color: color)
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
                .onAppear{

                    // FIX: No purchase check is needed; access follows the local Pro setting.

                }

            }
        }

    }
}

struct KyoPlusButtonBinding: View {
    var color: Color
    @Binding var kyoPlus_hasPlus: Bool
    @Binding var kyoPlus_showPurchaseScreen: Bool

    var text: String = "Upgrade to Kyo+ to access more features and customisation options"
    var emoji: String = "🚀"
    var rotation: Double = -20
    var position: CGPoint = CGPoint(x: 13, y: 11)

    var actionIfNot: (() -> Void)? = nil
    var body: some View {
        ZStack{
            if !kyoPlus_hasPlus{
                Button {
                    kyoPlus_showPurchaseScreen.toggle()
                } label: {
                    VStack(alignment: .leading){
                        Text(text)
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

#if os(visionOS)
                .buttonStyle(PolishedButton(color: color, background: true))
#else
                .buttonStyle(PolishedButton(color: color, background: true))
#endif

                .overlay(alignment: .bottomTrailing, content: {
                    Text(emoji)
                        .font(.system(size: 60))
                        .stroke(color: Color.white, width: 4)
                        .overlay(content: {
                            LinearGradient(stops:
                                            [
                                                Gradient.Stop(color: Color.clear, location: 0.0),
                                                Gradient.Stop(color: Color.white.opacity(0.3), location: 0.7),
                                                Gradient.Stop(color: Color.clear, location: 1.0)
                                            ],
                                           startPoint: .top, endPoint: .bottom)
                            .mask {
                                Text(emoji)
                                    .font(.system(size: 60))
                            }
                        })
                        .rotationEffect(Angle(degrees: rotation))
                        .offset(x: position.x, y: position.y)
                        .shadow(color: .black.opacity(0.15), radius: 3, y: 3)


                })
                .padding(.horizontal, 20)
                .sheet(isPresented: $kyoPlus_showPurchaseScreen, onDismiss: {

                    // FIX: No purchase check is needed; access follows the local Pro setting.

                }, content: {
#if !os(visionOS)
                    KyoPlus(color: color)
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
            else{
                Color.clear.frame(height: 1)
                   
            }
        }
        .onAppear{

                               // FIX: No purchase check is needed; access follows the local Pro setting.

                           }

    }
}
