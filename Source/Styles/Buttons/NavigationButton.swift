//
//  NavigationButton.swift
//  KyoNeo
//
//  Created by Aether on 10/07/2023.
//

import SwiftUI
import AmethystUI

public enum scrolledLookBehaviourSetting{
    case regularOverlayMode
    case keepColor
    case noChange
}

public struct NavigationButton: ButtonStyle {
    // Properties
    var cornerRadius: CGFloat = 14
    var color: Color = .blue
    var scrolledLookBehaviour: scrolledLookBehaviourSetting = .regularOverlayMode
    var role: neoButtonRole = .regularAction
    @Environment(\.colorScheme) var colorScheme
    @Binding var scrolled: Bool
    var width: Double?
    var height: Double?
    var fillBg: Bool
    // Public initializer
    public init(cornerRadius: CGFloat = 14,
                color: Color = .blue,
                scrolledLookBehaviour: scrolledLookBehaviourSetting = .regularOverlayMode,
                role: neoButtonRole = .regularAction,
                scrolled: Binding<Bool>,

     width: Double? = nil,
     height: Double? = nil,
                fillBackground: Bool = false
    ) {
        self.cornerRadius = cornerRadius
        self.color = color
        self.scrolledLookBehaviour = scrolledLookBehaviour
        self.role = role
        self._scrolled = scrolled
        self.width = width
        self.height = height
        self.fillBg = fillBackground
    }
    

    // ButtonStyle method
    public func makeBody(configuration: Self.Configuration) -> some View {
        // Determine the actual color based on the button role
        let actualColor = (role == .regularAction ? color :
                            role == .destructive ? .red :
                            color
        )

        return configuration.label

            // Apply blend mode based on scrolledLookBehaviour setting

            .scaledFrame(width: width, height: height, relativeTo: .body)
            .foregroundColor(scrolled ? .primary : fillBg ? .white : actualColor)

            .background {
                if !fillBg{
                    Color("navButton")
                        .opacity(colorScheme == .dark ? 0.5 : 0.6)
                        .background(BackdropBlurView(radius: 4))


                }
                else{
                    Color(actualColor)


                }
            }
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .shadow(color: actualColor.opacity(scrolled ? 0.04 : 0.07), radius: 5, x: 0, y: 4)
            .overlay(RoundedRectangle(cornerRadius: cornerRadius).strokeBorder((scrolled ? .primary : actualColor).opacity(colorScheme == .dark ? 0.3 : scrolled ? 0.15 : 0.3), lineWidth: 1.4))
            .animation(.easeOut(duration: 0.3)) { content in
                content
                    .scaleEffect(configuration.isPressed ? 0.73 : 1.0)
                
                    .opacity(configuration.isPressed ? 0.55 : 1)
                }
            .animation(.bouncy(duration: 0.45, extraBounce: 0.0), value: fillBg)

//            .hoverEffect()

    }
}


