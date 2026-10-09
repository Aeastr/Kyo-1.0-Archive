//
//  Device Functions.swift
//  KyoNeo
//
//  Created by Aether on 27/01/2024.
//

import SwiftUI

func is_iPadDevice() -> Bool {
    #if os(iOS)
    return UIDevice.current.userInterfaceIdiom == .pad
    #else
    return false
    #endif
}
