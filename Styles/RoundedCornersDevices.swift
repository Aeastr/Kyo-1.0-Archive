//
//  RoundedCornersDevices.swift
//  KyoNeo
//
//  Created by Aether on 22/04/2023.
//

import Foundation

#if canImport(DeviceKit)
import DeviceKit

func cornerRadiusForDevice() -> CGFloat {
    let device = Device.current
    print("Device: \(device)")
    switch device {
    case .iPhoneX, .iPhoneXS, .iPhoneXSMax, .iPhone11Pro, .iPhone11ProMax:
        print("CornerRadius: 39.0")
        return 39.0
    case .iPhoneXR, .iPhone11:
        print("CornerRadius: 41.5")
        return 41.5
    case .iPhone12Mini, .iPhone13Mini, .simulator(.iPhone13Mini):
        print("CornerRadius: 44.0")
        return 44.0
    case .iPhone12, .iPhone12Pro, .iPhone13Pro, .iPhone14:
        print("CornerRadius: 47.33")
        return 47.33
    case .iPhone12ProMax, .iPhone13ProMax, .iPhone14Plus, .simulator(.iPhone14Plus):
        print("CornerRadius: 53.33")
        return 53.33
    case .iPhone14Pro, .iPhone14ProMax, .simulator(.iPhone14ProMax), .simulator(.iPhone14Pro):
        print("CornerRadius: 55.0")
        return 55.0
    case .iPhone15Pro, .iPhone15ProMax, .simulator(.iPhone15ProMax), .iPhone15, .iPhone15Plus:
        print("CornerRadius: 55.0")
        return 55.0
    case .iPadAir, .iPadPro11Inch, .iPadPro12Inch:
        print("CornerRadius: 18.0")
        return 18.0
    default:
        print("CornerRadius: 0.0")
        return 0.0
    }
}

#else
func cornerRadiusForDevice() -> CGFloat {

        print("CornerRadius: 0.0")
        return 0.0
    
}
#endif



