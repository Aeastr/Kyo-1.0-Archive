//
//  NavigationMenu(Deprecated).swift
//  KyoNeo
//
//  Created by Aether on 22/07/2023.
//

import SwiftUI


public struct NavigationMenu: MenuStyle {
    // Properties
    var cornerRadius: CGFloat = 14
    var color: Color = .blue
    var scrolledLookBehaviour: scrolledLookBehaviourSetting = .regularOverlayMode
    var role: neoButtonRole = .regularAction
    @Environment(\.colorScheme) var colorScheme
    @Binding var scrolled: Bool

    // Public initializer
    public init(cornerRadius: CGFloat = 14,
                color: Color = .blue,
                scrolledLookBehaviour: scrolledLookBehaviourSetting = .regularOverlayMode,
                role: neoButtonRole = .regularAction,
                scrolled: Binding<Bool>) {
        self.cornerRadius = cornerRadius
        self.color = color
        self.scrolledLookBehaviour = scrolledLookBehaviour
        self.role = role
        self._scrolled = scrolled
    }

    // ButtonStyle method
    public func makeBody(configuration: Self.Configuration) -> some View {

        // Determine the actual color based on the button role
        let actualColor = (role == .regularAction ? color :
                            role == .destructive ? .red :
                            color
        )


        // Create the menu with the actual color as the foreground color.
        Menu(configuration)

            // Apply blend mode based on scrolledLookBehaviour setting


            .foregroundColor(scrolled ? .primary : actualColor)




            .background {
                Color("navButton")
                    .opacity(colorScheme == .dark ? 0.5 : 0.4)
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                    .shadow(color: actualColor.opacity(scrolled ? 0.05 : 0.15), radius: 5, x: 0, y: 4)
                    .overlay(RoundedRectangle(cornerRadius: cornerRadius).strokeBorder((scrolled ? .primary : actualColor).opacity(colorScheme == .dark ? 0.15 : scrolled ? 0.15 : 0.3), lineWidth: 1.4))


            }
#if !os(macOS)
        .hoverEffect()
        #endif

    }
}
