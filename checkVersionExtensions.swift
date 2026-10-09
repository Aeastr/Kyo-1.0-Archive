//
//  checkVersionExtensions.swift
//  KyoNeo
//
//  Created by Aether on 14/07/2023.
//


import SwiftUI

extension View {
    @ViewBuilder
    func modify<Content: View>(@ViewBuilder _ transform: (Self) -> Content?) -> some View {
        if let view = transform(self), !(view is EmptyView) {
            view
        } else {
            self
        }
    }
}


