//
//  regularOutlineMenu.swift
//  KyoNeo
//
//  Created by Aether on 15/08/2023.
//

import SwiftUI

struct regularOutlineMenu: ButtonStyle {
    var color: Color = Color.accentColor
    func makeBody(configuration: Configuration) -> some View {
        configuration.label

        .opacity(configuration.isPressed ? 0.7 : 1)
            .padding(.vertical, 15)
//            .background((accent).opacity(0.1))
            .background (
                Color("NeoButton").opacity(0.4)
            )
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .regularOutline(lineWidth: configuration.isPressed ? 2.1 : 1.1 ,color: configuration.isPressed ? color : .primary.opacity(0.3))
    }
}
