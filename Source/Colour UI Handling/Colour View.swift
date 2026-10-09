//
//  Colour View.swift
//  KyoNeo
//
//  Created by Aether on 28/01/2023.
//

import SwiftUI
import RevenueCatUI

struct ColorPanel: View {
    @State var showMenu = false
    @State var showEditMenu = false
    @Binding var current1: Color
    @Binding var current2: Color
    @State var editingColor: CustomUserColor = CustomUserColor()

    @Environment(\.dismiss) var dismiss

    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "timestamp", ascending: true)]) var colors: FetchedResults<CustomUserColor>

    @AppStorage("selectedHueSet") var selectedHueSet: HueSet = .defaultHues
    @State var colourName: String = ""

    // FIX: Archive access is unconditional; do not read or update a persisted purchase flag.

    private var kyoPlus_hasPlus: Bool { true }
    @State private var kyoPlus_showPurchaseScreen: Bool = false
    var body: some View {
        #if !os(macOS)
        let columns = [
                GridItem(.adaptive(minimum: 63))

        ]
        #elseif os(macOS)

        let columns = [
            GridItem(.adaptive(minimum: 60, maximum: 70))
        ]
        #endif

        VStack {

            HStack{
                Menu {
                    Picker("Colour", selection: $selectedHueSet) {
                        ForEach(HueSet.allCases, id: \.self){ set in

                            if kyoPlus_hasPlus{
                                Label(set.rawValue.capitalized, systemImage: "")


                            }
                            else{
                                if set == .defaultHues{

                                        Label(set.rawValue.capitalized, systemImage: "")
                                            .id(set)

                                }
                                else{
                                    Label(set.rawValue.capitalized, systemImage: "lock")
//                                        .tag(HueSet.none)
                                        .disabled(true) // Disable the label with the lock icon
                                }
                            }


                        }
                    }
                } label: {
                    HStack(spacing: 4){
                        Text(selectedHueSet.rawValue.capitalized)
                            .contentTransition(.interpolate)
                            .fixedSize(horizontal: true, vertical: false)

                        Image(systemName: "chevron.down")
                            .font(.caption)
                            .offset(y: 1)
                    }
                    .padding(10)

                    .padding(.horizontal, 5)
                    .regularOutline()
                }
                .buttonStyle(BouncyButton())
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .animation(.smooth, value: selectedHueSet)
                .padding(.bottom, 6)

                Spacer()
            }
            


            LazyVGrid(columns: columns, spacing: 10) {
                if let hues = selectedHueSet.hues {
                    ForEach(hues, id: \.id) { hue in

                        CustomColorCircleHard(hue: hue, current1: $current1, current2: $current2, colourName: $colourName)
                            .modify {
                                if #available(iOS 17.0, *) {
                                    $0.scrollTransition { content, phase in
                                        content
                                            .opacity(phase.isIdentity ? 1 : 0.5)
                                    }
                                }
                                else{
                                    $0
                                }
                            }
                            .transition(.move(edge: .trailing).animation(.smooth))
                            .disabled((kyoPlus_hasPlus ? false : selectedHueSet != .defaultHues))
//                            .blur(radius: (kyoPlus_hasPlus ? false : selectedHueSet == .defaultHues) ? 0 : 15)


                    }
                }
                else if selectedHueSet == .customColours && kyoPlus_hasPlus{

                    Button {
                        showMenu.toggle()
                    } label: {
                        Image(systemName: "plus")
                            .frame(width: 60, height: 60)
                            .background(Circle().fill(Color.secondary))

                    }

                        #if os(iOS) || os(visionOS)
                        .contentShape(.contextMenuPreview, Circle())
                        #endif
                        .contextMenu {
                            Button {
                                withAnimation(.smoothCard){
                                    current1 = Color.random()
                                    current2 = Color.random()

                                    let newItem = CustomUserColor(context: viewContext)
                                    newItem.color1 = current1.hexString
                                    newItem.color2 = current2.hexString
                                    newItem.timestamp = Date()

                                    do {
                                        try viewContext.save()
                                    } catch {
                                        let nsError = error as NSError
                                        fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                                    }
                                }
                            } label: {
                                Label {
                                    Text("Random")
                                } icon: {
                                    Image(systemName: "dice")
                                }

                            }
                            .buttonStyle(colourCircleButton())
                        }
                        .sheet(isPresented: $showMenu, content: {
                            if #available(iOS 16.4, *) {
                                CustomColour(color1: $current1, color2: $current2)
                                    .presentationDetents([.fraction(0.4), .fraction(0.7)])

                                    .presentationCornerRadius(25)
                            } else {

                                    CustomColour(color1: $current1, color2: $current2)
                            }
                        })
                        .buttonStyle(colourCircleButton())

                    ForEach(colors, id: \.self) { hue in

                            CustomColorCircle(hue: hue, current1: $current1, current2: $current2, colors: colors)
                            //  .shadow(color: hue.color1.opacity(0.5), radius: 6, y: 5)

                        .modify {
                            if #available(iOS 17.0, *) {
                                $0.scrollTransition { content, phase in
                                    content
                                        .opacity(phase.isIdentity ? 1 : 0.5)
                                }
                            }
                            else{
                                $0
                            }
                        }

                            .aspectRatio(1, contentMode: .fit)
                    }

                }
                else if selectedHueSet == .customColours && !kyoPlus_hasPlus{
                    Text("")
                }
                else if selectedHueSet == .appAccents{
                    ForEach(accentColorOptions, id: \.self){ option in
                        ForEach(1..<6) { i in
#if !os(macOS)
                            CustomColorCircleHard(
                                hue: colorItem(id: UUID(),
                                               name: "Accent",
                                               color1: Color(red: UIColor(Color("\(option.name)/\(i)")).redComponent, green: UIColor(Color("\(option.name)/\(i)")).greenComponent, blue: UIColor(Color("\(option.name)/\(i)")).blueComponent),
                                               color2: Color(red: UIColor(Color("\(option.name)/\(i)")).redComponent, green: UIColor(Color("\(option.name)/\(i)")).greenComponent, blue: UIColor(Color("\(option.name)/\(i)")).blueComponent)),
                                current1: $current1,
                                current2: $current2,
                                colourName: $colourName)
                            .aspectRatio(1, contentMode: .fit)
#endif
//                            CustomColorCircle(hue: hue, current1: $current1, current2: $current2, colors: colors)
//                            //  .shadow(color: hue.color1.opacity(0.5), radius: 6, y: 5)
                            

                            

                        }
                    }
                }
            }
            .padding(.bottom)
            .padding(.horizontal, 30)
            .opacity((kyoPlus_hasPlus ? true : selectedHueSet == .defaultHues) ? 1.0 : 0.6)
            .offset(y: (kyoPlus_hasPlus ? false : selectedHueSet == .defaultHues) ? 0 : 5)


        }

    }
}

struct colourCircleButton: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.7 : 1.0)
            .opacity(configuration.isPressed ? 0.7 : 1)
            .animation(.easeOut, value: configuration.isPressed)
    }
}
