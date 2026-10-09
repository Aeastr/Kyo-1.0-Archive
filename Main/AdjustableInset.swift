//
//  AdjustableInset.swift
//  KyoNeo
//
//  Created by Aether on 24/04/2024.
//

import SwiftUI

struct AdjustableInset: View {

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    var compactSize: CGFloat = 95
    var regularSize: CGFloat = 50

    var body: some View {
        Color.clear.frame(height: horizontalSizeClass == .compact ? compactSize : regularSize)
    }

    func adjustableInset() -> CGFloat{
        return horizontalSizeClass == .compact ? compactSize : regularSize
    }
}


#Preview {
    AdjustableInset()
}
