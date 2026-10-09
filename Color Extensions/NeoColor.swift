//
//  Color.swift
//  KyoNeo
//
//  Created by Aether on 02/04/2023.
//

import Foundation
import SwiftUI

extension Color{
    
    static func getAdjustedColor(color: Color, colorScheme: ColorScheme, factor: Double = 1) -> Color {
        let brightness = color.getBrightness()
           let accentn = (
            colorScheme == .light ?
            (brightness > 0.75 ? color.darken(by: 0.5) : color)
            :

                (brightness < 0.25 ? color.darken(by: -0.25) : color)
            )
        return accentn
    }

    static func getAdjustedBGColor(color: Color, colorScheme: ColorScheme, factor: Double = 1) -> Color {
        let brightness = color.getBrightness()
           let accentn = (
            colorScheme == .light ?
            (brightness > 0.8 ? color.darken(by: 0.2) : color)
            :

                (brightness > 0.8 ? color.darken(by: 0.2) : color)
            )
        return accentn
    }

    static func checkColor(color: Color)-> Bool{
        return color.isLight() ?? true
    }

    static func getPercent(color: Color) -> Double{
        return Double(color.getBrightness()) * 0.2

    }

    static func getForegroundColor(color: Color) -> Color{
        let b = color.getBrightness()
        return b > 0.73 ? color.darken(by: 0.5) : Color.white
    }

    static func getIdealColor(color: Color, colorScheme: ColorScheme) -> Color{
        let b = color.getBrightness()
        return colorScheme == .light ? b > 0.73 ? color.darken(by: 0.5) : color : b > 0.73 ? color : color.lighten(by: 0.5)
    }
}
