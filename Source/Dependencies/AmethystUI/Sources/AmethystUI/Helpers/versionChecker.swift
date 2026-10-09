//
//  versionChecker.swift
//  
//
//  Created by Aether on 08/08/2023.
//

import SwiftUI

extension View {
    @ViewBuilder
    func checkMod<Content: View>(@ViewBuilder _ transform: (Self) -> Content?) -> some View {
        if let view = transform(self), !(view is EmptyView) {
            view
        } else {
            self
        }
    }
}
