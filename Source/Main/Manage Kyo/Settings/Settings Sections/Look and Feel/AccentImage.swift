//
//  AccentImage.swift
//  KyoNeo
//
//  Created by Aether on 28/07/2023.
//

import SwiftUI

var accentImageOptions: [accentOption] = [
    accentOption(name: "doodle1"),
    accentOption(name: "doodle2"),
  //  accentOption(name: "doodle3"),
    accentOption(name: "curves"),
    accentOption(name: "lines"),
  //  accentOption(name: "abstract"),
 //   accentOption(name: "hex"),
    accentOption(name: "candy cane"),
    accentOption(name: "circles"),
    accentOption(name: "none-disabledAEF23r"),
]

struct AccentImage: View {
    @AppStorage("accentImageName") var accentImageName = "doodle1"
    @Binding var TEMPaccentImageName: String

    var color: Color
    var body: some View {
        ScrollViewReader{ proxy in
            ScrollView(.horizontal, showsIndicators: false){
                HStack{
                    ForEach(Array(accentImageOptions.enumerated()), id:\.element) { index, option in

                            Button {
                                withAnimation(.smooth){
                                    TEMPaccentImageName = option.name
                                }
                            } label: {
                                Group{
                                    if option.name != "none-disabledAEF23r"{
                                        
                                        Image(option.name)
                                            .resizable()
                                            .foregroundStyle(color)
                                            .aspectRatio(contentMode: .fit)
                                            .scaleEffect(1.5)

                                    }
                                    else{
                                        Text("None")
                                            .frame(maxHeight: .infinity)
                                    }
                                }
                                .frame(width: 100, height: 70)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke( option.name == TEMPaccentImageName ? Color.primary.opacity(0.8) : color.opacity(0.6), lineWidth: option.name == TEMPaccentImageName ? 2 : 0.8)

                                )
                                .padding(1)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(bounceButton())
                          
                            .id(option.name)


                    }
                }
                .padding(15)
            }
            .animation(.bouncy(duration: 0.2), value: TEMPaccentImageName)
            .onAppear{

                proxy.scrollTo(TEMPaccentImageName, anchor: .center)
            }
            .onChange(of: TEMPaccentImageName){ change in
                withAnimation(.bouncy){
                    proxy.scrollTo(TEMPaccentImageName, anchor: .center)
                }
            }



        }
        .background {
            Color("NeoButton").opacity(0.6)


        }
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .regularOutline()
        .onAppear{
            TEMPaccentImageName = accentImageName
        }
        .onDisappear{
            accentImageName = TEMPaccentImageName
        }
    }
}
