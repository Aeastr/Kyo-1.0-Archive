//
//  NavigationTitleBg.swift
//  KyoNeo
//
//  Created by Aether on 05/02/2024.
//

import SwiftUI
import AmethystUI

struct NavigationTitleBg: View {
    var body: some View {
#if !os(macOS)
        VariableBlurView()
                            .overlay(content: {
                                LinearGradient(stops: [Gradient.Stop(color: .white, location: 0.5), Gradient.Stop(color: .white.opacity(0.0), location: 1.0)], startPoint: .top, endPoint: .bottom).opacity(0.5)
                            })
                                    .frame(maxHeight: 105)
                                    .ignoresSafeArea()
        #endif
    }
}

#Preview {
    NavigationTitleBg()
}

struct VerticalLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack {
            configuration.icon.font(.headline)
            configuration.title.font(.subheadline)
        }
    }
}
