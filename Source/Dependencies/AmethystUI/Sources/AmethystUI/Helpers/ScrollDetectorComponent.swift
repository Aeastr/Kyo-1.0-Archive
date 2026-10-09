//
//  SwiftUIView.swift
//  
//
//  Created by Aether on 13/06/2023.
//

import SwiftUI

public struct ScrollDetector: View {
    @Binding var scrolled: Bool
    var scrollTrigger: CGFloat = -13
    @Binding var scrolledFar: Bool
    var scrollFarTrigger: CGFloat = -200
    @Binding var scrollValue: Double

    public init(scrolled: Binding<Bool> = .constant(false), scrollTrigger: CGFloat = -13, scrolledFar: Binding<Bool> = .constant(false), scrollFarTrigger: CGFloat = -200, scrollValue: Binding<Double> = .constant(0.0)) {
        self._scrolled = scrolled
        self.scrollTrigger = scrollTrigger
        self._scrolledFar = scrolledFar
        self.scrollFarTrigger = scrollFarTrigger
        self._scrollValue = scrollValue
    }

    public var body: some View {
        GeometryReader { proxy in
            Color.clear
                .preference(key: ScrollPreferenceKey.self, value: proxy.frame(in: .named("scroll")).minY)
        }
        .frame(height: 0)
        .onPreferenceChange(ScrollPreferenceKey.self, perform: { value in
            withAnimation(.spring(response: 0.1, dampingFraction: 3)) {
                scrollValue = value
                scrolled = value < scrollTrigger
                scrolledFar = value < scrollFarTrigger
            }
        })
    }
}

struct ScrollPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

