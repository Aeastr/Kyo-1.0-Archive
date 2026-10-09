//
//  File.swift
//  KyoNeo
//
//  Created by Aether on 11/03/2023.
//

import SwiftUI
import AmethystUI

struct neoFieldCardModifier: ViewModifier {
    var padding = 15.0
    var accent = Color.clear
    var color = Color.primary
    func body(content: Content) -> some View {
        content
            .padding(.vertical, padding)
            .background(accent.opacity(0.1))
            .background (
                Color("NeoButton").opacity(0.4)
            )
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .regularOutline(color: color)

    }
}


extension View {
    func neoFieldCard(padding: Double = 15.0, accent: Color = Color.clear, color: Color = Color.primary.opacity(0.4)) -> some View{
        modifier(neoFieldCardModifier(padding: padding, accent: accent, color: color))
    }
}


