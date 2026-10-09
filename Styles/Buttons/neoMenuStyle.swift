//
//  neoMenuStyle.swift
//  KyoNeo
//
//  Created by Aether on 21/03/2023.
//

import SwiftUI

#if !os(tvOS)
//struct neoNavigationMenu: MenuStyle {
//    var cornerRadius: CGFloat = 14
//    var color: Color = .blue
//    var role: neoButtonRole = .regularAction
//    @Binding var scrolled: Bool
//    @Environment(\.colorScheme) var colorScheme
//
//    func makeBody(configuration: Self.Configuration) -> some View {
//
//        let actualColor = (role == .regularAction ? color :
//                            role == .destructive ? .red :
//                            color
//        )
//        Menu(configuration)
//            .foregroundColor(scrolled ? .primary : actualColor)
//            .background(Color("NeoButton").opacity(colorScheme == .dark ? 0.6 : 0.4), in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
//
//        // .strokeStyle(cornerRadius: 14)
//            .shadow(color: scrolled ? .primary.opacity(colorScheme == .dark ? 0.1 : 0.4)
//
//                    :
//
//                actualColor
//                .opacity(0.3), radius: 5, x:0, y: 5)
//            .neoOutline(cornerRadius: cornerRadius, lineWidth: 1.5)
////            .overlay(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous).stroke(
////                actualColor.opacity(0.1)
////                , lineWidth: 1.17))
//
//    }
//}


struct neoMenu: MenuStyle {
    var cornerRadius: CGFloat = 14
    var color: Color = .blue
    var role: neoButtonRole = .regularAction
    @Environment(\.colorScheme) var colorScheme

    // This function creates the menu's appearance.
    // It takes a configuration object and returns a View.
    func makeBody(configuration: Self.Configuration) -> some View {

        // Determine the menu's actual color based on its role.
        let actualColor = (role == .regularAction ? color :
                            role == .destructive ? .red :
                            color
        )

        // Create the menu with the actual color as the foreground color.
        Menu(configuration)
            .foregroundColor(actualColor)

            // Add padding and a background color to the menu.
            .padding(12)

        .background(Color("NeoButton").opacity(colorScheme == .dark ? 0.6 : 0.3), in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))

            // Add a material and shadow effect to the menu.
            .background(Color("NeoButton").opacity(colorScheme == .dark ? 0.6 : 0.3), in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .shadow(color: actualColor
                .opacity((Double(actualColor.getBrightness() / (colorScheme == .dark ? 3 : 1.9)))), radius: 7, x:0, y: 8)

            // Add an overlay that creates a stroke border around the menu.
            // The color and opacity of the border depend on the color scheme.
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: actualColor.opacity(0.2), location: 0),
                            .init(color: actualColor.opacity(0.1), location: 1)]),
                        startPoint: UnitPoint(x: -2.220446049250313e-16, y: -2.220446049250313e-16),
                        endPoint: UnitPoint(x: 0.9999999999999998, y: 0.9999999999999998)), lineWidth: 1.1666667461395264)
                    .opacity(colorScheme == .dark ? 0.5 : 1)
            )
    }
}


#endif
