//
//  ColorEnginer.swift
//  KyoNeo
//
//  Created by Aether on 13/01/2024.
//

import SwiftUI

struct ColorEngine {
    @AppStorage("appAccentColor") var appAccentColor = "Default"
    @AppStorage("multicolored") var multicolored = true
    @AppStorage("appAccentColorIndex") var appAccentColorIndex = 1

    #if !os(macOS)
    func getColor(_ name: String, colorScheme: ColorScheme) -> Color{
        return Color(cgColor: Color(name).convertToCGColor(name: name, in: colorScheme))
    }
    #else
    func getColor(_ name: String, colorScheme: ColorScheme) -> Color{
        return Color(name)
    }
    #endif

    func getXColor(_ x: Int, colorScheme: ColorScheme) -> Color{
        return self.getColor((multicolored ? "\(appAccentColor)/\(x)" : "\(appAccentColor)/\(appAccentColorIndex)"), colorScheme: colorScheme)
    }

}

