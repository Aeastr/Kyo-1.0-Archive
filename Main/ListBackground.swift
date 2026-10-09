//
//  ListBackground.swift
//  KyoNeo
//
//  Created by Aether on 09/05/2024.
//

import SwiftUI

struct ListBackground: View {
    @Environment(\.colorScheme) var colorScheme
    var radius: CGFloat = 18
    var mode: outLineMode = .all
    var body: some View {
        ZStack{
            UnevenRoundedRectangle(
                cornerRadii: RectangleCornerRadii(
                    topLeading: mode == .top ? radius : 0,
                    bottomLeading: mode == .bottom ? radius: 0, bottomTrailing: mode == .bottom ? radius : 0, topTrailing: mode == .top ? radius : 0),
                style: .continuous
            )
            .strokeBorder(Color("splitter").opacity(colorScheme == .dark ? 0.22 : 0.15), lineWidth: 0.8)

        }
        .padding(.bottom, mode == .top ? -3 : 0)
        .padding(.top, mode == .bottom ? -3 : 0)

    }
}

#Preview {
    ListBackground()
}

struct TotalHeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value += nextValue()
    }
}

struct HeightReporter: ViewModifier {
    func body(content: Content) -> some View {
        content

            .opacity(0.2)
            .background(GeometryReader { geometry in
            Color.red
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                .preference(key: TotalHeightPreferenceKey.self, value: geometry.size.height)
                .overlay {
                    Text("\(geometry.size.height)")
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
        })
    }
}
