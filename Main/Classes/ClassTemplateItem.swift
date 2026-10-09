//
//  ClassTemplateItem.swift
//  KyoNeo
//
//  Created by Aether on 16/07/2023.
//

import SwiftUI


struct ClassTemplateItem: View {
    let name: String
    let icon: String
    let color1: Color
    let color2: Color
    let shortName: String

    var body: some View {
        ZStack {
            let brightness1 = color1.getBrightness()
            let c1 = color1
            let brightness2 = color2.getBrightness()
            LinearGradient(
                gradient: Gradient(colors: [color1, color2]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .mask(
                RoundedRectangle(cornerRadius: 25, style: .continuous)
            )

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: icon)
                        .symbolRenderingMode(.hierarchical)
                        .font(.system(size: 23))
                        .padding(10)
                        .frame(width: 50, height: 50)
                        .shadow(color: color1.opacity(0.2), radius: 3, y: 3)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .foregroundColor(brightness1 > 0.82 ? c1.darken(by: 0.5) : c1)
                        .padding(.trailing, 3)
                        .transition(.blur)
                        .contentTransition(.opacity)
                        .animation(.smooth, value: icon)
                    VStack(alignment: .leading) {
                        Text(name)
                            .font(Font.body.weight(.semibold))
                            .lineLimit(2)
                            .minimumScaleFactor(0.5)
                            .foregroundColor(brightness1 > 0.82 ? c1.darken(by: 0.5) : Color.white)
                            .lineSpacing(1)
                            .multilineTextAlignment(.leading)
                    }
                    Spacer()
                }
            }
            .padding(.leading, 14)
            .padding(.trailing, 25)
            .padding(.vertical, 13)
        }
    }
}
