//
//  TitleWeight.swift
//  KyoNeo
//
//  Created by Aether on 25/12/2023.
//

import SwiftUI

struct TitleWeight: View {
    
    @AppStorage("fontWeightIndex") private var fontWeightIndex: Int = 1
    @Binding var fontWeightIndexState: Int
    @Environment(\.colorScheme) var colorScheme
    var color = Color.indigo // Replace with your desired color

    var body: some View {
        VStack {
            HStack(spacing: 0) {
                ForEach(0..<fontWeights.count) { index in
//                    let mode = fontWeights[index]
                    let makeDivider = index < fontWeights.count - 1

                    Button {
                        fontWeightIndex = index
                    } label: {
                        HStack(spacing: 7) {
                         
                            Text(fontWeights[index].name).tag(index)
                                .font(.caption)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(8)
                        .padding(.vertical, 2)

                        .contentShape(Rectangle())
                    }
                    .buttonStyle(bounceButton())
                    .foregroundStyle(index == fontWeightIndex ? Color.getIdealColor(color: color, colorScheme: colorScheme) : Color.primary)
                    if makeDivider {
                      if !(index == fontWeightIndex || (index + 1) == fontWeightIndex)  {
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
                    let caseCount = fontWeights.count
                    color.opacity(colorScheme == .light ? 0.1 : 0.25)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .frame(width: proxy.size.width / CGFloat(caseCount))
                        // Offset the background horizontally based on the selected animation mode
                        .offset(x: proxy.size.width / CGFloat(caseCount) * CGFloat(fontWeightIndex))
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
            .animation(.bouncy(duration: 0.2, extraBounce: -0.5), value: fontWeightIndex)
            .onAppear{
                fontWeightIndexState = fontWeightIndex

                // FIX: No purchase check or access-state write is needed; Kyo+ is permanently unlocked.

            }
            .onDisappear{
                fontWeightIndex = fontWeightIndexState
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

