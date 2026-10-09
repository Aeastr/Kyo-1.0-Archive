//
//  SwiftUIView.swift
//
//
//  Created by Aether on 20/07/2023.
//

import SwiftUI

extension Color {
    func darken(by percentage: Double) -> Color {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var opacity: CGFloat = 0

        #if os(iOS)
        UIColor(self).getRed(&red, green: &green, blue: &blue, alpha: &opacity)
        #elseif os(macOS)
        // Convert the SwiftUI Color to an NSColor in the sRGB color space
        let nsColor = NSColor(self).usingColorSpace(.sRGB) ?? NSColor.clear
        nsColor.getRed(&red, green: &green, blue: &blue, alpha: &opacity)
        #endif

        // Darken the color by the specified percentage
        red = max(red * (1 - CGFloat(percentage)), 0)
        green = max(green * (1 - CGFloat(percentage)), 0)
        blue = max(blue * (1 - CGFloat(percentage)), 0)

        // Return the new, darker color
        return Color(red: Double(red), green: Double(green), blue: Double(blue), opacity: Double(opacity))
    }
}
