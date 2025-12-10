//
//  SecureAlert.swift
//  EventTracker
//

import SwiftUI
import UIKit

// Essentially makes an alert, but with SecureField (characters are masked by dots for security)
struct SecureAlert: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    var title: String
    var message: String?
    var placeholder: String = ""
    var onComplete: (String?) -> Void

    func makeUIViewController(context: Context) -> UIViewController {
        UIViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        guard context.coordinator.alert == nil, isPresented else { return }

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        alert.addTextField { textField in
            textField.placeholder = placeholder
            textField.isSecureTextEntry = true // Makes it secure
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            onComplete(nil)
            isPresented = false
            context.coordinator.alert = nil
        })

        alert.addAction(UIAlertAction(title: "Confirm", style: .default) { _ in
            let text = alert.textFields?.first?.text
            onComplete(text)
            isPresented = false
            context.coordinator.alert = nil
        })

        uiViewController.present(alert, animated: true, completion: nil)
        context.coordinator.alert = alert
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject {
        var parent: SecureAlert
        var alert: UIAlertController?

        init(_ parent: SecureAlert) {
            self.parent = parent
        }
    }
}