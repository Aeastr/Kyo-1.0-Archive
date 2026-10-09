//
//  CustomBG Blur.swift
//  KyoNeo
//
//  Created by Aether on 30/07/2023.
//

import SwiftUI

#if os(iOS) || os(visionOS)
/// A View in which content reflects all behind it
struct BackdropView: UIViewRepresentable {

    func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView()
        let blur = UIBlurEffect()
        let animator = UIViewPropertyAnimator()
        animator.addAnimations { view.effect = blur }
        animator.fractionComplete = 0
        animator.stopAnimation(false)
        animator.finishAnimation(at: .current)
        return view
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) { }

}

#elseif os(macOS)
struct BackdropView: NSViewRepresentable {

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.blendingMode = .behindWindow
        view.state = .active
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) { }

}
#endif

/// A transparent View that blurs its background
struct BackdropBlurView: View, ShapeStyle {

    let radius: CGFloat

    @ViewBuilder
    var body: some View {
        BackdropView()
            .blur(radius: radius)
            .animation(.smooth)

    }

}
