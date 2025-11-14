//
//  EventTrackerApp.swift
//  EventTracker
//

import SwiftUI
import SwiftData

@main
struct EventTrackerApp: App {
    @StateObject private var ViewModel = APIViewModel()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            CreateAccountView()
                .environmentObject(ViewModel)
        }
        .modelContainer(sharedModelContainer)
    }
}