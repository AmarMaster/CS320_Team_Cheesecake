//
//  Map.swift
//  EventTracker
//

import SwiftUI
import MapKit

struct MapView: View {
    @EnvironmentObject var ViewModel: APIViewModel
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 42.3757, longitude: -72.5199),
        span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
    )
    
    @State private var selectedEvent: EventData? = nil

    var body: some View {
        ZStack {
            EventsMap(region: $region, events: ViewModel.events, selectedEvent: $selectedEvent)
                .cornerRadius(16)
                .task {
                    await ViewModel.fetchEvents()
                }
                .ignoresSafeArea() 
        }
        .sheet(item: $selectedEvent) { event in
            EventPage(event: event)
                .presentationDetents([.medium, .large])  
        }
    }
}

// Can also test with a mock APIViewModel that returns mock data 
#Preview {
    MapView()
        .environmentObject(APIViewModel())
}