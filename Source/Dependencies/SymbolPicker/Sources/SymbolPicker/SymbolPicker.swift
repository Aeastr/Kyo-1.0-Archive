//
//  SymbolPicker.swift
//  SymbolPicker
//
//  Created by Yubo Qin on 2/14/22.
//

import SwiftUI

/// A simple and cross-platform SFSymbol picker for SwiftUI.
public struct SymbolPicker: View {

    // MARK: - Static consts

    private static var symbols: [String] {
        Symbols.shared.allSymbols
    }

    private static var hightlightSymbols: [String] {
        Symbols.shared.hightlightSymbols
    }

    private static var gridDimension: CGFloat {
        #if os(iOS)
        return 62
        #elseif os(tvOS)
        return 128
        #elseif os(macOS)
        return 48
        #else
        return 48
        #endif
    }

    private static var symbolSize: CGFloat {
        #if os(iOS)
        return 24
        #elseif os(tvOS)
        return 48
        #elseif os(macOS)
        return 24
        #else
        return 24
        #endif
    }

    private static var symbolCornerRadius: CGFloat {
        #if os(iOS)
        return 8
        #elseif os(tvOS)
        return 12
        #elseif os(macOS)
        return 8
        #else
        return 8
        #endif
    }

    private static var unselectedItemBackgroundColor: Color {
        #if os(iOS)
        return Color(UIColor.systemBackground)
        #else
        return .clear
        #endif
    }


    // MARK: - Properties

    @Binding public var symbol: String


    @State private var searchText = ""
    @Environment(\.presentationMode) private var presentationMode

    // MARK: - Public Init

    /// Initializes `SymbolPicker` with a string binding that captures the raw value of
    /// user-selected SFSymbol.
    /// - Parameter symbol: String binding to store user selection.


    private let backgroundColor: Color
    private let accent: Color
#if os(iOS)
    public init(symbol: Binding<String>, background: Color = Color(UIColor.systemGroupedBackground), accent: Color = .blue) {
            _symbol = symbol

        self.backgroundColor = background
        self.accent = accent
        }
    #else
    public init(symbol: Binding<String>, background: Color = .clear, accent: Color = .blue) {
            _symbol = symbol
        self.backgroundColor = background
        self.accent = accent
        }
    #endif


    // MARK: - View Components

    @ViewBuilder
    private var searchableSymbolGrid: some View {
        #if os(iOS)
        if #available(iOS 15.0, *) {
            symbolGrid
                .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
            
                .background(Color("Background3"))
        } else {
            VStack {
                TextField(LocalizedString("search_placeholder"), text: $searchText)
                    .padding(8)
                    .padding(.horizontal, 8)
                    .background(Color(UIColor.systemGray5))
                    .cornerRadius(8.0)
                    .padding(.horizontal, 16.0)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                symbolGrid
                    .padding(.top)
            }
        }
        #elseif os(tvOS)
        VStack {
            TextField(LocalizedString("search_placeholder"), text: $searchText)
                .padding(.horizontal, 8)
                .autocapitalization(.none)
                .disableAutocorrection(true)
            symbolGrid
        }

        /// `searchable` is crashing on tvOS 16. What the hell aPPLE?
        ///
        /// symbolGrid
        ///     .searchable(text: $searchText, placement: .automatic)
        #elseif os(macOS)
        VStack(spacing: 0) {
            HStack {
                TextField(LocalizedString("search_placeholder"), text: $searchText)
                    .textFieldStyle(.plain)
                    .font(.system(size: 18.0))
                    .disableAutocorrection(true)

                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .frame(width: 16.0, height: 16.0)
                }
                .buttonStyle(.borderless)
            }
            .padding()

            Divider()

            symbolGrid
        }
        #else
        symbolGrid
            .searchable(text: $searchText, placement: .automatic)
        #endif
    }

    private var symbolGrid: some View {
        ScrollView {
            Text("Highlights")
                .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                .font(.headline)
                .padding(.horizontal, 10)
                .padding(.top, 10)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: Self.gridDimension, maximum: Self.gridDimension), spacing: 0)], spacing: 0) {
                ForEach(Self.hightlightSymbols.filter { searchText.isEmpty ? true : $0.localizedCaseInsensitiveContains(searchText) }, id: \.self) { thisSymbol in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)){
                            symbol = thisSymbol
                            presentationMode.wrappedValue.dismiss()
                        }
                    } label: {
                        Image(systemName: thisSymbol)
                            .font(.system(size: Self.symbolSize))
                            .frame(maxWidth: .infinity, minHeight: Self.gridDimension)
                            .foregroundColor(thisSymbol == symbol ? .white : .primary)
                            .background(thisSymbol == symbol ? accent.opacity(0.6) : Color.clear)
                            .clipShape(RoundedRectangle(cornerRadius: Self.symbolCornerRadius, style: .continuous))
                            .shadow(color: accent.opacity(0.6), radius: thisSymbol == symbol ? 10 : 0, y: thisSymbol == symbol ? 2 : 0)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(bounceButton())

                    #if os(iOS)
                    .hoverEffect(.lift)
                    #endif
                }
            }
            .padding(.horizontal, 5)

            Text("All Symbols")
                .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                .font(.headline)
                .padding(.horizontal, 10)
                .padding(.top, 10)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: Self.gridDimension, maximum: Self.gridDimension), spacing: 0)], spacing: 0) {
                ForEach(Self.symbols.filter { searchText.isEmpty ? true : $0.localizedCaseInsensitiveContains(searchText) }, id: \.self) { thisSymbol in
                    Button {
                        symbol = thisSymbol
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        if thisSymbol == symbol {
                            Image(systemName: thisSymbol)
                            

                                .font(.system(size: Self.symbolSize))
                                #if os(tvOS)
                                .frame(minWidth: Self.gridDimension, minHeight: Self.gridDimension)
                                #else
                                .frame(maxWidth: .infinity, minHeight: Self.gridDimension)
                                #endif
                                .background(accent.opacity(0.6))
                                .clipShape(RoundedRectangle(cornerRadius: Self.symbolCornerRadius, style: .continuous))
                                .shadow(color: accent.opacity(0.6), radius: 10, y: 2)
                                .foregroundColor(.white)
                        } else {
                            Image(systemName: thisSymbol)
                                .font(.system(size: Self.symbolSize))
                                .frame(maxWidth: .infinity, minHeight: Self.gridDimension)


                                .cornerRadius(Self.symbolCornerRadius)
                                .foregroundColor(.primary)
                        }
                    }
                    .buttonStyle(bounceButton())

                    #if os(iOS)
                    .hoverEffect(.lift)
                    #endif
                }
            }
            .padding(.horizontal, 5)

        }
    }

    public var body: some View {
        #if !os(macOS)
        NavigationView {
            ZStack {
                #if os(iOS)
                backgroundColor
                    .edgesIgnoringSafeArea(.all)
                #endif
                searchableSymbolGrid
            }
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            #if !os(tvOS)
            /// tvOS can use back button on remote
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(LocalizedString("cancel")) {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            #endif
        }
        .navigationViewStyle(.stack)
        #else
        searchableSymbolGrid
            .frame(width: 540, height: 320, alignment: .center)
            .background(.regularMaterial)
        #endif
    }

}

private func LocalizedString(_ key: String) -> String {
    NSLocalizedString(key, bundle: .module, comment: "")
}

struct SymbolPicker_Previews: PreviewProvider {
    @State static var symbol: String = "square.and.arrow.up"

    static var previews: some View {
        Group {
            preview1()

            SymbolPicker(symbol: Self.$symbol)
                .preferredColorScheme(.dark)
                .accentColor(.blue)
        }
    }
}

struct preview1: View {
    @State var symbol: String = "book.closed"
    var body: some View {
        SymbolPicker(symbol: $symbol, accent: .blue)
            .accentColor(.red)
    }
}

struct bounceButton: ButtonStyle {

    // Define the body of the ButtonStyle
    func makeBody(configuration: Self.Configuration) -> some View {

        configuration.label
            .scaleEffect(x: configuration.isPressed ? 1.0 : 1.0 , y:configuration.isPressed ? 1.2 : 1.0)
            .opacity(configuration.isPressed ? 0.7 : 1)
            .scaleEffect(x: configuration.isPressed ? 0.9 : 1.0 , y:configuration.isPressed ? 0.7 : 1.0)
            .animation(.easeOut, value: configuration.isPressed)

    }
}
