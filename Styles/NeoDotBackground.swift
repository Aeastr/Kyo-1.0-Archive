//
//  NeoDotBackground.swift
//  KyoNeo
//
//  Created by Aether on 04/04/2023.
//

import SwiftUI

struct NeoDotBackground: View{
    @Environment(\.colorScheme) var colorScheme
    var color1: Color
    var color2: Color = .white
    var gradient: Bool = false
    var opacity: Double =   0.035
    var body: some View{
        ZStack{

            if colorScheme == .dark{
                Image("dots")
                    .resizable()
                    .colorInvert()
                    .ignoresSafeArea()
                    .blendMode(.normal)
                    .opacity(0.1)
            }
            else{
                Image("dots")
                    .resizable()
                    .ignoresSafeArea()
                    .opacity(0.1)
            }
            if gradient{
                LinearGradient(gradient: Gradient(colors: [color1.opacity(colorScheme == .light ? opacity * 1.1 : opacity), color2.opacity(colorScheme == .light ? opacity * 1.1 : opacity)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()

            }
            else{
                color1
                    .ignoresSafeArea()
                    .opacity(colorScheme == .light ? opacity - 0.005 : opacity + 0.005)
            }
        }
    }
}
