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
    
    @Published var selectedEventDetails: EventData? = nil

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
    
    func fetchFilteredEvents(
        userID: String? = nil,
        location: (lat: Double, lon: Double)? = nil,
        radius: Int? = nil,
        datetime: Date? = nil,
        twentyoneplus: Bool? = nil,
        cost: Double? = nil
    ) async {
        isLoading = true
        errorMessage = nil

        do {
            let filtered = try await api.fetchFilteredEvents(
                userID: userID,
                location: location,
                radius: radius,
                datetime: datetime,
                twentyoneplus: twentyoneplus,
                cost: cost
            )
            self.events = filtered
        } catch {
            self.errorMessage = error.localizedDescription
        }

        isLoading = false
    }
    
    func fetchEventDetails(_ eventID: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let eventDetails = try await api.fetchEventDetails(eventID: eventID)
            self.selectedEventDetails = eventDetails
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
    
    func updateEvent(_ event: EventData, token: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let updatedEvent = try await api.updateEvent(event, token: token)
            if let index = events.firstIndex(where: { $0.id == updatedEvent.id }) {
                events[index] = updatedEvent
            }
        } catch {
            self.errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func deleteEvent(eventID: String, token: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            _ = try await api.deleteEvent(eventID: eventID, token: token)
            events.removeAll { String($0.id ?? 0) == eventID }
        } catch {
            self.errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func toggleFavorite(eventID: String) async {
        do {
            let message = try await api.toggleFavorite(eventID: eventID)
            print("Toggle Favorite: \(message)")
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    func toggleRSVP(eventID: String) async {
        do {
            let message = try await api.toggleRSVP(eventID: eventID)
            print("Toggle RSVP: \(message)")
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    func toggleHosted(eventID: String) async {
        do {
            let message = try await api.toggleHosted(eventID: eventID)
            print("Toggle Hosted: \(message)")
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
}gi