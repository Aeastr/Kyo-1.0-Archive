//
//  colorTest.swift
//  KyoNeo
//
//  Created by Aether on 17/03/2023.
//

import SwiftUI
#if os(iOS) || os(visionOS)

struct colorTest: View {
    @State var hex: String = ""
    @State var convHex: String = ""
    @State var col: Color = .black
    @State var convCol: Color = .white
    @State var hexString: Bool = false
    @State var toCol: Bool = false

    var body: some View {
        VStack{

            Text("Color Test")
                .font(.title)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            if hexString{
                Text("Result:").frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                HStack{
                    Rectangle()
                        .fill(Color(hex: hex))
                        .frame(width: 100, height: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    Spacer()
                    Text("Hex Code: \(hex)")
                        .padding(.trailing)


                }
                .padding()
            }
            if toCol{

                    Text("Result:").frame(maxWidth: .infinity, alignment: .leading)
                    .padding()

                let uiColor = UIColor(col)
                let red = uiColor.cgColor.components?[0]
                let green = uiColor.cgColor.components?[1]
                let blue = uiColor.cgColor.components?[2]
                let alpha = uiColor.cgColor.alpha

                let roundedRed = String(format: "%.3f", red ?? 0)
                let roundedGreen = String(format: "%.3f", green ?? 0)
                let roundedBlue = String(format: "%.3f", blue ?? 0)
                let roundedAlpha = String(format: "%.3f", alpha)

                // Convert the components to a string
                let colorString = "R: \(roundedRed), G: \(roundedGreen), B: \(roundedBlue), A: \(roundedAlpha)"

                HStack{
                    Rectangle()
                        .fill(col)
                        .frame(width: 100, height: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    Spacer()
                    Text("\(colorString)")
                        .padding(.trailing)


                }
                .padding(30)
            }

            Spacer()
            Spacer()
            Divider()

            VStack(alignment: .center){
                VStack{

                        TextField("Enter a hex code", text: $convHex)
                    Button("Convert To 'Color'") {
                        hexString = false
                        toCol = true
                        col = Color(hex: convHex)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
                Divider()
                    .padding()
                VStack{
                    ColorPicker("Pick a colour", selection: $convCol)
                    Button("Convert To 'Hex'") {
                        hexString = true
                        toCol = false
                        hex = convCol.hexString
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
            }

        Spacer()
        }
    }
}

struct colorTest_Previews: PreviewProvider {
    static var previews: some View {
        colorTest()
    }
}
#endif
