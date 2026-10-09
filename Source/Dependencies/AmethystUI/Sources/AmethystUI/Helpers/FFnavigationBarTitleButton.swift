//
//  SwiftUIView.swift
//  
//
//  Created by Aether on 09/06/2023.
//

import SwiftUI

struct FFnavigationBarTitleButton: ButtonStyle {

    // Define the body of the ButtonStyle
    func makeBody(configuration: Self.Configuration) -> some View {

        configuration.label
            .scaleEffect(x: configuration.isPressed ? 1.0 : 1.0 , y:configuration.isPressed ? 1.2 : 1.0)
            .opacity(configuration.isPressed ? 0.7 : 1)
            .scaleEffect(x: configuration.isPressed ? 0.85 : 1.0 , y:configuration.isPressed ? 0.65 : 1.0)
            .animation(.easeOut, value: configuration.isPressed)

            .offset(x: configuration.isPressed ? -22 : 0)

    }
}

struct FFnavigationBarButtons: ButtonStyle {

    // Define the body of the ButtonStyle
    func makeBody(configuration: Self.Configuration) -> some View {

        configuration.label
            .scaleEffect(x: configuration.isPressed ? 1.0 : 1.0 , y:configuration.isPressed ? 1.2 : 1.0)
            .opacity(configuration.isPressed ? 0.7 : 1)
            .scaleEffect(x: configuration.isPressed ? 0.9 : 1.0 , y:configuration.isPressed ? 0.7 : 1.0)
            .animation(.easeOut, value: configuration.isPressed)

    }
}
