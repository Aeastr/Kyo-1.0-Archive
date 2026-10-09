//
//  Default Colours.swift
//  KyoNeo
//
//  Created by Aether on 28/01/2023.
//

import SwiftUI

//extension Color {
//    func toIntRepresentation() -> Int {
//        let uiColor = UIColor(self)
//        var red: CGFloat = 0
//        var green: CGFloat = 0
//        var blue: CGFloat = 0
//        uiColor.getRed(&red, green: &green, blue: &blue, alpha: nil)
//
//        let redInt = Int(red * 255.0) << 16
//        let greenInt = Int(green * 255.0) << 8
//        let blueInt = Int(blue * 255.0)
//        return redInt | greenInt | blueInt
//    }
//}

struct colorItem: Identifiable {
    var id = UUID()
    var name: String = ""
    var color1: Color
    var color2: Color
}

struct hueSet: Identifiable{
    var id = UUID()
    var name: String
    var hues: [colorItem]
}

enum HueSet: String, CaseIterable {
    case customColours = "Custom Colours"
    case defaultHues = "Default Hues"
    case timberlandTones = "Timberland Tones"
    case oceanBreeze = "Ocean Breeze"
    case electroPop = "Electro Pop"
    case sereneHues = "Serene Hues"
    case enchantedGarden = "Enchanted Garden"
    case sunsetSerenade = "Sunset Serenade"
    case cosmicDreams = "Cosmic Dreams"
    case whimsicalWonderland = "Whimsical Wonderland"
    case auroraBorealis = "Aurora Borealis"
    case appAccents = "App Accents"


    var hues: [colorItem]? {
        switch self {
        case .customColours:
            return nil
        case .defaultHues:
            return defaultHuesArray
        case .oceanBreeze:
            return oceanBreezeArray
        case .electroPop:
            return electroPopArray
        case .sereneHues:
            return sereneHuesArray
        case .enchantedGarden:
            return enchantedGardenArray
        case .sunsetSerenade:
            return sunsetSerenadeArray
        case .cosmicDreams:
            return cosmicDreamsArray
        case .whimsicalWonderland:
            return whimsicalWonderlandArray
        case .auroraBorealis:
            return auroraBorealisPalette
        case .timberlandTones:
            return timberlandTonesPalette
        case .appAccents:
            return nil
        }
    }
}

var timberlandTonesPalette: [colorItem] = [
    colorItem(name: "Walnut", color1: Color(hex: "#59300C"), color2: Color(hex: "#8B572A")),
    colorItem(name: "Maple", color1: Color(hex: "#C15C1D"), color2: Color(hex: "#F7A440")),
    colorItem(name: "Oak", color1: Color(hex: "#8D6E63"), color2: Color(hex: "#D7BBA8")),
    colorItem(name: "Cherry", color1: Color(hex: "#B22025"), color2: Color(hex: "#FF5555")),
    colorItem(name: "Mahogany", color1: Color(hex: "#4C0B1D"), color2: Color(hex: "#990A3D")),
    colorItem(name: "Cedar", color1: Color(hex: "#964B00"), color2: Color(hex: "#C87533")),
    colorItem(name: "Birch", color1: Color(hex: "#D0B08C"), color2: Color(hex: "#F3E5CF")),
    colorItem(name: "Pine", color1: Color(hex: "#1E4F1E"), color2: Color(hex: "#2E8B57")),
    colorItem(name: "Redwood", color1: Color(hex: "#5B1818"), color2: Color(hex: "#A13030")),
    colorItem(name: "Driftwood", color1: Color(hex: "#A67C52"), color2: Color(hex: "#D9B99B"))
]

let auroraBorealisPalette: [colorItem] = [
    colorItem(name: "Aurora Borealis", color1: Color(hex: "#0F4C81"), color2: Color(hex: "#B993D6")),
    colorItem(name: "Mystic Green", color1: Color(hex: "#3D9970"), color2: Color(hex: "#00FF80")),
    colorItem(name: "Astral Blue", color1: Color(hex: "#0074D9"), color2: Color(hex: "#8ED5FF")),
    colorItem(name: "Northern Lights", color1: Color(hex: "#4400FF"), color2: Color(hex: "#FF0077")),
    colorItem(name: "Polaris Pink", color1: Color(hex: "#FF80ED"), color2: Color(hex: "#FF1493")),
    colorItem(name: "Luminous Lime", color1: Color(hex: "#00FF00"), color2: Color(hex: "#CCFF00")),
    colorItem(name: "Electric Indigo", color1: Color(hex: "#6A00FF"), color2: Color(hex: "#00FFFF")),
    colorItem(name: "Celestial Teal", color1: Color(hex: "#00A5CF"), color2: Color(hex: "#66FFB2")),
    colorItem(name: "Violet Horizon", color1: Color(hex: "#702963"), color2: Color(hex: "#C25FFF")),
    colorItem(name: "Solar Flare", color1: Color(hex: "#FFC300"), color2: Color(hex: "#FF9000"))
]

var defaultHuesArray: [colorItem] = [
    colorItem(name: "Mystic Mauve", color1: Color(red: 0.91, green: 0.61, blue: 0.76), color2: Color(red: 0.93, green: 0.75, blue: 0.83)),
    colorItem(name: "Eternal Ember", color1: Color(red: 1, green: 0.60, blue: 0.69), color2: Color(red: 0.97, green: 0.56, blue: 0.56)),
    colorItem(name: "Twilight Flame", color1: Color(red: 0.96, green: 0.57, blue: 0.53), color2: Color(red: 0.97, green: 0.66, blue: 0.56)),
    colorItem(name: "Fading Sunset", color1: Color(red: 0.96, green: 0.73, blue: 0.53), color2: Color(red: 0.97, green: 0.71, blue: 0.56)),
    colorItem(name: "Dusk's Gold", color1: Color(red: 1, green: 0.75, blue: 0.38), color2: Color(red: 0.97, green: 0.81, blue: 0.56)),
    colorItem(name: "Enchanted Moss", color1: Color(red: 0.76, green: 0.92, blue: 0.55), color2: Color(red: 0.54, green: 0.91, blue: 0.62)),
    colorItem(name: "Luminous Jade", color1: Color(red: 0.44, green: 0.90, blue: 0.73), color2: Color(red: 0.60, green: 0.93, blue: 0.85)),
    colorItem(name: "Twilight Azure", color1: Color(red: 0.52, green: 0.79, blue: 0.82), color2: Color(red: 0.60, green: 0.81, blue: 0.93)),
    colorItem(name: "Ethereal Indigo", color1: Color(red: 0.50, green: 0.65, blue: 0.95), color2: Color(red: 0.47, green: 0.73, blue: 0.96)),
    colorItem(name: "Celestial Aqua", color1: Color(red: 0.68, green: 0.81, blue: 0.86), color2: Color(red: 0.61, green: 0.78, blue: 0.83)),
    colorItem(name: "Velvet Amethyst", color1: Color(red: 0.85, green: 0.68, blue: 0.99), color2: Color(red: 0.81, green: 0.50, blue: 0.96)),
    colorItem(name: "Eternal Twilight", color1: Color(red: 0.59, green: 0.69, blue: 0.83), color2: Color(red: 0.70, green: 0.78, blue: 0.91)),
    colorItem(name: "Luminescent Opal", color1: Color(red: 0.74, green: 0.76, blue: 0.86), color2: Color(red: 0.79, green: 0.81, blue: 0.90)),
    colorItem(name: "Glimmering Lilac", color1: Color(red: 0.82, green: 0.62, blue: 0.83), color2: Color(red: 0.87, green: 0.68, blue: 0.88)),
    colorItem(name: "Starlit Sapphire", color1: Color(red: 0.38, green: 0.55, blue: 0.70), color2: Color(red: 0.47, green: 0.64, blue: 0.80)),
    colorItem(name: "Eternal Amaranth", color1: Color(red: 0.80, green: 0.47, blue: 0.52), color2: Color(red: 0.88, green: 0.56, blue: 0.62)),
    colorItem(name: "Dawning Horizon", color1: Color(red: 0.61, green: 0.57, blue: 0.75), color2: Color(red: 0.70, green: 0.65, blue: 0.83)),
    colorItem(name: "Lustrous Topaz", color1: Color(red: 0.84, green: 0.67, blue: 0.37), color2: Color(red: 0.91, green: 0.75, blue: 0.46)),
    colorItem(name: "Midnight Whispers", color1: Color(red: 0.34, green: 0.41, blue: 0.54), color2: Color(red: 0.46, green: 0.50, blue: 0.62)),
    colorItem(name: "Eternal Aurora", color1: Color(red: 0.79, green: 0.39, blue: 0.47), color2: Color(red: 0.87, green: 0.47, blue: 0.56)),
    colorItem(name: "Moonlit Pearl", color1: Color(red: 0.88, green: 0.88, blue: 0.92), color2: Color(red: 0.94, green: 0.94, blue: 0.96))
]


var electroPopArray: [colorItem] = [
    colorItem(name: "Neon Pink", color1: Color(red: 0.92, green: 0.35, blue: 0.62), color2: Color(red: 0.98, green: 0.67, blue: 0.57)),
    colorItem(name: "Electric Blue", color1: Color(red: 0.48, green: 0.67, blue: 0.74), color2: Color(red: 0.84, green: 0.91, blue: 0.77)),
    colorItem(name: "Lime Burst", color1: Color(red: 0.22, green: 0.85, blue: 0.60), color2: Color(red: 0.84, green: 0.33, blue: 0.50)),
    colorItem(name: "Funky Purple", color1: Color(red: 0.73, green: 0.29, blue: 0.80), color2: Color(red: 0.96, green: 0.87, blue: 0.25)),
    colorItem(name: "Turquoise Teal", color1: Color(red: 0.28, green: 0.67, blue: 0.95), color2: Color(red: 0.80, green: 0.44, blue: 0.58)),
    colorItem(name: "Vibrant Green", color1: Color(red: 0.12, green: 0.80, blue: 0.78), color2: Color(red: 0.95, green: 0.40, blue: 0.65)),
    colorItem(name: "Electric Violet", color1: Color(red: 0.63, green: 0.57, blue: 0.88), color2: Color(red: 0.98, green: 0.85, blue: 0.18)),
    colorItem(name: "Radiant Emerald", color1: Color(red: 0.16, green: 0.89, blue: 0.62), color2: Color(red: 0.86, green: 0.49, blue: 0.76)),
    colorItem(name: "Blazing Orange", color1: Color(red: 0.97, green: 0.49, blue: 0.28), color2: Color(red: 1, green: 0.73, blue: 0.48)),
    colorItem(name: "Fierce Fuchsia", color1: Color(red: 0.89, green: 0.22, blue: 0.56), color2: Color(red: 0.98, green: 0.40, blue: 0.78)),
    colorItem(name: "Electric Lemon", color1: Color(red: 0.98, green: 0.95, blue: 0.35), color2: Color(red: 1, green: 0.97, blue: 0.58)),
    colorItem(name: "Shockwave Coral", color1: Color(red: 0.96, green: 0.51, blue: 0.40), color2: Color(red: 1, green: 0.70, blue: 0.58)),
    colorItem(name: "Laser Lime", color1: Color(red: 0.76, green: 0.98, blue: 0.27), color2: Color(red: 0.84, green: 1, blue: 0.55)),
    colorItem(name: "Intense Cyan", color1: Color(red: 0.12, green: 0.97, blue: 0.85), color2: Color(red: 0.44, green: 1, blue: 0.95)),
    colorItem(name: "Sizzling Yellow", color1: Color(red: 1, green: 0.88, blue: 0.11), color2: Color(red: 1, green: 0.96, blue: 0.53)),
    colorItem(name: "Dynamic Coral", color1: Color(red: 1, green: 0.47, blue: 0.32), color2: Color(red: 1, green: 0.65, blue: 0.55)),
    colorItem(name: "Ultra Violet", color1: Color(red: 0.49, green: 0.11, blue: 0.74), color2: Color(red: 0.59, green: 0.34, blue: 0.85)),
    colorItem(name: "Energetic Aqua", color1: Color(red: 0.27, green: 0.92, blue: 0.87), color2: Color(red: 0.38, green: 0.98, blue: 0.93))
]


var sereneHuesArray: [colorItem] = [
    colorItem(name: "Misty Blue", color1: Color(red: 0.82, green: 0.93, blue: 0.92), color2: Color(red: 0.67, green: 0.85, blue: 0.85)),
    colorItem(name: "Lavender Dusk", color1: Color(red: 0.92, green: 0.84, blue: 0.92), color2: Color(red: 0.77, green: 0.73, blue: 0.85)),
    colorItem(name: "Gentle Moss", color1: Color(red: 0.90, green: 0.92, blue: 0.83), color2: Color(red: 0.78, green: 0.85, blue: 0.70)),
    colorItem(name: "Soft Sandstone", color1: Color(red: 0.91, green: 0.85, blue: 0.82), color2: Color(red: 0.79, green: 0.75, blue: 0.71)),
    colorItem(name: "Tranquil Aqua", color1: Color(red: 0.85, green: 0.91, blue: 0.92), color2: Color(red: 0.73, green: 0.82, blue: 0.85)),
    colorItem(name: "Peaceful Olive", color1: Color(red: 0.88, green: 0.90, blue: 0.84), color2: Color(red: 0.75, green: 0.80, blue: 0.73)),
    colorItem(name: "Silent Birch", color1: Color(red: 0.93, green: 0.88, blue: 0.82), color2: Color(red: 0.85, green: 0.79, blue: 0.71)),
    colorItem(name: "Serenity Sky", color1: Color(red: 0.84, green: 0.92, blue: 0.89), color2: Color(red: 0.70, green: 0.85, blue: 0.77)),
    colorItem(name: "Whispering Lilac", color1: Color(red: 0.87, green: 0.84, blue: 0.92), color2: Color(red: 0.76, green: 0.73, blue: 0.85)),
    colorItem(name: "Calm Beige", color1: Color(red: 0.89, green: 0.86, blue: 0.85), color2: Color(red: 0.78, green: 0.76, blue: 0.75)),
    colorItem(name: "Dreamy Peach", color1: Color(red: 0.91, green: 0.80, blue: 0.77), color2: Color(red: 0.87, green: 0.73, blue: 0.71)),
    colorItem(name: "Harmonious Orchid", color1: Color(red: 0.88, green: 0.78, blue: 0.90), color2: Color(red: 0.83, green: 0.70, blue: 0.85)),
    colorItem(name: "Blissful Jade", color1: Color(red: 0.86, green: 0.91, blue: 0.81), color2: Color(red: 0.79, green: 0.85, blue: 0.76)),
    colorItem(name: "Tranquil Slate", color1: Color(red: 0.83, green: 0.84, blue: 0.90), color2: Color(red: 0.75, green: 0.78, blue: 0.85)),
    colorItem(name: "Harbor Mist", color1: Color(red: 0.80, green: 0.82, blue: 0.88), color2: Color(red: 0.69, green: 0.71, blue: 0.78)),
    colorItem(name: "Soft Willow", color1: Color(red: 0.75, green: 0.88, blue: 0.82), color2: Color(red: 0.60, green: 0.75, blue: 0.71)),
    colorItem(name: "Dusky Lavender", color1: Color(red: 0.70, green: 0.65, blue: 0.80), color2: Color(red: 0.60, green: 0.55, blue: 0.65))
]



var enchantedGardenArray: [colorItem] = [
    colorItem(name: "Mystic Violet", color1: Color(red: 0.73, green: 0.44, blue: 0.65), color2: Color(red: 0.85, green: 0.60, blue: 0.78)),
    colorItem(name: "Whispering Willow", color1: Color(red: 0.55, green: 0.78, blue: 0.64), color2: Color(red: 0.68, green: 0.88, blue: 0.76)),
    colorItem(name: "Glowing Firefly", color1: Color(red: 0.99, green: 0.80, blue: 0.39), color2: Color(red: 1.00, green: 0.85, blue: 0.50)),
    colorItem(name: "Ethereal Mist", color1: Color(red: 0.71, green: 0.88, blue: 0.94), color2: Color(red: 0.80, green: 0.93, blue: 0.96)),
    colorItem(name: "Enchanted Bloom", color1: Color(red: 0.95, green: 0.46, blue: 0.60), color2: Color(red: 0.98, green: 0.62, blue: 0.74)),
    colorItem(name: "Sparkling Dew", color1: Color(red: 0.80, green: 0.91, blue: 0.71), color2: Color(red: 0.88, green: 0.95, blue: 0.76)),
    colorItem(name: "Moonlit Grove", color1: Color(red: 0.45, green: 0.66, blue: 0.71), color2: Color(red: 0.57, green: 0.76, blue: 0.81)),
    colorItem(name: "Majestic Iris", color1: Color(red: 0.61, green: 0.40, blue: 0.76), color2: Color(red: 0.74, green: 0.54, blue: 0.87))
]

var sunsetSerenadeArray: [colorItem] = [
    colorItem(name: "Golden Hour", color1: Color(red: 0.98, green: 0.74, blue: 0.39), color2: Color(red: 0.99, green: 0.88, blue: 0.60)),
    colorItem(name: "Crimson Sky", color1: Color(red: 0.90, green: 0.40, blue: 0.36), color2: Color(red: 0.97, green: 0.55, blue: 0.50)),
    colorItem(name: "Amber Glow", color1: Color(red: 0.99, green: 0.62, blue: 0.40), color2: Color(red: 1.00, green: 0.75, blue: 0.56)),
    colorItem(name: "Mellow Horizon", color1: Color(red: 0.81, green: 0.64, blue: 0.60), color2: Color(red: 0.91, green: 0.73, blue: 0.71)),
    colorItem(name: "Dusk Embrace", color1: Color(red: 0.59, green: 0.49, blue: 0.65), color2: Color(red: 0.71, green: 0.60, blue: 0.74)),
    colorItem(name: "Evening Breeze", color1: Color(red: 0.45, green: 0.68, blue: 0.71), color2: Color(red: 0.57, green: 0.78, blue: 0.80)),
    colorItem(name: "Twilight Hues", color1: Color(red: 0.34, green: 0.53, blue: 0.62), color2: Color(red: 0.47, green: 0.64, blue: 0.73)),
    colorItem(name: "Dreamy Sundown", color1: Color(red: 0.72, green: 0.36, blue: 0.52), color2: Color(red: 0.86, green: 0.50, blue: 0.63)),
    colorItem(name: "Soothing Sepia", color1: Color(red: 0.80, green: 0.62, blue: 0.46), color2: Color(red: 0.88, green: 0.72, blue: 0.57)),
    colorItem(name: "Velvet Indigo", color1: Color(red: 0.28, green: 0.36, blue: 0.47), color2: Color(red: 0.42, green: 0.51, blue: 0.60)),
    colorItem(name: "Copper Canyon", color1: Color(red: 0.82, green: 0.49, blue: 0.31), color2: Color(red: 0.91, green: 0.61, blue: 0.40)),
    colorItem(name: "Radiant Amber", color1: Color(red: 0.96, green: 0.60, blue: 0.41), color2: Color(red: 1.00, green: 0.72, blue: 0.50)),
    colorItem(name: "Dancing Flame", color1: Color(red: 0.84, green: 0.36, blue: 0.32), color2: Color(red: 0.94, green: 0.48, blue: 0.40))
]

var oceanBreezeArray: [colorItem] = [
    colorItem(name: "Aqua Sky", color1: Color(red: 0.47, green: 0.80, blue: 0.89), color2: Color(red: 0.58, green: 0.91, blue: 0.96)),
    colorItem(name: "Seashell White", color1: Color(red: 0.95, green: 0.93, blue: 0.89), color2: Color(red: 0.97, green: 0.96, blue: 0.93)),
    colorItem(name: "Cerulean Breeze", color1: Color(red: 0.29, green: 0.63, blue: 0.71), color2: Color(red: 0.40, green: 0.78, blue: 0.85)),
    colorItem(name: "Sandy Beige", color1: Color(red: 0.88, green: 0.82, blue: 0.72), color2: Color(red: 0.92, green: 0.87, blue: 0.78)),
    colorItem(name: "Ocean Spray", color1: Color(red: 0.60, green: 0.86, blue: 0.90), color2: Color(red: 0.71, green: 0.92, blue: 0.95)),
    colorItem(name: "Minty Foam", color1: Color(red: 0.78, green: 0.92, blue: 0.86), color2: Color(red: 0.84, green: 0.96, blue: 0.90)),
    colorItem(name: "Powdered Sand", color1: Color(red: 0.87, green: 0.83, blue: 0.76), color2: Color(red: 0.91, green: 0.88, blue: 0.82)),
    colorItem(name: "Azure Bliss", color1: Color(red: 0.40, green: 0.76, blue: 0.84), color2: Color(red: 0.53, green: 0.87, blue: 0.96)),
    colorItem(name: "Palm Green", color1: Color(red: 0.35, green: 0.68, blue: 0.61), color2: Color(red: 0.47, green: 0.81, blue: 0.72)),
    colorItem(name: "Coastal Grey", color1: Color(red: 0.60, green: 0.66, blue: 0.67), color2: Color(red: 0.70, green: 0.75, blue: 0.77)),
    colorItem(name: "Azure Waters", color1: Color(red: 0.00, green: 0.44, blue: 0.64), color2: Color(red: 0.08, green: 0.76, blue: 0.81)),
    colorItem(name: "Turquoise Waves", color1: Color(red: 0.22, green: 0.67, blue: 0.64), color2: Color(red: 0.32, green: 0.86, blue: 0.82)),
    colorItem(name: "Deep Blue Sea", color1: Color(red: 0.10, green: 0.56, blue: 0.73), color2: Color(red: 0.18, green: 0.84, blue: 0.94)),
    colorItem(name: "Ocean Depths", color1: Color(red: 0.34, green: 0.50, blue: 0.63), color2: Color(red: 0.47, green: 0.72, blue: 0.87)),
    colorItem(name: "Tropical Teal", color1: Color(red: 0.18, green: 0.57, blue: 0.59), color2: Color(red: 0.28, green: 0.78, blue: 0.76)),
    colorItem(name: "Emerald Bay", color1: Color(red: 0.47, green: 0.72, blue: 0.60), color2: Color(red: 0.63, green: 0.86, blue: 0.74)),
    colorItem(name: "Caribbean Coast", color1: Color(red: 0.25, green: 0.61, blue: 0.71), color2: Color(red: 0.39, green: 0.82, blue: 0.88)),
    colorItem(name: "Seafoam Green", color1: Color(red: 0.59, green: 0.54, blue: 0.66), color2: Color(red: 0.74, green: 0.72, blue: 0.87)),
    colorItem(name: "Mystic Aqua", color1: Color(red: 0.32, green: 0.59, blue: 0.66), color2: Color(red: 0.47, green: 0.76, blue: 0.88)),
    colorItem(name: "Tidal Turquoise", color1: Color(red: 0.68, green: 0.50, blue: 0.63), color2: Color(red: 0.86, green: 0.72, blue: 0.87))
]

var cosmicDreamsArray: [colorItem] = [
    colorItem(name: "Starry Night", color1: Color(red: 0.09, green: 0.14, blue: 0.28), color2: Color(red: 0.20, green: 0.27, blue: 0.44)),
    colorItem(name: "Galactic Blue", color1: Color(red: 0.12, green: 0.23, blue: 0.43), color2: Color(red: 0.23, green: 0.32, blue: 0.50)),
    colorItem(name: "Astral Indigo", color1: Color(red: 0.12, green: 0.14, blue: 0.32), color2: Color(red: 0.22, green: 0.25, blue: 0.44)),
    colorItem(name: "Nebula Violet", color1: Color(red: 0.33, green: 0.18, blue: 0.36), color2: Color(red: 0.43, green: 0.27, blue: 0.46)),
    colorItem(name: "Cosmic Dust", color1: Color(red: 0.27, green: 0.27, blue: 0.38), color2: Color(red: 0.35, green: 0.35, blue: 0.47)),
    colorItem(name: "Aurora Green", color1: Color(red: 0.00, green: 0.41, blue: 0.46), color2: Color(red: 0.15, green: 0.52, blue: 0.57)),
    colorItem(name: "Lunar Silver", color1: Color(red: 0.55, green: 0.55, blue: 0.60), color2: Color(red: 0.63, green: 0.63, blue: 0.68)),
    colorItem(name: "Comet Grey", color1: Color(red: 0.35, green: 0.37, blue: 0.39), color2: Color(red: 0.43, green: 0.45, blue: 0.47)),
    colorItem(name: "Milky Way", color1: Color(red: 0.31, green: 0.30, blue: 0.47), color2: Color(red: 0.38, green: 0.37, blue: 0.54)),
    colorItem(name: "Celestial Teal", color1: Color(red: 0.11, green: 0.33, blue: 0.38), color2: Color(red: 0.24, green: 0.44, blue: 0.49)),
    colorItem(name: "Starlight Spark", color1: Color(red: 0.35, green: 0.43, blue: 0.47), color2: Color(red: 0.42, green: 0.49, blue: 0.54)),
    colorItem(name: "Supernova Gold", color1: Color(red: 0.55, green: 0.42, blue: 0.18), color2: Color(red: 0.63, green: 0.50, blue: 0.24)),
    colorItem(name: "Meteorite Brown", color1: Color(red: 0.25, green: 0.18, blue: 0.12), color2: Color(red: 0.33, green: 0.25, blue: 0.18)),
    colorItem(name: "Cosmic Coral", color1: Color(red: 0.72, green: 0.22, blue: 0.30), color2: Color(red: 0.80, green: 0.29, blue: 0.37)),
    colorItem(name: "Solar Flare", color1: Color(red: 0.75, green: 0.51, blue: 0.23), color2: Color(red: 0.83, green: 0.58, blue: 0.29)),

    colorItem(name: "Lunar Glow", color1: Color(red: 0.86, green: 0.95, blue: 0.94), color2: Color(red: 0.71, green: 0.85, blue: 0.88)),
        colorItem(name: "Solar Burst", color1: Color(red: 0.97, green: 0.76, blue: 0.36), color2: Color(red: 1.00, green: 0.92, blue: 0.52)),
        colorItem(name: "Eclipse Black", color1: Color(red: 0.08, green: 0.08, blue: 0.14), color2: Color(red: 0.16, green: 0.16, blue: 0.22)),
        colorItem(name: "Starship Silver", color1: Color(red: 0.80, green: 0.81, blue: 0.84), color2: Color(red: 0.66, green: 0.68, blue: 0.72)),
        colorItem(name: "Comet Tail", color1: Color(red: 0.29, green: 0.21, blue: 0.36), color2: Color(red: 0.37, green: 0.29, blue: 0.44)),
        colorItem(name: "Nebula Pink", color1: Color(red: 0.73, green: 0.29, blue: 0.49), color2: Color(red: 0.85, green: 0.36, blue: 0.58)),
        colorItem(name: "Cosmic Plum", color1: Color(red: 0.27, green: 0.09, blue: 0.16), color2: Color(red: 0.35, green: 0.18, blue: 0.26)),
        colorItem(name: "Interstellar Violet", color1: Color(red: 0.31, green: 0.14, blue: 0.31), color2: Color(red: 0.39, green: 0.23, blue: 0.39)),
        colorItem(name: "Milky Quartz", color1: Color(red: 0.83, green: 0.81, blue: 0.92), color2: Color(red: 0.69, green: 0.67, blue: 0.81)),
        colorItem(name: "Aurora Mist", color1: Color(red: 0.61, green: 0.77, blue: 0.84), color2: Color(red: 0.75, green: 0.87, blue: 0.92)),
        colorItem(name: "Galaxy Dust", color1: Color(red: 0.37, green: 0.37, blue: 0.47), color2: Color(red: 0.45, green: 0.45, blue: 0.55)),
        colorItem(name: "Nebulous Grey", color1: Color(red: 0.50, green: 0.47, blue: 0.53), color2: Color(red: 0.58, green: 0.55, blue: 0.61)),
        colorItem(name: "Stellar Stream", color1: Color(red: 0.49, green: 0.57, blue: 0.63), color2: Color(red: 0.57, green: 0.65, blue: 0.71)),
        colorItem(name: "Moonlit Jade", color1: Color(red: 0.19, green: 0.35, blue: 0.28), color2: Color(red: 0.27, green: 0.43, blue: 0.36)),
        colorItem(name: "Asteroid Olive", color1: Color(red: 0.26, green: 0.27, blue: 0.22), color2: Color(red: 0.34, green: 0.35, blue: 0.30)),
        colorItem(name: "Meteorite Grey", color1: Color(red: 0.19, green: 0.19, blue: 0.19), color2: Color(red: 0.27, green: 0.27, blue: 0.27)),
        colorItem(name: "Galactic Turquoise", color1: Color(red: 0.00, green: 0.63, blue: 0.62), color2: Color(red: 0.14, green: 0.71, blue: 0.71)),
        colorItem(name: "Stardust Gold", color1: Color(red: 0.83, green: 0.60, blue: 0.18), color2: Color(red: 0.91, green: 0.68, blue: 0.24)),
      
]

var whimsicalWonderlandArray: [colorItem] = [
    colorItem(name: "Mystic Mauve", color1: Color(red: 0.72, green: 0.55, blue: 0.73), color2: Color(red: 0.87, green: 0.75, blue: 0.87)),
    colorItem(name: "Cotton Candy Clouds", color1: Color(red: 0.91, green: 0.78, blue: 0.87), color2: Color(red: 1.0, green: 0.93, blue: 1.0)),
    colorItem(name: "Lavender Lullaby", color1: Color(red: 0.66, green: 0.70, blue: 0.92), color2: Color(red: 0.81, green: 0.84, blue: 0.96)),
    colorItem(name: "Pixie Pink", color1: Color(red: 0.92, green: 0.60, blue: 0.73), color2: Color(red: 1.0, green: 0.78, blue: 0.87)),
    colorItem(name: "Buttercup Bliss", color1: Color(red: 1.0, green: 0.86, blue: 0.56), color2: Color(red: 1.0, green: 0.94, blue: 0.73)),
    colorItem(name: "Dandelion Dream", color1: Color(red: 0.98, green: 0.90, blue: 0.49), color2: Color(red: 1.0, green: 0.96, blue: 0.76)),
    colorItem(name: "Candy-Coated Carousel", color1: Color(red: 0.94, green: 0.70, blue: 0.85), color2: Color(red: 1.0, green: 0.80, blue: 0.94)),
    colorItem(name: "Twilight Teal", color1: Color(red: 0.47, green: 0.76, blue: 0.83), color2: Color(red: 0.62, green: 0.88, blue: 0.94)),
    colorItem(name: "Bubblegum Breeze", color1: Color(red: 0.89, green: 0.63, blue: 0.80), color2: Color(red: 1.0, green: 0.75, blue: 0.88)),
    colorItem(name: "Peaches and Cream", color1: Color(red: 1.0, green: 0.81, blue: 0.68), color2: Color(red: 1.0, green: 0.89, blue: 0.80)),
    colorItem(name: "Moonlit Meadow", color1: Color(red: 0.40, green: 0.66, blue: 0.59), color2: Color(red: 0.57, green: 0.76, blue: 0.68)),
    colorItem(name: "Starlight Silver", color1: Color(red: 0.75, green: 0.83, blue: 0.86), color2: Color(red: 0.88, green: 0.91, blue: 0.92)),
    colorItem(name: "Golden Glitter", color1: Color(red: 1.0, green: 0.86, blue: 0.20), color2: Color(red: 1.0, green: 0.90, blue: 0.49)),
]

