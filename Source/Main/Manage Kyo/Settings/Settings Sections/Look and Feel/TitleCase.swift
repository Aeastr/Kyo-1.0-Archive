//
//  TitleCase.swift
//  KyoNeo
//
//  Created by Aether on 25/12/2023.
//

import SwiftUI

struct TitleCase: View {
    @AppStorage("fontCaseIndex") private var fontCaseIndex: Int = 0
    @Binding var fontCaseIndexState: Int
    @Environment(\.colorScheme) var colorScheme
    var color = Color.indigo // Replace with your desired color

    var body: some View {
        VStack {
            HStack(spacing: 0) {
                ForEach(0..<fontCase.count) { index in
//                    let mode = fontCase[index]
                    let makeDivider = index < fontCase.count - 1

                    Button {
                        fontCaseIndex = index
                    } label: {
                        HStack(spacing: 7) {

                            Text(fontCase[index].name).tag(index)
                                .font(.caption)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(8)
                        .padding(.vertical, 2)

                        .contentShape(Rectangle())
                    }
                    .buttonStyle(bounceButton())
                    .foregroundStyle(index == fontCaseIndex ? Color.getIdealColor(color: color, colorScheme: colorScheme) : Color.primary)
                    if makeDivider {
                      if !(index == fontCaseIndex || (index + 1) == fontCaseIndex)  {
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
                    let caseCount = fontCase.count
                    color.opacity(colorScheme == .light ? 0.1 : 0.25)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .frame(width: proxy.size.width / CGFloat(caseCount))
                        // Offset the background horizontally based on the selected animation mode
                        .offset(x: proxy.size.width / CGFloat(caseCount) * CGFloat(fontCaseIndex))
                }
            }

            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background {
                Color("NeoButton")
                    .opacity(0.6)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.primary.opacity(colorScheme == .dark ? 0.15 : 0.08), lineWidth: 1.2))

            }
            .animation(.bouncy(duration: 0.2, extraBounce: -0.5), value: fontCaseIndex)
            .onAppear{
//                fontCaseIndexState = fontCaseIndex

                // FIX: No purchase check is needed; access follows the local Pro setting.

            }
//            .onDisappear{
//                fontCaseIndex = fontCaseIndexState
//            }


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

