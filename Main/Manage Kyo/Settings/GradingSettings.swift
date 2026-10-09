//
//  GradingSettings.swift
//  KyoNeo
//
//  Created by Aether on 14/08/2023.
//

import SwiftUI
import AmethystUI
enum GradingSystem: String {
    case noneSelected = "None Selected"
    case passOrFail = "Pass/Fail"
    case gcse1To9 = "GCSE 1-9"
    case aLevels = "A-levels"
    case ib = "IB"
    // Add more grading systems here
}

struct Country: Hashable {
    let name: String
    let gradingSystems: [GradingSystem]
}

let countriesWithGradingSystems: [Country] = [
    Country(name: "United Kingdom", gradingSystems: [.gcse1To9, .aLevels, .ib, .passOrFail])
    // Add more countries and their grading systems here
]


struct GradingSettings: View {
    @AppStorage("selectedGradingSystem") var selectedGradingSystem: GradingSystem = .noneSelected
    @State var scrolled: Bool = false
    var color: Color = .teal
    var body: some View {

                    ScrollView {
                        HStack{
                            Image(systemName: "globe")
                                .frame(width: 20, alignment: .center)
                                .symbolRenderingMode(/*@START_MENU_TOKEN@*/.hierarchical/*@END_MENU_TOKEN@*/)
                                .foregroundColor(color)

                            VStack(alignment: .leading, spacing: 3){
                                Text("System")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(.leading, 1)




                            Menu {

                                    ForEach(countriesWithGradingSystems, id: \.self) { country in
                                        Menu {
                                            Picker("", selection: $selectedGradingSystem) {
                                            ForEach(country.gradingSystems, id: \.self) { system in

                                                Label(system.rawValue, systemImage: "")


                                                    .id(system)
                                            }
                                        }
                                        } label: {
                                            Label(country.name, systemImage: "globe")
                                        }

                                    }

                            } label: {
                                HStack{
                                    Text(selectedGradingSystem.rawValue)
                                    Image(systemName: "chevron.up.chevron.down")
                                        .font(.caption)
                                }
                                    .transition(.blur)
                                    .animation(.smooth, value: selectedGradingSystem)
                            }
                            .tint(color)

                        }
                        .padding(.horizontal, 2)
                        .padding(.vertical, 1.7)

                        .neoSettingsCard()
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 20)


                    }
                    .coordinateSpace(name: "scroll")
                    .safeAreaInset(edge: .top, content: {
                        Color.clear.frame(height: 80)
                    })


                    .overlay(alignment: .top){
                        
                        FluidNavigationBar(title: "Grading", titleColor: .primary,   tintColor: color, compactMode: true, type: .back, scrolled: $scrolled, content: {
                            //
                        }, toolbar: {
                            
                            
                        })
                        
                        //                    NavigationBar(type: .hiddenSelector ,title: "settings-title", color: color, scrolled: $scrolled){
                        //                        navigationButtons()
                        //                    }toolbar: {
                        //
                        //                    }
                        
                    }
                    .toolbar(.hidden)


    }
}

#Preview {
    GradingSettings()
}
