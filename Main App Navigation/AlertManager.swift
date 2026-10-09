//
//  AlertManager.swift
//  KyoNeo
//
//  Created by Aether on 26/12/2023.
//

import SwiftUI


class AlertManager: ObservableObject {
    @Published var showAlert = false
    var alertTitle = ""
    var alertMessage = ""
    var alertContent: () -> AnyView

    // Initialize with a default alert content
    init(alertContent: @escaping () -> AnyView = { AnyView(EmptyView()) }) {
        self.alertContent = alertContent
    }

    func showAlert<V: View>(title: String, message: String, @ViewBuilder content: @escaping () -> V) {

        print("show Alert Called")
        alertTitle = title
        alertMessage = message
        // Wrap the content in AnyView
        self.alertContent = { AnyView(content()) }
        showAlert = true
    }

    func dismissAlert() {
        showAlert = false
    }
}

// Example usage
extension AlertManager {
    func showAlertWithCustomContent() {
        self.showAlert(title: "Custom Alert", message: "This is a custom alert.") {
            Text("Test") // No need to wrap in AnyView
        }
    }
}
