//
//  ColorBrightness.swift
//  KyoNeo
//
//  Created by Aether on 07/03/2023.
//

import SwiftUI

#if os(iOS) || os(visionOS) || os(watchOS)


import UIKit
extension Color {

    // Check if the color is light or dark, as defined by the injected lightness threshold.
    // Some people report that 0.7 is best. I suggest to find out for yourself.
    // A nil value is returned if the lightness couldn't be determined.
    func isLight(threshold: Float = 0.80) -> Bool? {
        guard let components = self.cgColor?.components else {
            return nil
        }
        guard components.count >= 3 else {
            return nil
        }

        let brightness = Float(((components[0] * 299) + (components[1] * 587) + (components[2] * 114)) / 1000)
        return (brightness > threshold)
    }

    func getBrightness() -> Float {
        guard let components = self.convertToCGColor().components, components.count >= 3 else {
                print("failed to get brightness")
                return 0
            }

            // Calculate luminance using the WCAG formula
        
            let luminance = Float(((components[0] * 299) + (components[1] * 587) + (components[2] * 114)) / 1000)
            return luminance
        }

    func isBright() -> Bool{
        return self.getBrightness() > 0.73
    }

    func convertToCGColor() -> CGColor {
           // Convert SwiftUI Color to UIColor
           let uiColor = UIColor(self)

           // Return the CGColor from UIColor
           return uiColor.cgColor
       }

    func convertToCGColor(name: String, in colorScheme: ColorScheme = .light) -> CGColor {
            // Convert SwiftUI Color to UIColor
            var uiColor: UIColor

            let resolvedColor = UIColor(named: name)?.resolvedColor(with: UITraitCollection(userInterfaceStyle: colorScheme == .light ? .light : .dark))
        uiColor = resolvedColor ?? UIColor(self)


            // Return the CGColor from UIColor
            return uiColor.cgColor
        }


    func darken(by percentage: Double) -> Color {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var opacity: CGFloat = 0

        // Get the red, green, blue, and opacity values of the color
        UIColor(self).getRed(&red, green: &green, blue: &blue, alpha: &opacity)

        // Darken the color by the specified percentage
        red = max(red * (1 - CGFloat(percentage)), 0)
        green = max(green * (1 - CGFloat(percentage)), 0)
        blue = max(blue * (1 - CGFloat(percentage)), 0)

        // Return the new, darker color
        return Color(red: Double(red), green: Double(green), blue: Double(blue), opacity: Double(opacity))
    }

    func lighten(by percentage: Double) -> Color {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var opacity: CGFloat = 0

        // Get the red, green, blue, and opacity values of the color
        UIColor(self).getRed(&red, green: &green, blue: &blue, alpha: &opacity)

        // Lighten the color by the specified percentage
        red = min(red + CGFloat(percentage), 1)
        green = min(green + CGFloat(percentage), 1)
        blue = min(blue + CGFloat(percentage), 1)

        // Return the new, lighter color
        return Color(red: Double(red), green: Double(green), blue: Double(blue), opacity: Double(opacity))
    }
}


#elseif os(macOS)
import AppKit
extension Color {

    // Check if the color is light or dark, as defined by the injected lightness threshold.
    // Some people report that 0.7 is best. I suggest to find out for yourself.
    // A nil value is returned if the lightness couldn't be determined.
    func isLight(threshold: Float = 0.5) -> Bool? {
        guard let components = self.cgColor?.components else {
            return nil
        }
        guard components.count >= 3 else {
            return nil
        }

        let brightness = Float(((components[0] * 299) + (components[1] * 587) + (components[2] * 114)) / 1000)
        return (brightness > threshold)
    }

    func getBrightness() -> Float {
        guard let components = self.cgColor?.components else {
            return 0
        }
        guard components.count >= 3 else {
            return 0
        }

        let brightness = Float(((components[0] * 299) + (components[1] * 587) + (components[2] * 114)) / 1000)
        return brightness
    }

    func isBright() -> Bool{
        return self.getBrightness() > 0.73
    }
}



extension Color {
    func darken(by percentage: Double) -> Color {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var opacity: CGFloat = 0

        // Get the red, green, blue, and opacity values of the color
        let nsColor = NSColor(self).usingColorSpace(.sRGB) ?? NSColor.clear
                nsColor.getRed(&red, green: &green, blue: &blue, alpha: &opacity)

        // Darken the color by the specified percentage
        red = max(red * (1 - CGFloat(percentage)), 0)
        green = max(green * (1 - CGFloat(percentage)), 0)
        blue = max(blue * (1 - CGFloat(percentage)), 0)

        // Return the new, darker color
        return Color(red: Double(red), green: Double(green), blue: Double(blue), opacity: Double(opacity))
    }


    func lighten(by percentage: Double) -> Color {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var opacity: CGFloat = 0

        // Get the red, green, blue, and opacity values of the color
        let nsColor = NSColor(self).usingColorSpace(.sRGB) ?? NSColor.clear
                nsColor.getRed(&red, green: &green, blue: &blue, alpha: &opacity)

        // Darken the color by the specified percentage
        red = max(red * (1 + CGFloat(percentage)), 0)
        green = max(green * (1 + CGFloat(percentage)), 0)
        blue = max(blue * (1 + CGFloat(percentage)), 0)

        // Return the new, darker color
        return Color(red: Double(red), green: Double(green), blue: Double(blue), opacity: Double(opacity))
    }
}



#endif
