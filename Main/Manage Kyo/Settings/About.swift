//
//  About.swift
//  KyoNeo
//
//  Created by Aether on 11/03/2023.
//

import SwiftUI
import AmethystUI

struct betaTester{
    let ID: UUID = UUID()
    var name: String
    var link: String?
    var linkString: String?
    var imageName: String?
}


let kyoBetaTesters: [betaTester] = [
//    betaTester(name: "Jace", link: "https://twitter.com/JaceThings", linkString: "@JaceThings", imageName: "jaceIMG"),
    betaTester(name: "Ben", link: "https://github.com/bengiv", linkString: "@bengiv", imageName: "benIMG"),
    betaTester(name: "Zander", link: "https://twitter.com/Zander0009", linkString: "@Zander0009", imageName: "zanderIMG"),
    betaTester(name: "Trent", link: nil, imageName: nil),
    betaTester(name: "Alice", link: nil, imageName: nil),
    betaTester(name: "J Chris", link: "https://twitter.com/jchris1_", linkString: "@jchris1_", imageName: "jcriimg"),
    betaTester(name: "Álvaro", link: "https://x.com/lvaroMartnezVa1?t=qMpmMZJZn07QmMm_7z8SHg&s=35", linkString: "@lvaroMartnezVa1", imageName: "ÁlvaroIMG"),
    betaTester(name: "Lorenzo", link: "https://sites.google.com/view/lollo21/h", linkString: "Website", imageName: "LorenzoIMG"),
    betaTester(name: "Alex", link: "https://twitter.com/alexkbwi", linkString: "@alexkbwi"),
    betaTester(name: "Rubén MLL", link: "https://rubenmll.es/", linkString: "Website", imageName: "rubenIMG")
]


let specialThanks: [betaTester] = [
//    betaTester(name: "Jace", link: "https://twitter.com/JaceThings", linkString: "@JaceThings", imageName: "jaceIMG"),
    betaTester(name: "Jace", link: "https://twitter.com/JaceThings", linkString: "@JaceThings", imageName: "jaceIMG"),
    betaTester(name: "Michael", link: "https://twitter.com/mbrkhrdt", linkString: "@mbrkhrdt", imageName: "michael"),
    betaTester(name: "Ethan", link: "https://twitter.com/EthanLipnik", linkString: "@EthanLipnik", imageName: "ethan"),
    betaTester(name: "Thomas", link: "https://twitter.com/tomsp05", linkString: "@tspeake5", imageName: "thomas"),
    betaTester(name: "Esty", linkString: "@ey@mstdn.ca", imageName: "esty"),
    betaTester(name: "Cherry", imageName: "cherry"),
    betaTester(name: "Mum & Dad", imageName: "heart")
]



struct About: View {
    var color: Color
    @AppStorage("Contrast") var contrast = false
    @AppStorage("tintPages") var tintPages = false

        @AppStorage("activeAppIcon") var activeAppIcon: String = "AppIconDefault"
    @Environment(\.colorScheme) private var colorScheme
    @State var startTime = Date()
    @State var endTime = Date()

    var back = true
    @State var scrolled: Bool = false
    var body: some View {
        ZStack {
            ScrollView {
                ScrollDetector(scrolled: $scrolled)
                Group{
                LazyVStack{
                    VStack{
#if os(iOS)
                        Image(uiImage: UIImage(named: activeAppIcon) ?? UIImage())
                            .resizable()
                            .frame(width: 90, height: 90)
                            .clipShape(RoundedRectangle(cornerRadius: 16.2807017544))
                            .regularOutline(cornerRadius: 16.2807017544)
                            .padding(.top, 5)
                        #elseif os(visionOS)
                        Image("Kyo")
                            .resizable()
                            .frame(width: 90, height: 90)
                            .clipShape(Circle())
                            .regularOutline(cornerRadius: 16.2807017544)
                            .padding(.top, 5)
                        #else
                        Image(nsImage: NSImage(named: activeAppIcon) ?? NSImage())
                            .resizable()
                            .frame(width: 90, height: 90)
                            .clipShape(RoundedRectangle(cornerRadius: 16.2807017544))
                            .padding(.top, 15)
                        #endif

                        HStack(alignment: .center) {
                            if #available(iOS 16.0, *) {
                                HStack(alignment: .bottom){
                                    Text("Kyo")
                                        .font(.title)
                                        .fontWidth(.expanded)
                                        .fontWeight(.semibold)
                                        .padding(.bottom, 1)
                                }
                            } else {
                                Text("Kyo")
                                    .font(Font.title.weight(.semibold))
                            }
                        }
                        .padding(.top, 5)
                    }
                    
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 20)

                    Text("Development")
                        .sectionTitle()
                        .padding(.horizontal, 20)
                    VStack(alignment: .leading){

                        HStack{
//                            Image("ethan")
//                                .resizable()
//                                .aspectRatio(CGSize(width: 1.0, height: 1.0), contentMode: .fit)
//                                .frame(width: 40)
//                                .clipShape(Circle())

                                Image("aeth")
                                    .resizable()
                                    .aspectRatio(CGSize(width: 1.0, height: 1.0), contentMode: .fit)
                                    .frame(width: 40)
                                    .clipShape(Circle())
                                    .padding(.trailing, 5)
                            Menu {
                                Link(destination: URL(string: "https://twitter.com/AetherAurelia")!) {
                                    Text("Twitter")
                                    Text("@AetherAurelia")
                                }
                                Link(destination: URL(string: "https://bsky.app/profile/aethers.world")!) {
                                    Text("Bluesky")
                                    Text("@aethers.world")
                                }
//                                Link(destination: URL(string: "https://bsky.app/profile/aethers.world")!) {
//                                    Text("Threads")
//                                }
                                Link(destination: URL(string: "https://mastodon.social/@Aeastr")!) {
                                    Text("Mastodon")
                                    Text("@Aeastr")
                                }
                                Button(action: {
                                    guard let url = URL(string: "mailto:contact@aethers.world") else { return }
#if !os(macOS)
                                    UIApplication.shared.open(url)
                                    #endif
                                }) {
                                    Text("Email")
                                    Text("contact@aethers.world")
                                }
                            } label: {
                                VStack(alignment: .leading, spacing: 2){
                                    Text("Lead Developer & Designer")
                                        .font(.caption)
                                    Text("Aether")
                                    Text("Contact")
                                        .font(.caption)
                                        .foregroundStyle(color)
                                        .saturation(1.4)
                                }
                            }

                        }

                        .padding(8)
                        .frame(maxWidth: .infinity, alignment: .leading)

                        Divider()
                            .padding(.horizontal, 2)



                        HStack{
                                                                            //                            Image("ethan")
                                                                            //                                .resizable()
                                                                            //                                .aspectRatio(CGSize(width: 1.0, height: 1.0), contentMode: .fit)
                                                                            //                                .frame(width: 40)
                                                                            //                                .clipShape(Circle())

                                                                                                            Image("amethystLogo")
                                                                                                                .resizable()
                                                                                                                .aspectRatio(CGSize(width: 1.0, height: 1.0), contentMode: .fit)
                                                                                                                .frame(width: 40)
                                                                                                                .padding(.trailing, 5)
                                                                                VStack(alignment: .leading, spacing: 2){
                                                                               //                            Text("Lead Developer & Designer")
                                                                               //                                .font(.caption)
                                                                                                           Text("Made with Amethyst")
//                                                                                                           Text("Learn more")
//                                                                                                               .font(.caption)
//                                                                                                               .foregroundStyle(color)
//                                                                                                               .saturation(1.4)
                                                                                                       }

                                                                                                    }
                                                                            .padding(8)
                                                                            .frame(maxWidth: .infinity, alignment: .leading)

//                        Divider()
//                            .padding(.horizontal, 2)
//
//                        NavigationLink(destination: {
//
//                        }, label: {
//                            HStack{
//                                                    //                            Image("ethan")
//                                                    //                                .resizable()
//                                                    //                                .aspectRatio(CGSize(width: 1.0, height: 1.0), contentMode: .fit)
//                                                    //                                .frame(width: 40)
//                                                    //                                .clipShape(Circle())
//
//                                                                                    Image("ameIcon")
//                                                                                        .resizable()
//                                                                                        .aspectRatio(CGSize(width: 1.0, height: 1.0), contentMode: .fit)
//                                                                                        .frame(width: 40)
//                                                                                        .padding(.trailing, 5)
//                                                        VStack(alignment: .leading, spacing: 2){
//                                                       //                            Text("Lead Developer & Designer")
//                                                       //                                .font(.caption)
//                                                                                   Text("Ame")
//                                                            Text("AI Features")
//                                                                .font(.caption)
//                                                                .foregroundStyle(color)
//                                                                .saturation(1.4)
//                                                                               }
//                                                        Spacer()
//
//                                                        Image(systemName: "chevron.right")
//                                                            .foregroundColor(.secondary)
//                                                            .font(Font.caption.bold())
//                                                                            }
//                            .contentShape(Rectangle())
//                        })
//                        .padding(8)
//                        .frame(maxWidth: .infinity, alignment: .leading)

                    }
                    .neoSettingsCard()
                    .padding(.horizontal, 20)


                    Text("Community Management")
                        .sectionTitle()
                        .padding(.horizontal, 20)
                    VStack(alignment: .leading){

                        HStack{
                            Circle()
                                .fill(color.opacity(0.5))
                                .frame(width: 40)
                                .overlay(alignment: .center) {
                                    Image(systemName: "person.fill")
                                        .blendMode(.overlay)
                                }
                                .padding(.trailing, 5)
                            VStack(alignment: .leading, spacing: 2){
                                Text("Skye")
                                Text("@3A33YT")
                                    .font(.caption)
                            }
                        }
                        .padding( 8)
                        Divider()
                            .padding(.horizontal, 2)

                        HStack{
                            Circle()
                                .fill(color.opacity(0.5))
                                .frame(width: 40)
                                .overlay(alignment: .center) {
                                    Image(systemName: "person.fill")
                                        .blendMode(.overlay)
                                }
                                .padding(.trailing, 5)
                            VStack(alignment: .leading, spacing: 2){
                                Text("Lily")
                                Button(action: {
                                    guard let url = URL(string: "mailto:hi@pomonella.dev") else { return }
#if !os(macOS)
                                    UIApplication.shared.open(url)
                                    #endif

                                }) {
                                    Text("hi@pomonella.dev")

                                        .foregroundStyle(color)
                                        .font(.caption)
                                        


                                }
                                .accentColor(color)

                            }
                        }
                        .padding( 8)

                    }
                    .neoSettingsCard()
                    .padding(.horizontal, 20)


                    Text("Special Thanks")
                        .sectionTitle()
                        .padding(.horizontal, 20)
                    VStack(alignment: .leading){



                        ForEach(Array(specialThanks.enumerated()), id: \.offset) { index, tester in
                            HStack{
                                if let image = tester.imageName{
                                    Image(image)
                                        .resizable()
                                        .aspectRatio(CGSize(width: 1.0, height: 1.0), contentMode: .fit)
                                        .frame(width: 40)
                                        .clipShape(Circle())
#if !os(macOS)
                                        .overlay(Circle().strokeBorder(Color((tester.imageName != nil ? Color.getIdealColor(color: Color(uiColor: UIImage(named: tester.imageName!)?.averageColor ?? UIColor(color)), colorScheme: colorScheme) : color)).opacity(0.3), lineWidth: 1.0))
#endif
                                        .padding(.trailing, 5)

                                }
                                else{
                                    Circle()
                                        .fill(color.opacity(0.5))
                                        .frame(width: 40)
                                        .overlay(alignment: .center) {
                                            Image(systemName: "person.fill")
                                                .blendMode(.overlay)
                                        }
                                        .padding(.trailing, 5)
                                }
                                VStack(alignment: .leading, spacing: 2){
                                    Text(tester.name)
                                        .frame(maxWidth:. infinity, alignment: .leading)
                                    if let link = tester.link, let url = URL(string: link){
                                        Link(destination: url) {

                                            Text(tester.linkString ?? link)

                                                .font(.caption)
                                            
#if !os(macOS)
                                                .foregroundStyle(tester.imageName != nil ? Color.getIdealColor(color: Color(uiColor: UIImage(named: tester.imageName!)?.averageColor ?? UIColor(color)), colorScheme: colorScheme) : color)
                                            #endif


                                        }
                                    }
                                    else{
                                        if let linkString = tester.linkString{
                                            Text(linkString)

                                                .font(.caption)
#if !os(macOS)
                                                .foregroundStyle(tester.imageName != nil ? Color.getIdealColor(color: Color(uiColor: UIImage(named: tester.imageName!)?.averageColor ?? UIColor(color)), colorScheme: colorScheme) : color)
                                            #endif
                                        }
                                    }
                                }
                                .frame(maxWidth:. infinity)
                            }
                            .padding(8)

                            if index < specialThanks.count - 1 {
                                Divider()
                            }
                        }


                    }
                    .neoSettingsCard()
                    .padding(.horizontal, 20)

                    Text("Beta Testers")
                        .sectionTitle()
                        .padding(.horizontal, 20)
                    VStack(alignment: .leading){



                        ForEach(Array(kyoBetaTesters.enumerated()), id: \.offset) { index, tester in
                            HStack{
                                if let image = tester.imageName{
                                    Image(image)
                                        .resizable()
                                        .aspectRatio(CGSize(width: 1.0, height: 1.0), contentMode: .fit)
                                        .frame(width: 40)
                                        .clipShape(Circle())
#if !os(macOS)
                                        .overlay(Circle().strokeBorder(Color((tester.imageName != nil ? Color.getIdealColor(color: Color(uiColor: UIImage(named: tester.imageName!)?.averageColor ?? UIColor(color)), colorScheme: colorScheme) : color)).opacity(0.3), lineWidth: 1.0))
#endif
                                        .padding(.trailing, 5)

                                }
                                else{
                                    Circle()
                                        .fill(color.opacity(0.5))
                                        .frame(width: 40)
                                        .overlay(alignment: .center) {
                                            Image(systemName: "person.fill")
                                                .blendMode(.overlay)
                                        }
                                        .padding(.trailing, 5)
                                }
                                VStack(alignment: .leading, spacing: 2){
                                    Text(tester.name)
                                        .frame(maxWidth:. infinity, alignment: .leading)
                                    if let link = tester.link, let url = URL(string: link){
                                        Link(destination: url) {

                                            Text(tester.linkString ?? link)

                                                .font(.caption)
#if !os(macOS)
                                                .foregroundStyle(tester.imageName != nil ? Color.getIdealColor(color: Color(uiColor: UIImage(named: tester.imageName!)?.averageColor ?? UIColor(color)), colorScheme: colorScheme) : color)
                                            #endif

                                        }
                                    }
                                    else{
                                        if let linkString = tester.linkString{
                                            Text(linkString)

                                                .font(.caption)
#if !os(macOS)
                                                .foregroundStyle(tester.imageName != nil ? Color.getIdealColor(color: Color(uiColor: UIImage(named: tester.imageName!)?.averageColor ?? UIColor(color)), colorScheme: colorScheme) : color)
                                            #endif
                                        }
                                    }
                                }
                                .frame(maxWidth:. infinity)
                            }
                            .padding(8)

                            if index < kyoBetaTesters.count - 1 {
                                Divider()
                            }
                        }


                    }
                    .neoSettingsCard()
                    .padding(.horizontal, 20)
                Spacer()
            }
         
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .shadow(color: .primary.opacity(0.05), radius: 13, x: 0, y: 5)
            .coordinateSpace(name: "scroll")

            .safeAreaInset(edge: .top, content: {
                Color.clear.frame(height: 80)
            })


        }
        .amethystNavigationBar(title: "About", tintColor: color, overrideType: back ? .back : .regular, scrolled: $scrolled) {

                            } toolbar: {

                            }
    }
}

#if !os(macOS)
extension UIImage {
    /// Average color of the image, nil if it cannot be found
    var averageColor: UIColor? {
        // convert our image to a Core Image Image
        guard let inputImage = CIImage(image: self) else { return nil }

        // Create an extent vector (a frame with width and height of our current input image)
        let extentVector = CIVector(x: inputImage.extent.origin.x,
                                    y: inputImage.extent.origin.y,
                                    z: inputImage.extent.size.width,
                                    w: inputImage.extent.size.height)

        // create a CIAreaAverage filter, this will allow us to pull the average color from the image later on
        guard let filter = CIFilter(name: "CIAreaAverage",
                                  parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: extentVector]) else { return nil }
        guard let outputImage = filter.outputImage else { return nil }

        // A bitmap consisting of (r, g, b, a) value
        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull!])

        // Render our output image into a 1 by 1 image supplying it our bitmap to update the values of (i.e the rgba of the 1 by 1 image will fill out bitmap array
        context.render(outputImage,
                       toBitmap: &bitmap,
                       rowBytes: 4,
                       bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
                       format: .RGBA8,
                       colorSpace: nil)

        // Convert our bitmap images of r, g, b, a to a UIColor
        return UIColor(red: CGFloat(bitmap[0]) / 255,
                       green: CGFloat(bitmap[1]) / 255,
                       blue: CGFloat(bitmap[2]) / 255,
                       alpha: CGFloat(bitmap[3]) / 255)
    }
}
#elseif os(macOS)
import Cocoa

extension NSImage {
    /// Average color of the image, nil if it cannot be found
    var averageColor: NSColor? {
        // Convert our image to an NSBitmapImageRep
        guard let cgImage = self.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return nil }
        let bitmapRep = NSBitmapImageRep(cgImage: cgImage)

        // Get the image size
        let imageSize = size
        let width = Int(imageSize.width)
        let height = Int(imageSize.height)

        // Initialize variables to accumulate the color components
        var totalRed: CGFloat = 0.0
        var totalGreen: CGFloat = 0.0
        var totalBlue: CGFloat = 0.0
        var totalAlpha: CGFloat = 0.0

        // Iterate through each pixel in the image
        for x in 0..<width {
            for y in 0..<height {
                let pixelColor = bitmapRep.colorAt(x: x, y: y)
                totalRed += pixelColor?.redComponent ?? 0.0
                totalGreen += pixelColor?.greenComponent ?? 0.0
                totalBlue += pixelColor?.blueComponent ?? 0.0
                totalAlpha += pixelColor?.alphaComponent ?? 0.0
            }
        }

        // Calculate the average color
        let pixelCount = CGFloat(width * height)
        let averageRed = totalRed / pixelCount
        let averageGreen = totalGreen / pixelCount
        let averageBlue = totalBlue / pixelCount
        let averageAlpha = totalAlpha / pixelCount

        return NSColor(red: averageRed, green: averageGreen, blue: averageBlue, alpha: averageAlpha)
    }
}

#endif
