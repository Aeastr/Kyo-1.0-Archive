//
//  ColorScheme.swift
//  KyoNeo
//
//  Created by Aether on 12/07/2023.
//

import SwiftUI

enum ColorSchemeMode: Int, CaseIterable {
    case light
    case dark
    case system

    var imageName: String {
        switch self {
        case .light:
            return "circle.bottomhalf.filled"
        case .dark:
            return "circle.tophalf.filled"
        case .system:
            return "circle.bottomrighthalf.checkered"
        }
    }

        var title: String {
            switch self {
            case .light:
                return "Light"
            case .dark:
                return "Dark"
            case .system:
                return "System"
            }
        }
}

struct ColorSchemeSettings: View {
    @AppStorage("colorSchemeMode") private var colorSchemeMode: ColorSchemeMode = .system
    @Environment(\.colorScheme) var colorScheme
    var color = Color.indigo // Replace with your desired color

    @State var TEMPmulticolored = true
    @State var TEMPappAccentColor = "Default"
    @State var TEMPappAccentColorIndex = 0
    var body: some View {
        VStack {
            HStack(spacing: 0) {
                ForEach(ColorSchemeMode.allCases.indices, id: \.self) { index in
                    let mode = ColorSchemeMode.allCases[index]
                    let makeDivider = index < ColorSchemeMode.allCases.count - 1

                    Button {
                        colorSchemeMode = mode
                    } label: {
                        HStack(spacing: 7) {
                            Image(systemName: mode.imageName)
                                .font(.title3)

                            Text(mode.title)
                                .font(.caption)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(8)
                        .padding(.vertical, 6)

                        .contentShape(Rectangle())
                    }
                    .buttonStyle(bounceButton())
                    .foregroundStyle(mode == colorSchemeMode ? color.darken(by: 0.2) : .primary)
                    if makeDivider {
                      if !(index == colorSchemeMode.rawValue || (index + 1) == colorSchemeMode.rawValue )  {
                        Divider()
                          .frame(width: 0)
                          .padding(.vertical, 10)
                      }
                    }
                }


            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 2)
            .background {
                GeometryReader { proxy in
                    let caseCount = AnimationMode.allCases.count
                    color.opacity(colorScheme == .light ? 0.1 : 0.25)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .frame(width: proxy.size.width / CGFloat(caseCount))
                        // Offset the background horizontally based on the selected animation mode
                        .offset(x: proxy.size.width / CGFloat(caseCount) * CGFloat(colorSchemeMode.rawValue))
                }
            }

            .padding(12)
            .background {
                Color("NeoButton")
                    .opacity(0.6)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.primary.opacity(colorScheme == .dark ? 0.15 : 0.08), lineWidth: 1.2))

            }
            .padding(.horizontal, 20)
            .animation(.smooth, value: colorSchemeMode)


        }
//        .modify {
//            if #available(iOS 17.0, *) {
//                $0.sensoryFeedback(.increase, trigger: colorSchemeMode)
//            }
//            else{
//                $0
//            }
//        }
    }
}

