//
//  AnimationsCustomisation .swift
//  KyoNeo
//
//  Created by Aether on 01/05/2023.
//

import SwiftUI

enum AnimationMode: Int, CaseIterable {
    case enabled
    case reduced
    case disabled

    var imageName: String {
        switch self {
        case .disabled:
            return "figure.stand"
        case .reduced:
            return "figure.walk"
        case .enabled:
            return "figure.run"
        }
    }

        var title: String {
            switch self {
            case .disabled:
                return "None"
            case .reduced:
                return "Reduced"
            case .enabled:
                return "Full"
            }
        }
}


struct AnimationsView: View {
    @AppStorage("animationModeKey") private var animationsMode: AnimationMode = .enabled
    @State private var animationsModeState: AnimationMode = .enabled
    @Environment(\.colorScheme) var colorScheme
    var color = Color.indigo // Replace with your desired color

    var body: some View {
        VStack {
            HStack(spacing: 0) {
                ForEach(AnimationMode.allCases.indices, id: \.self) { index in
                    let mode = AnimationMode.allCases[index]
                    let makeDivider = index < AnimationMode.allCases.count - 1

                    Button {
                        animationsModeState = mode
                    } label: {
                        HStack(spacing: 7) {
                            Image(systemName: mode.imageName)
                                .font(.title3)

                            Text(mode.title)
                                .font(.caption)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(8)
                        .padding(.vertical, 2)

                        .contentShape(Rectangle())
                    }
                    .buttonStyle(bounceButton())
                    .foregroundStyle(mode == animationsModeState ? Color.getIdealColor(color: color, colorScheme: colorScheme) : Color.primary)
                    if makeDivider {
                      if !(index == animationsModeState.rawValue || (index + 1) == animationsModeState.rawValue )  {
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
                        .offset(x: proxy.size.width / CGFloat(caseCount) * CGFloat(animationsModeState.rawValue))
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
            .animation(.bouncy(duration: 0.2, extraBounce: -0.5), value: animationsModeState)
            .onAppear{
                animationsModeState = animationsMode
            }
            .onDisappear{
                animationsMode = animationsModeState
            }


        }
//        .modify {
//            if #available(iOS 17.0, *) {
//                $0.sensoryFeedback(.increase, trigger: animationsMode)
//            }
//            else{
//                $0
//            }
//        }

    }
}
