//
//  SectionTitleStyle.swift
//  KyoNeo
//
//  Created by Aether on 22/01/2023.
//

import SwiftUI

struct SectionTitleStyle: ViewModifier {
    var topPadding: CGFloat
    var bottomPadding: CGFloat
    var verticalPadding: CGFloat
    var horizontalPadding: CGFloat
    var font: Font = .caption
    func body(content: Content) -> some View {
        content
//            .textCase(.uppercase)
            .font(font.weight(.regular))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, bottomPadding)
            .padding(.top, topPadding)

        .padding(.vertical,  verticalPadding)
    }
}

struct SectionTitleStyleWithoutFrame: ViewModifier {
    var topPadding: CGFloat
    var bottomPadding: CGFloat
    var verticalPadding: CGFloat
    var horizontalPadding: CGFloat

    var font: Font = .caption
    func body(content: Content) -> some View {
        content
//            .textCase(.uppercase)
            .font(font.weight(.regular))
            .padding(.bottom, bottomPadding)
            .padding(.top, topPadding)

        .padding(.vertical,  verticalPadding)
    }
}



extension View {
    func sectionTitle(topPadding: CGFloat = 8, bottomPadding: CGFloat = 4, verticalPadding: CGFloat = 3, horizontalPadding: CGFloat = 25, font: Font = .caption) -> some View{
        modifier(SectionTitleStyle(topPadding: topPadding, bottomPadding: bottomPadding, verticalPadding: verticalPadding, horizontalPadding: horizontalPadding, font: font))
    }

    func framelessSectionTitle(topPadding: CGFloat = 8, bottomPadding: CGFloat = 4, verticalPadding: CGFloat = 3, horizontalPadding: CGFloat = 25, font: Font = .caption) -> some View{
        modifier(SectionTitleStyleWithoutFrame(topPadding: topPadding, bottomPadding: bottomPadding, verticalPadding: verticalPadding, horizontalPadding: horizontalPadding, font: font))
    }
}
