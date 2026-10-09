//
//  HexColor.swift
//  KyoNeo
//
//  Created by Aether on 26/11/2022.
//

import SwiftUI
import Foundation
import CoreGraphics

extension Color: HexDecodable {

    // MARK: HexDecodable
    public init(hex: Int, opacity: Double) {
        self.init(.displayP3, red: hex.red, green: hex.green, blue: hex.blue, opacity: opacity)
    }
}

extension Color: HexEncodable {

    // MARK: HexEncodable
    public var hex: Int {
        return Int(cgColor?.components)
    }
}


public typealias HexCodable = HexDecodable & HexEncodable

public protocol HexDecodable {
    init(hex: Int, opacity: Double)
}

extension HexDecodable {
    public init(hex string: String, opacity: Double = 1.0) {
        self.init(hex: string.hex, opacity: opacity)
    }

    public init(hex: Int) {
        self.init(hex: hex, opacity: 1.0)
    }
}

public protocol HexEncodable {
    var hex: Int {
        get
    }
}

extension HexEncodable {
    public var hexString: String {
        return String(hex: hex)
    }
}

extension Int {
    var red: CGFloat {
        return CGFloat((self & 0xFF0000) >> 16) / 255.0
    }

    var green: CGFloat {
        return CGFloat((self & 0x00FF00) >> 8) / 255.0
    }

    var blue: CGFloat {
        return CGFloat(self & 0x00FF) / 255.0
    }

    init(_ components: [CGFloat]? = nil) {
        switch (components ?? []).count {
        case 4: // RGB
            self = (Int(components![0] * 255.0) << 16) + (Int(components![1] * 255.0) << 8) + (Int(components![2] * 255.0) << 0)
        case 2: // Grayscale
            self = (Int(components![0] * 255.0) << 16) + (Int(components![0] * 255.0) << 8) + (Int(components![0] * 255.0) << 0)
        default:
            self = 0
        }
    }
}

//#if canImport(Cocoa)
//import Cocoa
//
//extension NSColor: HexCodable {
//
//}
//
//extension HexDecodable where Self: NSColor {
//
//    // MARK: HexDecodable
//    public init(hex: Int, opacity: Double) {
//        self.init(red: hex.red, green: hex.green, blue: hex.blue, alpha: opacity)
//    }
//}
//
//extension HexEncodable where Self: NSColor {
//
//    // MARK: HexEncodable
//    public var hex: Int {
//        return Int(cgColor.components)
//    }
//}
//#endif

#if canImport(UIKit)
extension UIColor {
    var redComponent: CGFloat {
        var red: CGFloat = 0
        getRed(&red, green: nil, blue: nil, alpha: nil)
        return red
    }

    var greenComponent: CGFloat {
        var green: CGFloat = 0
        getRed(nil, green: &green, blue: nil, alpha: nil)
        return green
    }

    var blueComponent: CGFloat {
        var blue: CGFloat = 0
        getRed(nil, green: nil, blue: &blue, alpha: nil)
        return blue
    }
}
#else
extension NSColor {
    var redComponent: CGFloat {
        var red: CGFloat = 0
        getRed(&red, green: nil, blue: nil, alpha: nil)
        return red
    }

    var greenComponent: CGFloat {
        var green: CGFloat = 0
        getRed(nil, green: &green, blue: nil, alpha: nil)
        return green
    }

    var blueComponent: CGFloat {
        var blue: CGFloat = 0
        getRed(nil, green: nil, blue: &blue, alpha: nil)
        return blue
    }
}
#endif
extension String {
    var hex: Int {
        var hex: UInt64 = 0
        Scanner(string: normalizedHexString).scanHexInt64(&hex)
        return Int(hex)
    }

    init(hex: Int) {
        self = "#\(String(hex, radix: 16).normalizedHexString)"
    }

    private var normalizedHexString: String {
        
        let substring: Substring = uppercased().replacingOccurrences(of: "[^A-F0-9]+", with: "", options: .regularExpression).prefix(6)
        switch substring.count {
        case 3:
            return substring.map { character in
                return String(repeating: character, count: 2)
            }.joined()
        case 1:
            return String(repeating: substring.first!, count: 6)
        default:
            return "\(String(repeating: "0", count: 6 - substring.count))\(substring)"
        }
    }
}

#if canImport(UIKit)
import UIKit

extension UIColor: HexCodable {

}

extension HexDecodable where Self: UIColor {

    // MARK: HexDecodable
    public init(hex: Int, opacity: Double) {
        self.init(red: hex.red, green: hex.green, blue: hex.blue, alpha: opacity)
    }
}

extension HexEncodable where Self: UIColor {

    // MARK: HexEncodable
    public var hex: Int {
        return Int(cgColor.components)
    }
}
#endif
