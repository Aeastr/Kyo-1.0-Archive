//
//  neoSettingsCard.swift
//  KyoNeo
//
//  Created by Aether on 11/03/2023.
//

import SwiftUI


struct neoSettingsCardModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    var cornerRadius: CGFloat = 18
    func body(content: Content) -> some View {
        content

            .buttonStyle(.plain)
            .padding(.horizontal, 2)
            .padding(13)
        #if !os(visionOS)
            .background {
                Color("NeoButton").opacity(0.6)
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                    .regularOutline(cornerRadius: cornerRadius)

            }
        #else
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .regularOutline(cornerRadius: cornerRadius)
        #endif

    }
}

struct neoSettingsToggleModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme

    func body(content: Content) -> some View {
        content
        .padding(.horizontal, 2)
        .padding(.horizontal, 13)
        .padding(.vertical, 9)
        .background {
            Color("NeoButton").opacity(0.6)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .regularOutline()

        }
    }
}

extension View {
    func neoSettingsCard(cornerRadius: CGFloat = 18) -> some View{
        modifier(neoSettingsCardModifier(cornerRadius: cornerRadius))
    }
    func neoSettingsToggle() -> some View{
        modifier(neoSettingsToggleModifier())
    }
}
