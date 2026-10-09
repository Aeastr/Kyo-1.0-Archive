//
//  PolishedButton.swift
//  KyoNeo
//
//  Created by Aether on 24/03/2023.
//

import SwiftUI

struct PolishedButton: ButtonStyle {

    // Define properties for the corner radius, color, and role of the button
    var cornerRadius: CGFloat = 18
    var color: Color = Color("1")
    var role: neoButtonRole = .regularAction
    var background = false
    var compact: Bool = false

    // Access the color scheme environment variable
    @Environment(\.colorScheme) var colorScheme

    // Define the body of the ButtonStyle
    func makeBody(configuration: Self.Configuration) -> some View {

        // Determine the actual color of the button based on its role
        let actualColor = (role == .regularAction ? color :
                            role == .destructive ? .red :
                            color
        )

        // Create the basic button using various SwiftUI modifiers
        configuration.label
            .contentTransition(.interpolate)
            .foregroundColor(background ? actualColor.isBright() ? actualColor.darken(by: 0.7) : .white : actualColor.isBright() ? actualColor.darken(by: 0.7) : actualColor)
            .opacity(configuration.isPressed ? 0.55 : 1)
            .padding(.horizontal, 15)
            .padding(.vertical, compact ? 10 : 15)
            .animation(.smooth, body: { body in
                   body.background{
                        if background {
                            Color.clear
                                .background(
                                    actualColor.gradient.opacity(1)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        }
                        else{
                            Color("NeoButton")
                                .opacity(0.6)
                                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        }

                    }
            })
            .opacity(configuration.isPressed ? 0.96 : 1.0)



            .animation(.easeOut, body: { body in
                body
                    .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(Color( color).opacity(colorScheme == .dark ? 0.22 : 1.0), lineWidth: 1.7).saturation(1.3).brightness(-0.25).opacity(configuration.isPressed ? 0.05 : 0.4))
                    .background{
                        Color.clear
                            .background ( background ? color.gradient.opacity(1) :
                                                        Color("NeoButton").gradient
                                            .opacity(0.6)

                                        )
                            .offset(y: 1.5)
                            .brightness(-0.25).opacity(0.3)
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                            .blur(radius: configuration.isPressed ? 3 : 10)
                    }
                    .overlay(RoundedRectangle(cornerRadius: cornerRadius - 2).strokeBorder(LinearGradient(gradient: Gradient(colors: [color.lighten(by: 0.7).opacity(configuration.isPressed ? 0 : 0.3), Color.black.opacity( 0)]), startPoint: .top, endPoint: .bottom), lineWidth: background ? 1.2 : 0.4).padding(2))
                    .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            })
        

    }
}

struct FlatButton: ButtonStyle {

    // Define properties for the corner radius, color, and role of the button
    var cornerRadius: CGFloat = 18
    var color: Color = Color("1")
    var role: neoButtonRole = .regularAction
    var background = false

    // Access the color scheme environment variable
    @Environment(\.colorScheme) var colorScheme

    // Define the body of the ButtonStyle
    func makeBody(configuration: Self.Configuration) -> some View {

        // Determine the actual color of the button based on its role
        let actualColor = (role == .regularAction ? color :
                            role == .destructive ? .red :
                            color
        )

        // Create the basic button using various SwiftUI modifiers
        configuration.label
            .contentTransition(.interpolate)
            .animation(.smooth)
            .foregroundColor(background ? actualColor.isBright() ? actualColor.darken(by: 0.7) : .white : actualColor.isBright() ? actualColor.darken(by: 0.7) : actualColor)
            .opacity(configuration.isPressed ? 0.3 : 1)
            .padding(.horizontal, 2)
            .padding(13)
            .padding(.vertical, 2)
            .background{
                if background {

                    Color.clear
                        .background(
                            actualColor.opacity(1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
                else{
                    Color.clear
                        .background(
                    Color("NeoButton")
                        .opacity(0.6)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                }

            }
            .opacity(configuration.isPressed ? 0.96 : 1.0)



            .regularOutline()


        .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeOut, value: configuration.isPressed)

    }
}

struct regularNeoMenu: MenuStyle {

    // Define properties for the corner radius, color, and role of the button
    var cornerRadius: CGFloat = 18
    var color: Color = Color("1")
    var role: neoButtonRole = .regularAction

    // Define the body of the ButtonStyle
    func makeBody(configuration: Self.Configuration) -> some View {

        // Determine the actual color of the button based on its role
        let actualColor = (role == .regularAction ? color :
                            role == .destructive ? .red :
                            color
        )

        // Create the menu using various SwiftUI modifiers
        Menu(configuration)
            .foregroundColor(actualColor)
            .padding(.horizontal, 2)
            .padding(13)
            .background(Color("NeoButton"))
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .neoOutline()
    }
}

struct settingsButton: ButtonStyle {

    // Define properties for the corner radius, color, and role of the button
    var cornerRadius: CGFloat = 18
    var color: Color = Color("1")
    var role: neoButtonRole = .regularAction
    var background = false

    // Access the color scheme environment variable
    @Environment(\.colorScheme) var colorScheme

    // Define the body of the ButtonStyle
    func makeBody(configuration: Self.Configuration) -> some View {

        // Determine the actual color of the button based on its role
        let actualColor = (role == .regularAction ? color :
                            role == .destructive ? .red :
                            color
        )

        // Create the basic button using various SwiftUI modifiers
        configuration.label
            .foregroundColor(background ? colorScheme == .dark ? .black : .white : actualColor)

            .scaleEffect(x: configuration.isPressed ? 1.0 : 1.0 , y:configuration.isPressed ? 1.2 : 1.0)
            .opacity(configuration.isPressed ? 0.3 : 1)
            .padding(.horizontal, 2)
            .padding(13)
            .background(background ? actualColor : Color("settingsCard"))
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .neoOutline(lineWidth: background ? colorScheme == .dark ? 2 : 1.7 : 1.17)
            .scaleEffect(x: configuration.isPressed ? 0.9 : 1.0 , y:configuration.isPressed ? 0.7 : 1.0)
            .animation(.easeOut, value: configuration.isPressed)

    }
}
struct settingsMenu: MenuStyle {

    // Define properties for the corner radius, color, and role of the button
    var cornerRadius: CGFloat = 18
    var color: Color = Color("1")
    var role: neoButtonRole = .regularAction

    // Define the body of the ButtonStyle
    func makeBody(configuration: Self.Configuration) -> some View {

        // Determine the actual color of the button based on its role
        let actualColor = (role == .regularAction ? color :
                            role == .destructive ? .red :
                            color
        )

        // Create the menu using various SwiftUI modifiers
        Menu(configuration)
            .foregroundColor(actualColor)
            .padding(.horizontal, 2)
            .padding(13)
            .background(Color("settingsCard"))
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .neoOutline()
    }
}
