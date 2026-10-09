//
//  neoOutline.swift
//  KyoNeo
//
//  Created by Aether on 11/03/2023.
//

import SwiftUI

// Define a ViewModifier for a neomorphic outline around a view
struct neoOutlineModifier: ViewModifier {
    var cornerRadius: CGFloat  // Corner radius of the outline
    var lineWidth: Double  // Width of the outline line

    @Environment(\.colorScheme) var colorScheme
    // Define the body of the ViewModifier
    func body(content: Content) -> some View {
        // Apply the modifier to the content
        content
            // Overlay a rounded rectangle with a gradient stroke to create the outline effect
            .overlay(RoundedRectangle(cornerRadius: cornerRadius).stroke(Color.primary.opacity(colorScheme == .dark ? 0.15 : 0.08), lineWidth: 1.2))
    }
}


fileprivate let RADIUS = CGFloat(20)
fileprivate let overCompensateUpAndDown = CGFloat(12)

struct TopRoundedBorder: Shape {
    let  adjustDown = CGFloat(10)
    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: CGPoint(x: rect.minX + 1, y: rect.maxY +  adjustDown))

        let leftPt = CGPoint(x: rect.minX + 1, y: rect.minY+RADIUS)
        path.addLine(to: leftPt)

        let leftCenter = CGPoint(x: rect.minX + RADIUS + 1, y: rect.minY+RADIUS + 1)

        path.addRelativeArc(center: leftCenter, radius: RADIUS,
                            startAngle: Angle(radians: 3.14),
                            delta:  Angle(radians: 1.57))

        path.addLine(to: CGPoint(x: rect.maxX-RADIUS, y: rect.minY + 1)) // we can skip, CoreGrtaphics will joit arcs.

        let rightCenter = CGPoint(x: rect.maxX - RADIUS - 0.6, y: rect.minY + RADIUS + 1)

        path.addRelativeArc(center: rightCenter, radius: RADIUS,
                            startAngle: Angle(radians: 3.14 + 1.57),
                            delta:  Angle(radians: 1.57))

        // we should be already here, anyway:
        //let rightPt = CGPoint(x: rect.maxX, y: rect.minY+RADIUS)
        // go down at right:
        path.addLine(to: CGPoint(x: rect.maxX - 0.6, y: rect.maxY + adjustDown))

        return path
    }
}

struct BottomRoundedBorder: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        // start from topleft:
        path.move(to: CGPoint(x: rect.minX + 1, y: rect.minY - overCompensateUpAndDown))

        let leftPt = CGPoint(x: rect.minX + 1, y: rect.maxY-RADIUS)
        path.addLine(to: leftPt)


        let leftCenter = CGPoint(x: rect.minX + RADIUS + 1, y: rect.maxY-RADIUS - 1)

        path.addRelativeArc(center: leftCenter, radius: RADIUS,
                            startAngle: Angle(radians: 3.14),
                            delta:  Angle(radians: -1.58))

        path.addLine(to: CGPoint(x: rect.maxX-RADIUS, y: rect.maxY - 1)) // we can skip, CoreGrtaphics will joit arcs.

        let rightCenter = CGPoint(x: rect.maxX - RADIUS - 0.6, y: rect.maxY-RADIUS - 1)

        path.addRelativeArc(center: rightCenter, radius: RADIUS,
                            startAngle: Angle(radians: 1.57),
                            delta:  Angle(radians: -1.57))

        // we should be already here, anyway:
        //let rightPt = CGPoint(x: rect.maxX, y: rect.maxY-RADIUS)
        // go up at right:
        path.addLine(to: CGPoint(x: rect.maxX - 0.6, y: rect.minY - overCompensateUpAndDown))

        return path
    }
}

struct BordersOnBothSides: Shape {
    let withSeparator: Bool
    func path(in rect: CGRect) -> Path {
        var path = Path()


        // start from topleft:
        path.move(to: CGPoint(x: rect.minX + 1, y: rect.minY - overCompensateUpAndDown))

        let leftPt = CGPoint(x: rect.minX + 1, y: rect.maxY + overCompensateUpAndDown)
        path.addLine(to: leftPt)

        // top rigth:
        let overCompensateRightArrow = CGFloat(0)
        path.move(to: CGPoint(x: rect.maxX+overCompensateRightArrow  - 0.6, y: rect.minY - overCompensateUpAndDown))

        path.addLine(to: CGPoint(x: rect.maxX+overCompensateRightArrow  - 0.6, y: rect.maxY + overCompensateUpAndDown))

        return path
    }
}

enum outLineMode {
    case all
    case top
    case bottom
    case sides
}

struct RegularOutline: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    var cornerRadius: CGFloat  // Corner radius of the outline
 //   @AppStorage("Contrast")
    var contrast = false
    var lineWidth: Double
    var color: Color = Color.primary
    @AppStorage("appAccentColor") var appAccentColor = "defaultAccent"
    var mode: outLineMode = .all

    func body(content: Content) -> some View {
        // Apply the modifier to the content
        content
            // Overlay a rounded rectangle with a gradient stroke to create the outline effect

            .modify {
                if #available(iOS 17.0, *) {
                    if mode == .all{
                        $0.overlay(RoundedRectangle(cornerRadius: cornerRadius).stroke(Color(color).opacity(colorScheme == .dark ? 0.22 : contrast ? 0.3 : 0.2), lineWidth: lineWidth + 0.1))
                    }
                    else if mode == .top{
                        $0.overlay(TopRoundedBorder().stroke(Color(contrast ? Color("\(appAccentColor)/4") : color).opacity(colorScheme == .dark ? 0.22 : contrast ? 0.3 : 0.2), lineWidth: lineWidth + 0.1))
                    }
                    else if mode == .bottom{
                        $0.overlay(BottomRoundedBorder().stroke(Color(contrast ? Color("\(appAccentColor)/4") : color).opacity(colorScheme == .dark ? 0.22 : contrast ? 0.3 : 0.2), lineWidth: lineWidth + 0.1))
                    }
                    else if mode == .sides{
                        $0.overlay(
                            BordersOnBothSides(withSeparator: true).stroke(Color(contrast ? Color("\(appAccentColor)/4") : color).opacity(colorScheme == .dark ? 0.22 : contrast ? 0.3 : 0.2), lineWidth: lineWidth + 0.1))
                    }

                }
                else{
                    $0.overlay(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous).stroke(Color.primary.opacity(colorScheme == .dark ? 0.18 : contrast ? 0.3 : 0.14), lineWidth: lineWidth + 0.1))
                }
            }
            
    }
}

// Define an extension to the View protocol to add the neomorphic outline modifier
extension View {
    // Define the neoOutline function to apply the neoOutlineModifier to a view
    func neoOutline(cornerRadius: CGFloat = 18, lineWidth: Double = 1.2) -> some View{
        // Apply the neoOutlineModifier to the view
        modifier(neoOutlineModifier(cornerRadius: cornerRadius, lineWidth: lineWidth))
    }

    func regularOutline(cornerRadius: CGFloat = 18, lineWidth: Double = 1.1, color: Color = Color.primary.opacity(0.3), mode: outLineMode = .all) -> some View{
        // Apply the neoOutlineModifier to the view
        modifier(RegularOutline(cornerRadius: cornerRadius, lineWidth: lineWidth, color: color, mode: mode))
    }
}

// Define a PreviewProvider that shows a preview of the neoOutlineModifier applied to different Image views with different sizes and corner radii
struct neoOutlineModifier_Previews: PreviewProvider {
    static var previews: some View {
        // Define an HStack containing three VStacks, each containing an Image view with a different width, height, and corner radius
        VStack {
            HStack {

                Spacer()
                VStack{
                    Spacer()
                    Image(systemName: "ellipsis")
                        .font(.body.weight(.regular))
                        .frame(width: 56, height: 56)
                        .neoOutline(lineWidth: 3)
                        .scaleEffect(1)
                    Spacer()
                }

                VStack{
                    Spacer()
                    Image(systemName: "ellipsis")
                        .font(.body.weight(.regular))
                        .frame(width: 76, height: 56)
                        .neoOutline(cornerRadius: 100)
                        .scaleEffect(1)
                    Spacer()
                }


                VStack{
                    Spacer()
                    Image(systemName: "ellipsis")
                        .font(.body.weight(.regular))
                        .frame(width: 96, height: 56)
                        .neoOutline(cornerRadius: 1)
                        .scaleEffect(1)
                    Spacer()
                }

                Spacer()

            }
            // Set the background color of the HStack to gray
            .background(.gray)
            
        }
        
    }
}
/// The purpose of this code is to provide a visual preview of how the neoOutlineModifier looks when applied to Image views of different sizes and corner radii. The PreviewProvider defines an HStack containing three VStacks, each containing an Image view with a different width, height, and corner radius. The neoOutlineModifier is applied to each Image view to add the neomorphic outline effect, and the scaleEffect modifier is used to set the scale of the image to 1.

/// The entire HStack is then wrapped in a .background modifier to set the background color to .grey (for visibility)
