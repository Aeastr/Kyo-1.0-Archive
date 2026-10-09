//
//  SwiftUIView.swift
//  
//
//  Created by Aether on 09/06/2023.
//

import SwiftUI
#if !os(macOS)
import UIKit
func getTitleFontSize(isLargeTitle: Bool) -> CGFloat {
    let contentSizeCategory = UIApplication.shared.preferredContentSizeCategory

    if isLargeTitle {
        switch contentSizeCategory {
        case .extraSmall:
            return 32.0
        case .small:
            return 32.0
        case .medium:
            return 32.0
        case .large:
            return 34.0
        case .extraLarge:
            return 36.0
        case .extraExtraLarge:
            return 38.0
        case .extraExtraExtraLarge:
            return 40.0
        case .accessibilityMedium:
            return 42.0
        case .accessibilityLarge:
            return 46.0
        case .accessibilityExtraLarge:
            return 50.0
        case .accessibilityExtraExtraLarge:
            return 54.0
        case .accessibilityExtraExtraExtraLarge:
            return 58.0
        default:
            return 32.0
        }
    } else {
        switch contentSizeCategory {
        case .extraSmall:
            return 20.0
        case .small:
            return 20.0
        case .medium:
            return 20.0
        case .large:
            return 20.0
        case .extraLarge:
            return 22.0
        case .extraExtraLarge:
            return 24.0
        case .extraExtraExtraLarge:
            return 26.0
        case .accessibilityMedium:
            return 28.0
        case .accessibilityLarge:
            return 32.0
        case .accessibilityExtraLarge:
            return 36.0
        case .accessibilityExtraExtraLarge:
            return 40.0
        case .accessibilityExtraExtraExtraLarge:
            return 44.0
        default:
            return 18.0
        }
    }
}
#elseif os(macOS)
func getTitleFontSize(isLargeTitle: Bool) -> CGFloat {
    return 44.0
}
#endif

struct CustomAnimatableFontModifier: AnimatableModifier {
    var size: Double
    var weight: Font.Weight = .semibold
    var width: Font.Width = .expanded
    var design: Font.Design = .default
    var openDyslexic: Bool = false

    var animatableData: Double {
        get {size}
        set {size = newValue}
    }

    func body(content: Content) -> some View {
        content

            .font(!openDyslexic ? .system(size: size, design: design).weight(weight).width(width) : .custom("OpenDyslexic-Regular", size: size))

    }
}




extension View {
    func animatableFont(size: Double, weight: Font.Weight, width: Font.Width, design: Font.Design, openDyslexic: Bool = false) -> some View {
        self.modifier(CustomAnimatableFontModifier(size: size, weight: weight, width: width, design: design, openDyslexic: openDyslexic))
    }
}





