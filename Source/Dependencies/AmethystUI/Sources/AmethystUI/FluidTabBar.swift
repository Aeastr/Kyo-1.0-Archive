//
//  SwiftUIView.swift
//  
//
//  Created by Aether on 28/07/2023.
//

import SwiftUI
#if canImport(RiveRuntime)
import RiveRuntime
#endif

/// A model representing an item in a tab bar supporting either an SF Symbol, or a RiveViewModel.
public struct TabItem {
    /// A unique identifier for the tab item.
    public let id: UUID = UUID()

    /// The label text for the tab item.
    public let label: String

    /// The name of the icon image for the tab item.
    public let icon: String?

#if canImport(RiveRuntime)
    /// The Rive animation view model for the tab item.
    public let riveView: RiveViewModel?
    #endif
    /// The color of the tab item.
    public let color: Color

    /// The main content view of the tab item.
    public let content: AnyView

    /// An action that will trigger when the button is pressed while active
    public let codeToExecute: (() -> Void)?

    /// Creates a tab item with an icon.
    /// - Parameters:
    ///   - label: The label text for the tab item.
    ///   - icon: The name of the icon image for the tab item.
    ///   - color: The color of the tab item.
    ///   - content: The content of the tab item.
    public init<Content: View>(label: String, icon: String, color: Color = .teal, @ViewBuilder content: () -> Content, secondaryAction: (() -> Void)? = nil) {
        self.label = label
        self.icon = icon
        self.color = color
        self.content = AnyView(content())

#if canImport(RiveRuntime)
        self.riveView = nil
        #endif
        self.codeToExecute = secondaryAction
    }

#if canImport(RiveRuntime)
    /// Creates a tab item with a Rive animation.
    /// - Parameters:
    ///   - label: The label text for the tab item.
    ///   - riveView: The Rive animation view model for the tab item.
    ///   - color: The color of the tab item.
    ///   - content: The content of the tab item.
    public init<Content: View>(label: String, riveView: RiveViewModel, color: Color = .teal, @ViewBuilder content: () -> Content, secondaryAction: (() -> Void)? = nil) {
        self.label = label
        self.riveView = riveView
        self.color = color
        self.content = AnyView(content())
        self.icon = nil
        self.codeToExecute = secondaryAction
    }
    #endif
}


struct TabPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

/// A  fluid tab bar UI element.
///
///Example Usage
///     struct ContentView: View {
///     @State private var selectedIndex = 0
///
///          var body: some View {
///               VStack {
///         // Create a VStack containing the FluidTabBar and other content
///         FluidTabBar(tabItems: [
///                // Define tab items with labels, icons, colors, and content views
///             TabItem(label: "Home", icon: "house.fill", color: .blue) {
///                 Text("Home Content")
///              },
///             TabItem(label: "Profile", icon: "person.fill", color: .green) {
///                 Text("Profile Content")
///             },
///            TabItem(label: "Settings", icon: "gearshape.fill", color: .orange) {
///                   Text("Settings Content")
///                }
///           ], selectedIndex: $selectedIndex)
///           }
///           }
///          }
///

public enum fluidTabBarPageAnimationType{
    case full
    case fade
    case none
}

public enum fluidTabBarType{
    case regular
    case progressiveBlur
}

public struct FluidTabBar: View {
    var tabItems: [TabItem] = []
    @Binding var selectedIndex: Int
    @State var previousIndex: Int = 0

    // Internal @State variable to manage the selection if binding isn't provided
    @State var selectedX: CGFloat = 0
    @State var x: [CGFloat] = []
    @State var color: Color = Color.teal
    /// Initializes a fluid tab bar with the given tab items and a binding to the selected index.
        /// - Parameters:
        ///   - tabItems: An array of `TabItem` instances representing the tabs in the tab bar.
        ///   - selectedIndex: A binding to the index of the currently selected tab.
    public init(tabItems: [TabItem], selectedIndex: Binding<Int>, animateIcons: Bool = true, pageAnimation: fluidTabBarPageAnimationType = .full, showTabBar: Binding<Bool>? = nil, type: fluidTabBarType = .regular) {
        self.tabItems = tabItems
        self._selectedIndex = selectedIndex
        self._selectedX = .init(initialValue: 0)
        self._x = State(initialValue: [CGFloat](repeating: 0, count: tabItems.count))
        self.animateIcons = animateIcons
        self.pageAnimation = pageAnimation
        self.showTabBar = showTabBar
        self.barType = type
    }
    
    @Environment(\.colorScheme) var colorScheme
    var cornerRadius: CGFloat = 30
    var enableDragGesture = true
    var animation: Animation = .spring(response: 0.3, dampingFraction: 0.7)
    @State var overview = false

    var animateIcons: Bool = true
    var pageAnimation: fluidTabBarPageAnimationType = .full
    var showTabBar: Binding<Bool>?
    var barType: fluidTabBarType


    #if os(iOS)
    var drag: some Gesture {
        DragGesture()

            .onChanged { gesture in
//                let percentage = gesture.translation.width / UIScreen.main.bounds.width
//                let tabIndex = Int(ceil(5 - ((1 - percentage) * 5)))
//
//                    withAnimation(animation) {
//                    overview = true
//                    
//                    if !(tabIndex > (x.count - 1)) && !(tabIndex < 0) {
//
//                        selectedIndex = tabIndex
//                        color = tabItems[tabIndex].color
//                        selectedX = x[tabIndex]
//                    }
//
//                }
            }
            .onEnded { gesture in

                withAnimation(animation) {
                    overview = false
                }
            }
    }
    #endif

    public var body: some View {
        TabView(selection: $selectedIndex) {
                    ForEach(Array(tabItems.enumerated()), id: \.element.id) { index, tabItem in
                        NavigationStack{
                            tabItem.content
                        }
                        .tag(index)
                        #if !os(macOS)
                        .toolbar(.hidden, for: .tabBar)
                        #endif
                    }
                }

        .safeAreaInset(edge: .bottom){
            if let showTabBar = showTabBar{
                portraitTabBar
                    .ignoresSafeArea()
                    .scaleEffect(x: showTabBar.wrappedValue ? 1 : 0.75, y: showTabBar.wrappedValue ? 1 : 0.9)
                    .offset(y: showTabBar.wrappedValue ? 0 : 200)
                    .animation(.bouncy, value: showTabBar.wrappedValue)
            }
            else{
                    portraitTabBar
                        .ignoresSafeArea()
            }

        }

        // FIX: Read UIKit geometry after SwiftUI finishes the current layout evaluation.
        .onAppear {
            #if os(iOS)
            DispatchQueue.main.async {
                let value = archiveReadHomeIndicator()
                if archiveHasHomeIndicator != value {
                    archiveHasHomeIndicator = value
                }
            }
            #endif
        }

    }

    #if os(iOS)
    // FIX: Cache the window inset outside body evaluation to avoid a SwiftUI layout cycle.
    // Preserve the original inset lookup below; only its timing changes.
    @State private var archiveHasHomeIndicator = false
    var hasHomeIndicator: Bool { archiveHasHomeIndicator }

    private func archiveReadHomeIndicator() -> Bool {
        if #available(iOS 15.0, *) {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
                return false
            }
            return windowScene.windows.first?.safeAreaInsets.bottom ?? 0 > 0
        } else {
            return UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0 > 0
        }
    }
    #else
    var hasHomeIndicator: Bool {
        return false
    }
    #endif

    var portraitTabBar: some View{
        VStack{

            HStack{

                    ForEach(Array(tabItems.enumerated()), id: \.element.id) { index, tabItem in
                    // Add a Spacer() for the first item
                        if index == 0 { Spacer().accessibilityHidden(true) }

                    // Create a VStack containing the tab icon and text with a spacing of 3
                    ZStack {




                    VStack(spacing: 3) {
                        // Use a ZStack to adjust the icon color based on the selected tab
                        ZStack {
                            if index == selectedIndex {
                                color
                                    .frame(width: 31, height: 29)
                            } else {


                                    Color.secondary
                                        .frame(width: 31, height: 29)

                            }
                        }
                        // Mask the ZStack with the icon view
                        .mask{

#if canImport(RiveRuntime)
                            if let icon = tabItem.icon{
                                Image(systemName: icon)
                                    .font(.system(size: 20))
                                    .frame(width: 31, height: 29)
                            }
                            else if let icon = tabItem.riveView{
                                icon.view()
                                    .frame(width: 31, height: 27)
                            }
                            #else
                            if let icon = tabItem.icon{
                                Image(systemName: icon)
                                    .font(.system(size: 20))
                                    .frame(width: 31, height: 29)
                            }
                            #endif

                        }
                        // Display the tab text with a font of .caption2 and a maximum width of 58 points
                        Text(tabItem.label.capitalized).font(.caption2)
                            .fontWeight(.medium)
                            .frame(width: 58)
                            .foregroundStyle(index == selectedIndex ? color : .secondary)

                    }
                    // Add an overlay using a GeometryReader to track the X-coordinate of each tab item
                    .overlay(
                        GeometryReader { proxy in
                            let offset = proxy.frame(in: .global).minX
                            Color.clear
                                .preference(key: TabPreferenceKey.self, value: offset)
                                .onAppear{
                                    if index == selectedIndex {
                                        selectedX = x[index]
                                    }
                                }
                                .onPreferenceChange(TabPreferenceKey.self) { value in
                                    if index >= x.count {
                                        x.append(value)
                                    } else {
                                        x[index] = value
                                    }
                                    if index == selectedIndex {
                                        selectedX = x[index]
                                    }
                                }
                        }
                    )
                }
                    .accessibilityLabel(tabItem.label)
                    .id(tabItem.id)
                    .contentShape(Rectangle())
                    .onAppear{
                        if selectedIndex == index{
                            color = tabItem.color
                            selectedX = x[index]
                        }
                    }
                    .onTapGesture {
                        withAnimation(animation) {
                            if selectedIndex == index{
                                print("AmethystUI - cI")
                                if let code = tabItem.codeToExecute{
                                    code()
                                    print("AmethystUI - execute secondaryCode")
                                }
                                else{
                                    print("AmethystUI - couldn't find secondaryCode")
                                }
                            }
                            else{
                                print("AmethystUI - cN")
#if os(iOS)
                                let impact = UIImpactFeedbackGenerator(style: .light)
                                impact.impactOccurred()
#endif
                                previousIndex = selectedIndex
                                selectedIndex = index
                                //
                                color = tabItem.color
                                selectedX = x[index]

#if canImport(RiveRuntime)
                                if let icon = tabItem.riveView, animateIcons{

                                    try? icon.setInput("press", value: true)
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                        try? icon.setInput("press", value: false)
                                    }
                                }
                                #endif

                            //                                if animationsMode == .enabled{
                            //                                    // Update the icon's "press" input value and reset it after a delay
                            //                                    try? tab.icon.setInput("press", value: true)
                            //                                    print("set press state to true for \(tab.text)")
                            //                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            //                                        try? tab.icon.setInput("press", value: false)
                            //                                        print("set press state to false for \(tab.text)")
                            //                                    }
                            //                                }
                        }
                    }
                    }

//
//
//                        .modify {
//                            if #available(iOS 17.0, *) {
//                                $0.onChange(of: selectedTab){
//                                    if selectedTab == tab.tab{
//                                        withAnimation((animationsMode == .enabled && !reduceMotion) ? .spring(response: 0.3, dampingFraction: 0.7) : .none) {
//                                            selectedX = x[index]
//                                        }
//                                    }
//                                }
//                            }
//                            else{
//                                $0.onChange(of: selectedTab){ change in
//                                    if selectedTab == tab.tab{
//                                        withAnimation((animationsMode == .enabled && !reduceMotion) ? .spring(response: 0.3, dampingFraction: 0.7) : .none) {
//                                            selectedX = x[index]
//                                        }
//                                    }
//                                }
//                            }
//                        }

                Spacer()
            }
            }
            .accessibilityElement(children: .contain)
            #if os(iOS)
            .gesture(enableDragGesture ? drag : nil)
            #endif
            .padding(.bottom, hasHomeIndicator ? 20 : 13)
            .padding(.horizontal, 2)
            .padding(.top, hasHomeIndicator ? 6 : 10)
            .frame(maxWidth: .infinity, maxHeight: hasHomeIndicator ? 85 : 69)
            .background{
                if barType == .regular {
                    Color.clear
                        .background(.regularMaterial)
                }
            }

            .clipShape(UnevenRoundedRectangle(cornerRadii: .init(
                            topLeading: hasHomeIndicator ? cornerRadius : 0,
                            bottomLeading: 0,
                            bottomTrailing: 0,
                            topTrailing: hasHomeIndicator ? cornerRadius : 0),
                                                          style: .continuous))

            .background(
                            barType == .regular ?
                            background
                                .frame(maxWidth: .infinity, maxHeight: hasHomeIndicator ? 85 : 69)
                                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                            : nil
                        )
            #if !os(macOS)
            .background{

                if let mask = UIImage(named: "maskbottomtotop"), barType == .progressiveBlur {
                    // Display the image only if it's successfully loaded
                    VariableBlurView(gradientMask: mask)
                        .ignoresSafeArea()
                }
                else{

                }
            }
            #endif

            .overlay(
                            barType == .regular ?
                            UnevenRoundedRectangle(cornerRadii: .init(
                                topLeading: hasHomeIndicator ? cornerRadius : 0,
                                bottomLeading: 0,
                                bottomTrailing: 0,
                                topTrailing: hasHomeIndicator ? cornerRadius : 0),
                                                   style: .continuous)
                                .trim(from: 0.5, to: 1)
                                .stroke(
                                    colorScheme == .dark ? .white.opacity(1)
                                    : .primary.opacity(1), lineWidth: 1
                                )
                                .padding(.horizontal, hasHomeIndicator ? 0.5 : -0.5)
                                .padding(.vertical, hasHomeIndicator ? 0.5 : 0.5)

                                .blendMode(colorScheme == .dark ? .overlay : .overlay)
                            : nil

                        )
            .overlay(barType == .regular ? overlay : nil)


            .ignoresSafeArea()

    }
        .ignoresSafeArea()
    }

    var verticalTabBar: some View{
        VStack{
        GeometryReader { proxy in

            let hasHomeIndicator = proxy.safeAreaInsets.bottom > 0
            VStack{

                    ForEach(Array(tabItems.enumerated()), id: \.element.id) { index, tabItem in
                    // Add a Spacer() for the first item
                    if index == 0 { Spacer() }

                    // Create a VStack containing the tab icon and text with a spacing of 3
                    ZStack {




                    VStack(spacing: 3) {
                        // Use a ZStack to adjust the icon color based on the selected tab
                        ZStack {
                            if index == selectedIndex{
                                color
                                    .frame(width: 31, height: 29)
                            } else {


                                    Color.secondary
                                        .frame(width: 31, height: 29)

                            }
                        }
                        // Mask the ZStack with the icon view
                        .mask{
                            if let icon = tabItem.icon{
                                Image(systemName: icon)
                                    .font(.title3)
                                    .frame(width: 31, height: 29)
                            }


                        }
                        // Display the tab text with a font of .caption2 and a maximum width of 58 points
                        Text(tabItem.label.capitalized).font(.caption2)
                            .fontWeight(.medium)
                            .frame(width: 58)
                            .foregroundStyle(index == selectedIndex  ? color : .secondary)

                    }
                    // Add an overlay using a GeometryReader to track the X-coordinate of each tab item
                    .overlay(
                        GeometryReader { proxy in
                            let offset = proxy.frame(in: .global).minX
                            Color.clear
                                .preference(key: TabPreferenceKey.self, value: offset)
                                .onAppear{
                                    if index == selectedIndex {
                                        selectedX = x[index]
                                    }
                                }
                                .onPreferenceChange(TabPreferenceKey.self) { value in
                                    if index >= x.count {
                                        x.append(value)
                                    } else {
                                        x[index] = value
                                    }
                                    if index == selectedIndex {
                                        selectedX = x[index]
                                    }
                                }
                        }
                    )
                    // Handle tap gestures on each tab item

                    // Set the foreground style based on whether the tab is selected


                    // Add a Spacer() between each tab item
                }
                    .id(tabItem.id)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(animation) {
    //                        let impact = UIImpactFeedbackGenerator(style: .light)
    //                        impact.impactOccurred()


//                                color = Color(multicolored ? "\(appAccentColor)/\(tab.id + 1)" : "\(appAccentColor)/\(appAccentColorIndex)")
                            color = tabItem.color
                            selectedX = x[index]
//                                if animationsMode == .enabled{
//                                    // Update the icon's "press" input value and reset it after a delay

#if canImport(RiveRuntime)
                            if let icon = tabItem.riveView{
                                
                                icon.setInput("press", value: true)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                    icon.setInput("press", value: false)
                                }
                            }
                            #endif
//                                }
                        }
                    }

//                        .modify {
//                            if #available(iOS 17.0, *) {
//                                $0.sensoryFeedback(.increase, trigger: selectedTab)
//                            }
//                        }
//
//
//                        .modify {
//                            if #available(iOS 17.0, *) {
//                                $0.onChange(of: selectedTab){
//                                    if selectedTab == tab.tab{
//                                        withAnimation((animationsMode == .enabled && !reduceMotion) ? .spring(response: 0.3, dampingFraction: 0.7) : .none) {
//                                            selectedX = x[index]
//                                        }
//                                    }
//                                }
//                            }
//                            else{
//                                $0.onChange(of: selectedTab){ change in
//                                    if selectedTab == tab.tab{
//                                        withAnimation((animationsMode == .enabled && !reduceMotion) ? .spring(response: 0.3, dampingFraction: 0.7) : .none) {
//                                            selectedX = x[index]
//                                        }
//                                    }
//                                }
//                            }
//                        }

                Spacer()
            }
        }
            .padding(.bottom, hasHomeIndicator ? 20 : 13)
            .padding(.horizontal, 2)
            .padding(.top, hasHomeIndicator ? 6 : 10)
            .frame(maxWidth:  hasHomeIndicator ? 85 : 69, maxHeight: .infinity)
            .background(.regularMaterial)

            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))

            .background(
                 background
            )
            .overlay(overlay)

            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(
                        colorScheme == .dark ? .white.opacity(0.5)
    : color.opacity(0.15)
                    )
                    .blendMode(colorScheme == .dark ? .overlay : .normal)

            )

            .frame(maxHeight: .infinity, alignment: .bottom)
            .ignoresSafeArea()
        }
    }
    }

    var background: some View{
        RoundedRectangle(cornerRadius: 30)
            .fill(color)
            .offset(x: selectedX)
            .frame(width: 108)
            .frame(width: 58)
            .scaleEffect(y: 0.86)
            .frame(maxWidth: .infinity, alignment: .leading)
            .opacity(colorScheme == .dark ? 0.3 : 0.5)
        }

    var overlay: some View{
        Rectangle()
            .fill(color)
            .frame(width: 28, height: 5)
            .cornerRadius(3)
            .frame(width: 58)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .offset(x: selectedX)
    }
}



#Preview {
    regularIconExample()
}


struct regularIconExample: View {
    @AppStorage("index") var index: Int = 0
    @State var scrolled: Bool = false
    var body: some View {
        FluidTabBar(tabItems: [
            TabItem(label: "circle", icon: "circle", content: {
                ScrollView{
                    Text("View 1")
                }
            }),
            TabItem(label: "square", icon: "square", color: Color.red, content: {
                ScrollView{
                    Text("View 2")
                }
            }),
            TabItem(label: "rectangle", icon: "rectangle",color: Color.indigo , content: {
                ScrollView{
                    Text("View 3")
                }
            }),
            TabItem(label: "triangle", icon: "triangle", color: Color.pink ,content: {
                ScrollView{
                    ScrollDetector(scrolled: $scrolled)
                    ForEach(0..<30, id: \.self) { _ in
                        HStack{
                            Image(systemName: "triangle")
                                .frame(maxWidth: .infinity)
                            Image(systemName: "triangle")
                                .frame(maxWidth: .infinity)
                            Image(systemName: "triangle")
                                .frame(maxWidth: .infinity)
                            Image(systemName: "triangle")
                                .frame(maxWidth: .infinity)
                            Image(systemName: "triangle")
                                .frame(maxWidth: .infinity)
                            Image(systemName: "triangle")
                                .frame(maxWidth: .infinity)
                            Image(systemName: "triangle")
                                .frame(maxWidth: .infinity)
                            Image(systemName: "triangle")
                                .frame(maxWidth: .infinity)
                            Image(systemName: "triangle")
                                .frame(maxWidth: .infinity)
                        }
                        .font(.title3.weight(.bold))
                        .padding()
                        .background(Color.pink.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: /*@START_MENU_TOKEN@*/.continuous/*@END_MENU_TOKEN@*/))
                        .foregroundStyle(Color.pink)
                    }
                    .padding(.horizontal, 20)

                }
                .coordinateSpace(name: "scroll")
                .safeAreaInset(edge: .top, content: {
                    Color.clear.frame(height: 85)
                })
                .overlay(alignment: .top) {
                    FluidNavigationBar(title: "Triangle", compactMode: true, scrolled: $scrolled) {
                        Button {

                        } label: {
                            Text("Test")
                        }

                    } toolbar: {
                        
                    }

                }
            })
        ], selectedIndex: $index, type: .regular)
        .ignoresSafeArea(edges: [.bottom])

    }
}


