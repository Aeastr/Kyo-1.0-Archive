//
//  exportPage.swift
//  KyoNeo
//
//  Created by Aether on 09/10/2023.
//

import SwiftUI
import AmethystUI

enum exportSettingsTypes: String{
    case classes = "Classes"
    case splits = "Splits"
    case plannerEntries = "Planner Entries"
    case tasksEntries = "Task Entries"
    case customisationSettings = "Settings"
    case weeksDays = "Weeks and Days"
}

struct exportPage: View {
    @State var scrolled: Bool = false
    @State var exportSetings: Set<exportSettingsTypes> = [.classes, .splits, .plannerEntries, .tasksEntries,  .weeksDays]
    var color: Color = .purple
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ScrollView{
            let allCases: [exportSettingsTypes] = [.weeksDays, .classes, .splits, .plannerEntries, .tasksEntries /*.customisationSettings,*/]
            ScrollDetector(scrolled: $scrolled)
            VStack{
                ForEach(allCases, id: \.self) { setting in

                    Button(action: {
                        if !exportSetings.contains(setting){
                            if setting != .plannerEntries{
                                exportSetings.insert(setting)
                            }


                            else if exportSetings.contains(.weeksDays) && exportSetings.contains(.classes) && exportSetings.contains(.splits){
                                exportSetings.insert(setting)
                            }
                        }
                        else{
                            exportSetings.remove(setting)
                            if !exportSetings.contains(.weeksDays) || (!exportSetings.contains(.classes) && !exportSetings.contains(.splits)){
                                exportSetings.remove(.plannerEntries)
                            }
                        }
                    }, label: {
                        HStack(spacing: 13){
                            Circle()
                                .fill(exportSetings.contains(setting) ? color : Color.clear)
                                .regularOutline(cornerRadius: 999, lineWidth: 1.3, color: .primary.opacity(0.6))
                                .frame(width: 15, height: 15)

                            Text(setting.rawValue)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .strikethrough((!exportSetings.contains(.classes) && !exportSetings.contains(.splits) && setting == .plannerEntries))

                        }
                        .opacity(((!exportSetings.contains(.weeksDays) || (!exportSetings.contains(.classes) && !exportSetings.contains(.splits))) && setting == .plannerEntries) ? 0.5 : 1)
                        .contentShape(Rectangle())
                    })


                    .frame(height: 25)
                    .padding(.vertical, 7)
                    .buttonStyle(BouncyButton())

                    if setting != allCases.last{
                        Divider()
                            .opacity(0.6)
                    }
                }


            }
            .padding(.horizontal, 20)
            .padding(.vertical, 15)
            .regularOutline()
            .padding(.horizontal, 20)

        }
        .coordinateSpace(name: "scroll")
        .safeAreaInset(edge: .top) {
            Color.clear.frame(height: 100)
        }
        .safeAreaInset(edge: .bottom, content: {
            if !exportSetings.isEmpty{
                if let url = try? kn_DataExporterImporter(debug: true).exportCoreDataToJSON(fileName: "KyoData", fileExtension: "json", exportSettings: exportSetings) {
                    ShareLink(item: url) {
                        Label("Export", systemImage: "square.and.arrow.up")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(PolishedButton(color: color, background: true))
                    .padding(.horizontal, 20)
                    .disabled(exportSetings.isEmpty)
                    .opacity(exportSetings.isEmpty ? 0.5 : 1)
                    .transition(.blur.animation(.smooth))
                    .animation(.smooth, value: exportSetings.isEmpty)
                    .padding(.bottom, 10)

                }
            }
            else{
                Text("Select at least one thing to export")
                    .transition(.blur.animation(.smooth))
                    .font(.caption)
                    .opacity(0.6)
                    .padding(.bottom, 25)
            }



        })
        .overlay(alignment: .top){
            FluidNavigationBar(title: "Export Data", tintColor: color,  scrolled: $scrolled, inSheet: true) {
                Button {
                    dismiss()
                } label: {
                    Text("Done")
                        .scaledFrame(width: 60, height: 40, relativeTo: .body)
                }
                .buttonStyle(NavigationButton(color: color, scrolled: $scrolled))

                    .padding(.trailing, -5)
                    .padding(.top, 15)

            } toolbar: {

            }

        }
    }
}

#Preview {
    exportPage()
}

struct CheckboxToggleStyle: ToggleStyle {
    var color: Color

    func makeBody (configuration: Configuration) -> some View {
        HStack(alignment: .center){

            Circle()
                .fill(configuration.isOn ? color : Color.clear)
                .regularOutline(cornerRadius: 999, lineWidth: 1.3, color: .primary.opacity(0.6))
                .frame(width: 15, height: 15)
//                .overlay {
//
//                    Image(systemName: "checkmark")
//                        .foregroundStyle(configuration.isOn ? .white : Color.clear)
//                        .scaleEffect(configuration.isOn ? 0.86 : 0.45)
//                }



            configuration.label
        }
        .contentShape(Rectangle())
        .onTapGesture{

                configuration.isOn.toggle()


        }
    }
}
