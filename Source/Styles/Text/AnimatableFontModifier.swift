//
//  AnimatableFontModifier.swift
//  KyoNeo
//
//  Created by Aether on 20/11/2022.
//

import SwiftUI

@available(iOS 16.0, *)
struct AnimatableFontModifier: AnimatableModifier {
    var size: Double
    var weight: Font.Weight = .semibold
    var width: Font.Width = .expanded
    var design: Font.Design = .default
    
    var animatableData: Double {
        get {size}
        set {size = newValue}
    }
    
    func body(content: Content) -> some View {
        content
            
            .font(.system(size: size, design: design).weight(weight).width(width))
            
    }
}


extension View {
    @available(iOS 16.0, *)
    func animatableFont(size: Double, weight: Font.Weight, width: Font.Width, design: Font.Design) -> some View {
        self.modifier(AnimatableFontModifier(size: size, weight: weight, width: width, design: design))
    }
    func animatableFontLegacy(size: Double, weight: Font.Weight, design: Font.Design) -> some View {
        self.modifier(AnimatableFontModifierLegacy(size: size, weight: weight, design: design))
    }
}

struct AnimatableFontModifierLegacy: AnimatableModifier {
    var size: Double
    var weight: Font.Weight = .semibold
    var design: Font.Design = .default

    var animatableData: Double {
        get {size}
        set {size = newValue}
    }

    func body(content: Content) -> some View {
        content

            .font(.system(size: size, design: design).weight(weight))
            .frame(maxWidth: .infinity, alignment: .leading)

    }
}
