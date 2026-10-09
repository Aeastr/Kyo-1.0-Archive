//
//  CustomBlur.swift
//  KyoNeo
//
//  Created by Aether on 20/07/2023.
//

import SwiftUI
#if !os(macOS)
public struct TransparentBlurView: UIViewRepresentable {
    public var removeAllFilters: Bool = false

    public func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))

        return view
    }

    public func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        DispatchQueue.main.async{
            if let backdropLayer = uiView.layer.sublayers?.first {
                if removeAllFilters {
                    backdropLayer.filters = []
                }
                else{
                    backdropLayer.filters?.removeAll(where: { filter in
                        String(describing: filter) != "gaussianBlur"
                    })
                }
            }
        }
    }

}
#endif
