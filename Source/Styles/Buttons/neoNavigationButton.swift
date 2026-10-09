//
//  neoNavigationButton.swift
//  KyoNeo
//
//  Created by Aether on 27/11/2022.
//

import SwiftUI

//struct neoNavigationButton: ButtonStyle {
//    var cornerRadius: CGFloat = 14
//    var color: Color = .blue
//    var role: neoButtonRole = .regularAction
//    @Environment(\.colorScheme) var colorScheme
//    @Binding var scrolled: Bool
//
//    func makeBody(configuration: Self.Configuration) -> some View {
//
//        let actualColor = (role == .regularAction ? color :
//                            role == .destructive ? .red :
//                            color
//        )
//        configuration.label
//            .foregroundColor(scrolled ? .primary : actualColor.moreSaturated(factor: 1))
//
//            .scaleEffect(x: configuration.isPressed ? 1.2 : 1.0)
//           
//            .background(Color("NeoButton").opacity(0.3), in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
//
//        // .strokeStyle(cornerRadius: 14)
//            .shadow(color: scrolled ? .primary.opacity(colorScheme == .dark ? 0.1 : 0.2)
//
//                    :
//
//                actualColor
//                .opacity(0.4), radius: 7, x:0, y: 8)
//            .neoOutline(cornerRadius: cornerRadius)
//
//
//        .scaleEffect(configuration.isPressed ? 0.7 : 1.0)
//        .opacity(configuration.isPressed ? 0.4 : 1)
//        .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
//    }
//}


struct borderlessButton: ButtonStyle {
    var cornerRadius: CGFloat = 14
    var color: Color = .blue
    var role: neoButtonRole = .regularAction
    @Environment(\.colorScheme) var colorScheme
    @Binding var scrolled: Bool

    func makeBody(configuration: Self.Configuration) -> some View {

        let actualColor = (role == .regularAction ? color :
                            role == .destructive ? .red :
                            color
        )
        configuration.label
            .foregroundColor(scrolled ? .primary : actualColor.moreSaturated(factor: 1))
            .saturation(1.3)
            .scaleEffect(x: configuration.isPressed ? 1.2 : 1.0)

            .opacity(configuration.isPressed ? 0.5 : 1)


        // .strokeStyle(cornerRadius: 14)
            .shadow(color: scrolled ? .primary.opacity(colorScheme == .dark ? 0.1 : 0.2)

                    :

                actualColor
                .opacity(0.4), radius: 7, x:0, y: 8)


        .scaleEffect(configuration.isPressed ? 0.7 : 1.0)
        .animation(.easeOut(duration: 0.4), value: configuration.isPressed)

    }
}



