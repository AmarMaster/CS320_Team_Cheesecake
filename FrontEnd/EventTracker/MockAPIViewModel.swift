//
//  MockAPIViewModel.swift
//  EventTracker
//

import Foundation
import CoreLocation
import SwiftUI

@MainActor
class MockAPIViewModel: ObservableObject {
    @Published var events: [EventData] = []
    @Published var isLoading = false
    
    init() {
        loadMockEvents()
    }
    
    private func loadMockEvents() {
        events = [
            EventData(
                id: 1,
                name: "UMass Basketball Game",
                description: "Minutemen vs URI Rams - exciting college basketball action!",
coordinate: CLLocationCoordinate2D(latitude: 42.3868, longitude: -72.5301),
                locationString: "Mullins Center, UMass Amherst",
                time: Calendar.current.date(byAdding: .day, value: 2, to: Date()) ?? Date(),
                durationHours: 3,
                durationMinutes: 0,
                details: "College basketball rivalry game",
                adultOnly: false,
                cost: 15,
                owner_id: "1"
            ),
            EventData(
                id: 2,
                name: "Downtown Amherst Food Festival",
                description: "Local restaurants showcase their best dishes with live music",
coordinate: CLLocationCoordinate2D(latitude: 42.3732, longitude: -72.5199),
                locationString: "Amherst Common, Downtown",
                time: Calendar.current.date(byAdding: .day, value: 5, to: Date()) ?? Date(),
                durationHours: 6,
                durationMinutes: 0,
                details: "Food trucks, live music, family fun",
                adultOnly: false,
                cost: 0,
                owner_id: "2"
            ),
            EventData(
                id: 3,
                name: "Tech Career Fair",
                description: "Meet recruiters from top tech companies and startups",
coordinate: CLLocationCoordinate2D(latitude: 42.3912, longitude: -72.5267),
                locationString: "Campus Center, UMass Amherst",
                time: Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date(),
                durationHours: 4,
                durationMinutes: 0,
                details: "Networking with tech companies",
                adultOnly: false,
                cost: 0,
                owner_id: "1"
            ),
            EventData(
                id: 4,
                name: "Northampton Brewery Tour",
                description: "Guided tour of local craft breweries with tastings",
coordinate: CLLocationCoordinate2D(latitude: 42.3251, longitude: -72.6412),
                locationString: "Northampton Brewery District",
                time: Calendar.current.date(byAdding: .day, value: 10, to: Date()) ?? Date(),
                durationHours: 4,
                durationMinutes: 0,
                details: "21+ craft beer tasting tour",
                adultOnly: true,
                cost: 35,
                owner_id: "3"
            ),
            EventData(
                id: 5,
                name: "Hampshire College Art Show",
                description: "Student art exhibition featuring paintings, sculptures, and digital art",
coordinate: CLLocationCoordinate2D(latitude: 42.3252, longitude: -72.5321),
                locationString: "Hampshire College Gallery",
                time: Calendar.current.date(byAdding: .day, value: 12, to: Date()) ?? Date(),
                durationHours: 2,
                durationMinutes: 0,
                details: "Student artwork exhibition",
                adultOnly: false,
                cost: 5,
                owner_id: "2"
            ),
            EventData(
                id: 6,
                name: "Amherst Farmers Market",
                description: "Fresh local produce, baked goods, and handmade crafts",
coordinate: CLLocationCoordinate2D(latitude: 42.3751, longitude: -72.5170),
                locationString: "Amherst Town Common",
                time: Calendar.current.date(byAdding: .day, value: 3, to: Date()) ?? Date(),
                durationHours: 4,
                durationMinutes: 0,
                details: "Weekly farmers market",
                adultOnly: false,
                cost: 0,
                owner_id: "1"
            )
        ]
    }
    
    // Mock API methods
    func fetchEvents() async {
        isLoading = true
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        isLoading = false
    }
    
    func createEvent(_ event: EventData) async -> Bool {
        isLoading = true
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        let newEvent = EventData(
            id: events.count + 1,
            name: event.name,
            description: event.description,
            coordinate: event.coordinate ?? CLLocationCoordinate2D(latitude: 42.391155, longitude: -72.526711),
            locationString: event.locationString,
            time: event.time,
            durationHours: event.durationHours,
            durationMinutes: event.durationMinutes,
            details: event.details,
            adultOnly: event.adultOnly,
            cost: event.cost,
            owner_id: event.owner_id,
            imageData: event.imageData
        )
        
        events.append(newEvent)
        isLoading = false
        return true
    }
    
    func updateEvent(_ event: EventData, at index: Int) async -> Bool {
        isLoading = true
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        if index < events.count {
            events[index] = event
        }
        
        isLoading = false
        return true
    }
    
    func deleteEvent(at index: Int) async -> Bool {
        isLoading = true
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        if index < events.count {
            events.remove(at: index)
        }
        
        isLoading = false
        return true
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
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        var filteredEvents = events
        
        if let twentyoneplus = twentyoneplus, twentyoneplus {
            filteredEvents = filteredEvents.filter { $0.adultOnly }
        }
        
        if let maxCost = cost {
            filteredEvents = filteredEvents.filter { $0.cost <= maxCost }
        }
        
        events = filteredEvents
        isLoading = false
    }
}
