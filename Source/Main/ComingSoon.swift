//
//  ComingSoon.swift
//  KyoNeo
//
//  Created by Aether on 30/04/2023.
//

import SwiftUI

import SwiftUI
struct ComingSoon: View{
    var night = false
    @Environment(\.colorScheme) var colorScheme

    var body: some View{
        ZStack {
            Color("BackgroundNight").ignoresSafeArea()
            VStack {
                Shimmer {
                                AnyView(
                                    VStack{
                                        Text("""
                                        .  *  .                 .  *  .                    .  *  .          .       .         *
                            .                               *
                                    .             .                      .          *          *      .          .       .
                                *                         .              .               .
                        .                                  .                         .     .                   *
                .                    .           .     .              .         .  *  .               .        .     .
                                    *                       .      *                .     .
                     .  *        .                               *                 .       . .          *.         .  *  .
                """)
                                        .shadow(color: .white, radius: 2)
                                        .frame(width: 700, alignment: .center)
                                        .foregroundColor(night ? .white : .primary)
                                        .font(Font.body.weight(.bold))


                                        Text("""
                                        .  *  .                 .  *  .                    .  *  .          .       .         *
                            .          \\                     *
                                    .   \\           .                      .          *          *      .          .       .
                                *        \\                 .              .               .
                        .                 *                 .                         .     .                   *
                .                    .           .     .              .         .  *  .               .        .     .
                                    *                       .      *                .     .
                     .  *        .                                                      .                .  *  .
                                             .                              .                       *.
                """)
                                        .shadow(color: .white, radius: 2)
                                        .frame(width: 700, alignment: .center)
                                        .foregroundColor(night ? .white : .primary)
                                        .font(Font.body.weight(.bold))
                                    })
                }.ignoresSafeArea()
                    .offset(y: -60)


                HStack {
                    Spacer()
                    VStack{
                        Spacer().frame(width: 200)
                        if colorScheme == .light && !night {
                            Image("cat")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 100)
                                .padding(.horizontal, 20)
                                .colorInvert()
                        }
                        else{
                            Image("cat")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 100)
                                .padding(.horizontal, 20)
                        }

                        Text("We're working on it")
                            .padding()
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(night ? .white : .primary)

                        Text("Kyo Goals is designed to help motiviate your study, coming soon")
                            .padding()
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(night ? .white : .primary)

                        Spacer().frame(height: 130)
                    }
                    Spacer()
                }
            }.ignoresSafeArea()
        }
    }
}

struct ComingSoon_Previews: PreviewProvider {
    static var previews: some View {
        ComingSoon()
    }
}


struct Shimmer: View {
    @State private var animation = false
    var content: () -> AnyView

    var body: some View {
        ZStack {

            Color.white.opacity(0.1)

            .mask(content())
            .blur(radius: 2)

            LinearGradient(gradient: Gradient(colors: [Color.white.opacity(0),Color.yellow.opacity(0.3), Color.white.opacity(0.8), Color.white.opacity(0.1)]), startPoint: .leading, endPoint: .trailing).ignoresSafeArea()
                .offset(x: animation ? 600 : -600)
                .mask(content())
                .animation(Animation.linear(duration: 5).repeatForever(autoreverses: false))
                .onAppear {
                    self.animation.toggle()
                }
        }
    }}
