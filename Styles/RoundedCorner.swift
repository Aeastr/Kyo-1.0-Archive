//
//  RoundedCorner.swift
//  KyoNeo
//
//  Created by Aether on 04/01/2023.
//

import SwiftUI

#if canImport(UIKit)
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
            
        )
        return Path(path.cgPath)
    }
}
#endif
