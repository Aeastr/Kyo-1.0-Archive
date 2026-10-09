//
//  NavObservableObject.swift
//  KyoNeo
//
//  Created by Aether on 21/03/2023.
//

import SwiftUI
import Combine

class plannerEditObject: ObservableObject {
    @Published var selectedItemsArray: [UUID] = []
    @Published var scrollTo: UUID? = nil
}

