//
//  KyoPlus.swift
//  KyoNeo
//
//  Created by Aether on 15/08/2023.
//

import SwiftUI
import AmethystUI
import RevenueCat
import RevenueCatUI

extension Purchases {
    func resetToDefaultState(){
        
    }
}

//import SDWebImageSwiftUI

enum plusOptions: Int{
    case yearly
    case monthly
    case lifetime

    public var price: Double {
        switch self {
        case .lifetime:
            return 29.99
        case .monthly:
            return 1.99
        case .yearly:
            return 12.99
        }
    }

    public var text: String {
        switch self {
        case .lifetime:
            return ""
        case .monthly:
            return "month"
        case .yearly:
            return "year"
        }
    }
}

struct Header: Codable {
    var imageURL: String
    var isSticky: Bool
    var stretchyHeader: Bool
    var allowInteractiveDismiss: Bool
    var showDismissButton: Bool
}

struct PlusSettings: Codable {
    var useBuiltInPaywall: Bool
}


struct PaywallModel: Codable {
    var features: [Feature]
    var header: Header?
    var settings: PlusSettings?
}

struct Feature: Codable, Identifiable {
    let id = UUID()
    var icon: String
    var iconColor: String
    var title: String
    var text: String
}

struct KyoPlus: View {
    var color: Color = Color.accentColor
    var onboard: Bool = false
    @State var show: Bool = true
    @State private var showFallback = false
    @State private var headerData: Header?
    @State private var features: [Feature] = []
    @State private var Model: PaywallModel?

    @AppStorage("kyoPlus_hasPlus") var kyoPlus_hasPlus: Bool = false
    var body: some View {

        GeometryReader{
            let size = $0.size
            let safeArea = $0.safeAreaInsets

            VStack{
                if let Model, !showFallback{
                    CustomView(model: Model, safeArea: safeArea)
                }
                else{
                    if Model == nil && !showFallback{
                        ProgressView()
                                               .frame(width: size.width, height: size.height)
                    }

                    if showFallback{
                        #if !os(macOS)
                        PaywallView(displayCloseButton: false)
                            .onDisappear{
                                KyoPlus().checkPaymentStatus { Bool in
                                    kyoPlus_hasPlus = Bool
                                }
                            }
                        #endif
                    }
                }
            }
        }

        .task {
            await loadFeatures()
        }
    }

    @ViewBuilder
    func CustomView(model: PaywallModel, safeArea: EdgeInsets) -> some View{
        ScrollView {
            VStack{
                if let header = model.header{
                    GeometryReader {
                        let size = $0.size
                        let isSticky = header.isSticky
                        let stretchyHeader = header.stretchyHeader
                        let minY = $0.frame(in: .global).minY

//                        WebImage(url: URL(string: header.imageURL))
//                            .resizable()
//                            .aspectRatio(contentMode: .fill)
//                        //                        .offset(y: 20)
//                            .frame(width: size.width, height: size.height + (stretchyHeader ? (minY > 0 ? minY  : 0) : 0))
//                            .clipped()
//                            .offset(y: isSticky ? (minY > 0 ? -minY : 0) : 0)


                    }
                    .frame(height: 270)
                }
                let features = model.features

                VStack(spacing: 10){
                    ForEach(features) { feature in
                        HStack(spacing: 24) {
                            Image(systemName: feature.icon)
                                .font(.title3)
                                .foregroundColor(colorForIconColorString(feature.iconColor))
                                .scaledFrame(width: 20, height: 20, relativeTo: .body, alignment: .center)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(feature.title)
                                    .fontWeight(.medium)

                                Text(feature.text)
                            }
                            .font(.callout)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal, 28)
                .padding(.top, 10)

            }
        }
        .coordinateSpace(name: "customView")
        .ignoresSafeArea(.container, edges: .top)
#if !os(macOS)
        .paywallFooter(condensed: true) { CustomerInfo in
                    // purchase complete
                } restoreCompleted: { CustomerInfo in
                    // restore complete
                }
        #endif
    }

    func loadFeatures() async {
        do {
            guard let offering = try await Purchases.shared.offerings().current else { return }

            // Extract features array from the offering metadata
            if let featuresMetadata = offering.metadata["features"] as? [[String: String]] {
                let features = featuresMetadata.map { dict -> Feature in
                    // Map each dictionary to a Feature struct
                    return Feature(
                        icon: dict["icon"] ?? "",
                        iconColor: dict["icon-color"] ?? "",
                        title: dict["title"] ?? "",
                        text: dict["text"] ?? ""
                    )
                }

                // Extract header from the offering metadata
                if let headerMetadata = offering.metadata["header"] as? [String: Any]{
                    // Use JSONSerialization to convert the headerMetadata to JSON data, then decode it
                    let headerData = try JSONSerialization.data(withJSONObject: headerMetadata as Any, options: [])
                    let decoder = JSONDecoder()
                    let header = try decoder.decode(Header.self, from: headerData)

                    if let settingsMetadata = offering.metadata["settings"] as? [String: Any]{
                        // Use JSONSerialization to convert the headerMetadata to JSON data, then decode it
                        let settingsData = try JSONSerialization.data(withJSONObject: settingsMetadata as Any, options: [])
                        let decoder = JSONDecoder()
                        let settings = try decoder.decode(PlusSettings.self, from: settingsData)

                        // Update state on the main thread
                                            DispatchQueue.main.async {
                                                let paywallModel = PaywallModel(features: features, header: header, settings: settings)
                                                self.Model = paywallModel

                                                if settings.useBuiltInPaywall{
                                                    showFallback = true
                                                }
                                            }
                    }


                }


            }
        } catch {
            print("Error loading offerings: \(error.localizedDescription)")
            showFallback = true
            // Handle the error appropriately, such as setting a state variable to show an error message
        }
    }

    func colorForIconColorString(_ colorString: String) -> Color {
        // Simple example of how you might convert a color string to a SwiftUI Color
        switch colorString {
        case "purple": return .purple
        case "blue": return .blue
        case "indigo": return .indigo
        case "orange": return .orange
        case "yellow": return .yellow
        case "green": return .green
        case "teal": return .teal
        default: return .gray
        }
    }
}

#Preview{
    KyoPlus()
}

struct KyoPlusCustom: View {
    @State var scrolled: Bool = false
    @Environment(\.dismiss) var dismiss
    var color: Color = Color.accentColor
    var onbaord: Bool = false
    @AppStorage("showOnboardNeo") var showOnboardNeo = true
    @AppStorage("buildNum") var buildNum = 0
    #if os(iOS)
    let features = [
            (Image(systemName: "paintpalette.fill"), "Customisation", "Personalise Kyo with colours, icons, themes, and fonts"),
            (Image(systemName: "doc.text.image"), "Today", "Unlock the today view to get a summary of your day"),
            (Image(systemName: "wrench.adjustable.fill"), "Tailored Planner", "Customise your planner to match your unique preferences"),
            (Image(systemName: "note.text"), "Organisation", "Easily attach notes and link teachers to entries for top-notch management"),
            (Image(systemName: "wand.and.rays"), "Smart Tools", "Automatically set icons, skip empty and completed days, and more"),
            (Image(systemName: "square.and.arrow.up"), "Export", "Export your data in json"),
            (Image(systemName: "eyes"), "Exciting Updates Ahead", "Grades, maps, notifications, attendance tracking, and file uploads!")
        ]
    #else
    let features = [
            (Image(systemName: "paintpalette.fill"), "Customisation", "Personalise with more colour options"),
            (Image(systemName: "doc.text.image"), "Today", "Unlock the today view to get a summary of your day"),
            (Image(systemName: "wrench.adjustable.fill"), "Tailored Planner", "Customise your planner to match your unique preferences"),
            (Image(systemName: "note.text"), "Organisation", "Easily attach notes and link teachers to entries for top-notch management"),
            (Image(systemName: "wand.and.rays"), "Smart Tools", "Automatically set icons, skip empty and completed days, and more"),
            (Image(systemName: "square.and.arrow.up"), "Export", "Export your data in json"),
            (Image(systemName: "eyes"), "Exciting Updates Ahead", "Grades, maps, notifications, attendance tracking, and file uploads!")
        ]
    #endif

    @AppStorage("multicolored") var multicolored = true
    @AppStorage("appAccentColor") var appAccentColor = "Default"
    @AppStorage("appAccentColorIndex") var appAccentColorIndex = 1
    
    @AppStorage("navigationFont") var fontDesign: navigationFont = .expanded
    @AppStorage("fontWeightIndex") private var fontWeightIndex: Int = 1
    @AppStorage("fontCaseIndex") private var fontCaseIndex: Int = 0

    @State var paymentOption: plusOptions = .yearly

    let emojis = ["🚀", "🧑‍🏫", "💯", "🔥", "🤩", "✍️", "📔",
                  "🎓", "📚", "🔬", "🧪", "📐", "📖", "🧮", "🔭",
                  "📝", "📙", "📘", "📗", "📕", "🧑‍🔬", "🧑‍💻", "💡", "🔍", "👩‍🏫",
                  "🧑‍🎓", "👨‍🎓", "👩‍🔬", "👨‍🔬", "👩‍💻", "👨‍💻", "🎨", "🎭", "🎲", "🧩",
                  "🎻", "🎺", "🥁", "🎹", "🪗", "🎷", "🎸", "🎮", "👾", "🎈",
                  "🎉", "🎊", "🪀", "🪁", "🧸", "🎠", "🎡", "🎢", "🛼", "🍞"]

        // State variable to track the current emoji
        @State private var currentEmojiIndex = 0
    let timer = Timer.publish(every: 4.7, on: .main, in: .common).autoconnect()

    var body: some View {

        ZStack{

            ScrollView{
//                Image("kyoBanner")
//                    .resizable()
//                    .frame(maxWidth: .infinity)
//                    .aspectRatio(contentMode: .fit)
//                    .overlay {
//                        Color(color)
//                            .blendMode(.color)
//                    }
//                    .padding(.top, 10)
//                    .padding(.bottom, 25)
//                    .ignoresSafeArea()
//                    .background {
//                        LinearGradient(gradient: Gradient(colors: [ Color.clear, Color("bw"),Color("bw"),Color("bw"), Color.clear]), startPoint: .top, endPoint: .bottom)
//                    }
//                    .ignoresSafeArea()
//                    .padding(.bottom, -15)
                Button {
                    currentEmojiIndex = (currentEmojiIndex + 1) % emojis.count
                } label: {
                    Text(emojis[currentEmojiIndex])
                        .font(.system(size: 60))
                        .stroke(color: Color.white, width: 4)
                        .shadow(color: .black.opacity(0.15), radius: 3, y: 3)
                        .animation(.bouncy)
                }
                .buttonStyle(bounceButton())
                .padding(.top, 25)
                .onReceive(timer) { _ in
                                currentEmojiIndex = (currentEmojiIndex + 1) % emojis.count
                            }
#if !os(visionOS)
                .sensoryFeedback(.increase, trigger: currentEmojiIndex)
                #endif

                Text("Kyo+")
                    .font(.title.weight(.semibold).width(.expanded))
                    .padding(.top, 5)
                                    .padding(.bottom, 20)
                VStack{
                    Group{
                        Button {
                            paymentOption = .yearly
                        } label: {
                            HStack{

                                Image(systemName: paymentOption == .yearly ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(color)
                                Label {
                                    VStack(alignment: .leading){
                                        Text("Yearly + 1 Week Trial")
                                            .foregroundColor(.primary)
                                        Group{
                                            Text("$23.88/year")
                                                .strikethrough()
                                            +
                                            Text(" $12.99/year")

                                        }.foregroundColor(.primary)
                                            .opacity(0.6)
                                            .font(Font.caption.bold())
                                    }
                                } icon: {
                                    //                                Image(systemName: "repeat")
                                    //                                    .frame(width: 20, alignment: .center)
                                    //                                    .symbolRenderingMode(.hierarchical)
                                    //                                    .foregroundStyle(color)
                                }

                                .frame(maxWidth: .infinity, alignment: .leading)
                                Spacer()

                                Text("$1.08/month")
                                    .foregroundColor(.secondary)
                                    .font(Font.caption.bold())
                                    .padding(.leading, 6)
                                    .padding(.trailing, 10)
                            }
                            .contentShape(Rectangle())
                        }


                        Divider()
                            .padding(.leading, 25)
                            .padding(.vertical, 1.5)
                            .opacity(0.7)
#if os(visionOS)
                            .opacity(0.3)
                        #endif


                        Button {
                            paymentOption = .monthly
                        } label: {
                            HStack{
                                Image(systemName: paymentOption == .monthly ? "checkmark.circle.fill" : "circle")

                                    .foregroundStyle(color)

                                Label {
                                    Text("Monthly")
                                        .foregroundColor(.primary)
                                } icon: {
                                    //                                Image(systemName: "calendar")
                                    //                                    .frame(width: 20, alignment: .center)
                                    //                                    .symbolRenderingMode(.hierarchical)
                                    //                                    .foregroundStyle(color)
                                }

                                .frame(maxWidth: .infinity, alignment: .leading)
                                Spacer()

                                Text("$1.99/month")
                                    .foregroundColor(.secondary)
                                    .font(Font.caption.bold())
                                    .padding(.leading, 6)
                                    .padding(.trailing, 10)
                            }
                            .contentShape(Rectangle())
                        }

                        Divider()
                            .padding(.leading, 25)
                            .padding(.vertical, 1.5)
                            .opacity(0.7)
#if os(visionOS)
                            .opacity(0.3)
                        #endif


                        Button {
                            paymentOption = .lifetime
                        } label: {
                        HStack{
                            Image(systemName: paymentOption == .lifetime ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(color)

                            Label {
                                Text("Lifetime")
                                    .foregroundColor(.primary)
                            } icon: {
                                //                                Image(systemName: "calendar")
                                //                                    .frame(width: 20, alignment: .center)
                                //                                    .symbolRenderingMode(.hierarchical)
                                //                                    .foregroundStyle(color)
                            }

                            .frame(maxWidth: .infinity, alignment: .leading)
                            Spacer()

                            Text("$29.99")
                                .foregroundColor(.secondary)
                                .font(Font.caption.bold())
                                .padding(.leading, 6)
                                .padding(.trailing, 10)
                        }
                        .contentShape(Rectangle())
                    }
                    }
                    .padding(.horizontal, 2)
                    .padding(.vertical, 1.5)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 2)
                .padding(13)
#if !os(visionOS)
                .background(Color("NeoButton"))
                #else
                .background(.ultraThinMaterial.opacity(0.8))
                #endif
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .regularOutline(cornerRadius: 18)


                .padding(.horizontal, 20)
                .padding(.bottom, 20)

                VStack(spacing: 20){
                    ForEach(Array(features.enumerated()), id: \.element.1) { (index, feature) in
                                    HStack(spacing: 24) {
                                        feature.0
                                            .font(.title3)
                                            .foregroundColor(Color(multicolored ? "\(appAccentColor)/\((index + 1) > 5 ? 1 : index + 1)" : "\(appAccentColor)/\(appAccentColorIndex)"))
                                            .scaledFrame(width: 20, height: 20, relativeTo: .body, alignment: .center)
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(feature.1)
                                                .fontWeight(.medium)

                                            Text(feature.2)
                                        }
                                        .font(.callout)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                }
                .padding(.horizontal, 30)

            }


            .safeAreaInset(edge: .bottom) {
#if os(iOS)
    var hasHomeIndicator: Bool {
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

                VStack(spacing: 15){

                    HStack{
                        Button {

                        } label: {

                            HStack(spacing: 0){
                                Text(paymentOption != .lifetime
                                    ? "Subscribe $"
                                    : "Buy $")
                                .contentTransition(.numericText(value: paymentOption.price))
                                .animation(.smooth)


                                Text(paymentOption != .lifetime
                                    ? "\(String(format: "%.2f", paymentOption.price))/\(paymentOption.text)"
                                    : "\(String(format: "%.2f", paymentOption.price))")
                                    .contentTransition(.numericText(value: paymentOption.price))
                                    .animation(.smooth)

                            } .frame(maxWidth: .infinity, alignment: .center)
                        }
                        .buttonStyle(PolishedButton(color: color, background: true))
//
//                        Button {
//
//                        } label: {
//                            Text("$12.99 / year")
//                                .frame(maxWidth: .infinity, alignment: .center)
//                        }
//                        .buttonStyle(PolishedButton(color: Color(multicolored ? "\(appAccentColor)/1" : "\(appAccentColor)/\(appAccentColorIndex)"), background: true))
                    }
                    if onbaord{
                        Button {
                            withAnimation(.smooth){
                                showOnboardNeo = false
                                buildNum = 52
                            }
                        } label: {
                            Text("No Thanks")
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                        .buttonStyle(PolishedButton(color: color, background: false))
                    }
//                    HStack{
//                        Button {
//
//                        } label: {
//                            Text("Restore")
//                                .foregroundStyle(Color(multicolored ? "\(appAccentColor)/3" : "\(appAccentColor)/\(appAccentColorIndex)"))
//                                .frame(maxWidth: .infinity, alignment: .center)
//
//                        }
//
//                    }
//                    .padding(.horizontal, 6)


                }
                .padding(.horizontal, 30)

//                .overlay(alignment: .bottom){
//                    CherryCatView()
//                    .frame(maxWidth: .infinity, alignment: .trailing)
//                    .offset(y: 85)
//                    .offset(x: 10)
//                    .ignoresSafeArea()
//                }
                .padding(.top, 10)
                .padding(.bottom, !hasHomeIndicator ? 18 : 0)

#if !os(visionOS)
                .background{
                    ZStack{
                        LinearGradient(gradient: Gradient(colors: [ Color.clear, Color("bw").opacity(0.8),Color("bw").opacity(0.8),Color("bw").opacity(0.6)]), startPoint: .top, endPoint: .bottom)
                        BackdropBlurView(radius: 3)
                            .mask(LinearGradient(gradient: Gradient(colors: [ Color.clear, Color("bw").opacity(1),Color("bw").opacity(1),Color("bw").opacity(1)]), startPoint: .top, endPoint: .bottom))
                    }
                        .ignoresSafeArea()

                }
                #endif
            }
            .background{
                Image("bgPattern")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(ignoresSafeAreaEdges: [.horizontal, .bottom])
                    .opacity(0.18)

            }

        }
    }
}
