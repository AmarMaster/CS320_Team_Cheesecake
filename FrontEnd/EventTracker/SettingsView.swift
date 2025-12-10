//
//  SettingsView.swift
//  EventTracker
//

import SwiftUI

struct SettingsView: View {
    // These functions not implemented yet...UI works though 
    var onLogout: () -> Void
    var onChangePassword: (String) -> Void
    var onDeleteAccount: () -> Void

    @State private var showSecureAlert = false
    @State private var showDeleteConfirmation = false

    var body: some View {
        NavigationStack {
            List {
                Button("Logout") {
                    onLogout()
                }
                .foregroundColor(.blue)

                Button("Change Password") {
                    showSecureAlert = true
                }
                .foregroundColor(.blue)

                Button("Delete Account") {
                    showDeleteConfirmation = true
                }
                .foregroundColor(.red)
                .confirmationDialog(
                    "Are you sure you want to delete your account?",
                    isPresented: $showDeleteConfirmation,
                    titleVisibility: .visible
                ) {
                    Button("Delete", role: .destructive) {
                        onDeleteAccount()
                    }

                    Button("Cancel", role: .cancel) {}
                }
            }
            .navigationTitle("Settings")
        }
        .background(
            SecureAlert(isPresented: $showSecureAlert,
                        title: "Change Password",
                        message: "Please enter your new password",
                        placeholder: "New password") { input in
                if let newPassword = input, !newPassword.isEmpty {
                    onChangePassword(newPassword)
                } else {
                    // User cancelled or empty password - no action
                }
            }
        )
    }
}