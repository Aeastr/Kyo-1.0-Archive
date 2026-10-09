//
//  pageTopHue.swift
//  KyoNeo
//
//  Created by Aether on 12/07/2023.
//

import SwiftUI

struct pageTopHue: View {
    var color: Color
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("showPageTopHue") var showPageTopHue = true

    var body: some View {
        VStack{
//            if showPageTopHue{
//                ZStack{
//                    LinearGradient(gradient: Gradient(colors: [color.opacity(colorScheme == .light ? 0.15 : 0.2), Color.clear]), startPoint: .top, endPoint: .bottom)
//                        .frame(height: 180)
//                }
//                Spacer()
//            }
        }
        .ignoresSafeArea()
    }
}

