//
//  bounce.swift
//  KyoNeo
//
//  Created by Aether on 01/04/2023.
//

import SwiftUI

struct expbounceButton: ButtonStyle {
    var offset: Bool = false
    // Define the body of the ButtonStyle
    func makeBody(configuration: Self.Configuration) -> some View {

        configuration.label
            .scaleEffect(x: configuration.isPressed ? 1.0 : 1.0 , y:configuration.isPressed ? 1.2 : 1.0)
            .opacity(configuration.isPressed ? 0.7 : 1)
            .scaleEffect(x: configuration.isPressed ? 0.9 : 1.0 , y:configuration.isPressed ? 0.7 : 1.0)
            .offset(x: configuration.isPressed && offset ? 3.95 : 0.0)
            .animation(.easeOut, value: configuration.isPressed)


    }
}

struct bounceButton: ButtonStyle {

    // Define the body of the ButtonStyle
    func makeBody(configuration: Self.Configuration) -> some View {

        configuration.label
            .scaleEffect(x: configuration.isPressed ? 1.0 : 1.0 , y:configuration.isPressed ? 1.2 : 1.0)
            .opacity(configuration.isPressed ? 0.7 : 1)
            .scaleEffect(x: configuration.isPressed ? 0.9 : 1.0 , y:configuration.isPressed ? 0.7 : 1.0)
            .animation(.easeOut, value: configuration.isPressed)

    }
}

struct menuButton: ButtonStyle{
    var foreground: Color
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body.weight(.semibold))
        //    .regularOutline()
            .foregroundColor(foreground)
            .scaleEffect(x: configuration.isPressed ? 0.8 : 1.0 , y:configuration.isPressed ? 0.7 : 1.0)
            .animation(.easeOut, value: configuration.isPressed)
            .opacity(configuration.isPressed ? 0.5 : 1)

            .background{
                Color.white
                    .opacity(0.8)
                    .clipShape(Capsule())
                    .scaleEffect(x: configuration.isPressed ? 0.8 : 1.0 , y:configuration.isPressed ? 0.7 : 1.0)
                    .animation(.easeOut, value: configuration.isPressed)
            }


    }
}

struct BouncyButton: ButtonStyle {

    // Define the body of the ButtonStyle
    func makeBody(configuration: Self.Configuration) -> some View {

        configuration.label
            .scaleEffect(x: configuration.isPressed ? 0.8 : 1.0 , y:configuration.isPressed ? 0.7 : 1.0)
            .animation(.easeOut, value: configuration.isPressed)

    }
}

struct PlannerClassItem: ButtonStyle {

    // Define the body of the ButtonStyle
    func makeBody(configuration: Self.Configuration) -> some View {

        configuration.label
            .scaleEffect(x: configuration.isPressed ? 0.95 : 1.0 , y:configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeOut, value: configuration.isPressed)

    }
}
