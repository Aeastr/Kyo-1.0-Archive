//
//  SwiftUIView.swift
//
//
//  Created by Aether on 09/06/2023.
//

import SwiftUI

// MARK: - Text Case Environment

public enum FluidTextCase: Equatable {
    case uppercase
    case lowercase
    case none
}

public struct FluidTextCaseKey: EnvironmentKey {
    public static let defaultValue: FluidTextCase? = FluidTextCase.none
}

public extension EnvironmentValues {
    var fluidTextCase: FluidTextCase? {
        get { self[FluidTextCaseKey.self] }
        set { self[FluidTextCaseKey.self] = newValue }
    }
}

public struct FluidTextCaseModifier: ViewModifier {
    let textCase: FluidTextCase

    public func body(content: Content) -> some View {
        content
            .environment(\.fluidTextCase, textCase)
    }
}

public extension View {
    func fluidTextCase(_ textCase: FluidTextCase) -> some View {
        self.modifier(FluidTextCaseModifier(textCase: textCase))
    }
}


// MARK: - OpenDyslexic Environment

public struct FluidTitleOpenDyslexic: EnvironmentKey {
    public static let defaultValue: Bool = false
}

public extension EnvironmentValues {
    var fluidTitleOpenDyslexic: Bool {
        get { self[FluidTitleOpenDyslexic.self] }
        set { self[FluidTitleOpenDyslexic.self] = newValue }
    }
}

public struct FluidTitleOpenDyslexicModifier: ViewModifier {
    let openDyslexic: Bool

    public func body(content: Content) -> some View {
        content
            .environment(\.fluidTitleOpenDyslexic, openDyslexic)
    }
}

public extension View {
    func fluidTitleOpenDyslexic(_ openDyslexic: Bool) -> some View {
        self.modifier(FluidTitleOpenDyslexicModifier(openDyslexic: openDyslexic))
    }
}

// MARK: - Title Width Environment

public struct FluidTitleWidthKey: EnvironmentKey {
    public static let defaultValue: Font.Width = .standard
}

public extension EnvironmentValues {
    var fluidTitleWidth: Font.Width {
        get { self[FluidTitleWidthKey.self] }
        set { self[FluidTitleWidthKey.self] = newValue }
    }
}

public struct FluidTitleWidthModifier: ViewModifier {
    let titleWidth: Font.Width

    public func body(content: Content) -> some View {
        content
            .environment(\.fluidTitleWidth, titleWidth)
    }
}

public extension View {
    func fluidTitleWidth(_ width: Font.Width) -> some View {
        self.modifier(FluidTitleWidthModifier(titleWidth: width))
    }
}

// MARK: - Title Weight Environment

public struct FluidTitleWeightKey: EnvironmentKey {
    public static let defaultValue: Font.Weight = .regular
}

public extension EnvironmentValues {
    var fluidTitleWeight: Font.Weight {
        get { self[FluidTitleWeightKey.self] }
        set { self[FluidTitleWeightKey.self] = newValue }
    }
}

public struct FluidTitleWeightModifier: ViewModifier {
    let titleWeight: Font.Weight

    public func body(content: Content) -> some View {
        content
            .environment(\.fluidTitleWeight, titleWeight)
    }
}

public extension View {
    func fluidTitleWeight(_ weight: Font.Weight) -> some View {
        self.modifier(FluidTitleWeightModifier(titleWeight: weight))
    }
}

// MARK: - Title Design Environment

public struct FluidTitleDesignModifier: ViewModifier {
    let titleDesign: Font.Design

    public func body(content: Content) -> some View {
        content
            .environment(\.fluidTitleDesign, titleDesign)
    }
}

public struct FluidTitleDesignKey: EnvironmentKey {
    public static let defaultValue: Font.Design = .default
}

public extension EnvironmentValues {
    var fluidTitleDesign: Font.Design {
        get { self[FluidTitleDesignKey.self] }
        set { self[FluidTitleDesignKey.self] = newValue }
    }
}

public extension View {
    func fluidTitleDesign(_ design: Font.Design) -> some View {
        self.modifier(FluidTitleDesignModifier(titleDesign: design))
    }
}


public enum NavigationBarType: String {
    case regular
    case back
    case hybrid
}
// MARK: - Accent Image Environment

public struct FluidAccentImageKey: EnvironmentKey {
    public static let defaultValue: Image? = nil
}

public extension EnvironmentValues {
    var fluidAccentImage: Image? {
        get { self[FluidAccentImageKey.self] }
        set { self[FluidAccentImageKey.self] = newValue }
    }
}

public struct FluidAccentImageModifier: ViewModifier {
    let accentImage: Image

    public func body(content: Content) -> some View {
        content
            .environment(\.fluidAccentImage, accentImage)
    }
}

public extension View {
    func fluidAccentImage(_ image: Image) -> some View {
        self.modifier(FluidAccentImageModifier(accentImage: image))
    }
}


// MARK: - Main View
public struct FluidNavigationBar<Content: View, ToolbarContent: View>: View {
    // Properties

    // Title
    var title: String
    @Environment(\.fluidTitleWidth) var titleWidth
    @Environment(\.fluidTitleWeight) var titleWeight
    @Environment(\.fluidTitleDesign) var titleDesign
    @Environment(\.fluidTitleOpenDyslexic) var openDyslexic
    @Environment(\.fluidAccentImage) var accentImage
    @Environment(\.fluidTextCase) var textCase
    var compactMode: Bool

    // Navigation Bar
    var type: NavigationBarType = .regular
    var color: Color = Color("3", bundle: .module)
    var tintColor: Color = Color("3", bundle: .module)
    var linelimit: Int = 1
    var inSheet: Bool

    let method: navigationBarMethod
    let overrideBackAction: (() -> Void)?
    // Appearance
    @Environment(\.colorScheme) var colorScheme
    @State var scaleFactor: CGFloat = 350000

    // Interaction
    @Binding var scrolled: Bool
    @Environment(\.dismiss) var dismiss

    // Content
    @ViewBuilder var content: Content

    // Toolbar
    @ViewBuilder var toolbar: ToolbarContent
    @Namespace var ns



    public init(
        title: String = "Navigation Title",
        titleColor: Color = Color.primary,
        titleWidth: Font.Width = .standard,
        titleWeight: Font.Weight = .regular,
        titleDesign: Font.Design = .default,
        tintColor: Color = .purple,
        compactMode: Bool = true,
        type: NavigationBarType = .regular,
        scrolled: Binding<Bool>,
        linelimit: Int = 1,
        inSheet: Bool = false,
        method: navigationBarMethod = .auto,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder toolbar: @escaping () -> ToolbarContent,
        overrideBackAction: (() -> Void)? = nil
    ) {
        self.title = title
        self.color = titleColor
        self.tintColor = tintColor
        //        self.titleWidth = titleWidth
        //        self.titleWeight = titleWeight
        //        self.titleDesign = titleDesign
        self.compactMode = compactMode
        self.type = type
        self._scrolled = scrolled
        self.content = content()
        self.toolbar = toolbar()
        self.linelimit = linelimit
        self.method = method
        self.inSheet = inSheet
        self.overrideBackAction = overrideBackAction
    }
    /// Body

    let targetContentWidth: CGFloat = 159
    let baseFontSize: CGFloat = 30
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    public var body: some View {
        //        GeometryReader { geo in
        VStack {
            ZStack(alignment: .leading){
                HStack {
                    HStack {
                        if type == .back {
                            // VStack containing toolbar and title with new alignment and spacing

                            VStack(alignment: .leading, spacing: compactMode ? 4 : 10) {
                                if (horizontalSizeClass == .compact || method == .custom) && method != .hybrid {
                                HStack{
                                    ZStack{
                                        toolbar
                                            .foregroundColor(scrolled ? color : tintColor)
                                            .textCase(textCase == FluidTextCase.none ? nil : textCase == FluidTextCase.lowercase ? .lowercase : .uppercase)
                                    }
                                    .lineLimit(1)
                                    .frame(minHeight: 20)
                                    Spacer()
                                    HStack(spacing: 20){
                                        if compactMode{
                                            content
                                                .foregroundColor(scrolled ? .primary : color)

                                                .buttonStyle(FFnavigationBarButtons())
                                                .padding(.trailing, -6)
                                        }
                                    }
                                    //                                    .scaledFrame(width: nil, height: 44, relativeTo: .body)
                                }
                            }
                                HStack{

                                    Button {
                                        if let overrideBackAction = overrideBackAction{
                                            overrideBackAction()
                                        }
                                        else{
                                            dismiss()
                                        }
                                    } label: {

                                        HStack {
                                            Image(systemName: "chevron.backward")
                                                .font(Font.title2.weight(.semibold))

                                                .foregroundColor(color)

                                                .padding(.leading, 5)
                                                .padding(.trailing, 3)


                                            Text(LocalizedStringKey(title))

                                                .animatableFont(size: scrolled ? getTitleFontSize(isLargeTitle: false) :
                                                                    getTitleFontSize(isLargeTitle: true)
                                                                , weight: titleWeight, width: titleWidth, design: titleDesign, openDyslexic: openDyslexic)
                                                .minimumScaleFactor(0.1)
                                                .lineLimit(linelimit)
                                                .foregroundColor(color)
                                                .animation(.smooth, value: titleWeight)
                                                .animation(.smooth, value: titleWidth)
                                                .animation(.smooth, value: titleDesign)
                                                .textCase(textCase == FluidTextCase.none ? nil : textCase == FluidTextCase.lowercase ? .lowercase : .uppercase)
                                        }
                                    }
                                    .buttonStyle(FFnavigationBarTitleButton())


                                }

                            }
                        }
                        else{
                            // VStack containing toolbar and title with new alignment and spacing

                            VStack(alignment: .leading, spacing: compactMode ? 4 : 10) {
#if os(iOS)
                                if (horizontalSizeClass == .compact || method == .custom) && method != .hybrid {
                                    HStack{

                                        ZStack{
                                            toolbar
                                                .foregroundColor(scrolled ? color : tintColor)
                                                .blendMode(.normal)
                                                .textCase(textCase == FluidTextCase.none ? nil : textCase == FluidTextCase.lowercase ? .lowercase : .uppercase)
                                        }
                                        .frame(minHeight: 20)
                                        .lineLimit(1)

                                        Spacer()

                                        HStack(spacing: 20){
                                            if compactMode{
                                                content
                                                    .foregroundColor(scrolled ? .primary : color)

                                                    .buttonStyle(FFnavigationBarButtons())
                                                    .padding(.trailing, -6)
                                                    .frame(minHeight: 44)
                                            }
                                        }
                                        //                                    .scaledFrame(width: nil, height: 44, relativeTo: .body)
                                    }
                                }

#endif
                                ZStack{

                                    Button {

                                    } label: {

                                        Text(LocalizedStringKey(title))

                                            .contentTransition(.numericText())
                                            .animation(.smooth, value: title)
                                            .animatableFont(size: scrolled ? getTitleFontSize(isLargeTitle: false) :
                                                                getTitleFontSize(isLargeTitle: true)
                                                            , weight: titleWeight, width: titleWidth, design: titleDesign, openDyslexic: openDyslexic)
                                            .minimumScaleFactor(0.1)
                                            .lineLimit(linelimit)
                                            .foregroundColor(color)
                                            .textCase(textCase == FluidTextCase.none ? nil : textCase == FluidTextCase.lowercase ? .lowercase : .uppercase)

                                    }
                                    .buttonStyle(FFnavigationBarTitleButton())


                                }

                            }

                        }


                    }

                    .padding(.horizontal, 20)
                    Spacer()
                    if !compactMode{
                        HStack(spacing: 10){
                            content


                        }.padding(.trailing, 20)
                    }
                }

                .dynamicTypeSize(.large ... .xLarge)
                //                .frame(width: geo.size.width)
                .padding(.bottom, 4.5)
                .background{
                    ZStack{
#if !os(macOS)
                        GeometryReader{  geo in
                            VariableBlurView()

                            //                            .opacity(scrolled ? 1 : 0.6)
                            //                            .animation(.smooth(duration: 0.3), value: scrolled)

                            if let accentImage = accentImage{
                                accentImage
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(height: 130)
                                    .foregroundStyle(tintColor)
                                    .mask(LinearGradient(gradient: Gradient(colors: [Color.black.opacity(colorScheme == .dark ? 0.157 : 0.15), Color.clear]), startPoint: .top, endPoint: .bottom))
                                    .frame(maxHeight: .infinity, alignment: .top)
                                    .offset(y: inSheet ? -40 : 0)
                                    .opacity(scrolled ? 0.2 : 1)
                            }
                        }

                        .allowsHitTesting(false)

#endif
                    }

                    .ignoresSafeArea()
                    .accessibilityHidden(true)

                }

            }
            // .frame(height: scrolled ? 44 : 70)
            //  .offset(y: scrolled ? -4 : 0)
        }
        .padding(.bottom, 20)



    }

    func quadraticFunction(x: Double) -> Double {
        let a: Double = 0.000207
        let b: Double = -0.0648
        let c: Double = 38.408

        let y = a * pow(x, 2) + b * x + c
        return y
    }
}

struct neoPreview: View{
    @State var scrolled = false
    @State var title = "New Task"
    var body: some View{
        NavigationSplitView {
            ScrollView{
                scrollDetection

                items
            }
            .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
#if os(iOS)
            .safeAreaInset(edge: .top, content: {
                Color.clear.frame(height: 80)
            })
#endif
            .amethystNavigationBar(title: "Test Title", scrolled: $scrolled, content: {
                HStack{

                    Button {

                    } label: {
                        Image(systemName: "moon.stars.fill")
                        //                            .background{
                        //                                Rectangle().fill(Color.black.opacity(0.1)).blur(radius: 4).scaleEffect(1.7)
                        //                            }
                    }.buttonStyle(neoNavigationButton(scrolled: $scrolled))


                    Button {

                    } label: {
                        Image(systemName: "moon.stars.fill")
                        //                                .background{
                        //                                    Rectangle().fill(Color.black.opacity(0.1)).blur(radius: 4).scaleEffect(1.7)
                        //                                }
                    }.buttonStyle(neoNavigationButton(scrolled: $scrolled))


                }
            }, toolbar: {
                Text("test toolbar")
            })
        } detail: {
            ScrollView{
                items
                    .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
            }
            .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)

            .amethystNavigationBar(title: "Test Title", scrolled: $scrolled, content: {
                HStack{

                    Button {

                    } label: {
                        Image(systemName: "moon.stars.fill")
                        //                            .background{
                        //                                Rectangle().fill(Color.black.opacity(0.1)).blur(radius: 4).scaleEffect(1.7)
                        //                            }
                    }.buttonStyle(neoNavigationButton(scrolled: $scrolled))


                    Button {

                    } label: {
                        Image(systemName: "moon.stars.fill")
                        //                                .background{
                        //                                    Rectangle().fill(Color.black.opacity(0.1)).blur(radius: 4).scaleEffect(1.7)
                        //                                }
                    }.buttonStyle(neoNavigationButton(scrolled: $scrolled))


                }
            }, toolbar: {
                Text("test toolbar")
            })
        }


    }

    var scrollDetection: some View {
        GeometryReader { proxy in
            Color.clear
                .preference(key: ScrollPreferenceKey.self, value: proxy.frame(in: .named("scroll")).minY)
        }
        .frame(height: 0)
        .onPreferenceChange(ScrollPreferenceKey.self, perform: { value in
            withAnimation(.spring(response: 0.1, dampingFraction: 3)) {
                scrolled = value < -13
            }
        })
    }

    var items: some View {
        VStack(alignment: .leading) {
            ForEach((1...10), id: \.self) { _ in

                Button {
                    if title != "CO4149 CompSci Task" {
                        title = "CO4149 CompSci Task"
                    }
                    else{
                        title = "New Task"
                    }
                } label: {
                    Text("Button")
                }

                //                    .scrollTransition { content, phase in
                //                        content
                //                            .blur(radius: phase.isIdentity ? 0 : 10)
                //                            .opacity(phase.isIdentity ? 1 : 0.8)
                //                    }
            }
        }
        .padding()
    }

}

#Preview {

    neoPreview()


}

extension Color {
    static func randomSystemColor() -> Color {
        let systemColors: [Color] = [ .blue, .purple, .pink, .indigo]
        return systemColors.randomElement() ?? .teal
    }
}

// Custom Wrapper View
struct AmethystNavigationBarWrapper<Content: View, ToolbarContent: View, WrappedView: View>: View {
    @Environment(\.presentationMode) var presentationMode
    let wrappedView: WrappedView
    let title: String
    let titleColor: Color
    let tintColor: Color
    let compactMode: Bool
    let type: NavigationBarType?
    let method: navigationBarMethod
    let scrolled: Binding<Bool>
    let linelimit: Int
    let inSheet: Bool
    let content: () -> Content
    let toolbar: () -> ToolbarContent
    let overrideBackAction: (() -> Void)?
    let debug: Bool = true

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    var body: some View {
        if horizontalSizeClass == .compact && method == .auto{
            wrappedView
                .overlay(alignment: .top, content: {
                    FluidNavigationBar(
                        title: title,
                        titleColor: titleColor,
                        tintColor: tintColor,
                        compactMode: compactMode,
                        type: type ?? (presentationMode.wrappedValue.isPresented ? .back : .regular),
                        scrolled: scrolled,
                        linelimit: linelimit,
                        inSheet: inSheet,
                        content: content,
                        toolbar: toolbar,
                        overrideBackAction: overrideBackAction
                    )
                })
                .toolbar(.hidden)
                .onAppear{
                    if debug{
                        print("showing, is compact and is auto")
                    }
                }
        }
        else if method == .auto || method == .hybrid{
            VStack{
                wrappedView

                //                .navigationTitle(title)
                    .onAppear{
                        if debug{
                            print("showing, is not compact and is auto/hybrid")
                        }
                    }
            }
            .toolbar(content: {

                ToolbarItem(placement: .navigation) {
                    toolbar()
                }

                ToolbarItem(placement: .primaryAction) {
                    content()
                }

            })
            .navigationTitle("")
            #if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            #endif
            .overlay(alignment: .top, content: {
                FluidNavigationBar(
                    title: title,
                    titleColor: titleColor,
                    tintColor: tintColor,
                    compactMode: compactMode,
                    type: type ?? (presentationMode.wrappedValue.isPresented ? .back : .regular),
                    scrolled: scrolled,
                    linelimit: linelimit,
                    inSheet: inSheet,
                    content: { EmptyView() as? Content },
                    toolbar: { EmptyView() as? ToolbarContent },
                    overrideBackAction: overrideBackAction
                )


//                    .offset(y: 20)
            })

        }
        else{
            wrappedView
                .overlay(alignment: .top, content: {
                    FluidNavigationBar(
                        title: title,
                        titleColor: titleColor,
                        tintColor: tintColor,
                        compactMode: compactMode,
                        type: type ?? (presentationMode.wrappedValue.isPresented ? .back : .regular),
                        scrolled: scrolled,
                        linelimit: linelimit,
                        inSheet: inSheet,
                        content: content,
                        toolbar: toolbar,
                        overrideBackAction: overrideBackAction
                    )
                })
                .toolbar(.hidden)
                .onAppear{
                    if debug{
                        print("showing, on backup")
                    }
                }
        }
    }
}

public enum navigationBarMethod{
    case custom
    case native
    case hybrid
    case auto
}

// Extension
public extension View {
    func amethystNavigationBar<Content: View, ToolbarContent: View>(
        title: String = "Navigation Title",
        titleColor: Color = .primary,
        titleWidth: Font.Weight = .regular,
        titleWeight: Font.Weight = .regular,
        titleDesign: Font.Design = .default,
        tintColor: Color = .purple,
        compactMode: Bool = true,
        overrideType: NavigationBarType? = nil,
        method: navigationBarMethod = .auto,
        scrolled: Binding<Bool>,
        linelimit: Int = 1,
        inSheet: Bool = false,
        @ViewBuilder content: @escaping () -> Content = { EmptyView() as! Content },
        @ViewBuilder toolbar: @escaping () -> ToolbarContent,
        overrideBackAction: (() -> Void)? = nil
    ) -> some View {
#if os(iOS)
        Group{
            if method != .native {

                AmethystNavigationBarWrapper(
                    wrappedView: self,
                    title: title,
                    titleColor: titleColor,
                    tintColor: tintColor,
                    compactMode: compactMode,
                    type: overrideType,
                    method: method,
                    scrolled: scrolled,
                    linelimit: linelimit,
                    inSheet: inSheet,
                    content: content,
                    toolbar: toolbar,
                    overrideBackAction: overrideBackAction
                )
            }
            else{
                self
                    .navigationTitle(title)
                    .toolbar(content: {
                                        ToolbarItem(placement: .primaryAction) {
                                            content()
                                        }
                                    })
                    .toolbar(content: {
                        ToolbarItem(placement: .navigation) {
                                                                    toolbar()
                                                                }
                    })
            }
        }
#else
        self
            .navigationTitle(title)
            .toolbar(content: {
                                ToolbarItem(placement: .primaryAction) {
                                    content()
                                }

                                ToolbarItem(placement: .navigation) {
                                    toolbar()
                                }
                            })
#endif
    }
}


