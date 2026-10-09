//
//  ColorStaturation.swift
//  KyoNeo
//
//  Created by Aether on 03/04/2023.
//

import SwiftUI

extension Color {
#if os(iOS) || os(visionOS)
    func moreSaturated(factor: CGFloat) -> Color {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var opacity: CGFloat = 0
        UIColor(self).getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &opacity)
        let newSaturation = min(saturation * factor, 1.0)
        return Color(UIColor(hue: hue, saturation: newSaturation, brightness: brightness, alpha: opacity))
    }
    #elseif os(macOS)
    func moreSaturated(factor: CGFloat) -> Color {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var opacity: CGFloat = 0
        NSColor(self).getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &opacity)
        let newSaturation = min(saturation * factor, 1.0)
        return Color(NSColor(hue: hue, saturation: newSaturation, brightness: brightness, alpha: opacity))
    }
    #endif
}
