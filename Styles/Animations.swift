//
//  Animations.swift
//  KyoNeo
//
//  Created by Aether on 26/11/2022.
//

import SwiftUI

extension Animation {
    static let openCard = Animation.spring(response: 0.5, dampingFraction: 0.7)
    static let smoothCard = Animation.spring(response: 0.5, dampingFraction: 0.85)
    static let closeCard = Animation.spring(response: 0.6, dampingFraction: 0.9)
    static let flipCard = Animation.spring(response: 0.35, dampingFraction: 0.7)
    static let tabSelection = Animation.spring(response: 0.3, dampingFraction: 0.8)
    static let toggleNavigation = Animation.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0.1)
}
