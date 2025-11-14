//
//  APIViewModel.swift
//  EventTracker
//

import Foundation
import SwiftUI

// ViewModel for API usage without conflict with UI 
@MainActor
class APIViewModel: ObservableObject {
    
    // @Published makes observable objects that automatically announce when changes occur
    @Published var events: [EventData] = []
    @Published var errorMessage: String?
    @Published var isLoading = false

    private let api = APIService()

    func fetchEvents() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let list = try await api.fetchEvents()
            self.events = list
        } catch {
            self.errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }

    func createEvent(_ event: EventData, token: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let newEvent = try await api.createEvent(event, token: token)
            self.events.append(newEvent)
        } catch {
            self.errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}