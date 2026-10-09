//
//  SettingsGroup.swift
//  KyoNeo
//
//  Created by Aether on 24/12/2023.
//

import SwiftUI

struct GroupItem: Identifiable, Equatable, Hashable {
    var id: UUID = UUID()
    var label: String
    var description: String?
    var icon: String
    var trailingIcons: [String]?
    var color: Color?
    var destinationView: AnyView?
    var customContent: AnyView?
    var useOldLink: Bool = false
    var action: (() -> Void)?
    var link: URL?
    var linkedBoolBinding: (() -> Binding<Bool>)? = nil
    var visible: Bool = true
    var enabled: Bool = true

    static func == (lhs: GroupItem, rhs: GroupItem) -> Bool {
        return lhs.id == rhs.id && lhs.label == rhs.label && lhs.icon == rhs.icon
    }



    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(label)
        hasher.combine(icon)
        // Note: destinationView is not included
    }
}


struct SettingsGroup: View {
    var color: Color
    var groupItems: [GroupItem]
    var background: Bool
    var dividers: Bool

    init(color: Color = .accentColor, _ groupItems: [GroupItem], background: Bool = false, dividers: Bool = false) {
            self.color = color
            self.groupItems = groupItems
        self.background = background
        self.dividers = dividers
        }
    
    var body: some View {
      
        VStack(spacing: 10) {
            ForEach(Array(groupItems.enumerated()), id: \.offset) { index, group in
                if group.visible{
                let useColor = (group.color ?? color)
                if group.destinationView != nil {
                    if !group.useOldLink{
                        NavigationLink(value: group) {
                            HStack {
                                Label {
                                    Text(group.label).foregroundColor(.primary)
#if os(visionOS)
                                        .padding(.leading, 8)
#else
                                        .padding(.leading, 4)
#endif
                                } icon: {
                                    Image(systemName: group.icon)
                                        .frame(width: 20, height: 20, alignment: .center)
                                        .symbolRenderingMode(.monochrome)
                                        .fontWeight(.regular)
    #if os(visionOS)
                                        .foregroundColor(useColor.getBrightness() > 0.65 ? useColor.darken(by: 0.5) : Color.white)
                                        .scaleEffect(0.86)
                                        .padding(6)

                                        .background(useColor.darken(by: useColor.getBrightness() > 0.65 ? -0.2 : 0.2).gradient)
                                        .clipShape(Circle())
    #else
                                        .foregroundColor(useColor)
    #endif
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                Spacer()
                                if let trailingIcons = group.trailingIcons{
                                    ForEach(trailingIcons, id: \.self){ icon in
                                        Image(systemName: icon)
                                            .foregroundColor(.secondary)
                                            .font(Font.caption.bold())

                                    }
                                }
                                Image(systemName: "chevron.forward")
                                    .foregroundColor(.secondary)
                                    .font(Font.caption.bold())
                                    .padding(.trailing, 10)
                            }
#if os(visionOS)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
#else

                            .padding(.vertical, 2)
                            .padding(.horizontal, 3)
#endif
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .buttonBorderShape(.roundedRectangle(radius: 15))
                        .disabled(!group.enabled)
                        .opacity(group.enabled ? 1.0 : 0.5)

                    }
                    else{
                        NavigationLink {
                            group.destinationView
                        } label: {
                            HStack {
                                Label {
                                    Text(group.label).foregroundColor(.primary)
                                } icon: {
                                    Image(systemName: group.icon)
                                        .frame(width: 20, height: 20, alignment: .center)
                                        .symbolRenderingMode(.monochrome)
                                        .fontWeight(.regular)
    #if os(visionOS)
                                        .foregroundColor(useColor.getBrightness() > 0.65 ? useColor.darken(by: 0.5) : Color.white)
                                        .scaleEffect(0.86)
                                        .padding(6)

                                        .background(useColor.darken(by: useColor.getBrightness() > 0.65 ? -0.2 : 0.2).gradient)
                                        .clipShape(Circle())
    #else
                                        .foregroundColor(useColor)
    #endif
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                Spacer()
                                Image(systemName: "chevron.forward")
                                    .foregroundColor(.secondary)
                                    .font(Font.caption.bold())
                                    .padding(.trailing, 10)
                            }
                            .padding(.vertical, 10)
                            .padding(.horizontal, 15)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .disabled(!group.enabled)
                        .opacity(group.enabled ? 1.0 : 0.5)
                    }
                }
                else if let action = group.action{
                    Button {
                        action()
                    } label: {
                        HStack {
                            Label {
                                Text(group.label).foregroundColor(.primary)

                                #if os(visionOS)
                                .padding(.leading, 8)
                                #else
                                .padding(.leading, 2)
                                #endif
                            } icon: {
                                Image(systemName: group.icon)
                                    .frame(width: 20, height: 20, alignment: .center)
                                    .symbolRenderingMode(.monochrome)
                                    .fontWeight(.regular)
#if os(visionOS)
                                    .foregroundColor(useColor.getBrightness() > 0.65 ? useColor.darken(by: 0.5) : Color.white)
                                    .scaleEffect(0.86)
                                    .padding(6)

                                    .background(useColor.darken(by: useColor.getBrightness() > 0.65 ? -0.2 : 0.2).gradient)
                                    .clipShape(Circle())
#else
                                    .foregroundColor(useColor)
#endif
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            Spacer()
                            Image(systemName: "arrow.right.circle")
                                .foregroundColor(.secondary)
                                .font(Font.caption.bold())
                                .padding(.trailing, 10)
                        }
#if os(visionOS)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
#else

                            .padding(.vertical, 2)
                            .padding(.horizontal, 3)
#endif
                        .contentShape(Rectangle())
                    }
                    .disabled(!group.enabled)
                    .opacity(group.enabled ? 1.0 : 0.5)

                }
                else if let link = group.link{

                    Link(destination: link) {
                        HStack {
                            Label {
                                Text(group.label).foregroundColor(.primary)

                                #if os(visionOS)
                                .padding(.leading, 8)
                                #else
                                .padding(.leading, 2)
                                #endif
                            } icon: {
                                Image(systemName: group.icon)
                                    .frame(width: 20, height: 20, alignment: .center)
                                    .symbolRenderingMode(.monochrome)
                                    .fontWeight(.regular)
#if os(visionOS)
                                    .foregroundColor(useColor.getBrightness() > 0.65 ? useColor.darken(by: 0.5) : Color.white)
                                    .scaleEffect(0.86)
                                    .padding(6)

                                    .background(useColor.darken(by: useColor.getBrightness() > 0.65 ? -0.2 : 0.2).gradient)
                                    .clipShape(Circle())
#else
                                    .foregroundColor(useColor)
#endif
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            Spacer()
                        }
#if os(visionOS)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
#else

                            .padding(.vertical, 2)
                            .padding(.horizontal, 3)
#endif
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .buttonBorderShape(.roundedRectangle(radius: 15))
                    .disabled(!group.enabled)
                    .opacity(group.enabled ? 1.0 : 0.5)

                }
                else if let boolBindingClosure = group.linkedBoolBinding {
                    Toggle(isOn: boolBindingClosure()) {
                        HStack {
                            Label {
                                VStack(alignment: .leading){
                                    Text(group.label).foregroundColor(.primary)

                                    if let description = group.description{
                                        Text(description)
                                            .font(.caption).opacity(0.5)
                                    }
                                }
                                #if os(visionOS)
                                .padding(.leading, 8)
                                #else
                                .padding(.leading, 2)
                                #endif
                            } icon: {
                                Image(systemName: group.icon)
                                    .frame(width: 20, height: 20, alignment: .center)
                                    .symbolRenderingMode(.monochrome)
                                    .fontWeight(.regular)
#if os(visionOS)
                                    .foregroundColor(useColor.getBrightness() > 0.65 ? useColor.darken(by: 0.5) : Color.white)
                                    .scaleEffect(0.86)
                                    .padding(6)

                                    .background(useColor.darken(by: useColor.getBrightness() > 0.65 ? -0.2 : 0.2).gradient)
                                    .clipShape(Circle())
#else
                                    .foregroundColor(useColor)
#endif
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            Spacer()
                        }
                        .padding(.horizontal, 3)
                        .padding(.vertical, 2)
                        .contentShape(Rectangle())
                    }
                    .disabled(!group.enabled)
                    .opacity(group.enabled ? 1.0 : 0.5)

                }
                    else if let customContent = group.customContent{
                        HStack {
                            Label {
                                VStack(alignment: .leading){
                                    Text(group.label).foregroundColor(.primary)

                                    if let description = group.description{
                                        Text(description)
                                            .font(.caption).opacity(0.5)
                                    }
                                }

                                #if os(visionOS)
                                .padding(.leading, 8)
                                #else
                                .padding(.leading, 2)
                                #endif
                            } icon: {
                                Image(systemName: group.icon)
                                    .frame(width: 20, height: 20, alignment: .center)
                                    .symbolRenderingMode(.monochrome)
                                    .fontWeight(.regular)
#if os(visionOS)
                                    .foregroundColor(useColor.getBrightness() > 0.65 ? useColor.darken(by: 0.5) : Color.white)
                                    .scaleEffect(0.86)
                                    .padding(6)

                                    .background(useColor.darken(by: useColor.getBrightness() > 0.65 ? -0.2 : 0.2).gradient)
                                    .clipShape(Circle())
#else

                                    .scaleEffect(0.86)
                                    .foregroundColor(useColor)
#endif
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            Spacer()

                            customContent
                        }
                        .padding(.horizontal, 3)
                        .padding(.vertical, 2)
                        .contentShape(Rectangle())
                        .disabled(!group.enabled)
                        .opacity(group.enabled ? 1.0 : 0.5)

                    }
#if os(visionOS)
                if dividers && index < groupItems.count - 1 {
                    Divider().padding(.leading, 26).opacity(0.7).padding(.vertical, 1)

                        .opacity(0.35)
                }
#else
                if index < groupItems.count - 1 {
                    Divider().padding(.leading, 26).opacity(0.7).padding(.vertical, 1)


                }
#endif

            }}
            }
            .frame(maxWidth: 700)

        



        #if os(visionOS)
            .modify {
                        if background {
                            $0.neoSettingsCard()

                        } else {
                            $0
                        }
                    }
        #else
            .neoSettingsCard()
        #endif


    }


}

struct GroupSection<Content: View>: View {
    var label: String?
    var locked: Bool = false
    let content: () -> Content

    init(label: String? = nil, locked: Bool = false , @ViewBuilder content: @escaping () -> Content = { Text("") }) {
        self.label = label
        self.locked = locked
        self.content = content
    }

    var body: some View {
        VStack {
//#if !os(visionOS)
            HStack{
                if let label = label {
                                if locked{
                                    Image(systemName: "lock")
                                                            .framelessSectionTitle()
                                }
                                Text(label)
                                    .sectionTitle()
                            }
            }

//#endif

            content()
                .disabled(locked)
                .opacity(locked ? 0.5 : 1.0)
//#if os(visionOS)
//                .padding(.bottom, 20)
//            #endif
        }

        .frame(maxWidth: 700)
    }
}


struct groupDemo: View {
    var body: some View {
        SettingsGroup(color: .red, [GroupItem(label: "Rotation", icon: "rotate", destinationView: AnyView(AutomaticWeeks(color: .red)))])
    }
}
