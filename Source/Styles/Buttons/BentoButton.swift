//
//  BentoButton.swift
//  KyoNeo
//
//  Created by Aether on 10/07/2023.
//

import SwiftUI

public struct BentoButton: ButtonStyle {
    /// The corner radius of the button.
    var cornerRadius: CGFloat = 14
    /// The main color of the button.
    var color: Color = .blue
    /// The background tint color of the button.
    var backgroundTint: Color = Color("NeoButton")
    /// The role of the button.
    var role: neoButtonRole = .regularAction
    /// Binding to determine whether the button is scrolled.
    @Binding var scrolled: Bool

    /// Creates a BentoButton style with the specified properties.
    ///
    /// - Parameters:
    ///   - cornerRadius: The corner radius of the button. Default is 14.
    ///   - color: The main color of the button. Default is blue.
    ///   - backgroundTint: The background tint color of the button. Default is NeoButton color.
    ///   - scrolledLookBehaviour: The behavior of the button when scrolled. Default is regularOverlayMode.
    ///   - role: The role of the button. Default is regularAction.
    ///   - scrolled: Binding to determine whether the button is scrolled.
    public init(cornerRadius: CGFloat = 14,
                color: Color = .blue,
                backgroundTint: Color = Color("NeoButton"),

                role: neoButtonRole = .regularAction,
                scrolled: Binding<Bool> = .constant(false)) {
        self.cornerRadius = cornerRadius
        self.color = color
        self.backgroundTint = backgroundTint
        self.role = role
        self._scrolled = scrolled
    }

    /// Creates the body for the button style.
    ///
    /// - Parameter configuration: The configuration of the button.
    /// - Returns: A view representing the body of the button.
    public func makeBody(configuration: Self.Configuration) -> some View {
        // Determine the actual color based on the button role
        let actualColor = (role == .regularAction ? color :
                            role == .destructive ? .red :
                            color
        )

        let actualTintBgColor = (role == .regularAction ? backgroundTint :
                                    role == .destructive ? .red.opacity(0.2) :
                                    role == .create ? .accentColor :
                            backgroundTint
        )

        return configuration.label
            // Apply blend mode based on scrolledLookBehaviour setting

            .padding(11)
            .foregroundColor(scrolled ? .primary : actualColor)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
            .opacity(configuration.isPressed ? 0.4 : 1)
            .background {
                Color.clear
                    .background(Color("bw").opacity(0.6))
                    .overlay(actualTintBgColor.opacity(0.3))
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                    .shadow(color: actualColor.opacity(0.05), radius: 7, x: 0, y: 8)
                    .overlay(RoundedRectangle(cornerRadius: cornerRadius).stroke(actualColor.opacity(0.2), lineWidth: 1.5))
                    .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
                    .blur(radius: configuration.isPressed ? 0.5 : 0)
                    .animation(.bouncy, value: configuration.isPressed)
            }
            .dynamicTypeSize(.large ... .xLarge)
    }
}
