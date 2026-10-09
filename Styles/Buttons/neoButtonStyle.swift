//
//  neoButton.swift
//  KyoNeo
//
//  Created by Aether on 21/03/2023.
//

import SwiftUI

// Define a ButtonStyle for a custom neomorphic button
struct neoButton: ButtonStyle {

    // Define properties for the corner radius, color, and role of the button
    var cornerRadius: CGFloat = 14
    var color: Color = .blue
    var role: neoButtonRole = .regularAction

    // Access the color scheme environment variable
    @Environment(\.colorScheme) var colorScheme

    // Define the body of the ButtonStyle
    func makeBody(configuration: Self.Configuration) -> some View {

        // Determine the actual color of the button based on its role
        let actualColor = (role == .regularAction ? color :
                            role == .destructive ? .red :
                            color
        )

        // Create the neomorphic button using various SwiftUI modifiers
        configuration.label
            .foregroundColor(actualColor)
            .padding(12)
            .opacity(configuration.isPressed ? 0.7 : 1)
            .background(Color("NeoButton").opacity(colorScheme == .dark ? 0.6 : 0.3), in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))

        // .strokeStyle(cornerRadius: 14)
            .shadow(color: actualColor
                .opacity(0.3), radius: 7, x:0, y: 8)

            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: actualColor.opacity(0.2), location: 0),
                            .init(color: actualColor.opacity(0.1), location: 1)]),
                        startPoint: UnitPoint(x: -2.220446049250313e-16, y: -2.220446049250313e-16),
                        endPoint: UnitPoint(x: 0.9999999999999998, y: 0.9999999999999998)), lineWidth: 1.1666667461395264)
                    .opacity(colorScheme == .dark ? 0.5 : 1)
            )
            .scaleEffect(configuration.isPressed ? 0.7 : 1.0)
            .animation(.easeOut, value: configuration.isPressed)
       // Text("\()")
    }
}

// Define an enumeration for the different roles a neomorphic button can have
public enum neoButtonRole{
    case regularAction
    case destructive
    case cancel
    case create
}

struct Modifier_Previews: PreviewProvider {
    static var previews: some View {
        // This vertical stack contains two menus with some text.
        VStack {
            // This creates a Text view with the string "Standard", capitalizes it, sets the foreground color to white, and sets the font to a system-defined "caption" size.
            Text("Standard")
                .textCase(.uppercase)
                .foregroundColor(.white)
                .font(.caption)
            // This creates a Menu view with some items in it, and applies a custom style to it
            Menu(content: {
                Text("Menu Item")
                Text("Menu Item")
                Text("Menu Item")
            }, label: {
                Text("Menu")
                    .frame(maxWidth: .infinity, alignment: .leading)
            })
            .buttonStyle(PolishedButton())
            .padding()

            Divider()
                .padding()

            // This creates a Text view with the string "Scrolled", capitalizes it, sets the foreground color to white, and sets the font to a system-defined "caption" size.
            Text("Custom")
                .textCase(.uppercase)
                .foregroundColor(.white)
                .font(.caption)
            // This creates a Menu view with some items in it, and applies a custom style to it
            Menu(content: {
                Text("Menu Item")
                Text("Menu Item")
                Text("Menu Item")
            }, label: {
                Text("Menu")
                    .frame(maxWidth: .infinity, alignment: .leading)
            })
            .buttonStyle(PolishedButton(color: .yellow))
            .padding()

            Divider()
                .padding()
            Text("Destructive")
                .textCase(.uppercase)
                .foregroundColor(.white)
                .font(.caption)
            // This creates a Menu view with some items in it, and applies a custom style to it
            Menu(content: {
                Text("Menu Item")
                Text("Menu Item")
                Text("Menu Item")
            }, label: {
                Text("Menu")
                    .frame(maxWidth: .infinity, alignment: .leading)
            })
            .buttonStyle(PolishedButton(role: .destructive))
            .padding()
        }
        .frame(maxWidth: .infinity)
        .frame(maxHeight: .infinity)
        .background(.gray)
        // This sets the background color of the stack to gray.
    }
}

