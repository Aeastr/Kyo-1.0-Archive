//
//  old.swift
//  KyoNeo
//
//  Created by Aether on 24/03/2023.
//

import SwiftUI

struct old: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct old_Previews: PreviewProvider {
    static var previews: some View {
        old()
    }
}

struct neoNavigationButtonViewMod: ViewModifier {
    var cornerRadius: CGFloat
    var color: Color
    @Environment(\.colorScheme) var colorScheme
    @Binding var scrolled: Bool


    func body(content: Content) -> some View {
        content
            .foregroundColor(scrolled ? .primary : color)
            .background(.white.opacity(colorScheme == .dark ? 0.2 : 0.5), in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))

        // .strokeStyle(cornerRadius: 14)
            .shadow(color: scrolled ? .primary.opacity(0.3) : color.opacity(0.2), radius: 7, x:0, y: 8)
            .neoOutline(cornerRadius: cornerRadius)

    }
}

struct neoButtonMod: ViewModifier {
    var cornerRadius: CGFloat
    var color: Color
    @Environment(\.colorScheme) var colorScheme
    @Binding var scrolled: Bool


    func body(content: Content) -> some View {
        content
            .foregroundColor(scrolled ? .primary : color)
            .background(.white.opacity(colorScheme == .dark ? 0.2 : 0.2), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))

        // .strokeStyle(cornerRadius: 14)
            .shadow(color: color.opacity(0.05), radius: 7, x:0, y: 8)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.5)), location: 0),
                            .init(color: Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)), location: 1)]),
                        startPoint: UnitPoint(x: -2.220446049250313e-16, y: -2.220446049250313e-16),
                        endPoint: UnitPoint(x: 0.9999999999999998, y: 0.9999999999999998)), lineWidth: 1.1666667461395264)
                    .opacity(colorScheme == .dark ? 0.5 : 1)
            )

    }
}

extension View {
    func neoNavigationButtonStyle(cornerRadius: CGFloat = 14, color: Color = Color("2"), scrolled: Binding<Bool> = .constant(false)) -> some View{
        modifier(neoNavigationButtonViewMod(cornerRadius: cornerRadius, color: color, scrolled: scrolled))
    }

    func neoButtonOld(cornerRadius: CGFloat = 14, color: Color = Color("2"), scrolled: Binding<Bool> = .constant(false)) -> some View{
        modifier(neoButtonMod(cornerRadius: cornerRadius, color: color, scrolled: scrolled))
    }
}
