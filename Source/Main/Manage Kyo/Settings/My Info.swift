//
//  My Info.swift
//  KyoNeo
//
//  Created by Aether on 11/03/2023.
//

import SwiftUI
import AmethystUI
struct MyInfo: View {
    var color: Color
    @AppStorage("Contrast") var contrast = false
    @AppStorage("tintPages") var tintPages = false
    @AppStorage("name") var name = ""
    @Environment(\.colorScheme) private var colorScheme
    @FocusState private var focusedField: Bool

    @State var startTime = Date()
    @State var endTime = Date()

    @State var scrolled: Bool = false
    var body: some View {
        ScrollView {

            Group{
                Text("Name")
                    .sectionTitle(bottomPadding: 0)
                Text("Kyo will display your name in certain parts of the app")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                HStack(spacing: 0) {
                    Image(systemName: "character.textbox")
                        .font(Font.body.weight(.semibold))
                        .foregroundStyle(.primary)
                        .padding(.leading, 13)
                        .padding(.trailing, 5)
                        .modify {
                            if #available(iOS 17.0, *) {
                                $0.symbolEffect(.bounce, value: focusedField)
                            }
                            else{
                                $0
                            }
                        }

                    TextField("Enter your name..", text: $name)
                        .focused($focusedField)
                        .textContentType(.name)
                        .textFieldStyle(.plain)
#if !os(macOS)
                        .keyboardType(.asciiCapable)
                    #endif

                    //                        .onChange(of: scrollAmmount) { oldValue, newValue in
                    //
                    //                            if newValue > oldValue {
                    //
                    //                                focusedField = false
                    //                            }
                    //                        }
                }
                .padding(.vertical, 15)
                .background {
                    Color("textField").opacity( 0.3)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    // .shadow(color: actualColor.opacity(scrolled ? 0 : 0.3), radius: 7, x: 0, y: 8)
                        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.primary.opacity(0.15), lineWidth: 1.5))
                }
                .contentShape(Rectangle())

            }
            .padding(.horizontal, 20)

        }

        .navigationTitle("About")
#if os(iOS) || os(visionOS)
            .navigationTitle("")
            .navigationBarHidden(true)
            .coordinateSpace(name: "scroll")
            .safeAreaInset(edge: .top, content: {
                Color.clear.frame(height: 80)
            })
            .overlay(alignment: .top){
                FluidNavigationBar(title: "My Info", titleColor: .primary,   tintColor: color, compactMode: true, type: .back, scrolled: $scrolled, content: {
                    
                }, toolbar: {
                    
                })
            }
#endif
    }

}
