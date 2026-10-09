//
//  VariableDataNames.swift
//  KyoNeo
//
//  Created by Aether on 07/11/2023.
//

import SwiftUI

struct VariableDataNames {
    @AppStorage("terminology") var terminology: terminologySettings = .regular

    func classesName() -> String {
        let key = terminology == .regular ? "manage-classes" : "manage-modules"
        return NSLocalizedString(key, comment: "")
    }

    func className() -> String {
        let key = terminology == .regular ? "class" : "module"
        return NSLocalizedString(key, comment: "")
    }

    func classesAndSplitsName() -> String{
        let key = terminology == .regular ? "Classes and Splits" : "Modules and Splits"
        return NSLocalizedString(key, comment: "")
    }

    func editClassName() -> String{
        let key = terminology == .regular ? "Edit Class" : "Edit Module"
        return NSLocalizedString(key, comment: "")
    }

    func newClassName() -> String{
        let key = terminology == .regular ? "New Class" : "New Module"
        return NSLocalizedString(key, comment: "")
    }
}


enum terminologySettings: Int, CaseIterable{
    case regular
    case university


    public var name: String {
        switch self{
        case .regular:
            return "Regular"
        case .university:
                return "University"

        }
    }

}



